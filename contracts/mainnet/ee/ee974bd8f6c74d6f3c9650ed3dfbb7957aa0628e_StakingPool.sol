/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/Staking.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



contract StakingPool is Ownable {

    bool public paused = false;

    uint256 private token_decimal = 1 * 10 ** 18;
    uint256 private R_token_decimal = 1 * 10 ** 18;

    uint256 public _Daily_Reward;
    uint256 public _60Days_Reward;
    uint256 public _90Days_Reward;
    uint256 public _120Days_Reward;
    uint256 public _365Days_Reward;

    uint public perDaily;
    uint public perDailyReward;
    
    uint public per60days;
    uint public per60daysReward;

    uint public per90days;
    uint public per90daysReward;
    
    uint public per120days;
    uint public per120daysReward;

    uint public per365days;
    uint public per365daysReward;
    struct dataBase {
        address person;
        uint256 duration;
        uint256 stake_time;
        uint256 amount;
        uint256 id;  // 1 = daily , 2 = 60 days , 3 = 90 days
    }

    dataBase[] public _userdata;

    mapping(address=>uint256) public user_rtime;

    IERC20 private Stake_Token;
    IERC20 private Reward_Token;

    function Token_Modifier(IERC20 _Stake, IERC20 _Reward) public onlyOwner{
        Stake_Token = _Stake;
        Reward_Token = _Reward;
    }

    function set_Reward(uint _daily, uint _60days, uint _90days, uint _120days, uint _365days) public onlyOwner {
        _Daily_Reward = _daily * R_token_decimal;
        _60Days_Reward = _60days * R_token_decimal;
        _90Days_Reward = _90days * R_token_decimal;
        _120Days_Reward = _120days * R_token_decimal;
        _365Days_Reward = _365days * R_token_decimal;
    }

    function setDec(uint tokenA, uint tokenB) public onlyOwner {
        token_decimal = 1 * 10 ** tokenA;
        R_token_decimal = 1 * 10 ** tokenB;
    }

    function set_deduction(uint _onperDaily, uint _onperDailyReward, uint _onper60days, uint _onper60daysReward, uint _onper90days, uint _onper90daysReward, uint _onper120days, uint _onper120daysReward, uint _onper365days, uint _onper365daysReward ) public onlyOwner{
        perDaily = _onperDaily;
        perDailyReward = _onperDailyReward;
    
        per60days = _onper60days;
        per60daysReward = _onper60daysReward;

        per90days = _onper90days;
        per90daysReward = _onper90daysReward;

                per120days = _onper120days;
        per120daysReward = _onper120daysReward;

        per365days = _onper365days;
        per365daysReward = _onper365daysReward;

    }

    function Stake(uint _pid,uint256 _amount) public { //1=daily, 2=60days, 3=90days
        
        address _person = msg.sender;
        require(!paused,"Staking Pool is Paused!!");
        require(user_rtime[_person] == 0, "Already Invested!!");

        _amount = _amount * token_decimal;

        require(Stake_Token.allowance(msg.sender,address(this)) >= _amount,"Check your Allowance");
        Stake_Token.transferFrom(msg.sender,address(this),_amount);
        
        if(_pid == 1) {           
            uint256 time = block.timestamp + 1 days;   //make it to 1 days
            user_rtime[_person] = time;

            dataBase memory newdata = dataBase(_person,time,block.timestamp,_amount,_pid);  /// order must be same
           _userdata.push(newdata);   
        }

        if(_pid == 2) {
            uint256 time = block.timestamp + 60 days; //60 days;
            user_rtime[_person] = time;

            dataBase memory newdata = dataBase(_person,time,block.timestamp,_amount,_pid);  /// order must be same
           _userdata.push(newdata);   
        }

        if(_pid == 3) {
            uint256 time = block.timestamp +  90 days; //90 days;
            user_rtime[_person] = time;

            dataBase memory newdata = dataBase(_person,time,block.timestamp,_amount,_pid);  /// order must be same
           _userdata.push(newdata);   
        }
    }


    function get_Reward() public {

        require(!paused,"Staking Pool is Paused!!");

        for(uint i = 0 ; i < _userdata.length ; i++) {
            
            if(_userdata[i].person == msg.sender){

                if(_userdata[i].id == 1) {  //daily
                    require(block.timestamp >= _userdata[i].duration,"You can't get reward Now!");
                    
                    Reward_Token.transfer(msg.sender,_Daily_Reward);
                    Stake_Token.transfer(msg.sender,_userdata[i].amount);
                    
                    remove_data(i);
                    user_rtime[msg.sender] = 0;
                    break;
                }
                if(_userdata[i].id == 2) { //60 days
                    require(block.timestamp >= _userdata[i].duration,"You can't get reward Now!");
                    
                    Reward_Token.transfer(msg.sender,_60Days_Reward);
                    Stake_Token.transfer(msg.sender,_userdata[i].amount);
                    
                    remove_data(i);
                    user_rtime[msg.sender] = 0;
                    break;
                }
                if(_userdata[i].id == 3) { //90 days
                    require(block.timestamp >= _userdata[i].duration,"You can't get reward Now!");
                    
                    Reward_Token.transfer(msg.sender,_90Days_Reward);
                    Stake_Token.transfer(msg.sender,_userdata[i].amount);
                    
                    remove_data(i);
                    user_rtime[msg.sender] = 0;
                    break;
                }
            }
        }
    }

    function check_index() public view returns (uint index){
        for(uint i = 0 ; i < _userdata.length ; i++) {
            if(_userdata[i].person == msg.sender){
                return i;
            }
        }
    }

    function OpenReward() public {

         require(!paused,"Staking Pool is Paused!!");

        for(uint i = 0 ; i < _userdata.length ; i++) {
            
            if(_userdata[i].person == msg.sender){

                if(_userdata[i].id == 1) {  //daily
    
                    Stake_Token.transfer(msg.sender,getCal(_userdata[i].amount, perDaily));
                    Reward_Token.transfer(msg.sender, getCal(_Daily_Reward, perDailyReward));
                    
                    remove_data(i);
                    user_rtime[msg.sender] = 0;
                    break;
                }
                if(_userdata[i].id == 2) { //60 days
                    
                    Stake_Token.transfer(msg.sender,getCal(_userdata[i].amount,per60days));
                    Reward_Token.transfer(msg.sender, getCal(_60Days_Reward, per60daysReward));
                    
                    remove_data(i);
                    user_rtime[msg.sender] = 0;
                    break;
                }
                if(_userdata[i].id == 3) { //90 days
                    
                    Stake_Token.transfer(msg.sender,getCal(_userdata[i].amount,per90days));
                    Reward_Token.transfer(msg.sender, getCal(_90Days_Reward, per90daysReward));
                    
                    remove_data(i);
                    user_rtime[msg.sender] = 0;
                    break;
                }
            }
        }

    }

    function getCal(uint _amount, uint _per) internal pure returns (uint) {
        uint num;
        num = (_amount * _per ) / 100;
        uint total = _amount - num;
        return total;
    }

    function remove_data(uint _pid) private {
        _userdata[_pid].person = address(0);
        _userdata[_pid].duration = 0;
        _userdata[_pid].stake_time = 0;
        _userdata[_pid].amount = 0;
        _userdata[_pid].id = 0;
    }

    function Check_Allowance() public view returns (uint) {
        return Stake_Token.allowance(msg.sender,address(this));
    }

    function Pool_Balance(uint _pid) public view returns (uint) {
        if(_pid == 1) { return Stake_Token.balanceOf(address(this)); }
        if(_pid == 2) { return Reward_Token.balanceOf(address(this)); }
        else { revert("Wrong Option!!"); }
    }

    function Token_Balance(uint _pid) public view returns (uint) {
        if(_pid == 1) { return Stake_Token.balanceOf(msg.sender); }
        if(_pid == 2) { return Reward_Token.balanceOf(msg.sender); }
        else { revert("Wrong Option!!"); }
    }

    function EmergencyPause() public onlyOwner {
        Stake_Token.transfer(msg.sender,address(this).balance);
        Reward_Token.transfer(msg.sender,address(this).balance);
    }

    function Pause_Pool(bool _bool) public onlyOwner {
        paused = _bool;
    }

}