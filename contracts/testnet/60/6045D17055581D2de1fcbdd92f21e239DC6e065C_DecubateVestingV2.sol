// SPDX-License-Identifier: MIT

//** Decubate vesting Contract */
//** Author Aceson : Decubate Vesting Contract 2022.4 */

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./libraries/DateTime.sol";

contract DecubateVestingV2 is Ownable, DateTime {
  using SafeMath for uint256;

  enum Type {
    Linear,
    Monthly,
    Interval
  }

  struct VestingInfo {
    string name;
    uint256 cliff;
    uint256 start;
    uint256 duration;
    uint256 initialUnlockPercent;
    bool revocable;
    Type vestType;
    uint256 interval;
    uint256 unlockPerInterval;
    uint256[] timestamps;
  }

  struct VestingPool {
    string name;
    uint256 cliff;
    uint256 start;
    uint256 duration;
    uint256 initialUnlockPercent;
    WhitelistInfo[] whitelistPool;
    mapping(address => HasWhitelist) hasWhitelist;
    bool revocable;
    Type vestType;
    uint256 interval;
    uint256 unlockPerInterval;
    uint256[] timestamps;
  }

  struct MaxTokenTransferValue {
    uint256 amount;
    bool active;
  }

  /**
   *
   * @dev WhiteInfo is the struct type which store whitelist information
   *
   */
  struct WhitelistInfo {
    address wallet;
    uint256 dcbAmount;
    uint256 distributedAmount;
    uint256 joinDate;
    uint256 revokeDate;
    bool revoke;
    bool disabled;
  }

  struct HasWhitelist {
    uint256 arrIdx;
    bool active;
  }

  MaxTokenTransferValue public maxTokenTransfer;
  VestingPool[] public vestingPools;

  IERC20 private token;

  event AddToken(address indexed token);

  event Claim(address indexed token, uint256 amount, uint256 indexed option, uint256 time);

  event AddWhitelist(address indexed wallet);

  event Revoked(address indexed wallet);

  event StatusChanged(address indexed wallet, bool status);

  modifier optionExists(uint256 _option) {
    require(_option < vestingPools.length, "Vesting option does not exist");
    _;
  }

  modifier userInWhitelist(uint256 _option, address _wallet) {
    require(_option < vestingPools.length, "Vesting option does not exist");
    require(vestingPools[_option].hasWhitelist[_wallet].active, "User is not in whitelist");
    _;
  }

  constructor(address _token) {
    token = IERC20(_token);
  }

  function addVestingStrategy(
    string memory _name,
    uint256 _cliff,
    uint256 _start,
    uint256 _duration,
    uint256 _initialUnlockPercent,
    bool _revocable,
    uint256 _interval,
    uint16 _unlockPerInterval,
    uint8 _monthGap,
    Type _type
  ) external onlyOwner returns (bool) {
    VestingPool storage newStrategy = vestingPools.push();

    newStrategy.cliff = _start.add(_cliff);
    newStrategy.name = _name;
    newStrategy.start = _start;
    newStrategy.duration = _duration;
    newStrategy.initialUnlockPercent = _initialUnlockPercent;
    newStrategy.revocable = _revocable;
    newStrategy.vestType = _type;

    if (_type == Type.Interval) {
      require(_interval > 0, "Invalid interval");
      require(_unlockPerInterval > 0, "Invalid unlock per interval");

      newStrategy.interval = _interval;
      newStrategy.unlockPerInterval = _unlockPerInterval;
    } else if (_type == Type.Monthly) {
      require(_unlockPerInterval > 0, "Invalid unlock per interval");
      require(_monthGap > 0, "Invalid month gap");

      newStrategy.unlockPerInterval = _unlockPerInterval;

      uint8 day = getDay(newStrategy.cliff);
      uint8 month = getMonth(newStrategy.cliff);
      uint16 year = getYear(newStrategy.cliff);

      for (uint16 i = 0; i <= 1000; i += _unlockPerInterval) {
        month += _monthGap;

        if (month > 12) {
          month = 1;
          year++;
        }

        uint256 time = toTimestamp(year, month, day);
        newStrategy.timestamps.push(time);
      }
    }

    return true;
  }

  function setVestingStrategy(
    uint256 _strategy,
    string memory _name,
    uint256 _cliff,
    uint256 _start,
    uint256 _duration,
    uint256 _initialUnlockPercent,
    bool _revocable,
    uint256 _interval,
    uint16 _unlockPerInterval
  ) external onlyOwner returns (bool) {
    require(_strategy < vestingPools.length, "Strategy does not exist");

    VestingPool storage vest = vestingPools[_strategy];

    require(vest.vestType != Type.Monthly, "Changing monthly not supported");

    vest.cliff = _start.add(_cliff);
    vest.name = _name;
    vest.start = _start;
    vest.duration = _duration;
    vest.initialUnlockPercent = _initialUnlockPercent;
    vest.revocable = _revocable;

    if (vest.vestType == Type.Interval) {
      vest.interval = _interval;
      vest.unlockPerInterval = _unlockPerInterval;
    }

    return true;
  }

  function setMaxTokenTransfer(uint256 _amount, bool _active) external onlyOwner returns (bool) {
    maxTokenTransfer.amount = _amount;
    maxTokenTransfer.active = _active;
    return true;
  }

  function setToken(address _addr) external onlyOwner returns (bool) {
    token = IERC20(_addr);
    return true;
  }

  function batchAddWhitelist(
    address[] memory wallets,
    uint256[] memory amounts,
    uint256 option
  ) external onlyOwner returns (bool) {
    require(wallets.length == amounts.length, "Sizes of inputs do not match");

    for (uint256 i = 0; i < wallets.length; i++) {
      addWhitelist(wallets[i], amounts[i], option);
    }

    return true;
  }

  /**
   *
   * @dev set the address as whitelist user address
   *
   * @param {address} address of the user
   *
   * @return {bool} return status of the whitelist
   *
   */
  function setWhitelist(
    address _wallet,
    uint256 _dcbAmount,
    uint256 _option
  ) external onlyOwner userInWhitelist(_option, _wallet) returns (bool) {
    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo storage info = vestingPools[_option].whitelistPool[idx];
    info.dcbAmount = _dcbAmount;

    return true;
  }

  function revoke(uint256 _option, address _wallet)
    external
    onlyOwner
    userInWhitelist(_option, _wallet)
  {
    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo storage whitelist = vestingPools[_option].whitelistPool[idx];

    require(vestingPools[_option].revocable, "Strategy is not revocable");
    require(!whitelist.revoke, "already revoked");

    if (calculateReleasableAmount(_option, _wallet) > 0) {
      claimDistribution(_option, _wallet);
    }

    whitelist.revoke = true;
    whitelist.revokeDate = block.timestamp;

    emit Revoked(_wallet);
  }

  function setVesting(
    uint256 _option,
    address _wallet,
    bool _status
  ) external onlyOwner userInWhitelist(_option, _wallet) {
    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo storage whitelist = vestingPools[_option].whitelistPool[idx];

    whitelist.disabled = _status;

    emit StatusChanged(_wallet, _status);
  }

  function transferToken(address _addr, uint256 _amount) external onlyOwner returns (bool) {
    IERC20 _token = IERC20(_addr);
    bool success = _token.transfer(address(owner()), _amount);
    return success;
  }

  function getWhitelist(uint256 _option, address _wallet)
    external
    view
    userInWhitelist(_option, _wallet)
    returns (WhitelistInfo memory)
  {
    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    return vestingPools[_option].whitelistPool[idx];
  }

  function getAllVestingPools() external view returns (VestingInfo[] memory) {
    VestingInfo[] memory infoArr = new VestingInfo[](vestingPools.length);

    for (uint256 i = 0; i < vestingPools.length; i++) {
      infoArr[i] = getVestingInfo(i);
    }

    return infoArr;
  }

  function getToken() external view returns (address) {
    return address(token);
  }

  function getTotalToken(address _addr) external view returns (uint256) {
    IERC20 _token = IERC20(_addr);
    return _token.balanceOf(address(this));
  }

  function hasWhitelist(uint256 _option, address _wallet) external view returns (bool) {
    return vestingPools[_option].hasWhitelist[_wallet].active;
  }

  function getVestAmount(uint256 _option, address _wallet) external view returns (uint256) {
    return calculateVestAmount(_option, _wallet);
  }

  function getReleasableAmount(uint256 _option, address _wallet) external view returns (uint256) {
    return calculateReleasableAmount(_option, _wallet);
  }

  function getWhitelistPool(uint256 _option)
    external
    view
    optionExists(_option)
    returns (WhitelistInfo[] memory)
  {
    return vestingPools[_option].whitelistPool;
  }

  function claimDistribution(uint256 _option, address _wallet) public returns (bool) {
    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo storage whitelist = vestingPools[_option].whitelistPool[idx];

    require(!whitelist.disabled, "User is disabled from claiming token");

    uint256 releaseAmount = calculateReleasableAmount(_option, _wallet);

    require(releaseAmount > 0, "Zero amount to claim");

    if (maxTokenTransfer.active && releaseAmount > maxTokenTransfer.amount) {
      releaseAmount = maxTokenTransfer.amount;
    }

    whitelist.distributedAmount = whitelist.distributedAmount.add(releaseAmount);

    token.transfer(_wallet, releaseAmount);

    emit Claim(_wallet, releaseAmount, _option, block.timestamp);

    return true;
  }

  function addWhitelist(
    address _wallet,
    uint256 _dcbAmount,
    uint256 _option
  ) public onlyOwner optionExists(_option) returns (bool) {
    HasWhitelist storage whitelist = vestingPools[_option].hasWhitelist[_wallet];
    require(!whitelist.active, "Whitelist already available");

    WhitelistInfo[] storage pool = vestingPools[_option].whitelistPool;

    whitelist.active = true;
    whitelist.arrIdx = pool.length;

    pool.push(
      WhitelistInfo({
        wallet: _wallet,
        dcbAmount: _dcbAmount,
        distributedAmount: 0,
        joinDate: block.timestamp,
        revokeDate: 0,
        revoke: false,
        disabled: false
      })
    );

    emit AddWhitelist(_wallet);

    return true;
  }

  function getVestingInfo(uint256 _strategy)
    public
    view
    optionExists(_strategy)
    returns (VestingInfo memory)
  {
    return
      VestingInfo({
        name: vestingPools[_strategy].name,
        cliff: vestingPools[_strategy].cliff,
        start: vestingPools[_strategy].start,
        duration: vestingPools[_strategy].duration,
        initialUnlockPercent: vestingPools[_strategy].initialUnlockPercent,
        revocable: vestingPools[_strategy].revocable,
        vestType: vestingPools[_strategy].vestType,
        interval: vestingPools[_strategy].interval,
        unlockPerInterval: vestingPools[_strategy].unlockPerInterval,
        timestamps: vestingPools[_strategy].timestamps
      });
  }

  function calculateVestAmount(uint256 _option, address _wallet)
    internal
    view
    userInWhitelist(_option, _wallet)
    returns (uint256 amount)
  {
    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    WhitelistInfo memory whitelist = vestingPools[_option].whitelistPool[idx];
    VestingPool storage vest = vestingPools[_option];

    // initial unlock
    uint256 initial = whitelist.dcbAmount.mul(vest.initialUnlockPercent).div(1000);

    if (whitelist.revoke) {
      return whitelist.distributedAmount;
    }

    if (block.timestamp < vest.start) {
      return 0;
    } else if (block.timestamp >= vest.start && block.timestamp < vest.cliff) {
      return initial;
    } else if (block.timestamp >= vest.cliff) {
      if (vestingPools[_option].vestType == Type.Interval) {
        return calculateVestAmountForInterval(whitelist, vest);
      } else if (vestingPools[_option].vestType == Type.Linear) {
        return calculateVestAmountForLinear(whitelist, vest);
      } else {
        return calculateVestAmountForMonthly(whitelist, vest);
      }
    }
  }

  function calculateVestAmountForLinear(WhitelistInfo memory whitelist, VestingPool storage vest)
    internal
    view
    returns (uint256)
  {
    uint256 initial = whitelist.dcbAmount.mul(vest.initialUnlockPercent).div(1000);

    uint256 remaining = whitelist.dcbAmount.sub(initial);

    if (block.timestamp >= vest.cliff.add(vest.duration)) {
      return whitelist.dcbAmount;
    } else {
      return initial + remaining.mul(block.timestamp.sub(vest.cliff)).div(vest.duration);
    }
  }

  function calculateVestAmountForInterval(WhitelistInfo memory whitelist, VestingPool storage vest)
    internal
    view
    returns (uint256)
  {
    uint256 initial = whitelist.dcbAmount.mul(vest.initialUnlockPercent).div(1000);
    uint256 remaining = whitelist.dcbAmount.sub(initial);

    uint256 intervalsPassed = (block.timestamp.sub(vest.cliff)).div(vest.interval);
    uint256 totalUnlocked = intervalsPassed.mul(vest.unlockPerInterval);

    if (totalUnlocked >= 1000) {
      return whitelist.dcbAmount;
    } else {
      return initial + remaining.mul(totalUnlocked).div(1000);
    }
  }

  function calculateVestAmountForMonthly(WhitelistInfo memory whitelist, VestingPool storage vest)
    internal
    view
    returns (uint256)
  {
    uint256 initial = whitelist.dcbAmount.mul(vest.initialUnlockPercent).div(1000);
    uint256 remaining = whitelist.dcbAmount.sub(initial);

    if (block.timestamp > vest.timestamps[vest.timestamps.length - 1]) {
      return whitelist.dcbAmount;
    } else {
      uint256 multi = findCurrentTimestamp(vest.timestamps, block.timestamp);
      uint256 totalUnlocked = multi.mul(vest.unlockPerInterval);

      return initial + remaining.mul(totalUnlocked).div(1000);
    }
  }

  function calculateReleasableAmount(uint256 _option, address _wallet)
    internal
    view
    userInWhitelist(_option, _wallet)
    returns (uint256)
  {
    uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
    return
      calculateVestAmount(_option, _wallet).sub(
        vestingPools[_option].whitelistPool[idx].distributedAmount
      );
  }

  function findCurrentTimestamp(uint256[] memory timestamps, uint256 target)
    internal
    pure
    returns (uint256 pos)
  {
    uint256 last = timestamps.length;
    uint256 first = 0;
    uint256 mid = 0;

    if (target < timestamps[first]) {
      return 0;
    }

    if (target >= timestamps[last - 1]) {
      return last - 1;
    }

    while (first < last) {
      mid = (first + last) / 2;

      if (timestamps[mid] == target) {
        return mid + 1;
      }

      if (target < timestamps[mid]) {
        if (mid > 0 && target > timestamps[mid - 1]) {
          return mid;
        }

        last = mid;
      } else {
        if (mid < last - 1 && target < timestamps[mid + 1]) {
          return mid + 1;
        }

        first = mid + 1;
      }
    }
    return mid + 1;
  }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract DateTime {
  /*
   *  Date and Time utilities for ethereum contracts
   *
   */
  struct _DateTime {
    uint16 year;
    uint8 month;
    uint8 day;
    uint8 hour;
    uint8 minute;
    uint8 second;
    uint8 weekday;
  }

  uint256 internal constant DAY_IN_SECONDS = 86400;
  uint256 internal constant YEAR_IN_SECONDS = 31536000;
  uint256 internal constant LEAP_YEAR_IN_SECONDS = 31622400;

  uint256 internal constant HOUR_IN_SECONDS = 3600;
  uint256 internal constant MINUTE_IN_SECONDS = 60;

  uint16 internal constant ORIGIN_YEAR = 1970;

  function isLeapYear(uint16 year) public pure returns (bool) {
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

  function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
    if (
      month == 1 ||
      month == 3 ||
      month == 5 ||
      month == 7 ||
      month == 8 ||
      month == 10 ||
      month == 12
    ) {
      return 31;
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
      return 30;
    } else if (isLeapYear(year)) {
      return 29;
    } else {
      return 28;
    }
  }

  function getYear(uint256 timestamp) public pure returns (uint16) {
    uint256 secondsAccountedFor = 0;
    uint16 year;
    uint256 numLeapYears;

    // Year
    year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
    numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

    secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
    secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

    while (secondsAccountedFor > timestamp) {
      if (isLeapYear(uint16(year - 1))) {
        secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
      } else {
        secondsAccountedFor -= YEAR_IN_SECONDS;
      }
      year -= 1;
    }
    return year;
  }

  function getMonth(uint256 timestamp) public pure returns (uint8) {
    return parseTimestamp(timestamp).month;
  }

  function getDay(uint256 timestamp) public pure returns (uint8) {
    return parseTimestamp(timestamp).day;
  }

  function getHour(uint256 timestamp) public pure returns (uint8) {
    return uint8((timestamp / 60 / 60) % 24);
  }

  function getMinute(uint256 timestamp) public pure returns (uint8) {
    return uint8((timestamp / 60) % 60);
  }

  function getSecond(uint256 timestamp) public pure returns (uint8) {
    return uint8(timestamp % 60);
  }

  function getWeekday(uint256 timestamp) public pure returns (uint8) {
    return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
  }

  function toTimestamp(
    uint16 year,
    uint8 month,
    uint8 day
  ) public pure returns (uint256 timestamp) {
    return toTimestamp(year, month, day, 0, 0, 0);
  }

  function toTimestamp(
    uint16 year,
    uint8 month,
    uint8 day,
    uint8 hour
  ) public pure returns (uint256 timestamp) {
    return toTimestamp(year, month, day, hour, 0, 0);
  }

  function toTimestamp(
    uint16 year,
    uint8 month,
    uint8 day,
    uint8 hour,
    uint8 minute
  ) public pure returns (uint256 timestamp) {
    return toTimestamp(year, month, day, hour, minute, 0);
  }

  function toTimestamp(
    uint16 year,
    uint8 month,
    uint8 day,
    uint8 hour,
    uint8 minute,
    uint8 second
  ) public pure returns (uint256 timestamp) {
    uint16 i;

    // Year
    for (i = ORIGIN_YEAR; i < year; i++) {
      if (isLeapYear(i)) {
        timestamp += LEAP_YEAR_IN_SECONDS;
      } else {
        timestamp += YEAR_IN_SECONDS;
      }
    }

    // Month
    uint8[12] memory monthDayCounts;
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

    // Day
    timestamp += DAY_IN_SECONDS * (day - 1);

    // Hour
    timestamp += HOUR_IN_SECONDS * (hour);

    // Minute
    timestamp += MINUTE_IN_SECONDS * (minute);

    // Second
    timestamp += second;

    return timestamp;
  }

  function parseTimestamp(uint256 timestamp) internal pure returns (_DateTime memory dt) {
    uint256 secondsAccountedFor = 0;
    uint256 buf;
    uint8 i;

    // Year
    dt.year = getYear(timestamp);
    buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

    secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
    secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

    // Month
    uint256 secondsInMonth;
    for (i = 1; i <= 12; i++) {
      secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
      if (secondsInMonth + secondsAccountedFor > timestamp) {
        dt.month = i;
        break;
      }
      secondsAccountedFor += secondsInMonth;
    }

    // Day
    for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
      if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
        dt.day = i;
        break;
      }
      secondsAccountedFor += DAY_IN_SECONDS;
    }

    // Hour
    dt.hour = getHour(timestamp);

    // Minute
    dt.minute = getMinute(timestamp);

    // Second
    dt.second = getSecond(timestamp);

    // Day of week.
    dt.weekday = getWeekday(timestamp);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}