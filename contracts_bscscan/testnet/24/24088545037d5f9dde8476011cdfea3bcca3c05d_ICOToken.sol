/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

pragma solidity ^0.5.3;

interface IBEP20 {
    function totalSupply()external view returns(uint256);
    function balanceOf(address _owner)external view returns(uint256) ;
    function transfer(address _to, uint256 _value) external returns(bool success);

    function approve(address _spender, uint256 _value)external returns(bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool success);
    function allowace(address _owner, address _spender)external view returns(uint256);
  
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _from, address indexed _to, uint256 _value);

}

contract MyNewToken is IBEP20 {
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowed;

    string public name = "My New Token1";
    string public symbol = "MNT1";
    uint public decimals = 0;

    uint private _totalSupply;

    address public _creator;

    constructor() public {
        _creator = msg.sender;
        _totalSupply = 50000;
        _balances[_creator] = _totalSupply;
    }

    function totalSupply()external view returns(uint256) {
        return _totalSupply;
    }    

    function balanceOf(address _owner)external view returns(uint256) {
        return _balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns(bool success){
        require(_value > 0 && _balances[msg.sender] >= _value);
        _balances[_to] += _value;
        _balances[msg.sender] -= _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)external returns(bool success){
        require(_value > 0 && _balances[msg.sender] >= _value);
        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)public returns(bool success){
        require(_value > 0 && _balances[_from] >= _value && _allowed[_from][_to] >= _value);
        _balances[_to] += _value;
        _balances[_from] -= _value;
        _allowed[_from][_to] -= _value;
        return true;
    }

    function allowace(address _owner, address _spender)external view returns(uint256){
        return _allowed[_owner][_spender];
    }
}

contract ICOToken is MyNewToken {

    //need define the admin of ICO who will launch and who will stop ICO
    address public administrator;

    //account for deposite funds 
    address payable public receipient;

    //set initial price of the token 0.001 ETH = 1000000000000000
    uint public tokenPrice = 1000000000000000; //price of token in Wei

    //hard cap 500 Eth = 500000000000000000000
    uint public icoTarget = 500000000000000000000;

    //funds amount collected right now
    uint public recievedFund;

    //Max and Min amount to participate (in Eth)
    //Max 10 ETh = 10000000000000000000 (wei) Min 0.001 Eth = 1000000000000000
    uint public maxInvestment = 10000000000000000000;
    uint public minInvestment = 1000000000000000;

    enum Status {inactive, active, stopped, completed}
    Status public icoStatus;

    //ICO start time
    uint public icoStartTime = now;

    //ICO end time
    uint public icoEndTime = now + 432000; //5 days in seconds

    //trading start time we can set + 5 days after ico ends
    //uint public startTrading = icoEndTime + 432000;
    //but for now can just set it to ico end time
    uint public startTrading = icoEndTime;

    bool public transferOn;

    //setup ownerOnly modifier
    modifier ownerOnly {
        if(msg.sender == administrator){
            _;
        }
    }

    //save admn and receipient addresses
    constructor () public {
        administrator = msg.sender;
        receipient = 0x4b698D1231D35f6bE3E35B3EDa858906d3fbcd03;
    }

    //functions to sen ico statuses
    //function to stop ICO by admin only
    function setStopStatus() public ownerOnly {
        icoStatus = Status.stopped;
    }

    //resume ICO to active status by admin only
    function setActiveStatus()public ownerOnly {
        icoStatus = Status.active;
    }

    //lets create the function to get ICO status
    function getIcoStatus()public view returns(Status) {
        if (icoStatus == Status.stopped) {
            return Status.stopped;
        } else if(block.timestamp >= icoStartTime && block.timestamp <= icoEndTime) {
            return Status.active;
        } else if(block.timestamp <= icoStartTime){
            return Status.inactive;
        } else {
            return Status.completed;
        }
    }

    //function to receive the funds and release the tokens
    function Investing() payable public returns(bool){
        //So, only if ICO status is active, then will execute this function code lines
        icoStatus = getIcoStatus();//checking current ICO status and give it to icoStatus
        
        //checking is ICO status active or not
        require(icoStatus == Status.active, "ICO is not active");
        
        //we will check hardcap max and min of investment
       
        //check hard cap
        require(icoTarget >= recievedFund + msg.value, "Target Achieved. Investment not accepted");

        //check Max and Min investment
        require(msg.value >= minInvestment && msg.value <= maxInvestment, "Investment not in allowed range");        //when we call this function we need to know how many tokens we need to give
        //simple math to counted
        uint tokens = msg.value / tokenPrice;

        //to give this tokens to investor we need increase it
        _balances[msg.sender] += tokens; //increase bcs he san have some tokens before
        _balances[_creator] -= tokens; //and decrease from owner

        //now we need send recieved money to receipient address
        receipient.transfer(msg.value);

        //to keep update our total amount of callected tokens we need add tokens amount to
        //received funds
        recievedFund += msg.value;

        return true;
    }

    //burn unsold tokens
    function burn()public ownerOnly returns(bool) {
        icoStatus = getIcoStatus();
        //check if ICO status is completed
        require(icoStatus == Status.completed, "ICO not completed");

        //to burn the tokens we need just set value to zere of wallet where we want to burn
        _balances[_creator] = 0;
        return true;
    }

    //so, here we will restrict trading token while ico is in progress
    function transfer(address _to, uint256 _value) public returns(bool success) {
        //check start trading time is already or not
        require(block.timestamp > startTrading, "Trading is not allowed currently");
        require(transferOn, "Transactions is off by admin");
        //and here we dont need to write code lines for transfer function, we just used super
        //its will go and run lines of code transfer function
        super.transfer(_to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)public returns(bool success){
        require(block.timestamp > startTrading, "Trading is not allowed currently");
        require(transferOn, "Transactions is off by admin");
        super.transferFrom(_from, _to, _value);
        return true;
    }

    function transferIsOn() public ownerOnly returns (bool){
        transferOn = true;
        return transferOn;
    }

    function transferIsOff() public ownerOnly returns (bool){
        transferOn = false;
        return transferOn;
    }
}