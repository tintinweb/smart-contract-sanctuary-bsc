// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

/**
 * THIS IS THE CONTRACT BY PATRON DOGE MEME TOKEN DAO. ALL RIGHTS RESERVED. 
 */

contract Staking is Context, Ownable {

    using SafeMath for uint;

    uint256 private percentage;
    uint256 public startTime;
    uint256 public endTime;
    bool active;

    IBEP20 PATRON;

    struct stakeHolder {
        uint256 amount;
        uint256 startTime;
        uint256 unlockTime;
    }

    struct tierRules {
        uint256 lockTime;
        uint256 percentage;
        uint256 maxAmount;
        uint256 minAmount;
        uint256 limit;
        uint256 fines;
    }

    mapping(address => mapping(uint8 => stakeHolder)) public holders;
    mapping(uint256 => tierRules) public tiers;
    mapping(uint256 => uint8) public currentLimits;

    event LogClaim(address, uint256, bool);
    event LogDeposit(address, uint256, uint256);

    constructor(address _COIN) public {
        PATRON = IBEP20(_COIN);
        percentage = 1000000;
    }

    /**
     * @dev Throws if contract is not active.
     */
    modifier isActive() {
        require(active, "Staking: staking is not active");
        _;
    }

    modifier isAvailable(uint8 _tier, uint256 amount) {
        require(holders[msg.sender][_tier].amount == 0, "Already deposited");
        require(endTime > block.timestamp.add(tiers[_tier].lockTime), "Wrong time to deposit");
        require(tiers[_tier].limit > currentLimits[_tier], "Limit Exceeded");
        require(tiers[_tier].maxAmount == amount, "Deposit limit Exceeded");
        _;
    }

    function addTier(uint256 monthes, uint256 _percentage, uint256 maxAmount, uint256 minAmount, uint8 limit, uint256 fines) public onlyOwner {
        tierRules memory tR;
        tR.percentage = _percentage.mul(percentage);
        tR.lockTime = monthes.mul(86400).mul(30);
        tR.maxAmount = maxAmount.mul(1e18);
        tR.minAmount = minAmount.mul(1e18);
        tR.limit = limit;
        tR.fines = fines.mul(percentage);
        tiers[monthes] = tR;
    }

    /**
     * @dev Activating the staking with start block.
     * Can only be called by the current owner.
     */
    function ativate() public onlyOwner returns (bool){
        startTime = block.timestamp;
        endTime = block.timestamp + 30*15*86400;
        active = true;
        return true;
    }

    /**
     * @dev Deactivating the staking.
     * Can only be called by the current owner.
     */
    function deactivate() public onlyOwner returns (bool) {
        active = false;
        return true;
    }

    /**
     * @dev Deposits the PATRON tokens.
     * Can only be called when contract is active.
     */
    function depositTokens (uint256 _amount, uint8 _tier) external isActive isAvailable(_tier, _amount) {
        address from = msg.sender;
        address to = address(this);
        require(PATRON.transferFrom(from, to, _amount));
        currentLimits[_tier] += 1;
        _calculateHolder(from, _tier, _amount);
        emit LogDeposit(from, _amount, _tier);
    }

    /**
     * @dev Calcultae share and roi for the holder
     */
    function _calculateHolder(address holder, uint8 _tier, uint256 _amount) internal {
        stakeHolder memory sH = holders[holder][_tier];
        sH.amount = _amount;
        sH.startTime = block.timestamp;
        sH.unlockTime = block.timestamp + tiers[_tier].lockTime;
        holders[holder][_tier] = sH;
    }

    /**
     * @dev Claim PATRON reward and unstake tokens.
     * Can only be called when contract is active.
     */
    function unstake (uint8 _tier) public isActive {
        require(holders[msg.sender][_tier].unlockTime > block.timestamp, "Please use claim function");
        require(holders[msg.sender][_tier].amount > 0, "Low balance");
        _claim(msg.sender, true, _tier);
        currentLimits[_tier] -= 1;
    }

    /**
     * @dev unstake tokens.
     * Can only be called when contract is active.
     */
    function claim (uint8 _tier) public isActive {
        require(holders[msg.sender][_tier].unlockTime < block.timestamp, "To early to claim");
        require(holders[msg.sender][_tier].amount > 0, "Low balance");
        _claim(msg.sender, false, _tier);
        currentLimits[_tier] -= 1;
    }

    /**
     * @dev Send available reward to the holder
     */
    function _claim(address _to, bool _fined, uint8 _tier) internal {
        uint _staked = _calculateStaked(_to, _tier);
        uint total;
        if (_fined) {
            uint f = _staked.mul(tiers[_tier].fines).div(percentage.mul(100));
            total = _staked.sub(f);
        } else {
            uint e = _staked.mul(tiers[_tier].percentage).div(percentage.mul(100));
            total = _staked.add(e);
        }
        require(PATRON.transfer(_to, total));
        delete holders[_to][_tier];
        emit LogClaim(_to, total, _fined);
    }

    /**
     * @dev Calculate available reward for the holder
     */
    function _calculateStaked(address holder, uint8 _tier) internal view returns(uint256){
        stakeHolder memory st = holders[holder][_tier];
        return st.amount;
    }

    /**
     * @dev get base staking data
     */
    function getStakerData(address _player, uint8 _tier) public view returns(address, uint256, uint256, uint256) {
        stakeHolder memory st = holders[_player][_tier];
        return (_player, st.amount, st.unlockTime, st.startTime);
    }


    function sendTo(address payable _to, uint256 _amount) public onlyOwner returns(bool) {
        require(PATRON.balanceOf(address(this)) >= _amount);
        PATRON.transfer(_to, _amount);
    }

}