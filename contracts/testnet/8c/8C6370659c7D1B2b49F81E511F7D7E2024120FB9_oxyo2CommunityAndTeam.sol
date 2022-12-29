/**
 *Submitted for verification at BscScan.com on 2022-12-29
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

contract oxyo2CommunityAndTeam is Ownable {
    uint256 public amount = 80000e18;
    uint public totalAllocation = 0;
    uint256 public MAX = 10000000e18;
    uint public lastmonth;
    uint public lastyear;
    struct Members {
        address member;
        uint value;
        uint lastmonth;
        uint lastyear;
    }
    mapping(address => Members) public members;
    BEP20 ox2 = BEP20(0xE3Ca443c9fd7AF40A2B5a95d43207E763e56005F);
    constructor() {
        uint timestamp = block.timestamp;
        lastmonth = DateTime.getMonth(timestamp) == 1 ? 12 : (DateTime.getMonth(timestamp) - 1);
        lastyear = lastmonth == 12 ? (DateTime.getYear(timestamp) - 1 ) : DateTime.getYear(timestamp);
    }
    function addMember(address member,uint value) public onlyOwner {
        uint timestamp = block.timestamp;
        totalAllocation += value;
        require(totalAllocation <= amount,"max value allocated !");
        require(member != owner(),"owner cannot member !");
        require(members[member].member == address(0),"member already exist !");
        members[member].member = member;
        members[member].value = value;
        members[member].lastmonth = DateTime.getMonth(timestamp) == 1 ? 12 : (DateTime.getMonth(timestamp) - 1);
        members[member].lastyear = lastmonth == 12 ? (DateTime.getYear(timestamp) - 1 ) : DateTime.getYear(timestamp);
    }

    function removeMember(address member) public onlyOwner {
        require(members[member].member != address(0),"member does not exist !");
        uint value = members[member].value;
        delete members[member];
        totalAllocation -=value;
    }
    function getremainingmonths() public view returns (uint) {
        uint timestamp = block.timestamp;
        uint month;
        uint currentyear = DateTime.getYear(timestamp);
        uint currentmonth = DateTime.getMonth(timestamp);
        uint totalyears = currentyear - lastyear;
        if(currentmonth < lastmonth){
            uint remainigmonths = (lastmonth - currentmonth);
            month = ((totalyears * 12) - remainigmonths) - 1;
        } else {
            month = ((totalyears * 12) + (currentmonth - lastmonth)) - 1;
        }
        return (month);
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
        return (month);
    }
    function claimReward() public onlyOwner {
        uint timestamp = block.timestamp;
        uint month = getremainingmonths();
        uint value = amount - totalAllocation;
        require(value != 0,"all tokens allocated !");
        require(month > 0 , "timestamp exeeds");
        if (month > 0) {
            uint256 ox2balance = ox2.balanceOf(address(this));
            require(ox2balance > 0 , "balance exeeds");
            if (ox2balance < value*month) {
                ox2.transfer(owner(), ox2balance);
            } else {
                ox2.transfer(owner(), value * month);
            }
            uint currentmonth = DateTime.getMonth(timestamp);
            lastyear = DateTime.getYear(timestamp);
            if(currentmonth == 1){
                lastyear = (DateTime.getYear(timestamp) - 1);
                lastmonth = 12;
            }else {
                lastyear = DateTime.getYear(timestamp);
                lastmonth = currentmonth - 1;
            }
        }
    }
    function claimMemberReward() public {
        address member = msg.sender;
        require(members[member].member != address(0),"beep, you're not member !");
        require(members[member].member == member,"beep, you're not member !");
        uint value = members[member].value;
        uint timestamp = block.timestamp;
        uint month = getremainingmonths(member);
        require(month > 0 , "timestamp exeeds");
        if (month > 0) {
            uint256 ox2balance = ox2.balanceOf(address(this));
            require(ox2balance > 0 , "balance exeeds");
            if (ox2balance < value*month) {
                ox2.transfer(member, ox2balance);
            } else {
                ox2.transfer(member, value * month);
            }
            uint currentmonth = DateTime.getMonth(timestamp);
            members[member].lastyear = DateTime.getYear(timestamp);
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