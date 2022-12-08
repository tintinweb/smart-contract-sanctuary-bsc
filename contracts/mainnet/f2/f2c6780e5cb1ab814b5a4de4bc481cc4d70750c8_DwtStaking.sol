//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";

abstract contract IERC20Staking is ReentrancyGuard, Ownable {

    struct Plan {
        uint256 overallStaked;
        uint256 stakesCount;
        uint256 apr;
        uint256 stakeDuration;
        uint256 depositDeduction;
        uint256 withdrawDeduction;
        bool conclude;
    }
    
    struct Staking {
        uint256 amount;
        uint256 stakeAt;
        uint256 endstakeAt;
    }

    mapping(uint256 => mapping(address => Staking[])) public stakes;

    address public stakingToken;
    mapping(uint256 => Plan) public plans;

    constructor(address _stakingToken) {
        stakingToken = _stakingToken;
    }

    function stake(uint256 _stakingId, uint256 _amount) public virtual;
    function canWithdrawAmount(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function unstake(uint256 _stakingId, uint256 _amount) public virtual;
    function earnedToken(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function claimEarned(uint256 _stakingId) public virtual;
}

contract DwtStaking is IERC20Staking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 periodicTime = 365 days;
    uint256 planLimit = 4;

    constructor(address _stakingToken) IERC20Staking(_stakingToken) {
        plans[0].apr = 30;
        plans[0].stakeDuration = 30 days;
        plans[0].depositDeduction = 0;
        plans[0].withdrawDeduction = 0;
    
        plans[1].apr = 50;
        plans[1].stakeDuration = 60 days;
        plans[1].depositDeduction = 0;
        plans[1].withdrawDeduction = 0;

        plans[2].apr = 70;
        plans[2].stakeDuration = 90 days;
        plans[2].depositDeduction = 0;
        plans[2].withdrawDeduction = 0;

        plans[3].apr = 90;
        plans[3].stakeDuration = 180 days;
        plans[3].depositDeduction = 0;
        plans[3].withdrawDeduction = 0;
    }

    function stake(uint256 _stakingId, uint256 _amount) public override {
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
        
        if(stakelength == 0) {
            plan.stakesCount += 1;
        }

        stakes[_stakingId][msg.sender].push();
        
        Staking storage _staking = stakes[_stakingId][msg.sender][stakelength];
        _staking.amount = amount.sub(deductionAmount);
        _staking.stakeAt = block.timestamp;
        _staking.endstakeAt = block.timestamp + plan.stakeDuration;
        
        plan.overallStaked = plan.overallStaked.add(
            amount.sub(deductionAmount)
        );

    }

    function canWithdrawAmount(uint256 _stakingId, address account) public override view returns (uint256, uint256) {
        uint256 _stakedAmount = 0;
        uint256 _canWithdraw = 0;
        for (uint256 i = 0; i < stakes[_stakingId][account].length; i++) {
            Staking storage _staking = stakes[_stakingId][account][i];
            _stakedAmount = _stakedAmount.add(_staking.amount);
            
            if (block.timestamp >= _staking.endstakeAt)
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

    function unstake(uint256 _stakingId, uint256 _amount) public override {
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
        for (uint256 i = stakes[_stakingId][msg.sender].length; i > 0; i--) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i-1];
            
            if (block.timestamp >= _staking.endstakeAt) {

                _earned = _earned.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(periodicTime)
                        .mul(plan.apr)
                        .div(100)
                );

                if (amount >= _staking.amount) {
                    amount = amount.sub(_staking.amount);
                    _staking.amount = 0;
                } else {
                    _staking.amount = _staking.amount.sub(amount);
                    amount = 0;
                    break;
                }

                _staking.stakeAt = block.timestamp;
            }   
        }

        if(deductionAmount > 0) {
            IERC20(stakingToken).transfer(stakingToken, deductionAmount);
        }

        if(tamount > 0) {
            IERC20(stakingToken).transfer(msg.sender, tamount + _earned);
        }

        plans[_stakingId].overallStaked = plans[_stakingId].overallStaked.sub(_amount);
    }

    function claimEarned(uint256 _stakingId) public override {
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
        IERC20(stakingToken).transfer(msg.sender, _earned);
    }

    function getStakeLength(uint256 _stakingId, address _account) public view returns (uint256) {
        return stakes[_stakingId][_account].length;
    }

    function setAPR(uint256 _stakingId, uint256 _percent) external onlyOwner {
        plans[_stakingId].apr = _percent;
    }

    function setDepositDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        plans[_stakingId].depositDeduction = _deduction;
    }

    function setWithdrawDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        plans[_stakingId].withdrawDeduction = _deduction;
    }

    function setStakeConclude(uint256 _stakingId, bool _conclude) external onlyOwner {
        plans[_stakingId].conclude = _conclude;
    }

    function removeStuckToken() external onlyOwner {
        IERC20(stakingToken).transfer(owner(), IERC20(stakingToken).balanceOf(address(this)));
    }
}