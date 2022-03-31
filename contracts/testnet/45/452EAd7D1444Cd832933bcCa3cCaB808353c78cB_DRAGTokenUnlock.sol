pragma solidity ^0.8.0;

import "SafeMath.sol";

// interface IDRAGToken
// {
//     function getOwner() external returns (address);

//     function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
// }

contract DRAGTokenUnlock
{
    using SafeMath for uint256;

    //IDRAGToken private dragToken;

    uint private constant SECONDS_PER_DAY = 24 * 60 * 60;

    int private constant OFFSET19700101 = 2440588;

    address private chairman;

    uint256 private startTimeStamp;

    uint256 private alreadyTakeToken;

    constructor(address dragTokenAddress) public
    {
        chairman = msg.sender;
        startTimeStamp = block.timestamp;
        //dragToken = IDRAGToken(dragTokenAddress);
    }

    function withdrawUnlockTokenToWallet(uint256 intervalMonth, uint256[] memory unlockTokens) internal
    {
        uint256 amount = getUnlockAvailableToken(intervalMonth, unlockTokens);
        require(amount > 0, "no unlock token.");
        alreadyTakeToken = alreadyTakeToken.add(amount);
        //dragToken.transferFrom(dragToken.getOwner(), chairman, amount);
    }

    function getUnlockAvailableToken(uint256 intervalMonth, uint256[] memory unlockTokens) internal view returns (uint256)
    {
        return getUnlockTotalToken(intervalMonth, unlockTokens) - alreadyTakeToken;
    }

    function getUnlockTotalToken(uint256 intervalMonth, uint256[] memory unlockTokens) internal view returns (uint256)
    {
        uint256 total = 0;
        uint256 curTime = block.timestamp;
        uint256 count = uint256(diffMonths(startTimeStamp, curTime));
        count = count.div(intervalMonth);
        if (count < unlockTokens.length)
        {
            count = count.add(1);
        }
        else
        {
            count = unlockTokens.length;
        }
        for (uint256 i = 0; i < count; i++)
        {
            total = total.add(unlockTokens[i]);
        }
        return total;
    }

    function _daysToDate(uint _days) internal view returns (uint year, uint month, uint day)
    {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function diffMonths(uint fromTimestamp, uint toTimestamp) internal view returns (uint _months)
    {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
}