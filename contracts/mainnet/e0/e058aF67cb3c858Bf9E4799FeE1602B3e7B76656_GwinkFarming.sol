//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";

abstract contract IERC20Farm is ReentrancyGuard, Ownable {
    
    struct FarmLock {
        uint256 amount;
        uint256 farmLockAt;
    }

    uint256 public totalValueLocked;
    uint256 public depositDeduction;
    uint256 public withdrawDeduction;

    address[] public farmLockers;
    mapping(address => uint256) public rewards;
    mapping(address => FarmLock[]) public farmlocks;

    address public farmLockToken;
    address public rewardToken;
    uint256 public rewardTokensPerDay;

    constructor(address _farmLockToken, address _rewardToken, uint256 _rewardTokensPerDay) {
        farmLockToken = _farmLockToken;
        rewardToken = _rewardToken;
        rewardTokensPerDay = _rewardTokensPerDay;
    }

    function deposit(uint256 _amount) public virtual;

    function canWithdrawAmount(address account)
        public
        view
        virtual
        returns (uint256);

    function withdraw(uint256 _amount) public virtual;

    function getRewards(address account) public view virtual returns (uint256);

    function claim() public virtual;
}

contract GwinkFarming is IERC20Farm {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 maxDepositDeduction = 300;
    uint256 maxWithdrawDeduction = 300;
    uint256 public lastRewardDistributed;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(
        address _farmLockToken,
        address _rewardToken,
        uint256 _rewardTokensPerDay
    ) IERC20Farm(_farmLockToken, _rewardToken, _rewardTokensPerDay) {
        depositDeduction = 0;
        withdrawDeduction = 0;
        rewardTokensPerDay = _rewardTokensPerDay;
    }

    function deposit(uint256 _amount) public override {
        require(_amount > 0, "Deposit amount cannot be zero");
        require(
            IERC20(farmLockToken).balanceOf(msg.sender) >= _amount,
            "Balance is not enough"
        );

        uint256 beforeBalance = IERC20(farmLockToken).balanceOf(address(this));
        IERC20(farmLockToken).transferFrom(msg.sender, address(this), _amount);
        uint256 afterBalance = IERC20(farmLockToken).balanceOf(address(this));
        uint256 amount = afterBalance - beforeBalance;

        uint256 deductionAmount = amount.mul(depositDeduction).div(1000);
        if (deductionAmount > 0) {
            IERC20(farmLockToken).transfer(farmLockToken, deductionAmount);
        }

        uint256 farmLockLength = farmlocks[msg.sender].length;

        if (farmLockLength == 0 && !addressExists(farmLockers, msg.sender)) {
            farmLockers.push(msg.sender);
        }
        
        farmlocks[msg.sender].push();

        FarmLock storage _farmLocks = farmlocks[msg.sender][farmLockLength];
        _farmLocks.amount = amount.sub(deductionAmount);
        _farmLocks.farmLockAt = block.timestamp;

        if(totalValueLocked == 0) {
            lastRewardDistributed = block.timestamp;
        }

        totalValueLocked = totalValueLocked.add(amount.sub(deductionAmount));
        updateRewards();
        emit Deposit(msg.sender, amount.sub(deductionAmount));
    }

    function addressExists(address[] memory array, address search) public pure returns (bool){
      
      for (uint256 i; i < array.length; i++){
          if (array[i] == search)
            return true;
      }

      return false;
  }

    function canWithdrawAmount(address account)
        public
        view
        override
        returns (uint256)
    {
        uint256 _canWithdraw = 0;
        for (uint256 i = 0; i < farmlocks[account].length; i++) {
            FarmLock storage _farmLocks = farmlocks[account][i];
            _canWithdraw = _canWithdraw.add(_farmLocks.amount);
            
        }
        return _canWithdraw;
    }

    function withdraw(uint256 _amount) public override {
        uint256 _canWithdraw;

        _canWithdraw = canWithdrawAmount(msg.sender);
        require(_canWithdraw >= _amount, "Withdraw Amount is not enough");
        uint256 deductionAmount = _amount.mul(withdrawDeduction).div(1000);
        uint256 tamount = _amount - deductionAmount;
        uint256 amount = _amount;
        uint256 _penalty = 0;
        bool isEmptied;
        updateRewards();
        for (uint256 i = farmlocks[msg.sender].length; i > 0; i--) {
            FarmLock storage _farmLocks = farmlocks[msg.sender][i - 1];

            if (amount >= _farmLocks.amount) {
                amount = amount.sub(_farmLocks.amount);
                _farmLocks.amount = 0;
                isEmptied = true;
            } else {
                _farmLocks.amount = _farmLocks.amount.sub(amount);
                amount = 0;
                isEmptied = false;
                break;
            }
            _farmLocks.farmLockAt = block.timestamp;
        }

        if (deductionAmount > 0) {
            IERC20(farmLockToken).transfer(farmLockToken, deductionAmount);
        }

        if (tamount > 0) {
            IERC20(farmLockToken).transfer(msg.sender, tamount - _penalty);
        }

        totalValueLocked = totalValueLocked.sub(_amount);
        
        if(isEmptied) {
            claim();
            delete farmlocks[msg.sender];
        } else {
            updateRewards();
        }
        emit Withdraw(msg.sender, _amount);
    }

    function claim() public override {
        require(farmlocks[msg.sender].length > 0, "No lp deposited");
        updateRewards();
        require(rewards[msg.sender] > 0, "No rewards to claim");
        require(
            IERC20(rewardToken).transfer(msg.sender, rewards[msg.sender]),
            "Transfer failed"
        );
        rewards[msg.sender] = 0;
    }

    function updateRewards() public {

        if(block.timestamp <= lastRewardDistributed) {
            return;
        }

        for (uint256 i = 0; i < farmLockers.length; i++) {
            address account = farmLockers[i];
            for (uint256 j = 0; j < farmlocks[account].length; j++) {
                FarmLock storage _farmLocks = farmlocks[account][j];
                if(_farmLocks.amount > 0) {
                    rewards[account] += calcRewards(_farmLocks.amount, _farmLocks.farmLockAt); 
                }
            }
        }
        
        lastRewardDistributed = block.timestamp;
    }

    function getRewards(address account)
        public
        view
        override
        returns (uint256)
    {
        
        uint256 _pendingRewards;
        
        for (uint256 j = 0; j < farmlocks[account].length; j++) {
            FarmLock storage _farmLocks = farmlocks[account][j];
            _pendingRewards += calcRewards(_farmLocks.amount, _farmLocks.farmLockAt); 
        }

        return rewards[account] + _pendingRewards;
    }

    function calcRewards(uint256 _amount, uint256 _farmLockAt)
        public
        view
        returns (uint256)
    {
        uint256 sub = lastRewardDistributed;
        
        if(_farmLockAt > lastRewardDistributed) {
            sub = _farmLockAt;
        }

        return _amount
                .mul(rewardTokensPerDay)
                .div(1 days)
                .mul(block.timestamp - sub)
                .div(totalValueLocked);
    }

    function setDepositDeduction(uint256 _deduction) external onlyOwner {
        require(_deduction <= maxDepositDeduction);
        depositDeduction = _deduction;
    }

    function setWithdrawDeduction(uint256 _deduction) external onlyOwner {
        require(_deduction <= maxWithdrawDeduction);
        withdrawDeduction = _deduction;
    }

    function setRewardTokensPerDay(uint256 _rewardTokensPerDay) external onlyOwner {
        updateRewards();
        rewardTokensPerDay = _rewardTokensPerDay;
    }

    function getAccountTotalLockedAmount(address _account) public view returns(uint256) {

        uint256 lockedAmount;

        for (uint256 i = 0; i < farmlocks[_account].length; i++) {
            FarmLock storage _farmLocks = farmlocks[_account][i];
            lockedAmount += _farmLocks.amount;
        }

        return lockedAmount;
    }

}