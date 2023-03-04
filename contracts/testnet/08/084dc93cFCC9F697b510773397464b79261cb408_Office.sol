//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "./DateTime.sol";

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address payable) {
        return payable(_owner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Office is Context, Ownable, DateTime {
    using SafeMath for uint256;
    using SafeMath for uint16;

    event REGISTRATION(address user, address parent);
    event WITHDRAW_REF(address user, uint256 amount);
    event WITHDRAW_BODY(address user, uint256 amount);
    event WITHDRAW_INCOME(address user, uint256 amount);
    event REINVEST(address user, uint256 amount);
    event INVEST(address user, uint256 amount);
    event START_WORK(address user);

    uint256 public DIVISOR = 1000;

    uint public withdrawCommission;

    uint public firstLineReferralPercent = 10;
    uint public secondLineReferralPercent = 3;
    uint public thirdLineReferralPercent = 2;
    uint public fourthLineReferralPercent = 1;
    uint public fifthLineReferralPercent = 1;

    uint public changePercentTime = 30;

    uint256 public countUsers;
    uint256 public countInvest;

    bool public initialized = false;

    address payable public ceoAddress;

    struct LineInfo {
        uint256 usersCount;
        uint256 investAmount;
    }

    mapping (uint16 => uint16) public percents;
    mapping (address => Worker) public users;

    struct Worker {
        uint16 level;
        uint256 claimDate;
        uint256 timeZone;
        uint256 refAmount;
        uint256 balance;
        uint16 percent;
        address parent;
        uint256 activateTime;
        uint256 currentBalance;
        uint256 totalIncome;
        uint256 totalRefAmount;
        uint256 lastStart;
        uint256 lastEnd;
        LineInfo[6] lineInformation;
        uint256 teamIncome;
    }

    constructor() {
        ceoAddress = payable(msg.sender);
        withdrawCommission = 10;
        countUsers = 0;
        percents[1] = 12;
        percents[2] = 13;
        percents[3] = 14;
        percents[4] = 15;
        percents[5] = 16;
        percents[6] = 17;
    }

    function getOwner() external view returns (address payable) {
        return owner();
    }

    function init() public onlyOwner {
        users[owner()].activateTime = block.timestamp;
        users[owner()].parent = owner();
        users[owner()].level = 1;
        users[owner()].percent = percents[1];
        users[owner()].claimDate = block.timestamp;
        users[owner()].timeZone = 3 * 3600;
        initialized = true;
    }

    function getLineInformation(address _user, uint8 _level) public view returns(LineInfo memory) {
        Worker memory user = users[_user];
        return user.lineInformation[_level];
    }

    function getCeoCommission(uint256 _amount) private view returns(uint256) {
        return _amount.mul(withdrawCommission).div(100);
    }

    function getParent(address _user) public view returns (address) {
        address parent = users[_user].parent;
        return parent;
    }

    function setCeoAddress(address newCeoAddress) public onlyOwner {
        require(newCeoAddress != address(0), "newCeoAddress: new ceo address is the zero address");
        ceoAddress = payable(newCeoAddress);
    }

    function setWithdrawCommissionPercent(uint _newCommission) public onlyOwner {
        require(_newCommission >= 0, 'Commission should be more then or equal 0');
        require(_newCommission <= 30, 'Commission should be less then or equal 30');
        withdrawCommission = _newCommission;
    }

    function getWorker() public view returns(Worker memory) {
        return users[msg.sender];
    }

    function activateUser(uint256 _time, address _parent) public {
        address _user = msg.sender;
        require(users[_user].activateTime == 0, 'User has been activated');
        require(users[_parent].activateTime > 0, 'Error parent');
        require(_parent != _user, 'User equal parent');
        uint256 _now = block.timestamp;
        users[_user].level = 1;
        users[_user].claimDate = _now;
        users[_user].timeZone = _time;
        users[_user].percent = percents[1];
        users[_user].parent = _parent;
        users[_user].activateTime = _now;

        addUsersToStructure(_parent);
        countUsers = countUsers + 1;
        emit REGISTRATION(_user, _parent);
    }

    function addUsersToStructure(address _parent) private {
        users[_parent].lineInformation[1].usersCount = users[_parent].lineInformation[1].usersCount + 1;

        if(_parent == owner()) return;
        address _newParent = users[_parent].parent;
        users[_newParent].lineInformation[2].usersCount = users[_newParent].lineInformation[2].usersCount + 1;

        if(_newParent == owner()) return;
        _newParent = users[_newParent].parent;
        users[_newParent].lineInformation[3].usersCount = users[_newParent].lineInformation[3].usersCount + 1;

        if(_newParent == owner()) return;
        _newParent = users[_newParent].parent;
        users[_newParent].lineInformation[4].usersCount = users[_newParent].lineInformation[4].usersCount + 1;

        if(_newParent == owner()) return;
        _newParent = users[_newParent].parent;
        users[_newParent].lineInformation[5].usersCount = users[_newParent].lineInformation[5].usersCount + 1;
    }

    function addTeamIncomeToStructure(address _parent, uint256 _amount) private {
        users[_parent].teamIncome = users[_parent].teamIncome + _amount;

        if(_parent == owner()) return;
        address _newParent = users[_parent].parent;
        users[_newParent].teamIncome = users[_newParent].teamIncome + _amount;

        if(_newParent == owner()) return;
        _newParent = users[_newParent].parent;
        users[_newParent].teamIncome = users[_newParent].teamIncome + _amount;

        if(_newParent == owner()) return;
        _newParent = users[_newParent].parent;
        users[_newParent].teamIncome = users[_newParent].teamIncome + _amount;

        if(_newParent == owner()) return;
        _newParent = users[_newParent].parent;
        users[_newParent].teamIncome = users[_newParent].teamIncome + _amount;
    }

    function addInvestToStructure(address _parent, uint256 _amount) private {
        users[_parent].lineInformation[1].investAmount = users[_parent].lineInformation[1].investAmount + _amount;

        if(_parent == owner()) return;
        address _newParent = users[_parent].parent;
        users[_newParent].lineInformation[2].investAmount = users[_newParent].lineInformation[2].investAmount + _amount;

        if(_newParent == owner()) return;
        _newParent = users[_newParent].parent;
        users[_newParent].lineInformation[3].investAmount = users[_newParent].lineInformation[3].investAmount + _amount;

        if(_newParent == owner()) return;
        _newParent = users[_newParent].parent;
        users[_newParent].lineInformation[4].investAmount = users[_newParent].lineInformation[4].investAmount + _amount;

        if(_newParent == owner()) return;
        _newParent = users[_newParent].parent;
        users[_newParent].lineInformation[5].investAmount = users[_newParent].lineInformation[5].investAmount + _amount;
    }

    function invest() public payable {
        address _user = msg.sender;
        uint256 _amount = msg.value;
        require(users[_user].activateTime > 0, 'User not active');
        users[_user].balance = (users[_user].balance).add(getAmountAfterChargeCommission(_amount));
        addInvestToStructure(users[_user].parent, _amount);
        createReferralIncome(users[_user].parent, _amount);
        countInvest = countInvest + _amount;

        emit INVEST(_user, _amount);
    }

    function canStart(address _user) public view returns(bool) {
        require(users[_user].activateTime > 0, 'User not active');
        uint256 _now = block.timestamp;
        uint256 _userTime = _now + users[_user].timeZone;
        if (_userTime < users[_user].lastEnd) return false;
        if (users[_user].balance == 0) return false;
        uint256 _hour = DateTime.getHour(_userTime);
        if (_hour < 9 || _hour > 18) return false;
        return true;
    }

    function getLoops(address _user) public view returns(uint256) {
        uint256 _now = block.timestamp;
        return DateTime.getHour(_now);
    }

    function canWithdraw(address _user) public view returns(bool) {
        require(users[_user].activateTime > 0, 'User not active');
        uint256 _now = block.timestamp;
        uint256 _userTime = _now + users[_user].timeZone;
        uint256 _hour = DateTime.getHour(_userTime);
        if (_hour < 9 || _hour > 18) return true;
        return false;
    }

    function startWork() public {
        address _user = msg.sender;
        uint256 _now = block.timestamp + users[_user].timeZone;
        require(canStart(_user), 'Cant start now');
        require(!canWithdraw(_user), 'Cant start now');
        require(users[_user].lastEnd < _now, 'Error time');
        updatePercent(_user);
        uint16 _cYear = DateTime.getYear(_now);
        uint8 _cMonth = DateTime.getMonth(_now);
        uint8 _cDay = DateTime.getDay(_now);

        uint256 _finishTime = DateTime.toTimestamp(_cYear, _cMonth, _cDay, 18, 0, 0);
        uint256 _startTime = _finishTime - 28800;
        uint256 time;
        uint256 amount;
        if (_now > _startTime) {
            time = _now;
            amount = users[_user].balance.mul(users[_user].percent).div(DIVISOR);
            amount = amount / 28800 * (_finishTime - time);
        } else {
            time = _startTime;
            amount = users[_user].balance.mul(users[_user].percent).div(DIVISOR);
        }
        users[_user].lastStart = time;
        users[_user].lastEnd = _finishTime;
        users[_user].currentBalance = users[_user].currentBalance + amount;
        users[_user].totalIncome = users[_user].totalIncome + amount;
        addTeamIncomeToStructure(users[_user].parent, amount);

        emit START_WORK(_user);
    }

    function reinvest() public {
        address _user = msg.sender;
        require(canWithdraw(_user), 'Cant start now');
        uint256 _amount = users[_user].currentBalance;
        users[_user].currentBalance = 0;
        users[_user].balance = (users[_user].balance).add(getAmountAfterChargeCommission(_amount));
        addInvestToStructure(users[_user].parent, _amount);
        createReferralIncome(users[_user].parent, _amount);

        countInvest = countInvest + _amount;
        emit REINVEST(_user, _amount);
    }

    function reinvestRef() public {
        address _user = msg.sender;
        require(canWithdraw(_user), 'Cant start now');
        uint256 _amount = users[_user].refAmount;
        users[_user].refAmount = 0;
        users[_user].balance = (users[_user].balance).add(getAmountAfterChargeCommission(_amount));
        addInvestToStructure(users[_user].parent, _amount);
        createReferralIncome(users[_user].parent, _amount);

        countInvest = countInvest + _amount;
        emit REINVEST(_user, _amount);
    }

    function updatePercent(address _user) private {
        uint256 _now = block.timestamp;
        uint256 diff = (_now - (users[_user].activateTime)) / DateTime.DAY_IN_SECONDS;
        if (diff >= 150) {
            users[_user].level = 6;
            users[_user].percent = percents[6];
            return;
        } else if (diff >= 120) {
            users[_user].level = 5;
            users[_user].percent = percents[5];
            return;
        } else if (diff >= 90) {
            users[_user].level = 4;
            users[_user].percent = percents[4];
            return;
        } else if (diff >= 60) {
            users[_user].level = 3;
            users[_user].percent = percents[3];
            return;
        } else if (diff >= 30) {
            users[_user].level = 2;
            users[_user].percent = percents[2];
            return;
        } else {
            users[_user].level = 1;
            users[_user].percent = percents[1];
            return;
        }
    }

    function getAmountAfterChargeCommission(uint256 _amount) private view returns(uint256) {
        uint256 _percent = firstLineReferralPercent
        .add(secondLineReferralPercent)
        .add(thirdLineReferralPercent)
        .add(fourthLineReferralPercent)
        .add(fifthLineReferralPercent);
        return _amount.mul(100 - _percent).div(100);
    }

    function makeRefIncome(address toUser, uint256 amount, uint256 percent) private {
        uint256 toUserAmount = (users[toUser].balance).mul(percent).div(100);
        if (amount > toUserAmount) {
            users[owner()].refAmount = users[owner()].refAmount + (amount - toUserAmount);
            users[owner()].totalRefAmount = users[owner()].totalRefAmount + (amount - toUserAmount);
            amount = toUserAmount;
        }
        users[toUser].totalRefAmount = users[toUser].totalRefAmount + amount;
        users[toUser].refAmount = users[toUser].refAmount + amount;
    }

    function createReferralIncome(address parent, uint256 amount) private {
        address currentParent = parent;
        makeRefIncome(currentParent, amount.mul(firstLineReferralPercent).div(100), firstLineReferralPercent);

        currentParent = users[currentParent].parent;
        makeRefIncome(currentParent, amount.mul(secondLineReferralPercent).div(100), secondLineReferralPercent);

        currentParent = users[currentParent].parent;
        makeRefIncome(currentParent, amount.mul(thirdLineReferralPercent).div(100), thirdLineReferralPercent);

        currentParent = users[currentParent].parent;
        makeRefIncome(currentParent, amount.mul(fourthLineReferralPercent).div(100), fourthLineReferralPercent);

        currentParent = users[currentParent].parent;
        makeRefIncome(currentParent, amount.mul(fifthLineReferralPercent).div(100), fifthLineReferralPercent);
    }

    function withdraw() public {
        require(canWithdraw(msg.sender), 'Error time');
        address payable user = payable(msg.sender);

        uint256 amountOnContract = address(this).balance;
        uint256 amountToWithdraw = min(users[user].currentBalance, amountOnContract);

        users[user].currentBalance = 0;

        uint256 fee = amountToWithdraw.mul(withdrawCommission).div(100);
        owner().transfer(fee);
        user.transfer(amountToWithdraw.sub(fee));

        emit WITHDRAW_INCOME(user, amountToWithdraw.sub(fee));
    }

    function withdrawDeposit() public {
        address payable user = payable(msg.sender);
        uint256 _now = block.timestamp;
        require(canWithdraw(msg.sender), 'Error time');
        require((_now).sub(users[user].activateTime) > (30 * DateTime.DAY_IN_SECONDS), 'to early');

        uint256 amountOnContract = address(this).balance;
        uint256 amountToWithdraw = min(users[user].balance, amountOnContract);

        users[user].balance = 0;

        uint256 fee = amountToWithdraw.mul(withdrawCommission).div(100);

        owner().transfer(fee);
        user.transfer(amountToWithdraw.sub(fee));

        emit WITHDRAW_BODY(user, amountToWithdraw.sub(fee));
    }

    function withdrawRef() public {
        address payable user = payable(msg.sender);

        uint256 amountOnContract = address(this).balance;
        uint256 refAmount = users[user].refAmount;
        users[user].refAmount = 0;
        uint256 amountToWithdraw = min(amountOnContract, refAmount);

        uint256 fee = amountToWithdraw.mul(withdrawCommission).div(100);
        owner().transfer(fee);
        user.transfer(amountToWithdraw.sub(fee));

        emit WITHDRAW_REF(user, amountToWithdraw.sub(fee));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

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

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;

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

    function leapYearsBefore(uint year) public pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
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

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint secondsInMonth;
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

    function getYear(uint timestamp) public pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
        uint16 i;

        // Year
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            }
            else {
                timestamp += YEAR_IN_SECONDS;
            }
        }

        // Month
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        }
        else {
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
}