//// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

//import "@pipermerriam/contracts/DateTime.sol";

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

    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 constant YEAR_IN_SECONDS = 31536000;
    uint256 constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint256 constant HOUR_IN_SECONDS = 3600;
    uint256 constant MINUTE_IN_SECONDS = 60;

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

    function leapYearsBefore(uint256 year) public pure returns (uint256) {
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
            }
            else {
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

    function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint256 timestamp) {
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

// ************************************************************************************************************************************************************

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Modifications is Ownable {

    address payable public receiverAdd = payable(msg.sender);
    address payable public marketingAdr = payable(0x222222230703082Ec9fA58a2054D4dF33f3B3E7C);
    address payable public devAdr = payable(0x00000001404200e3921EF55C2Aea3115744D8D53);
    address payable public charityAdr = payable(0x444444444287b961d6045dDA127d2E42a1181EA2);
    address payable public reInvestAdr = payable(0x0000000000000000000000000000000000000000);

    receive() external payable {}

    function transferERC20(ERC20 token, address payable destAddr, uint256 amount, uint decimal) public onlyOwner {
        require(amount <= token.balanceOf(address(this)), "Insufficient funds");
        require(decimal < 19, "Decimal should be smaller then 19");

        while (decimal != 0) {
            decimal--;
            amount *= 10;
        }

        token.transfer(destAddr, amount);
    }

}

// ************************************************************************************************************************************************************

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VirtualUSD is Modifications {

    using SafeMath for uint;

    address public dateTimeAddr = 0x8Fc065565E3e44aef229F1D06aac009D6A524e82;
    DateTime dateTime = DateTime(dateTimeAddr);

    bool public isWhitelistRelease = true; //set to false before release
    bool public isFinalRelease = true; //set to false before release
    bool public isAutoReInvest = false;
    bool public isAutoCollect = false;
    bool public isPaused = false;

    // FEE
    uint8 public devFee = 3; // developer fee
    uint8 public marketingFee = 5; // marketing fee
    uint8 public charityFee = 2; // nature organisation fee
    uint8 public reInvestFee = 0; // own virtual usd pool
    uint8 public autoCollectFee = 10; // auto collect fee will be added to collectFee if auto collect is enabled
    uint8 public autoReInvestFee = 10; // auto re-invest fee is added to reInvestFee if auto re-invest is enabled
    // MECHANICS
    uint8 public daysToRecover = 9; // days to recover to full daily APR after collecting at penalty days
    uint256 public maxDailyReturn = 86400; // maximal daily return APR which can be reached
    uint8 public minStartDailyReturn = 0; // minimal APR will be set to user which attended collection 2 times not by #collectDays
    uint8 public roiReduction = 2; // divide daily max return by 2 everytime user reaches 100% ROI from invested funds
    uint8 public referralRewardPercentage = 25; // percentage from the collected investFee

    mapping(address => uint256) private userBalance;
    mapping(address => uint256) private userGeneratedCoins;
    mapping(address => uint) private investTime;

    uint16 private autoCollectCount;
    mapping(uint => address) public autoCollectAddress;

    uint8 public reInvestCount;
    mapping(uint => address) public reInvestAddresses;

    uint256[] private collectDays = [10, 20, 30]; // days when collecting without penalty is possible
    address[] private _feeFreeWallets = [receiverAdd, marketingAdr, devAdr, charityAdr]; // wallet excluded from absolutely all fees (except blockchain ofc)

    mapping(address => bool) private whitelist;
    mapping(address => address) private referrals;
    mapping(address => bool) public checkCollectAddresses;
    mapping(address => bool) public isReInvestAddress;
    mapping(uint => CollectWallet) public autoCollectAddresses;

    struct CollectWallet {
        address walletAddress;
        address referralAddress;
    }

    function setPause(bool paused) public onlyOwner {
        isPaused = paused;
    }

    function finalRelease() public onlyOwner {
        isFinalRelease = true;
    }

    function whitelistRelease() public onlyOwner {
        isWhitelistRelease = true;
    }

    function contractModerationCheck(address _address) private view {
        require(isWhitelistRelease);
        require(!isPaused);

        if (!isWhitelisted(_address)) {
            require(isFinalRelease);
        }
    }

    // this wallets can interact with the protocol before release.
    function addWhitelist(address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = true;
        }
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelist[_address];
    }
    // TODO: Should be added to invest, collect, reinvest, auto collect, auto reinvest
    //    it should be possible to disable all fees for certain wallets. So, community treasury
    //    can be staked on other protocols to have better sustainability of this platform.
    //    It should be possible to withdraw funds from the contract and deposit the same funds without any fees (check Nr. 5 for fees), if needed an extra treasury wallet should be created.
    function excludeWalletFromFees(address _address, bool _isExcluded) public onlyOwner {
        if (!_isExcluded) {
            for (uint256 i = 0; i < _feeFreeWallets.length; i++) {
                if (_feeFreeWallets[i] == _address) {
                    delete _feeFreeWallets[i];
                }
            }
        } else {
            _feeFreeWallets.push(_address);
        }
    }

    function isWalletExcludedFromFee(address _address) public view returns (bool) {
        for (uint256 i = 0; i < _feeFreeWallets.length; i++) {
            if (_feeFreeWallets[i] == _address) {
                return true;
            }
        }

        return false;
    }

    function onInvest(uint256 _amount) public payable {
        contractModerationCheck(msg.sender);

        if (!isWalletExcludedFromFee(msg.sender)) {
            uint256 _marketingFee = getMarketingFeeValue(_amount);
            uint256 _charityFee = getCharityFeeValue(_amount);

            // TODO: REFERAL FEES SHOULD BE HERE - CURRENTLY ITS NOT IMPLEMENTED
            uint256 _referralFee = getReferralRewardFeeValue(_marketingFee);
            address payable referredWallet;
            // REFERRED ADDRESS SHOULD BE IMPLEMENTED
            referredWallet.transfer(_referralFee);

            marketingAdr.transfer(_marketingFee.sub(_referralFee));
            charityAdr.transfer(_charityFee);

            userBalance[msg.sender] += getGeneratedValue() + _amount.sub(_marketingFee).sub(_charityFee);
        } else {
            userBalance[msg.sender] += getGeneratedValue() + _amount;
        }

        updateTimeStamp();
    }

    // ----------- RE-INVEST MECHANICS ------------

    function onReInvest() public {
        if (!isWalletExcludedFromFee(msg.sender)) {
            uint256 _reInvestFee = getReInvestFeeValue(getGeneratedValue());
            reInvestAdr.transfer(_reInvestFee);
            userBalance[msg.sender] += getGeneratedValue().sub(_reInvestFee);
        } else {
            userBalance[msg.sender] += getGeneratedValue();
        }

        updateTimeStamp();
    }

    // TODO: Logic should be added for this function
    function setAutoReInvest(bool condition, address _reInvestAddress) public payable {
        isAutoReInvest = condition;
        reInvestAddresses[reInvestCount] = _reInvestAddress;
        reInvestCount++;
        isReInvestAddress[_reInvestAddress] = true;
    }

    function setAutoReinvestAddress(address _address) public {
        require(getGeneratedValue() > 0, "No value was generated to invest");
        require(isReInvestAddress[_address] == false, "Address already set");

        reInvestCount++;
        reInvestAddresses[reInvestCount] = _address;
        isReInvestAddress[_address] = true;
    }

    // TODO: EXCLUDE AUTO-REINVEST FROM COLLECT DAYS
    function autoReInvest() public {
        if (!isWalletExcludedFromFee(msg.sender)) {
            uint256 _reInvestFee = getReInvestFeeValue(getGeneratedValue());
            uint256 _autoReInvestFee = getAutoReInvestFeeValue(getGeneratedValue());
            reInvestAdr.transfer(_reInvestFee);
            devAdr.transfer(_autoReInvestFee);

            userBalance[msg.sender] += getGeneratedValue().sub(_reInvestFee).sub(_autoReInvestFee);
        } else {
            userBalance[msg.sender] += getGeneratedValue();
        }

        updateTimeStamp();
    }

    // ----------- END RE-INVEST ------------


    // ----------- COLLECT MECHANICS ------------

    function onCollect() public {
        require(getGeneratedValue() > 0, "No value was generated");

        if (!isWalletExcludedFromFee(msg.sender)) {
            uint256 _devFee = getDevFeeValue(getGeneratedValue());
            uint256 _charityFee = getCharityFeeValue(getGeneratedValue());

            devAdr.transfer(_devFee);
            charityAdr.transfer(_charityFee);

            payable(msg.sender).transfer(getGeneratedValue().sub(SafeMath.add(_devFee, _charityFee)));
        }
        else {
            payable(msg.sender).transfer(getGeneratedValue());
        }

        updateTimeStamp();
    }

    function setAutoCollectAddress(address _address, bool condition) public {
        autoCollectCount++;
        checkCollectAddresses[_address] = condition;
    }

    // Only be investing there is some reward for referrals!
    // TODO: FEE EXCLUDED WALLETS MUST BE ALSO IMPLEMENTED IN AUTO-COLLECT, THERE CAN BE MORE DAYS- LIKE 5,10,15,20...., MAKE IT MORE GENERIC
    function onAutoCollect() public {
        require(dateTime.getDay(block.timestamp) == collectDays[0] || dateTime.getDay(block.timestamp) == collectDays[1] || dateTime.getDay(block.timestamp) == collectDays[2]);
        require(isAutoCollect, "Auto Collect is turned off");

        if (!isWalletExcludedFromFee(msg.sender)) {
            uint256 _devFee = getDevFeeValue(getGeneratedValue()).add(getAutoCollectFeeValue(getGeneratedValue()));
            uint256 _charityFee = getCharityFeeValue(getGeneratedValue());

            devAdr.transfer(_devFee);
            charityAdr.transfer(_charityFee);

            payable(msg.sender).transfer(getGeneratedValue().sub(SafeMath.add(_devFee, _charityFee)));
        }
        else {
            payable(msg.sender).transfer(getGeneratedValue());
        }

        updateTimeStamp();
    }

    // ----------- END COLLECT ------------

    function updateTimeStamp() private {
        //updating investTime sets also new generating period by getGeneratedCoins()
        investTime[msg.sender] = block.timestamp;
    }

    // after settings new daily apr no value is returned
    function getGeneratedValue() public returns (uint256) {
        uint generatingTime = block.timestamp.sub(investTime[msg.sender]);
        userGeneratedCoins[msg.sender] = userBalance[msg.sender].div(100).mul(maxDailyReturn.div(86400).mul(generatingTime));

        return userGeneratedCoins[msg.sender];
    }

    function getTotalTokenValue() public returns (uint256) {
        return userBalance[msg.sender].add(getGeneratedValue());
    }

    function getBalance() public view returns (uint) {
        return userBalance[msg.sender];
    }

    // ------- FEE SETTERS

    // developer fee a.k.a. collect fee
    function setDevFee(uint8 fee) public payable onlyOwner {
        require(marketingFee == fee, "Collect/Dev fee already set");
        devFee = fee;
    }

    // marketing fee a.k.a. invest fee
    function setMarketingFee(uint8 fee) public payable onlyOwner {
        require(marketingFee == fee, "Invest/Marketing fee already set");
        marketingFee = fee;
    }

    // charity fee a.k.a. nature fee - will be used by invest and collect
    function setCharityFee(uint8 fee) public payable onlyOwner {
        require(charityFee == fee, "Charity fee already set");
        charityFee = fee;
    }

    // reinvest - only used when user re-invests
    // TODO: should be send back to VUSD Contract (when VUSD Coin is created)
    function setReInvestFee(uint8 fee) public payable onlyOwner {
        require(reInvestFee == fee, "Re-Invest fee already set");
        reInvestFee = fee;
    }

    // autoReInvest - only used when user wants automation be reinvesting the funds
    function setAutoReInvestFee(uint8 fee) public payable onlyOwner {
        require(autoReInvestFee == fee, "Auto Re-Invest fee already set");
        autoReInvestFee = fee;
    }

    function setAutoCollect(uint8 fee) public payable onlyOwner {
        require(autoCollectFee == fee, "Auto Collect fee already set");
        autoCollectFee = fee;
    }


    // TODO: Logic should be added for this function
    // rewardPercentage value, represents the percentage of the value when referral user "INVEST" into
    // the treasury, this rewardPercentage will be subtracted from the fee (marketing fee) user has to pay by clicking "INVEST" and not from the full funds, this value will be given as $VUSD to the user which referral link was used.
    function setReferralRewardFee(uint8 _rewardPercentage) public payable onlyOwner {
        referralRewardPercentage = _rewardPercentage;
    }

    // ------- FEE VALUE

    // developer fee a.k.a. collect fee - only collect when user collects
    function getDevFeeValue(uint256 amount) private view returns (uint256) {
        return getFeeValuePercentage(amount, devFee);
    }

    // marketing fee a.k.a. invest fee - only used when user invests
    function getMarketingFeeValue(uint256 amount) private view returns (uint256) {
        return getFeeValuePercentage(amount, marketingFee);
    }

    // charity fee a.k.a. nature fee - only used when user re-invests
    function getCharityFeeValue(uint256 amount) private view returns (uint256) {
        return getFeeValuePercentage(amount, charityFee);
    }

    // reinvest - only used when user re-invests
    function getReInvestFeeValue(uint256 amount) private view returns (uint256) {
        return getFeeValuePercentage(amount, reInvestFee);
    }

    // auto reinvest - only used when user re-invests
    function getAutoReInvestFeeValue(uint256 amount) private view returns (uint256) {
        return getFeeValuePercentage(amount, autoReInvestFee);
    }

    // auto collect - only used when user re-invests
    function getAutoCollectFeeValue(uint256 amount) private view returns (uint256) {
        return getFeeValuePercentage(amount, autoCollectFee);
    }

    // referral user fee - only used when user invests
    function getReferralRewardFeeValue(uint256 amount) private view returns (uint256) {
        return getFeeValuePercentage(amount, referralRewardPercentage);
    }

    function getFeeValuePercentage(uint256 amount, uint256 percentage) private pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, percentage), 100);
    }

    // TODO: Logic should be implemented
    // days value, should represent how many days are needed for recovery if user collects by penalty days.
    function setPenaltyDays(uint8 _daysToRecover) public payable onlyOwner {
        require(daysToRecover == _daysToRecover, "Penalty days for recovering already set");
        daysToRecover = _daysToRecover;
    }

    // TODO: Logic should be implemented
    // if user collects at penalty days his apr will be dropped to minimalStartDailyReturn https://github.com/Ju8z/virtualcash/issues/4
    // minimal APR will be set to user which attended collection 2 times not by #collectDays
    function setMinStartDailyReturn(uint8 percentage) public payable onlyOwner {
        require(minStartDailyReturn == percentage, "Minimal start daily return is already set");
        minStartDailyReturn = percentage;
    }

    // _maxDailyReturn value, represent  daily maximal return in percentage which works for all wallets
    function setMaxDailyReturn(uint8 _maxDailyReturn) public payable onlyOwner {
        require(maxDailyReturn == _maxDailyReturn, "Daily maximal return APR was already set");
        maxDailyReturn = _maxDailyReturn;
    }

    // TODO: Logic should be added for this function
    // days value, represent at which days in the month collecting should be allowed without any penalties. Exp: 1, 10, 20
    function setCollectDay(uint256[31] memory monthDays) public payable onlyOwner {
        require(monthDays.length != 0, "This value should not be empty");
        collectDays = monthDays;
    }

    // TODO: Logic should be added for this function
    // dailyPercentage value, this value should be subtracted from the dailyReturnApr, example : dailyReturnApr = 8 %, after investor reaches 100 % of invested
    // funds dailyPercentage value will be subtracted from the dailyReturnApr. Formula : dailyReturnApr – dailyPercentage = dailyReturnApr for user
    function setDailyReturnReductionRate(uint8 dailyPercentage) public payable onlyOwner {
        if (maxDailyReturn != 0) {
            maxDailyReturn = maxDailyReturn - dailyPercentage;
        }
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

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