/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

pragma solidity ^0.8.1;

abstract contract DateUtil {
    uint256 internal constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 internal constant SECONDS_PER_HOUR = 60 * 60;
    uint256 internal constant SECONDS_PER_MINUTE = 60;
    uint256 internal constant OFFSET19700101 = 2440588;
    uint256 internal constant DAY_IN_SECONDS = 86400;
    uint256 internal constant YEAR_IN_SECONDS = 31536000;
    uint256 internal constant LEAP_YEAR_IN_SECONDS = 31622400;
    uint256 internal constant HOUR_IN_SECONDS = 3600;
    uint256 internal constant MINUTE_IN_SECONDS = 60;
    uint16 internal constant ORIGIN_YEAR = 1970;

    uint8[] monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    function getNow() internal view returns (uint256 timestamp) {
        uint256 year;
        uint256 month;
        uint256 day;
        (year, month, day) = daysToDate(block.timestamp, 8);
        return toTimestamp(year, month, day, 8);
    }

    function daysToDate(uint256 timestamp, uint8 timezone)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        return _daysToDate(timestamp + timezone * uint256(SECONDS_PER_HOUR));
    }

    function _daysToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        uint256 _days = uint256(timestamp) / SECONDS_PER_DAY;

        uint256 L = _days + 68569 + OFFSET19700101;
        uint256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * year) / 4 + 31;
        month = (80 * L) / 2447;
        day = L - (2447 * month) / 80;
        L = month / 11;
        month = month + 2 - 12 * L;
        year = 100 * (N - 49) + year + L;
    }

    function toTimestamp(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 timezone
    ) internal pure returns (uint256 timestamp) {
        uint256 i;
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            } else {
                timestamp += YEAR_IN_SECONDS;
            }
        }
        uint256[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        } else {
            monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;
        for (i = 1; i < month; i++) {
            timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
        }
        timestamp += DAY_IN_SECONDS * (day - 1);
        timestamp = timestamp - timezone * uint256(SECONDS_PER_HOUR);
        return timestamp;
    }

    function isLeapYear(uint256 year) internal pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }
}

contract PICC is DateUtil {
    mapping(uint256 => uint256) public dailyDestroy;

    function test() public view returns (uint256 num) {
        uint256 timestamp = getNow();
        return dailyDestroy[timestamp];
    }

    function set(uint256 num) public returns (uint256 numwa) {
        uint256 timestamp = getNow();
        uint256 nums = dailyDestroy[timestamp];
        if(nums>0){
            dailyDestroy[timestamp] = nums+num;
        }else{
            dailyDestroy[timestamp] = num;
        }
        return dailyDestroy[timestamp];
    }
}