//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

interface IRewardGiver {
    function requestRewards() external;
}

contract RewardGiver is Ownable, IRewardGiver {

    /**
        Constants
     */
    uint256 private constant day = 28800; // blocks per day on bsc
    address public immutable luxeToken;   // LuxeMeta Token For Staking
    address public immutable pool90Day;   // 90 Day Staking Pool
    address public immutable pool180Day;  // 180 Day Staking Pool

    /**
        Daily Rate Of 180 Day Pool To 18 Points Of Precision
     */
    uint256 public Rate_180_Day;

    /**
        Daily Rate Of 180 Day Pool To 18 Points Of Precision
     */
    uint256 public Rate_90_Day;

    /**
        Time Of Last 180 Day Donation
     */
    uint256 public last_180_day_donation;

    /**
        Time Of Last 90 Day Donation
     */
    uint256 public last_90_day_donation;

    /**
        Whether Pools Rewards Are Enabled Or Not
     */
    bool public rewardsOn;

    constructor(address luxeToken_, address pool90Day_, address pool180Day_) {
        luxeToken = luxeToken_;
        pool90Day = pool90Day_;
        pool180Day = pool180Day_;
    }

    function turnRewardsOn() external onlyOwner {
        rewardsOn = true;
        _resetRewardTimers();
    }

    function turnRewardsOff() external onlyOwner {
        rewardsOn = false;
        _resetRewardTimers();
    }

    function resetRewardTimers() external onlyOwner {
        _resetRewardTimers();
    }

    function set90DayRate(uint256 newDailyRate) external onlyOwner {
        Rate_90_Day = newDailyRate;
    }

    function set180DayRate(uint256 newDailyRate) external onlyOwner {
        Rate_180_Day = newDailyRate;
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function requestRewards() external override {

        // pending amounts
        uint pending90 = pending90Day();
        uint pending180 = pending180Day();

        // reset reward timers
        _resetRewardTimers();

        // if we have the balance, send the tokens
        _send(pool90Day, pending90);
        _send(pool180Day, pending180);
    }

    function pending90Day() public view returns (uint256) {
        uint duration = timeSince90Day();
        uint dueDaily = dueDaily90();
        if (duration == 0 || dueDaily == 0) {
            return 0;
        }

        // amount due is determined by: daily_rate * tvl * duration/day
        return ( dueDaily * duration ) / day;
    }

    function pending180Day() public view returns (uint256) {
        uint duration = timeSince180Day();
        uint dueDaily = dueDaily180();
        if (duration == 0 || dueDaily == 0) {
            return 0;
        }

        // amount due is determined by: daily_rate * tvl * duration/day
        return ( dueDaily * duration ) / day;
    }

    function dueDaily90() public view returns (uint256) {
        return Rate_90_Day * balanceOf90Pool() / 10**18;
    }

    function dueDaily180() public view returns (uint256) {
        return Rate_180_Day * balanceOf180Pool() / 10**18;
    }

    function balanceOf90Pool() public view returns (uint256) {
        return IERC20(luxeToken).balanceOf(pool90Day);
    }

    function balanceOf180Pool() public view returns (uint256) {
        return IERC20(luxeToken).balanceOf(pool180Day);
    }

    function timeSince90Day() public view returns (uint256) {
        if (!rewardsOn) {
            return 0;
        }
        return block.number > last_90_day_donation ? block.number - last_90_day_donation : 0;
    }

    function timeSince180Day() public view returns (uint256) {
        if (!rewardsOn) {
            return 0;
        }
        return block.number > last_180_day_donation ? block.number - last_180_day_donation : 0;
    }

    function balanceOf() public view returns (uint256) {
        return IERC20(luxeToken).balanceOf(address(this));
    }

    function _resetRewardTimers() internal {
        last_180_day_donation = block.number;
        last_90_day_donation = block.number;
    }

    function _send(address to, uint256 amount) internal {
        // ensure we don't send more than we own
        uint balance = balanceOf();
        if (amount > balance) {
            amount = balance;
        }
        // ensure we don't attempt to send zero
        if (to == address(0) || amount == 0) {
            return;
        }
        // send
        IERC20(luxeToken).transfer(to, amount);
    }
}