/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "pool001");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "pool002");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract USDTPoolPlus is Ownable {

    struct _DateTime {
        uint256 year;
        uint256 month;
        uint256 day;
        uint256 hour;
        uint256 minute;
        uint256 second;
        uint256 weekday;
    }

    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 constant YEAR_IN_SECONDS = 31536000;
    uint256 constant LEAP_YEAR_IN_SECONDS = 31622400;
    uint256 constant HOUR_IN_SECONDS = 3600;
    uint256 constant MINUTE_IN_SECONDS = 60;
    uint256 constant ORIGIN_YEAR = 1970;

    IERC20 public USDT;
    address public WETH;
    mapping(address => bool) public userBlackList;
    mapping(address => bool) public callerList;
    uint256 public swapRate = 100;
    uint256 public swapAllRate = 1000;
    mapping(address => uint256) public defaultMaxAmountList;
    mapping(address => mapping(address => uint256)) public userMaxAmountList;

    constructor(IERC20 _USDT, address _WETH, uint256 _swapRate, uint256 _swapAllRate, uint256 _defaultMaxUSDTAmount, uint256 _defaultMaxEthAmount) {
        USDT = _USDT;
        WETH = _WETH;
        swapRate = _swapRate;
        swapAllRate = _swapAllRate;
        defaultMaxAmountList[address(_USDT)] = _defaultMaxUSDTAmount;
        defaultMaxAmountList[_WETH] = _defaultMaxEthAmount;
    }

    function setUSDT(IERC20 _USDT, address _WETH) public onlyOwner {
        USDT = _USDT;
        WETH = _WETH;
    }

    function setSwapRates(uint256 _swapRate, uint256 _swapAllRate) public onlyOwner {
        swapRate = _swapRate;
        swapAllRate = _swapAllRate;
    }

    function setDefaultMaxAmountList(address _token, uint256 _defaultMaxAmount) public onlyOwner {
        defaultMaxAmountList[_token] = _defaultMaxAmount;
    }

    function setUserMaxAmountList(address _token, address _user, uint256 _userMaxAmount) external onlyOwner {
        userMaxAmountList[_token][_user] = _userMaxAmount;
    }

    function setCallerList(address _user, bool _status) external onlyOwner {
        callerList[_user] = _status;
    }

    function setUserBlackList(address _user, bool _status) external onlyOwner {
        userBlackList[_user] = _status;
    }

    function claimUSDT(address _user, uint256 _amount) external {
        require(callerList[msg.sender], "pool003");
        require(!userBlackList[_user], "pool004");
        if (userMaxAmountList[address(USDT)][_user] == 0) {
            require(_amount <= defaultMaxAmountList[address(USDT)], "pool005");
        } else {
            require(_amount <= userMaxAmountList[address(USDT)][_user], "pool006");
        }
        USDT.transfer(msg.sender, _amount);
    }

    function claimGas(address _user, uint256 _amount) external {
        require(callerList[msg.sender], "pool003");
        require(!userBlackList[_user], "pool004");
        if (userMaxAmountList[WETH][_user] == 0) {
            require(_amount <= defaultMaxAmountList[WETH], "pool005");
        } else {
            require(_amount <= userMaxAmountList[WETH][_user], "pool006");
        }
        payable(msg.sender).transfer(_amount);
    }

    function claimToken(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.transfer(msg.sender, _amount);
    }

    function claimEth(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function isLeapYear(uint256 year) public pure returns (bool) {
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

    function leapYearsBefore(uint256 year) public pure returns (uint256) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint256 month, uint256 year) public pure returns (uint256) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        }
        else if (isLeapYear(year)) {
            return 29;
        }
        else {
            return 28;
        }
    }

    function getYearMonthDay(uint256 _timestamp) public pure returns (uint256) {
        _DateTime memory dt = parseTimestamp(_timestamp + 3600 * 8);
        return dt.year * (10 ** 6) + dt.month * (10 ** 4) + dt.day * 10;
    }

    function parseTimestamp(uint256 timestamp) public pure returns (_DateTime memory dt) {
        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint256 i;

        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        uint256 secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
        dt.hour = getHour(timestamp);
        dt.minute = getMinute(timestamp);
        dt.second = getSecond(timestamp);
        dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint256 timestamp) public pure returns (uint256) {
        uint256 secondsAccountedFor = 0;
        uint256 year;
        uint256 numLeapYears;

        year = uint256(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint256(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint256 timestamp) public pure returns (uint256) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint256 timestamp) public pure returns (uint256) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint256 timestamp) public pure returns (uint256) {
        return uint256((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint256 timestamp) public pure returns (uint256) {
        return uint256((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    receive() external payable {
    }
}