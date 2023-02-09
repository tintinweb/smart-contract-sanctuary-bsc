//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";

abstract contract IERC20Staking is ReentrancyGuard, Ownable {

    struct Plan {
        uint256 overallStaked;
        uint256 overallRewarded;
        uint256 stakesCount;
        uint256 apr;
        uint256 stakeDuration;
        uint256 depositDeduction;
        uint256 withdrawDeduction;
        uint256 earlyPenalty;
        bool initialPool;
        bool conclude;
    }
    
    struct Staking {
        uint256 initialAmount;
        uint256 amount;
        uint256 stakeAt;
        uint256 endstakeAt;
        Unstaking[] unstakes;
    }

    struct Unstaking {
        uint256 amount;
        uint256 unstakeAt;
    }

    mapping(uint256 => mapping(address => Staking[])) public stakes;

    mapping(address => uint256) public totalStaked;
    mapping(address => uint256) public totalEarned;

    address public stakingToken;
    address public rewardToken;
    mapping(uint256 => Plan) public plans;

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
    }

    function stake(uint256 _stakingId, uint256 _amount) public virtual;
    function canWithdrawAmount(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function unstake(uint256 _stakingId, uint256 _amount) public virtual;
    function earnedToken(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function claimEarned(uint256 _stakingId) public virtual;
}

contract TokenStaking is IERC20Staking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public periodicTime = 365 days;
    uint256 public planLimit = 4;
    uint256 minAPR = 10;
    uint256 maxDepositDeduction = 300;
    uint256 maxWithdrawDeduction = 300;
    uint256 maxEarlyPenalty = 30;

    mapping(uint256 => address[]) public stakers;

    constructor(address _stakingToken, address _rewardToken) IERC20Staking(_stakingToken, _rewardToken) {
        plans[0].apr = 15;
        plans[0].stakeDuration = 30 days;
        plans[0].depositDeduction = 1;
        plans[0].withdrawDeduction = 1;
        plans[0].earlyPenalty = 5;

        plans[1].apr = 30;
        plans[1].stakeDuration = 90 days;
        plans[1].depositDeduction = 1;
        plans[1].withdrawDeduction = 1;
        plans[1].earlyPenalty = 15;

        plans[2].apr = 60;
        plans[2].stakeDuration = 180 days;
        plans[2].depositDeduction = 1;
        plans[2].withdrawDeduction = 1;
        plans[2].earlyPenalty = 30;

        plans[3].apr = 120;
        plans[3].stakeDuration = 365 days;
        plans[3].depositDeduction = 1;
        plans[3].withdrawDeduction = 1;
        plans[3].earlyPenalty = 50;
    }

    function stake(uint256 _stakingId, uint256 _amount) public nonReentrant override {
        require(_amount > 0, "Staking Amount cannot be zero");
        require(
            IERC20(stakingToken).balanceOf(msg.sender) >= _amount,
            "Balance is not enough"
        );
        require(_stakingId < planLimit, "Staking is unavailable");
        
        Plan storage plan = plans[_stakingId];
        require(!plan.conclude, "Staking in this pool is concluded");

        uint256 beforeBalance = IERC20(stakingToken).balanceOf(address(this));
        IERC20(stakingToken).transferFrom(msg.sender, address(this), _amount);
        uint256 afterBalance = IERC20(stakingToken).balanceOf(address(this));
        uint256 amount = afterBalance - beforeBalance;
        
        uint256 deductionAmount = amount.mul(plan.depositDeduction).div(1000);
        if(deductionAmount > 0) {
            IERC20(stakingToken).transfer(stakingToken, deductionAmount);
        }
        
        uint256 stakelength = stakes[_stakingId][msg.sender].length;
        
        if(stakelength == 0 && !addressExists(stakers[_stakingId], msg.sender)) {
            stakers[_stakingId].push(msg.sender);
            plan.stakesCount += 1;
        }

        stakes[_stakingId][msg.sender].push();
        
        Staking storage _staking = stakes[_stakingId][msg.sender][stakelength];
        _staking.initialAmount = amount.sub(deductionAmount);
        _staking.amount = _staking.initialAmount;
        _staking.stakeAt = block.timestamp;
        _staking.endstakeAt = block.timestamp + plan.stakeDuration;
        
        plan.overallStaked = plan.overallStaked.add(
            _staking.initialAmount
        );

        totalStaked[msg.sender] += _staking.initialAmount;
    }

    function addressExists(address[] memory array, address search) public pure returns (bool){
      
      for (uint256 i; i < array.length; i++){
          if (array[i] == search)
            return true;
      }

      return false;
    }

    function canWithdrawAmount(uint256 _stakingId, address account) public override view returns (uint256, uint256) {
        uint256 _stakedAmount = 0;
        uint256 _canWithdraw = 0;
        for (uint256 i = 0; i < stakes[_stakingId][account].length; i++) {
            Staking storage _staking = stakes[_stakingId][account][i];
            _stakedAmount = _stakedAmount.add(_staking.amount);
            _canWithdraw = _canWithdraw.add(_staking.amount);
        }
        return (_stakedAmount, _canWithdraw);
    }

    function earnedToken(uint256 _stakingId, address account) public override view returns (uint256, uint256) {
        uint256 _canClaim = 0;
        uint256 _earned = 0;
        Plan storage plan = plans[_stakingId];
        for (uint256 i = 0; i < stakes[_stakingId][account].length; i++) {
            Staking storage _staking = stakes[_stakingId][account][i];
            if (block.timestamp >= _staking.endstakeAt)
                _canClaim = _canClaim.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(periodicTime)
                        .mul(plan.apr)
                        .div(100)
                );
                _earned = _earned.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(periodicTime)
                        .mul(plan.apr)
                        .div(100)
                );
        }
        return (_earned, _canClaim);
    }

    function unstake(uint256 _stakingId, uint256 _amount) public nonReentrant override {
        uint256 _stakedAmount;
        uint256 _canWithdraw;
        Plan storage plan = plans[_stakingId];

        (_stakedAmount, _canWithdraw) = canWithdrawAmount(
            _stakingId,
            msg.sender
        );
        require(
            _canWithdraw >= _amount,
            "Withdraw Amount is not enough"
        );
        uint256 deductionAmount = _amount.mul(plans[_stakingId].withdrawDeduction).div(1000);
        uint256 tamount = _amount - deductionAmount;
        uint256 amount = _amount;
        uint256 _earned = 0;
        uint256 _penalty = 0;
        for (uint256 i = stakes[_stakingId][msg.sender].length; i > 0; i--) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i-1];
            
            if (amount >= _staking.amount) {
                
                if (block.timestamp >= _staking.endstakeAt) {
                    _earned = _earned.add(
                        _staking.amount
                            .mul(block.timestamp - _staking.stakeAt)
                            .div(periodicTime)
                            .mul(plan.apr)
                            .div(100)
                    );
                } else {
                    _penalty = _penalty.add(
                        _staking.amount
                        .mul(plan.earlyPenalty)
                        .div(100)
                    );
                }

                amount = amount.sub(_staking.amount);
                uint256 stakelength = _staking.unstakes.length;
                _staking.unstakes.push();
                Unstaking storage _unstake = _staking.unstakes[stakelength];
                _unstake.amount = _staking.amount;
                _unstake.unstakeAt = block.timestamp;

                _staking.amount = 0;
            } else {
                
                if (block.timestamp >= _staking.endstakeAt) {
                    _earned = _earned.add(
                        amount
                            .mul(block.timestamp - _staking.stakeAt)
                            .div(periodicTime)
                            .mul(plan.apr)
                            .div(100)
                    );
                } else {
                    _penalty = _penalty.add(
                        amount
                        .mul(plan.earlyPenalty)
                        .div(100)
                    );
                }

                _staking.amount = _staking.amount.sub(amount);
                
                uint256 stakelength = _staking.unstakes.length;
                _staking.unstakes.push();
                Unstaking storage _unstake = _staking.unstakes[stakelength];
                _unstake.amount = amount;
                _unstake.unstakeAt = block.timestamp;
                amount = 0;
                break;
            }
            _staking.stakeAt = block.timestamp;
        }

        if(deductionAmount > 0) {
            IERC20(stakingToken).transfer(stakingToken, deductionAmount);
        }
        
        if(tamount > 0) {
            IERC20(stakingToken).transfer(msg.sender, tamount - _penalty);
        }

        if(_earned > 0) {
            IERC20(rewardToken).transfer(msg.sender, _earned);
            plan.overallRewarded += _earned;
            totalEarned[msg.sender] += _earned;
        }

        plans[_stakingId].overallStaked = plans[_stakingId].overallStaked.sub(_amount);
    }

    function claimEarned(uint256 _stakingId) public nonReentrant override {
        uint256 _earned = 0;
        Plan storage plan = plans[_stakingId];
        for (uint256 i = 0; i < stakes[_stakingId][msg.sender].length; i++) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i];
            if (block.timestamp >= _staking.endstakeAt) {
                _earned = _earned.add(
                    _staking
                        .amount
                        .mul(plan.apr)
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(periodicTime)
                        .div(100)
                );
                _staking.stakeAt = block.timestamp;
            }
        }
        require(_earned > 0, "There is no amount to claim");
        IERC20(rewardToken).transfer(msg.sender, _earned);
        plan.overallRewarded += _earned;
        totalEarned[msg.sender] += _earned;
    }

    function getTotalOverallStaked() public view returns (uint256) {
        uint256 _totalStaked = 0;
        
        for (uint256 i = 0; i < planLimit; i++) {
            _totalStaked += plans[i].overallStaked;
        }

        return _totalStaked;
    }

    function getTotalRewardDistributed() public view returns (uint256) {
        uint256 _totalRewardDistributed = 0;
        
        for (uint256 i = 0; i < planLimit; i++) {
            _totalRewardDistributed += plans[i].overallRewarded; 
        }

        return _totalRewardDistributed;
    }

    function getTotalPendingRewards() public view returns(uint256) {
        uint256 _totalPendingRewards = 0;
        uint256 _earned = 0;
        uint256 _canClaim = 0;

        for (uint256 i = 0; i < planLimit; i++) {
            for(uint256 j=0; j < stakers[i].length; j++) {
                (_earned, _canClaim) = earnedToken(i, stakers[i][j]);
                _totalPendingRewards += _earned;
            
            }
        }

        return _totalPendingRewards;
    }

    function getCurrentStaked(address _account) public view returns(uint256) {
        uint256 _currentStaked = 0;

        for (uint256 i = 0; i < planLimit; i++) {
            Staking[] memory _currentStakes = stakes[i][_account];
            for(uint256 j=0; j< _currentStakes.length; j++) {
                _currentStaked += _currentStakes[j].amount;
            }
        } 

        return _currentStaked;
    }

    function getRewardPending(address _account) public view returns(uint256) {
        uint256 _rewardPending = 0;
        uint256 _earned = 0;
        uint256 _canClaim = 0;

        for (uint256 i = 0; i < planLimit; i++) {
            (_earned, _canClaim) = earnedToken(i, _account);
            _rewardPending += _earned;
        } 

        return _rewardPending;
    }

    function getStakeCount(address _account) public view returns(uint256) {
        uint256 stakeCount;

        for (uint256 i = 0; i < planLimit; i++) {
            Staking[] memory _currentStakes = stakes[i][_account];
            stakeCount += _currentStakes.length;
        }

        return stakeCount;
    }

    function getStakingHistory(address _account) public view returns(Staking[] memory) {
        Staking[] memory history = new Staking[](getStakeCount(_account));

        uint256 k=0;
        for (uint256 i = 0; i < planLimit; i++) {
            Staking[] memory _currentStakes = stakes[i][_account];
            for(uint256 j=0; j< _currentStakes.length; j++) {
                history[k++] = _currentStakes[j];
            }
        } 
        
        return history;
    } 

    function setRewardToken(address _rewardToken) external onlyOwner {
        rewardToken = _rewardToken;
    }

    function setAPR(uint256 _stakingId, uint256 _percent) external onlyOwner {
        require(_percent >= minAPR);
        plans[_stakingId].apr = _percent;
    }

    function setDepositDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        require(_deduction <= maxDepositDeduction);
        plans[_stakingId].depositDeduction = _deduction;
    }

    function setWithdrawDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        require(_deduction <= maxWithdrawDeduction);
        plans[_stakingId].withdrawDeduction = _deduction;
    }

    function setEarlyPenalty(uint256 _stakingId, uint256 _penalty) external onlyOwner {
        require(_penalty <= maxEarlyPenalty);
        plans[_stakingId].earlyPenalty = _penalty;
    }

    function setStakeConclude(uint256 _stakingId, bool _conclude) external onlyOwner {
        plans[_stakingId].conclude = _conclude;
    }

}