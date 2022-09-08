/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.16;

interface IBEP20 {
  function decimals() external view returns (uint8);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract StakingFixedAPY {
    Stakeholder[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) public totalStakedTokensForThisAddress;
    mapping(address => uint256) public totalStakedInPool1;
    mapping(address => uint256) public totalStakedInPool2;
    mapping(address => uint256) public totalStakedInPool3;

    address public constant TOKEN = 0x277819bF69667B48Af57aBC52DddCb92Ab6A2c45;
    address public constant CEO = 0x2323B9BfC3dA78913EE0aAfdFbA435BDb55186BD;
    
    mapping(uint256 => uint256) public apyRateForPool;
    mapping(uint256 => uint256) public lockDaysForPool;

    struct Stake {
        address user;
        uint256 amount;
        uint256 stakedDays;
        uint256 since;
        uint256 dueDate;
        uint256 baseRate;
        uint256 claimableReward;
        uint256 personalStakeIndex;
        uint256 pool;
    }
    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }
    struct StakingSummary {
        uint256 total_amount;
        Stake[] stakes;
    }
    
    modifier onlyOwner() {if(msg.sender != CEO) return; _;}

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 stakedDays,
        uint256 index,
        uint256 timestamp,
        uint256 dueDate,
        uint256 baseRate
    );


    constructor() {
        stakeholders.push();
        apyRateForPool[0] = 1;
        apyRateForPool[1] = 2;
        apyRateForPool[2] = 3;
    }

    function _addStakeholder(address staker) internal returns (uint256) {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex;
    }
    
    function _stake(uint256 _amount, uint256 _pool) internal {
        require(_amount > 0, "Cannot stake nothing");
        uint256 stakingRateTotal = apyRateForPool[_pool];
        uint256 dueDate = block.timestamp + lockDaysForPool[_pool] * 1 days;
        uint256 index = stakes[msg.sender];
        uint256 _personalStakeIndex;
        
        if (index == 0) {
            index = _addStakeholder(msg.sender);
            _personalStakeIndex = 0;
        } else _personalStakeIndex = stakeholders[stakes[msg.sender]].address_stakes.length;
        
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, lockDaysForPool[_pool], block.timestamp, dueDate, stakingRateTotal, 0, _personalStakeIndex, _pool));
        totalStakedTokensForThisAddress[msg.sender] += _amount;
        if(_pool == 0) totalStakedInPool1[msg.sender] += _amount;
        if(_pool == 1) totalStakedInPool2[msg.sender] += _amount;
        if(_pool == 2) totalStakedInPool3[msg.sender] += _amount;
        emit Staked(msg.sender, _amount, lockDaysForPool[_pool], index, block.timestamp, dueDate, stakingRateTotal);
    }

    function calculateStakeReward(Stake memory _current_stake) internal view returns (uint256) {
        return (((block.timestamp - _current_stake.since) * _current_stake.amount) * _current_stake.baseRate) / (365 days * 100);
    }

    function hasStake(address _staker) public view returns (StakingSummary memory){
        uint256 totalStakeAmount = 0;
        StakingSummary memory summary = StakingSummary(0,stakeholders[stakes[_staker]].address_stakes);
        
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateStakeReward(summary.stakes[s]);
            summary.stakes[s].claimableReward = availableReward;
            totalStakeAmount += summary.stakes[s].amount;
        }
        summary.total_amount = totalStakeAmount;
        return summary;
    }

    function howManyTokenHasThisAddressStaked(address account) external view returns (uint256) {
        return totalStakedTokensForThisAddress[account];
    }

    function setPools(uint256 _pool, uint256 _apy, uint256 _daysLocked) external onlyOwner {
        apyRateForPool[_pool] = _apy;
        lockDaysForPool[_pool] = _daysLocked;
    }
    
    function stake(uint256 _amount, uint256 _pool) public {
        require(IBEP20(TOKEN).balanceOf(msg.sender) >= _amount,"Cannot stake more than you own");
        _stake(_amount, _pool);
        IBEP20(TOKEN).transferFrom(msg.sender, address(this), _amount);
    }

    function unstake(uint256 amount, uint256 stake_index) public {
        uint256 stakingAmount;
        uint256 rewardForStaking;
        (stakingAmount, rewardForStaking) = _withdrawStake(msg.sender, amount, stake_index);
        uint256 totalWithdrawalAmount = stakingAmount + rewardForStaking;
        IBEP20(TOKEN).transfer(msg.sender, totalWithdrawalAmount);
    }

    function unstakeAll() external {
        uint256 user_index = stakes[msg.sender];
        uint256 totalWithdrawalAmount;
       
        for (uint i=0; i<stakeholders[user_index].address_stakes.length; i++) {
            Stake memory current_stake = stakeholders[user_index].address_stakes[i];
            uint256 stakeAmountOfCurrentStake = current_stake.amount;
            uint256 stakingAmount;
            uint256 rewardForStaking;
            (stakingAmount, rewardForStaking) = _withdrawStake(msg.sender,stakeAmountOfCurrentStake, i);
            totalWithdrawalAmount += stakingAmount + rewardForStaking;   
        }
        IBEP20(TOKEN).transfer(msg.sender, totalWithdrawalAmount);
    }

    function _withdrawStake(address staker, uint256 amount, uint256 index) internal returns (uint256, uint256){
        uint256 user_index = stakes[staker];
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];
        
        if(amount > 0){
            require(current_stake.dueDate < block.timestamp,"Stake can not be claimed yet");
            require(current_stake.amount >= amount,"Cannot withdraw more than you have staked");
            totalStakedTokensForThisAddress[staker] -= amount;
            if(current_stake.pool == 0) totalStakedInPool1[msg.sender] -= amount;
            if(current_stake.pool == 1) totalStakedInPool2[msg.sender] -= amount;
            if(current_stake.pool == 2) totalStakedInPool3[msg.sender] -= amount;
        }

        uint256 reward = calculateStakeReward(current_stake);
        current_stake.amount = current_stake.amount - amount;
        if (current_stake.amount == 0) {delete stakeholders[user_index].address_stakes[index];} 
        else {
            stakeholders[user_index].address_stakes[index].amount = current_stake.amount;
            stakeholders[user_index].address_stakes[index].since = block.timestamp;
        }
        return (amount, reward);
    }

    function rescueCRO() external onlyOwner{
        (bool tmpSuccess,) = payable(CEO).call{value: address(this).balance, gas: 40000}("");
        tmpSuccess = false;
    }

    function rescueCROWithTransfer() external onlyOwner{
        payable(CEO).transfer(address(this).balance);
    }
}