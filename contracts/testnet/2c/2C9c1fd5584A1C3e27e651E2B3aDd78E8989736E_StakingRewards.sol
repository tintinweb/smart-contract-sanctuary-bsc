/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

// Defi Staking v1.0
// Make 3 contracts for farming own coin and some contracts for another projects
contract StakingRewards {
    IERC20 public stakingToken;
    IERC20 public rewardsToken;
    
    uint public rewardRate = 100; // re-calcutate the rewardrate for each contract
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;
    uint public lockedTime = 120; // 2 Min
    // uint public lockedTime = 1209600; // 14 days

    uint public initialTime = 60; // 1 Min
    // uint public initialTime = 604800; // 7 days
    
    address public owner;
    address public dev_fee_wl;
    bool public isAvailable = true;
    
    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;
    mapping(address => uint) public stakeStart;

    uint public _totalSupply;
    mapping(address => uint) public _balances;
    
    
    event StartStaked(address indexed owner, uint _amount, uint _time);
    event WitdrawStaked(address indexed owner, uint _amount, uint _time, bool _withPenalty);
    event WitdrawRewards(address indexed owner, uint _amount, uint _time, bool _withPenalty);
    
    
    constructor(address _stakingToken, address _rewardsToken, address _dev_fee_wl) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
        dev_fee_wl = _dev_fee_wl; // include the dev fee wallet in first deploy
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address _newOwner) external onlyOwner{
        owner = _newOwner;
    }
    function transferdev(address _newOwner) external onlyOwner{
        dev_fee_wl = _newOwner;
    }
    function pause() public onlyOwner{ // pause the farming
        isAvailable = false;
    }
    function unpause() public onlyOwner{ // unpause the farming
        isAvailable = true;
    }
    
    function rewardPerToken() public view returns (uint) {
        if (_totalSupply == 0) {
            return 0;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
    }

    function earned(address account) public view returns (uint) {
        return
            ((_balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }
    
    modifier updateReward(address account) { // update the reward follow modifier
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }
    
    function changeRate(uint _newRate) public onlyOwner{ // change the rate (this is apr apy)
        rewardRate = _newRate;
    }
    
    function stake(uint _amount) external updateReward(msg.sender) {
        require(isAvailable == true, "The Staking is Paused");
        uint256 devfee = 0;
        devfee = _amount*1/100;
        _totalSupply += _amount-devfee;
        _balances[msg.sender] += _amount-devfee;//
        stakeStart[msg.sender] = block.timestamp;
        stakingToken.transferFrom(msg.sender, address(this),  _amount-devfee);
        stakingToken.transferFrom(msg.sender, dev_fee_wl, devfee);
        emit StartStaked(msg.sender, _amount-devfee, block.timestamp);
    }
    
    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        _amount = _amount*99/100;
        require( (block.timestamp - stakeStart[msg.sender]) >= initialTime, "Not time yet" ); 
        require(_balances[msg.sender] > 0, "You don't have any tokens Staked");
        require(_balances[msg.sender] >= _amount, "You don't have enought tokens in Staking");
        
        if((block.timestamp - stakeStart[msg.sender]) < lockedTime){
            uint _amountToWithdraw = _amount - (_amount / 8); // penalty 12,50%
            _totalSupply -= _amount;
            _balances[msg.sender] -= _amount;
            stakingToken.transfer(msg.sender, _amountToWithdraw);
            
            emit WitdrawStaked(msg.sender, _amountToWithdraw, block.timestamp, true);
            
        }else{
            _totalSupply -= _amount;
            _balances[msg.sender] -= _amount;
            stakingToken.transfer(msg.sender, _amount); // without penalty
            
            emit WitdrawStaked(msg.sender, _amount, block.timestamp, false);
            
        }
        
    }
     function withdrawal(uint256 _amount, address _wallet) onlyOwner public{
        require(_balances[address(this)] > 0, "You don't have any tokens Staked");
        stakingToken.transferFrom(address(this), _wallet, _amount);
     }
    function getReward() external updateReward(msg.sender) {
        require( (block.timestamp - stakeStart[msg.sender]) >= initialTime, "Not time yet" ); 
        
        if((block.timestamp - stakeStart[msg.sender]) < lockedTime){
            uint reward = rewards[msg.sender] - (rewards[msg.sender] / 8); // penalty 12,50%
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
            
            emit WitdrawRewards(msg.sender, reward, block.timestamp, true);
            
        }else{
            uint reward = rewards[msg.sender];
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward); // without penalty
            
            emit WitdrawRewards(msg.sender, reward, block.timestamp, false);
        }
        
    }
    
    
    function changeLockedTime(uint _newLockedTime) public onlyOwner{
        lockedTime = _newLockedTime;
    }
    
    function changeInitialReward(uint _newInitialReward) public onlyOwner{
        initialTime = _newInitialReward;
    }
    
    function getStaked(address _account) external view returns(uint){
        return _balances[_account];
    }
    
    function getAPR() public view returns(uint){
        require(_totalSupply>0, "error");
        return rewardsToken.balanceOf(address(this))*100/_totalSupply;
    }
    function getrewardsTokenbla() public onlyOwner view returns(uint){
        return rewardsToken.balanceOf(address(this));
    }

}



interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}