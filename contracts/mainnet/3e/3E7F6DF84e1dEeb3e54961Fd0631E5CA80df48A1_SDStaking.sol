// SPDX-License-Identifier: MIT
pragma solidity =0.8.10;

import "./ISDStaking.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";

contract SDStaking is ISDStaking, Ownable {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    uint8 public immutable fixedAPY;
    uint public immutable stakingDuration;
    uint public immutable lockupDuration;
    uint public immutable stakingMax;
    uint public startPeriod;
    uint public lockupPeriod;
    uint public endPeriod;
    uint8 public burnFee = 3;
    address public dead = 0x000000000000000000000000000000000000dEaD;
    uint private _totalStaked;
    uint internal _precision = 1E4;

    mapping(address => uint) public staked;
    mapping(address => uint) private _rewardsToClaim;
    mapping(address => uint) private _userStartTime;

    constructor(
        address _token,
        uint8 _fixedAPY,
        uint _durationInDays,
        uint _lockDurationInDays,
        uint _maxAmountStaked
    ) {
        stakingDuration = _durationInDays * 1 days;
        lockupDuration = _lockDurationInDays * 1 days;
        token = IERC20(_token);
        fixedAPY = _fixedAPY;
        stakingMax = _maxAmountStaked;
    }

    function startStaking() external override onlyOwner {
        require(startPeriod == 0, "Staking has already started");
        startPeriod = block.timestamp;
        lockupPeriod = block.timestamp + lockupDuration;
        endPeriod = block.timestamp + stakingDuration;
        emit StartStaking(startPeriod, lockupDuration, endPeriod);
    }

    function deposit(uint amount) external override {
        require(endPeriod == 0 || endPeriod > block.timestamp, "Staking period ended");
        require(_totalStaked + amount <= stakingMax, "The total quota of $SD to be staked is full! Please try to stake a lesser amount!");
        require(amount > 0, "You must stake an amount more than 0!");
        if (_userStartTime[_msgSender()] == 0) {
            _userStartTime[_msgSender()] = block.timestamp;
        }
        _updateRewards();
        staked[_msgSender()] += amount;
        _totalStaked += amount;
        token.safeTransferFrom(_msgSender(), address(this), amount);
        emit Deposit(_msgSender(), amount);
    }

    function withdraw(uint amount) external override {
        require(block.timestamp >= lockupPeriod, "You can't withdraw your $SD before the lockup period ends!");
        require(amount > 0, "You don't have any $SD to withdraw!");
        require(amount <= staked[_msgSender()], "You can't withdraw more $SD than what you have staked!");
        _updateRewards();
        if (_rewardsToClaim[_msgSender()] > 0) {
            _claimRewards();
        }
        _totalStaked -= amount;
        staked[_msgSender()] -= amount;
        token.safeTransfer(_msgSender(), amount);
        emit Withdraw(_msgSender(), amount);
    }

    function withdrawAll() external override {
        require(block.timestamp >= lockupPeriod, "You can't withdraw funds before the lockup ends.");
        _updateRewards();
        if (_rewardsToClaim[_msgSender()] > 0){
            _claimRewards();
        }
        _userStartTime[_msgSender()] = 0;
        _totalStaked -= staked[_msgSender()];
        uint stakedBalance = staked[_msgSender()];
        staked[_msgSender()] = 0;
        token.safeTransfer(_msgSender(), stakedBalance);
        emit Withdraw(_msgSender(), stakedBalance);
    }

    function withdrawResidualBalance() external onlyOwner {
        uint balance = token.balanceOf(address(this));
        uint residualBalance = balance - (_totalStaked);
        require(residualBalance > 0, "No residual Balance to withdraw.");
        token.safeTransfer(owner(), residualBalance);
    }

    function setBurnFees(uint8 newFee) external onlyOwner {
        require(newFee <= 25, "Burn Fees can't be higher then 25%.");
        burnFee = newFee;
    }

    function amountStaked(address stakeHolder) external view override returns (uint){
        return staked[stakeHolder];
    }

    function totalDeposited() external view override returns (uint) {
        return _totalStaked;
    }

    function rewardOf(address stakeHolder) external view override returns (uint){
        return _calculateRewards(stakeHolder);
    }

    function claimRewards() external override {
        _claimRewards();
    }

    function _calculateRewards(address stakeHolder) internal view returns (uint){
        if (startPeriod == 0 || staked[stakeHolder] == 0) {
            return 0;
        }

        return
            (((staked[stakeHolder] * fixedAPY) *
                _percentageTimeRemaining(stakeHolder)) / (_precision * 100)) +
            _rewardsToClaim[stakeHolder];
    }

    function _percentageTimeRemaining(address stakeHolder) internal view returns (uint){
        bool early = startPeriod > _userStartTime[stakeHolder];
        uint startTime;
        if (endPeriod > block.timestamp) {
            startTime = early ? startPeriod : _userStartTime[stakeHolder];
            uint timeRemaining = stakingDuration -
                (block.timestamp - startTime);
            return
                (_precision * (stakingDuration - timeRemaining)) /
                stakingDuration;
        }
        startTime = early
            ? 0
            : stakingDuration - (endPeriod - _userStartTime[stakeHolder]);
        return (_precision * (stakingDuration - startTime)) / stakingDuration;
    }

    function _claimRewards() private {
        _updateRewards();
        uint rewardsToClaim = _rewardsToClaim[_msgSender()];
        require(rewardsToClaim > 0, "You don't have any $SD rewards!");
        _rewardsToClaim[_msgSender()] = 0;
        uint rewardBurnFee = (rewardsToClaim / 100 * burnFee);
        rewardsToClaim = rewardsToClaim - rewardBurnFee;
        token.safeTransfer(_msgSender(), rewardsToClaim);
        token.safeTransfer(dead, rewardBurnFee);
        emit Claim(_msgSender(), rewardsToClaim);
    }

    function _updateRewards() private {
        _rewardsToClaim[_msgSender()] = _calculateRewards(_msgSender());
        _userStartTime[_msgSender()] = (block.timestamp >= endPeriod) ? endPeriod : block.timestamp;
    }
}