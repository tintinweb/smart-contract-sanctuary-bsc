// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

import "./IBEP20TokenTransfer.sol";

contract SpaceLqPairLocker {

    uint256 constant SECONDS_IN_MINUTE = 60;
    uint256 constant SECONDS_IN_HOUR = 3600;
    uint256 constant SECONDS_IN_DAY = 86400;
    uint256 constant SECONDS_IN_YEAR = 31536000;
    uint256 constant SECONDS_IN_FOUR_YEARS_WITH_LEAP_YEAR = 126230400;
    uint256 constant SECONDS_BETWEEN_JAN_1_1972_AND_DEC_31_1999 = 883612800;
    uint256 constant SECONDS_IN_100_YEARS = 3155673600;
    uint256 constant SECONDS_IN_400_YEARS = 12622780800;
    int constant OFFSET19700101 = 2440588;

    uint256 public releaseTime;

    address constant OWNER = 0x8710bE8eb9096E2D1Ce1E6139114D170423d3baA;

    event UpdatedReleaseTime(uint256 oldReleaseTime, uint256 newReleaseTime);
    event TokensReleased(address token, uint256 amount, address beneficiary);

    modifier onlyOwner() {
        require(msg.sender == OWNER);
        _;
    }

    constructor() {
        releaseTime = block.timestamp;
    }

    function extendLock(uint256 newReleaseTime) external onlyOwner {
        require(newReleaseTime > block.timestamp, "Release time must be in the future");
        require(newReleaseTime > releaseTime, "Can't make release time shorter");

        emit UpdatedReleaseTime(releaseTime, newReleaseTime);
        releaseTime = newReleaseTime;
    }

    function distributeTokens(IBEP20TokenTransfer token) external onlyOwner {
        require(block.timestamp >= releaseTime, "Lock is not expired");

        uint256 amount = token.balanceOf(address(this));
        require(token.transfer(OWNER, amount));
        emit TokensReleased(address(token), amount, OWNER);
    }

    /**
    @dev Convert timestamp to YMDHMS (year, month, day, hour, minute, second)
    @return year Returns year as `uint16`
    @return month Returns month as `uint8`
    @return day Returns day as `uint8`
    @return hour Returns hour as `uint8`
    @return minute Returns minute as `uint8`
    @return second Returns second as `uint8`
    */
    function convertReleaseTimestampToYMDHMS() 
                                     public view
                                     returns (uint16 year,
                                              uint8 month,
                                              uint8 day,
                                              uint8 hour,
                                              uint8 minute,
                                              uint8 second) {
    uint256 secondsRemaining = releaseTime;

    (secondsRemaining, year) = getYear(secondsRemaining);
    (secondsRemaining, month) = getMonth(secondsRemaining, year);
    (secondsRemaining, day) = getDay(secondsRemaining);
    (secondsRemaining, hour) = getHour(secondsRemaining);
    (secondsRemaining, minute) = getMinute(secondsRemaining);
    second = uint8(secondsRemaining);
    } 

    // functions to calculate year, month, or day from timestamp
    function getYear(uint256 _secondsRemaining)
                    private pure
                    returns (uint256 secondsRemaining,
                             uint16 year) {

     uint256 res;
     uint32 secondsInThisYear;

     secondsRemaining = _secondsRemaining;
     year = 1970;

     if (secondsRemaining < (2 * SECONDS_IN_YEAR)) {

       res = secondsRemaining / SECONDS_IN_YEAR;
       secondsRemaining -= res * SECONDS_IN_YEAR;
       year += uint16(res);

     } else {

       secondsRemaining -= 2 * SECONDS_IN_YEAR;
       year = 1972;

       if (secondsRemaining >= SECONDS_BETWEEN_JAN_1_1972_AND_DEC_31_1999) {

         secondsRemaining -= SECONDS_BETWEEN_JAN_1_1972_AND_DEC_31_1999;
         year += 28;

         res = secondsRemaining / SECONDS_IN_400_YEARS;
         secondsRemaining -= res * SECONDS_IN_400_YEARS;
         year += uint16(res * 400);

         secondsInThisYear = uint32(getSecondsInYear(year));

         if (secondsRemaining >= secondsInThisYear) {

           secondsRemaining -= secondsInThisYear;
           year += 1;
         }

         if (!isLeapYear(year)) {

           res = secondsRemaining / SECONDS_IN_100_YEARS;
           secondsRemaining -= res * SECONDS_IN_100_YEARS;
           year += uint16(res * 100);
         }
       }

       res = secondsRemaining / SECONDS_IN_FOUR_YEARS_WITH_LEAP_YEAR;
       secondsRemaining -= res * SECONDS_IN_FOUR_YEARS_WITH_LEAP_YEAR;
       year += uint16(res * 4);

       secondsInThisYear = uint32(getSecondsInYear(year));

       if (secondsRemaining >= secondsInThisYear) {

         secondsRemaining -= secondsInThisYear;
         year += 1;
       }

       if (!isLeapYear(year)) {

         res = secondsRemaining / SECONDS_IN_YEAR;
         secondsRemaining -= res * SECONDS_IN_YEAR;
         year += uint16(res);
       }
     }
    }
    
    // function to get total seconds in year
    function getSecondsInYear(uint16 _year) private pure returns (uint256) {

     if (isLeapYear(_year)) {
       return (SECONDS_IN_YEAR + SECONDS_IN_DAY);
     } else {
       return SECONDS_IN_YEAR;
     }
    }

    function getMonth(uint256 _secondsRemaining,
                     uint16 _year)
                     private pure
                     returns (uint256 secondsRemaining,
                              uint8 month) {

     uint8[13] memory monthDayMap;
     uint32[13] memory monthSecondsMap;

     secondsRemaining = _secondsRemaining;

     if (isLeapYear(_year)){

       monthDayMap = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
       monthSecondsMap = [0, 2678400, 5184000, 7862400, 10454400, 13132800,
                          15724800, 18403200, 21081600, 23673600, 26352000,
                          28944000, 31622400];

     } else {

       monthDayMap = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
       monthSecondsMap = [0, 2678400, 5097600, 7776000, 10368000, 13046400,
                          15638400, 18316800, 20995200, 23587200, 26265600,
                          28857600, 31536000];
     }

     for (uint8 i = 1; i < 13; i++) {

       if (secondsRemaining < monthSecondsMap[i]) {

         month = i;
         secondsRemaining -= monthSecondsMap[i - 1];
         break;
       }
     }
    }

    function isLeapYear(uint16 _year) internal pure returns (bool) {

     if ((_year % 4) != 0) { return false; }
     if (((_year % 400) == 0) || ((_year % 100) != 0)) { return true; }

     return false;
    }

    function getDay(uint256 _secondsRemaining)
                   private pure
                   returns (uint256 secondsRemaining,
                            uint8 day) {

     uint256 res;

     secondsRemaining = _secondsRemaining;

     res = secondsRemaining / SECONDS_IN_DAY;
     secondsRemaining -= res * SECONDS_IN_DAY;
     day = uint8(res + 1);
    }

    // functions to increment timestamp based on year
    function incrementYearAndTimestamp(uint16 _year,
                                      uint16 _yearCounter,
                                      uint256 _ts,
                                      uint16 _divisor,
                                      uint256 _seconds)
                                      private pure
                                      returns (uint16 year,
                                               uint256 ts) {

     uint256 res;

     res = uint256((_year - _yearCounter) / _divisor);
     year = uint16(_yearCounter + (res * _divisor));
     ts = _ts + (res * _seconds);
    }

    function incrementLeapYear(uint16 _year,
                              uint16 _yearCounter,
                              uint256 _ts)
                              private pure
                              returns (uint16 yearCounter,
                                       uint256 ts) {

     yearCounter = _yearCounter;
     ts = _ts;

     if ((yearCounter < _year) && isLeapYear(yearCounter)) {

       yearCounter += 1;
       ts += SECONDS_IN_YEAR + SECONDS_IN_DAY;
     }
    }

    // functions to get hours and minutes from timestamp

    function getHourOrMinute(uint256 _secondsRemaining,
                            uint256 _divisor)
                            private pure
                            returns (uint256 secondsRemaining,
                                     uint8 hourOrMinute) {

     uint256 res;

     secondsRemaining = _secondsRemaining;

     res = secondsRemaining / _divisor;
     secondsRemaining -= res * _divisor;
     hourOrMinute = uint8(res);
    }

    function getHour(uint256 _secondsRemaining) private pure returns (uint256 secondsRemaining, uint8 hour) {
     return getHourOrMinute(_secondsRemaining, SECONDS_IN_HOUR);
    }

    function getMinute(uint256 _secondsRemaining) private pure returns (uint256 secondsRemaining, uint8 minute) {
     return getHourOrMinute(_secondsRemaining, SECONDS_IN_MINUTE);
    }

    //function to convert date and time to Unix timestamp
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) 
        public 
        pure
        returns (uint timestamp) {
        require(year >= 2022, "Year must be greater than 2022");
        require(month >= 1 && month <= 12, "Month must be between 1~12");
        require(day >= 1 && day <= 31, "Day must be between 1~31");
        require(hour >= 0 && hour <= 24, "Hour must be between 0~24");
        require(minute >= 0 && minute <= 60, "Minute must be between 0~60");
        require(second >= 0 && second <= 60, "Second must be between 0~60");

        timestamp = _daysFromDate(year, month, day) * SECONDS_IN_DAY + hour * SECONDS_IN_HOUR + minute * SECONDS_IN_MINUTE + second;
    }

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------

    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }   
}