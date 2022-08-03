//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";

abstract contract IERC20Staking is ReentrancyGuard, Ownable {

    struct Plan {
        uint256 overallStaked;
        uint256 apy;
        uint256 stakeDuration;
        uint256 depositDeduction;
        uint256 withdrawDeduction;
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

    function deposit(uint256 _stakingId, uint256 _amount) public virtual;
    function canWithdrawAmount(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function withdraw(uint256 _stakingId, uint256 _amount) public virtual;
    function earnedToken(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function claim(uint256 _stakingId) public virtual;
}

contract TokenStaking is IERC20Staking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor(address _stakingToken) IERC20Staking(_stakingToken) {
        
        plans[0].apy = 250;
        plans[0].stakeDuration = 1 minutes;
        plans[0].depositDeduction = 5;
        plans[0].withdrawDeduction = 5;

        plans[1].apy = 300;
        plans[1].stakeDuration = 2 minutes;
        plans[1].depositDeduction = 10;
        plans[1].withdrawDeduction = 10;

        plans[2].apy = 500;
        plans[2].stakeDuration = 3 minutes;
        plans[2].depositDeduction = 20;
        plans[2].withdrawDeduction = 20;
    }

    function deposit(uint256 _stakingId, uint256 _amount) public override {
        require(
            IERC20(stakingToken).balanceOf(msg.sender) >= _amount,
            "Balance is not enough"
        );
        require(_stakingId < 3, "Staking is unavailable");

        uint256 beforeBalance = IERC20(stakingToken).balanceOf(address(this));
        IERC20(stakingToken).transferFrom(msg.sender, address(this), _amount);
        uint256 afterBalance = IERC20(stakingToken).balanceOf(address(this));
        uint256 amount = afterBalance - beforeBalance;
        
        uint256 deductionAmount = amount.mul(plans[_stakingId].depositDeduction).div(1000);
        IERC20(stakingToken).transfer(stakingToken, deductionAmount);
        
        uint256 stakelength = stakes[_stakingId][msg.sender].length;
        stakes[_stakingId][msg.sender].push();
        
        Staking storage _staking = stakes[_stakingId][msg.sender][stakelength];
        _staking.amount = amount.sub(deductionAmount);
        _staking.stakeAt = block.timestamp;
        _staking.endstakeAt = block.timestamp + plans[_stakingId].stakeDuration;
        
        plans[_stakingId].overallStaked = plans[_stakingId].overallStaked.add(
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
                        .div(plan.stakeDuration)
                        .mul(plan.apy)
                        .div(100)
                );
                _earned = _earned.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(plan.stakeDuration)
                        .mul(plan.apy)
                        .div(100)
                );
        }
        return (_earned, _canClaim);
    }

    function withdraw(uint256 _stakingId, uint256 _amount) public override {
        uint256 _stakedAmount;
        uint256 _canWithdraw;

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
        for (uint256 i = 0; i < stakes[_stakingId][msg.sender].length; i++) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i];
            if (block.timestamp >= _staking.endstakeAt) {
                if (amount >= _staking.amount) {
                    amount = amount.sub(_staking.amount);
                    _staking.amount = 0;
                } else {
                    _staking.amount = _staking.amount.sub(amount);
                    amount = 0;
                    break;
                }
            }
        }

        IERC20(stakingToken).transfer(stakingToken, deductionAmount);
        IERC20(stakingToken).transfer(msg.sender, tamount);

        plans[_stakingId].overallStaked = plans[_stakingId].overallStaked.sub(_amount);
    }

    function claim(uint256 _stakingId) public override {
        uint256 _earned = 0;
        Plan storage plan = plans[_stakingId];
        for (uint256 i = 0; i < stakes[_stakingId][msg.sender].length; i++) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i];
            if (block.timestamp >= _staking.endstakeAt) {
                _earned = _earned.add(
                    _staking
                        .amount
                        .mul(plan.apy)
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(plan.stakeDuration)
                        .div(100)
                );
                _staking.stakeAt = block.timestamp;
            }
        }
        require(_earned > 0, "There is no amount to claim");
        IERC20(stakingToken).transfer(msg.sender, _earned);
    }

    function setAPR(uint256 _stakingId, uint256 _percent) external onlyOwner {
        plans[_stakingId].apy = _percent;
    }

    function setDepositDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        plans[_stakingId].depositDeduction = _deduction;
    }

    function setWithdrawDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        plans[_stakingId].withdrawDeduction = _deduction;
    }

    function removeStuckToken() external onlyOwner {
        IERC20(stakingToken).transfer(owner(), IERC20(stakingToken).balanceOf(address(this)));
    }
}