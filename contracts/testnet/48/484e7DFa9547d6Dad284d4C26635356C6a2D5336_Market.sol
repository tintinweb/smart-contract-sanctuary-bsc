// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import 'IERC20.sol';
import 'SafeERC20.sol';
import "Math.sol";
import "ReentrancyGuard.sol";
import "Ownable.sol";
import "IBurnableERC20.sol";

contract Market is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20 for IBurnableERC20;

    event SetSellRate(address indexed admin, uint sellRate);
    event ClaimRewards(address indexed user, uint amount);
    event SellCaviar(address indexed user, uint amount);

    struct PriceHistory {
        uint256 totalStaked;
        uint256 busdBalance;
    }

    struct UserInfo {
        uint256 stakedAmount;
        uint256 lastUpdateDay;
        uint256 claimableAmount;
    }

    mapping(address => UserInfo) public userInfo;
    PriceHistory[] public priceHistories;

    PriceHistory public currentHistory;

    uint256 public immutable EPOCH;
    uint256 public SELL_RATE_BP = 500;
    IBurnableERC20 public caviar;
    IERC20 public busd;

    constructor(IBurnableERC20 _caviar, IERC20 _busd, uint256 _epoch){
        caviar = _caviar;
        busd = _busd;
        EPOCH = _epoch;
    }

    function daysSinceEpoch() public view returns (uint){
        return (block.timestamp - EPOCH) / 1 days;
    }

    function sellCaviar(uint256 amount) public nonReentrant {
        update();
        UserInfo memory userCopy = simulateUserInfo(userInfo[msg.sender]);
        userCopy.stakedAmount += amount;
        currentHistory.totalStaked += amount;
        caviar.safeTransferFrom(msg.sender, address(this), amount);
        userInfo[msg.sender] = userCopy;

        emit SellCaviar(msg.sender, amount);
    }

    function claimRewards() public nonReentrant {
        update();
        UserInfo memory userCopy = simulateUserInfo(userInfo[msg.sender]);
        if (userCopy.claimableAmount > 0) {
            uint amount = userCopy.claimableAmount;
            userCopy.claimableAmount = 0;
            busd.safeTransfer(msg.sender, amount);

            emit ClaimRewards(msg.sender, amount);
        }
        userInfo[msg.sender] = userCopy;
    }

    function simulateUserInfo(UserInfo memory userCopy) private view returns (UserInfo memory) {
        uint day = daysSinceEpoch();
        if (userCopy.stakedAmount > 0) {
            PriceHistory memory history = stampHistory();
            for (uint256 i = userCopy.lastUpdateDay; i < day; i++) {//If day has advanced since last update
                uint sellAmount = calculateSellAmount(userCopy.stakedAmount);
                userCopy.stakedAmount -= sellAmount;

                if (i < priceHistories.length) {
                    userCopy.claimableAmount += calculateValue(priceHistories[i], sellAmount);
                } else {//This should not trigger for actual updates, only for view simulations
                    userCopy.claimableAmount += calculateValue(history, sellAmount);
                    simulateDay(history);
                }
            }
        }
        userCopy.lastUpdateDay = day;
        return userCopy;
    }

    function calculateValue(PriceHistory memory history, uint256 sellAmount) public pure returns (uint256){
        return (sellAmount * history.busdBalance) / Math.max(history.totalStaked, 1 ether);
    }

    function calculateSellAmount(uint total) public view returns (uint256){
        return (total * SELL_RATE_BP) / 10000;
    }

    //Needs to be called from FishingRod when a user deposits
    function depositBUSD(uint256 amount) public {
        update();
        busd.safeTransferFrom(msg.sender, address(this), amount);
        currentHistory.busdBalance += amount;
    }

    //Needs to be called from Caviar if price is dependent on caviar supply
    function update() public {
        uint day = daysSinceEpoch();
        _update(day - priceHistories.length);
        require(priceHistories.length == day, "INVALID");
    }

    function partialUpdate(uint numDays) public {
        uint day = daysSinceEpoch();
        require(numDays <= day - priceHistories.length, "INVALID NUM DAYS");
        _update(numDays);
    }

    function _update(uint numDays) private {
        if (numDays > 0) {
            PriceHistory memory history = stampHistory();
            for (uint256 i = 0; i < numDays; i++) {
                priceHistories.push(history);
                simulateDay(history);
            }
            uint burnAmount = currentHistory.totalStaked - history.totalStaked;
            if (burnAmount > 0) {
                caviar.burn(burnAmount);
            }
            currentHistory = history;
        }
    }

    function stampHistory() private view returns (PriceHistory memory){
        return PriceHistory({
        totalStaked : currentHistory.totalStaked,
        busdBalance : currentHistory.busdBalance
        });
    }

    function simulateDay(PriceHistory memory history) private view {
        if (history.totalStaked > 0) {
            uint soldAmount = calculateSellAmount(history.totalStaked);
            uint soldBusd = calculateValue(history, soldAmount);
            history.totalStaked -= soldAmount;
            history.busdBalance -= soldBusd;
        }
    }

    // VIEW FUNCTIONS

    function getUpdatedPriceHistory() public view returns (PriceHistory memory){
        uint day = daysSinceEpoch();
        PriceHistory memory history = stampHistory();
        for (uint256 i = priceHistories.length; i < day; i++) {
            simulateDay(history);
        }
        return history;
    }

    function currentPrice() external view returns (uint){
        return calculateValue(getUpdatedPriceHistory(), 1 ether);
    }

    function getUpdatedUserInfo(address user) external view returns (UserInfo memory){
        return simulateUserInfo(userInfo[user]);
    }

    function getTimeUntilNextDay() external view returns (uint){
        uint overtime = (block.timestamp - EPOCH) % 1 days;
        return 1 days - overtime;
    }

    function getHistoricPrices(uint fromDay, uint toDay) public view returns (uint[] memory prices){
        require(fromDay <= toDay, "INVALID DAYS");
        uint len = toDay - fromDay + 1;
        prices = new uint[](len);
        PriceHistory memory history = stampHistory();
        for (uint256 i = 0; i < len; i++) {
            uint day = fromDay + i;
            if (day < priceHistories.length) {
                prices[i] = calculateValue(priceHistories[day], 1 ether);
            } else {
                prices[i] = calculateValue(history, 1 ether);
                simulateDay(history);
            }
        }
    }

    function getLatestPrices(uint count) public view returns (uint[] memory){
        uint day = daysSinceEpoch();
        if(day >= count){
            return getHistoricPrices(day - (count - 1), day);
        }else{
            return getHistoricPrices(0, day);
        }
    }

    // ADMIN FUNCTIONS

    function setSellRate(uint sellRate) external onlyOwner {
        SELL_RATE_BP = sellRate;

        emit SetSellRate(msg.sender, sellRate);
    }
}