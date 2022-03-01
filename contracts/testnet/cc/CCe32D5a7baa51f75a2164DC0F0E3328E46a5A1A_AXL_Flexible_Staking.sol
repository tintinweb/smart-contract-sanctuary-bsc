// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./Ownable.sol";
import "./SafeERC20.sol";

contract AXL_Flexible_Staking is Ownable {
    using SafeERC20 for IERC20;

    struct UserData {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
    }

    struct UserStake {
        uint256 amount;
        uint64 stakeTime;
        uint64 lockedFor;
    }

    struct PoolData {
        IERC20 stakingToken;
        uint256 lastRewardBlock;  
        uint256 accRewardPerShare;
    }

    IERC20 public rewardToken;
    uint256 public rewardPerBlock = 1 * 1e18; // 1 token
    uint public totalStaked;
    uint256 public endBlock = 10000000000000 * 1e18 * 1e18;
    uint256 totalRewardTokens = 0;
    uint256 public stakeFeesPercent = 0;
    uint256 public unstakeFeesPercent = 0;
    uint256 public collectedFees = 0;
    uint256 public collectedPenalty = 0;
    uint256 public penaltyPercent = 0;
    uint64 public lockperiod = 3 minutes;

    

    PoolData public liquidityMining;
    mapping(address => UserData) public userData;
    mapping(address => UserStake[]) public userStakes;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    function updateRewardToken(IERC20 _newRewadToken) external onlyOwner {
        rewardToken = _newRewadToken;
    }

    function setPoolData(IERC20 _rewardToken, IERC20 _stakingToken) external onlyOwner {
        require(address(rewardToken) == address(0) && address(liquidityMining.stakingToken) == address(0), 'Token is already set');
        rewardToken = _rewardToken;
        liquidityMining = PoolData({stakingToken : _stakingToken, lastRewardBlock : 0, accRewardPerShare : 0});
    }

    function startMining(uint256 startBlock) external onlyOwner {
        require(liquidityMining.lastRewardBlock == 0, 'Mining already started');
        liquidityMining.lastRewardBlock = startBlock;
    }

    function endMining(uint256 _endBlock) external onlyOwner {
        require(liquidityMining.lastRewardBlock <= _endBlock, "End block can't be less than last reward block");
        endBlock = _endBlock;
    }

    function depositeRewardTokens(uint256 _amount) public onlyOwner {
        require(address(rewardToken) != address(0), "Reward tokens are not specified");
        rewardToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        totalRewardTokens += _amount;
    }
 
    function updatePool() internal { 
        // TODO Remove the require condition
        // require(endBlock > block.number, "Mining has been ended");       

        // TODO Change the latest block Number as the endBlock if the it is hit.
        require(liquidityMining.lastRewardBlock > 0 && block.number >= liquidityMining.lastRewardBlock, 'Mining not yet started');
        if (block.number <= liquidityMining.lastRewardBlock) {
            return;
        }
        uint256 newBlockNumber = block.number;
        if(endBlock < newBlockNumber){
            newBlockNumber = endBlock;
        }
        uint256 stakingTokenSupply = totalStaked;
        if (stakingTokenSupply == 0) {
            liquidityMining.lastRewardBlock = newBlockNumber;
            return;
        }
        uint256 multiplier = newBlockNumber - liquidityMining.lastRewardBlock;
        uint256 tokensReward = multiplier * rewardPerBlock;
        liquidityMining.accRewardPerShare = liquidityMining.accRewardPerShare + (tokensReward * 1e18 / stakingTokenSupply);
        liquidityMining.lastRewardBlock = newBlockNumber;
    }

    function deposit(uint256 amount) external {
        
        require(endBlock > block.number, 'Mining has ended');
        
        UserData storage user = userData[msg.sender];
        updatePool();

        uint256 accRewardPerShare = liquidityMining.accRewardPerShare;

        if (user.amount > 0) {
            uint256 pending = (user.amount * accRewardPerShare / 1e18) - user.rewardDebt;
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards + pending;
            }
        }
        if (amount > 0) {
            uint256 _initialAmount = amount;
            
            if(stakeFeesPercent > 0){
                uint256 _fees = (amount * stakeFeesPercent) / 100000000000000000000;
                amount -= _fees;
                collectedFees += _fees;
            }
            
            userStakes[msg.sender].push(UserStake(amount,uint64(block.timestamp),lockperiod));
            user.amount = user.amount + amount;
            liquidityMining.stakingToken.safeTransferFrom(address(msg.sender), address(this), _initialAmount);
        }
        totalStaked = totalStaked + amount;
        
        user.rewardDebt = user.amount * accRewardPerShare / 1e18;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        UserData storage user = userData[msg.sender];
        uint256 initialAmount = amount;
        require(user.amount >= amount, "Withdrawing amount is more than staked amount");
        uint256 tempAmount = amount;
        uint256[500] memory unstakeFrom;
        uint256 j = 0;
        uint256[500] memory unstakeFromPenalty;
        uint256 jp = 0;
        for(uint256 i=0;i<userStakes[msg.sender].length;i++){
            if (tempAmount <= 0) {
                break;
            }
            if(endBlock < block.number){
                if(userStakes[msg.sender][i].amount <= tempAmount){
                    tempAmount -= userStakes[msg.sender][i].amount;
                    unstakeFrom[j] = i;
                    j++;
                    unstakeFrom[j] = userStakes[msg.sender][i].amount;
                    j++;
                }else{
                    unstakeFrom[j] = i;
                    j++;
                    unstakeFrom[j] = tempAmount;
                    j++;
                    tempAmount = 0;
                }
            }
            else if(userStakes[msg.sender][i].stakeTime + userStakes[msg.sender][i].lockedFor <= block.timestamp){ // unstake without penalty
                if(userStakes[msg.sender][i].amount <= tempAmount){
                    tempAmount -= userStakes[msg.sender][i].amount;
                    unstakeFrom[j] = i;
                    j++;
                    unstakeFrom[j] = userStakes[msg.sender][i].amount;
                    j++;
                }else{
                    unstakeFrom[j] = i;
                    j++;
                    unstakeFrom[j] = tempAmount;
                    j++;
                    tempAmount = 0;
                }    
            }else if(penaltyPercent > 0){ // unstake with penalty
                if (userStakes[msg.sender][i].amount <= tempAmount) {
                    tempAmount -= userStakes[msg.sender][i].amount;
                    unstakeFromPenalty[jp] = i;
                    jp++;
                    unstakeFromPenalty[jp] = userStakes[msg.sender][i].amount;
                    jp++;
                } else {
                    unstakeFromPenalty[jp] = i;
                    jp++;
                    unstakeFromPenalty[jp] = tempAmount;
                    jp++;
                    tempAmount = 0;
                }
            }
        }
        
        require(tempAmount == 0, "Not Enough token staked");

        updatePool();

        uint256 accRewardPerShare = liquidityMining.accRewardPerShare;

        uint256 pending = (user.amount * accRewardPerShare / 1e18) - user.rewardDebt;
        if (pending > 0) {
            user.pendingRewards = user.pendingRewards + pending;
        }
        if (amount > 0) {
            uint256 tempPenalty = 0;
            uint256[500] memory toRemoveInedxes;
            uint256 tempj = 0;
            for (uint256 i = 0; i < j; i++) {
                uint256 ind = unstakeFrom[i];
                i++;
                userStakes[msg.sender][ind].amount -= unstakeFrom[i];
                if (userStakes[msg.sender][ind].amount == 0) {
                    toRemoveInedxes[tempj] = ind;
                    tempj++;
                }
            }
            
            for (uint256 i = 0; i < jp; i++) {
                uint256 ind = unstakeFromPenalty[i];
                i++;
                userStakes[msg.sender][ind].amount -= unstakeFromPenalty[i];
                if(endBlock >= block.number){
                    uint256 penalty = (unstakeFromPenalty[i] * penaltyPercent) / 100000000000000000000;
                    collectedPenalty = collectedPenalty + penalty;
                    tempPenalty += penalty;
                }
                
                if (userStakes[msg.sender][ind].amount == 0) {
                    toRemoveInedxes[tempj] = ind;
                    tempj++;
                }
            }
            for(uint256 i=0;i<tempj;i++){
                delete userStakes[msg.sender][toRemoveInedxes[i]];
            }
            amount -= tempPenalty;
            if(endBlock >= block.number){
                if (unstakeFeesPercent > 0) {
                    uint256 fee = (amount * unstakeFeesPercent) / 100000000000000000000;
                    amount = amount - fee;
                    collectedFees = collectedFees + fee;
                }
            }
            
            user.amount = user.amount - initialAmount;
            liquidityMining.stakingToken.safeTransfer(address(msg.sender), amount);
        }
        totalStaked = totalStaked - initialAmount;
        user.rewardDebt = user.amount * accRewardPerShare / 1e18;
        emit Withdraw(msg.sender, initialAmount);
    }

    function claim() external {
        UserData storage user = userData[msg.sender];
        updatePool();

        uint256 accRewardPerShare = liquidityMining.accRewardPerShare;

        uint256 pending = (user.amount * accRewardPerShare / 1e18) - user.rewardDebt;
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards + pending;
            uint256 tempBalance = rewardToken.balanceOf(address(this));
            if(liquidityMining.stakingToken == rewardToken){
                tempBalance -= totalStaked;
            }
            // TODO Chnage the require condition to ---> user.pendingRewards <= tempBalance
            require(user.pendingRewards <= tempBalance, 'Insufficient reward tokens for this transfer');
            uint256 claimedAmount = safeRewardTransfer(msg.sender, user.pendingRewards);
            emit Claim(msg.sender, claimedAmount);
            user.pendingRewards = user.pendingRewards - claimedAmount;
        }
        user.rewardDebt = user.amount * accRewardPerShare / 1e18;
    }

    function safeRewardTransfer(address to, uint256 amount) internal returns (uint256) {
        uint256 balance = rewardToken.balanceOf(address(this));
        if(liquidityMining.stakingToken == rewardToken){
                balance -= totalStaked;
        }
        require(amount > 0, 'Reward amount must be more than zero');
        require(balance > 0, 'Insufficient reward tokens for this transfer');
        // TODO: Remove the if condition and generate the error.
        if (amount > balance) {
            rewardToken.transfer(to, balance);
            totalRewardTokens -= balance;
            return balance;
        }
        rewardToken.transfer(to, amount);
        totalRewardTokens -= amount;
        return amount;
    }

    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        require(_rewardPerBlock > 0, "Reward per block must be more than zero");
        rewardPerBlock = _rewardPerBlock;
    }

    function getUnstake(address _user) public view returns(uint256){
        UserData storage user = userData[_user];
        uint256 amount = user.amount;
        if(endBlock < block.number){
            return amount;
        }else{
            for(uint256 i=0;i<userStakes[_user].length;i++){
                if(userStakes[_user][i].stakeTime + userStakes[_user][i].lockedFor <= block.timestamp){
                    amount += userStakes[_user][i].amount;
                }else if(penaltyPercent > 0){
                    amount += userStakes[_user][i].amount;
                }
            }
        }

        return amount;
    }

    function getUnlocked(address _user) public view returns(uint256) {
        uint256 _amount = 0;
        for(uint256 i=0;i<userStakes[_user].length;i++){
            if(userStakes[_user][i].stakeTime + userStakes[_user][i].lockedFor <= block.timestamp){
                _amount += userStakes[_user][i].amount;
            }
        }
        return _amount;
    }

    
    function pendingRewards(address _user) external view returns (uint256) {
        // TODO Remove the require condition
        // if (endBlock != 0) {
        //     require(endBlock > block.number, 'Mining has ended');
        // }
        if (liquidityMining.lastRewardBlock == 0 || block.number < liquidityMining.lastRewardBlock) {
            return 0;
        }

        UserData storage user = userData[_user];
        uint256 accRewardPerShare = liquidityMining.accRewardPerShare;
        uint256 stakingTokenSupply = totalStaked;
        uint256 newBlockNumber = block.number;
        if(endBlock < newBlockNumber){
            newBlockNumber = endBlock;
        }

        if (newBlockNumber > liquidityMining.lastRewardBlock && stakingTokenSupply != 0) {
            uint256 perBlock = rewardPerBlock;
            uint256 multiplier = newBlockNumber - liquidityMining.lastRewardBlock;
            uint256 reward = multiplier * perBlock;
            accRewardPerShare = accRewardPerShare + (reward * 1e18 / stakingTokenSupply);
        }

        return (user.amount * accRewardPerShare / 1e18) - user.rewardDebt + user.pendingRewards;
    }

    function extraTokensWithdraw() external onlyOwner {
        require(block.number > endBlock, 'Mining in progress');
        uint256 rewardSupply = rewardToken.balanceOf(address(this));
        if(rewardToken == liquidityMining.stakingToken)
        {
            rewardSupply = rewardSupply - totalStaked;
        } 
        safeRewardTransfer(msg.sender,rewardSupply);
        rewardSupply = 0;
    }
    function updatePenaltyPercent(uint256 _penaltyPercent) external onlyOwner {
        penaltyPercent = _penaltyPercent;
    }

    function setStakeFee(uint256 fee) external onlyOwner {
        stakeFeesPercent = fee;
    }

    function setUnstakeFee(uint256 fee) external onlyOwner {
        unstakeFeesPercent = fee;
    }

// Function which are getting executed after the end block
// TODO Check if the late Withdraew function is even needed

    // function lateWithdraw(uint256 amount) external {
    //     require(endBlock != 0, 'Mining should be stopped');
    //     require(endBlock < block.number, 'Mining should be stopped');
    //     UserData storage user = userData[msg.sender];
    //     require(user.amount >= amount, "Withdrawing amount is more than staked amount");
    //     if (amount > 0) {
    //         user.amount = user.amount - amount;
    //         liquidityMining.stakingToken.safeTransfer(address(msg.sender), amount);
    //     }
    //     totalStaked = totalStaked - amount;
    //     emit Withdraw(msg.sender, amount);
    // }

}