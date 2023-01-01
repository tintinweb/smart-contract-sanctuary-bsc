/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.2;

interface BEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library DateTime {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

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

    function _daysToDate(uint256 _days) internal pure returns (uint256 year, uint256 month, uint256 day) {
        unchecked {
            int256 __days = int256(_days);

            int256 L = __days + 68569 + OFFSET19700101;
            int256 N = (4 * L) / 146097;
            L = L - (146097 * N + 3) / 4;
            int256 _year = (4000 * (L + 1)) / 1461001;
            L = L - (1461 * _year) / 4 + 31;
            int256 _month = (80 * L) / 2447;
            int256 _day = L - (2447 * _month) / 80;
            L = _month / 11;
            _month = _month + 2 - 12 * L;
            _year = 100 * (N - 49) + _year + L;

            year = uint256(_year);
            month = uint256(_month);
            day = uint256(_day);
        }
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256 _months) {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
}
contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract privatesale is Ownable {

    uint256 public MAX = 50000000e18;
    struct Members {
        address member;
        uint value;
        uint lastmonth;
        uint lastyear;
        uint totalAllocation;
        uint totalmonths;
        uint remainingmonths;
    }
    mapping(address => Members) public members;
    BEP20 ox2 = BEP20(0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3);


    function addMember(address member,uint value,uint allocation) public onlyOwner {
        uint months = allocation / value ;
        if((months * value) != allocation){
            months += 1;
        }
        uint timestamp = DateTime.addMonths(block.timestamp,6);
        require(value < allocation,"allocation cannot less !");
        require(member != owner(),"owner cannot member !");
        require(members[member].member == address(0),"member already exist !");
        members[member].member = member;
        members[member].value = value;
        members[member].lastmonth = DateTime.getMonth(timestamp) == 1 ? 12 : (DateTime.getMonth(timestamp) - 1);
        members[member].lastyear = members[member].lastmonth == 12 ? (DateTime.getYear(timestamp) - 1 ) : DateTime.getYear(timestamp);
        members[member].totalAllocation = allocation;
        members[member].totalmonths = months;
        members[member].remainingmonths = months;
    }

    function getremainingmonths(address member) public view returns (uint) {
        uint timestamp = block.timestamp;
        uint month;
        uint currentyear = DateTime.getYear(timestamp);
        uint currentmonth = DateTime.getMonth(timestamp);
        uint _lastmonth = members[member].lastmonth;
        uint _lastyear = members[member].lastyear;
        uint totalyears = currentyear - _lastyear;
        if(currentmonth < _lastmonth){
            uint remainigmonths = (_lastmonth - currentmonth);
            month = ((totalyears * 12) - remainigmonths) - 1;
        } else {
            month = ((totalyears * 12) + (currentmonth - _lastmonth)) - 1;
        }
        if(month > members[member].remainingmonths){
            return members[member].remainingmonths;
        }
        return (month);
    }
    function claimMemberReward() public {
        address member = msg.sender;
        require(members[member].member != address(0),"beep, you're not member !");
        require(members[member].member == member,"beep, you're not member !");
        require(members[member].remainingmonths != 0,"you have claimed all rewards");
        uint value = members[member].value;
        uint totalAllocation = members[member].totalAllocation;
        uint  remainingmonths = members[member].remainingmonths;
        uint lastmonthvalue;
        uint timestamp = block.timestamp;
        uint month = getremainingmonths(member);
        if((month*value) != totalAllocation){
            if(remainingmonths == 1){
                uint actualmonths = members[member].totalmonths - 1;
                lastmonthvalue = totalAllocation - (value * actualmonths);
            }
        }
        require(month > 0 , "timestamp exeeds");
        if (month > 0) {
            uint256 ox2balance = ox2.balanceOf(address(this));
            if((month*value) != totalAllocation && remainingmonths == 1){
            require(ox2balance >= lastmonthvalue , "insufficient balance of token !!");
                ox2.transfer(member, lastmonthvalue);
            } else {
                require(ox2balance >= value * month , "insufficient balance of token !!");
                ox2.transfer(member, month * value);
            }
            uint currentmonth = DateTime.getMonth(timestamp);
            members[member].lastyear = DateTime.getYear(timestamp);
            members[member].remainingmonths = remainingmonths - month;
            if(currentmonth == 1){
                members[member].lastyear = (DateTime.getYear(timestamp) - 1);
                members[member].lastmonth = 12;
            }else {
                members[member].lastyear = DateTime.getYear(timestamp);
                members[member].lastmonth = currentmonth - 1;
            }
        }
    }
}