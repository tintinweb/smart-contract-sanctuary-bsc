/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;


contract Acium{

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    address public owner;

    string public name = "Acium Token";
    string public symbol = "ACIUM";
    uint8 public decimals = 3;
    bool public stake = true;
    

    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => mapping(uint => uint)) public rewards;
    mapping(address => mapping(uint => uint)) public timeLocked;
    mapping(address => mapping(uint => uint)) public lockedIn;
    mapping(uint256 => uint256) public feePerMonth;


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    // Event that log buy operation
    event Lock(address locker, uint period, uint amountOfTokens);
    event Claim(address claimer, uint amountOfTokens);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
        totalSupply = 20_000 * 10 ** decimals;
        balanceOf[owner] = totalSupply;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success){
        require(allowance[_from][msg.sender] >= _value);
        require(balanceOf[_from] >= _value);
        require(_from != address(0));
        require(_to != address(0));

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);        

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function changeRewardFee(uint256 _period, uint256 _value) public onlyOwner {
        feePerMonth[_period] = _value;
    }

    function changeStateStake() public onlyOwner {
        if(stake == true){
            stake = false;
        }
        else{
            stake = true;
        }
    }
    
    /*function mint(uint256 _value) public onlyOwner {
        require(_value + tokensMinted <= totalSupply, "Already minted all tokens allowed.");
        tokensMinted += _value;
        balanceOf[owner] += _value;
        emit Mint(owner, _value);
    }

    function burn(uint _value) public {
        require(balanceOf[msg.sender] >= _value, "Token insufficient balance.");
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        tokensBurned += _value;
        emit Burn(msg.sender, _value);
    }*/

    //period value in days
    function lock(uint _period, uint _value) public {
        require(stake == true, "Stake not allowed.");
        require(balanceOf[msg.sender] >= _value, "Token insufficient balance.");
        require(_value >= 10**decimals, "The minimum quantity to stake is 1 token.");
        require(feePerMonth[_period] > 0, "Stake not allowed.");
        balanceOf[msg.sender] -= _value;
        rewards[msg.sender][_period] += _value;
        timeLocked[msg.sender][_period] = block.timestamp + _period * 60 * 60;//_period * 24 * 60 * 60;
        lockedIn[msg.sender][_period] = block.timestamp;
        emit Lock(msg.sender, _period, _value);
    }

    function claim(uint _period, uint _value) public {
        require(timeLocked[msg.sender][_period] <= block.timestamp, "Lock time not yet terminated.");
        require(_value >= 10**decimals, "The minimum quantity to withdraw is 1 token.");
        require(rewards[msg.sender][_period] > 0, "You don't have tokens locked in this period.");
        require(feePerMonth[_period] > 0, "Claim not allowed because stake not allowed.");
        uint256 timeStaked = ((block.timestamp - lockedIn[msg.sender][_period])/60 * 60);//30 * 24 * 60 * 60;
        require(balanceOf[owner] >= ((_value/(10**decimals)) * ((feePerMonth[_period] * timeStaked * totalSupply)/(totalSupply/(10**decimals)))/10**decimals), "Sorry, the owner balance is insufficient.");
        balanceOf[owner] -= ((_value/(10**decimals)) * ((feePerMonth[_period] * timeStaked * totalSupply)/(totalSupply/(10**decimals)))/10**decimals);
        balanceOf[msg.sender] += _value + ((_value/(10**decimals)) * ((feePerMonth[_period] * timeStaked * totalSupply)/(totalSupply/(10**decimals)))/10**decimals);
        
        rewards[msg.sender][_period] -= _value;
        
        emit Claim(msg.sender, _value);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value);
        require(_to != address(0));
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

}