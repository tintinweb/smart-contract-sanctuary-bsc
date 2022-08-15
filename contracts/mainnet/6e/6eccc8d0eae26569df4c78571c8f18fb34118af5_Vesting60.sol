/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIТ

/**
MIT License

Copyright (c) 2022 Woonkly OU

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED BY WOONKLY OU "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

pragma solidity 0.6.12;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


library SafeMath {
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
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}



library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}




contract FundGuardianRole {
    using Roles for Roles.Role;

    event FundGuardianAdded(address indexed account);
    event FundGuardianRemoved(address indexed account);

    Roles.Role private _fundGuardians;

    constructor() internal {
        _addFundGuardian(msg.sender);
    }

    modifier onlyFundGuardian() {
        require(
            isFundGuardian(msg.sender),
            "FundGuardianRole: caller does not have the FundGuardian role"
        );
        _;
    }

    function isFundGuardian(address account) public view returns (bool) {
        return _fundGuardians.has(account);
    }

    function addFundGuardian(address account) public onlyFundGuardian {
        _addFundGuardian(account);
    }

    function removeFundGuardian(address account) public onlyFundGuardian {
        _removeFundGuardian(account);
    }

    function renounceFundGuardian() public {
        _removeFundGuardian(msg.sender);
    }

    function _addFundGuardian(address account) internal {
        _fundGuardians.add(account);
        emit FundGuardianAdded(account);
    }

    function _removeFundGuardian(address account) internal {
        _fundGuardians.remove(account);
        emit FundGuardianRemoved(account);
    }
}



pragma solidity 0.6.12;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


pragma solidity 0.6.12;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


library DateHelper{

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



        function isLeapYear(uint16 year) internal pure returns (bool) {
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

  
    function leapYearsBefore(uint year) internal pure returns (uint) {
            year -= 1;
            return year / 4 - year / 100 + year / 400;
    }


    function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {
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

    function getHour(uint timestamp) internal pure returns (uint8) {
            return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint timestamp) internal pure returns (uint8) {
            return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) internal pure returns (uint8) {
            return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) internal pure returns (uint8) {
            return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
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



    function getYear(uint timestamp) internal pure returns (uint16) {
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


    function getMonth(uint timestamp) internal pure returns (uint8) {
            return parseTimestamp(timestamp).month;
    }


    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) internal pure returns (uint timestamp) {
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


    function getYMnumber(uint256 timestamp ) internal pure returns(uint32){

        uint32 y= getYear(timestamp);
        return  (y *100) + getMonth(timestamp) ;    
    }


    function calcMonthQty(uint256 fromt, uint256 tot )  internal pure returns(uint32){
        
        if(fromt >= tot) return 0;
        
        uint16 fromY = getYear(fromt);
        uint16 toY = getYear(tot);
        uint16 yDif = toY - fromY ;
        uint32 ymFrom=getYMnumber(fromt );
        uint32 ymTo=getYMnumber(tot );
        uint32 ymDif = ymTo - ymFrom;
        
    
        return  ymDif -  (yDif * 100)  + (yDif * 12);

    }

    function countDay(uint256 fromt, uint256 tot,uint8 dayInMonth) internal pure returns(uint32){

            uint32 montQty = calcMonthQty(fromt,  tot );

            _DateTime memory dt = parseTimestamp(tot);

            if(dt.day >= dayInMonth){
                    return montQty;         
            }else{
                    if(montQty>0)  return montQty-1;         

            }

            return 0;

    }

    
}

/**
 * FONDO P
 * @dev Main contract: Manage token delivery spread over 60 months:
 * Distribution rule:
 * Releases 10% immediately once deposited:
 * The remaining 90% is distributed in equal amounts each day 3 of the following months within a period of 60 months
 */
contract Vesting60 is Context,Ownable,ReentrancyGuard,Pausable,FundGuardianRole{
    using SafeMath for uint256;

    //Section Type declarations
    struct Freeze {
        address account;
        uint256 fund;
        uint256 date;
        uint256 delivered;
        uint8 flag; //0 no exist  1 exist 2 deleted

    }

    //Section State variables

    uint256 internal _lastIndexFreezes;
    mapping(uint256 => Freeze) internal _freezes;
    mapping(address => uint256) internal _idFreezesIndex;
    uint256 internal _freezeCount;
    uint256 internal _totalFunds;
    uint256 internal _totalDelivered;

    uint8 initDeliveryPerc = 10;
    uint8 daymonthTrigger = 3;
    uint8 totalMonthPeriod = 61;
    
    IERC20 internal _tokenfund;

    //Section Modifier
    modifier onlyNewFreeze(address account) {
        require(!freezeExist(account), "This Freeze account exist");
        _;
    }

    modifier onlyfreezeExist(address account) {
        require(freezeExist(account), "This Freeze account not exist");
        _;
    }

    modifier onlyfreezeIndexExist(uint256 index) {
        require(freezeIndexExist(index), "This Freeze index not exist");
        _;
    }

    //Section Events

    event FreezeAdded(address indexed account, uint256 amount,address executor);
    event FreezeRemoved(address indexed account, uint256 amount,uint256 delivered,address executor);
    event Withdrawal(address indexed account, uint256 pending);
    event DateUpdated(address indexed account,uint256 oldDate, uint256 newDate,address executor);

    //Section functions
    constructor(address tokenToDistribute) public {
        _lastIndexFreezes = 0;
        _freezeCount = 0;
        _totalFunds = 0;
        _totalDelivered = 0;
        _tokenfund = IERC20(tokenToDistribute);
    }

    function getTokenToDistribute() external view returns (address) {
        return address(_tokenfund);
    }

    function getFreezeCount() external view returns (uint256) {
        return _freezeCount;
    }

    function getLastIndexFreezes() internal view returns (uint256) {
        return _lastIndexFreezes;
    }

    function freezeExist(address account) public view returns (bool) {
        return _freezeExist(_idFreezesIndex[account]);
    }

    function freezeIndexExist(uint256 index) internal view returns (bool) {
        return (index < (_lastIndexFreezes + 1));
    }

    function _freezeExist(uint256 FreezeID) internal view returns (bool) {
        return (_freezes[FreezeID].flag == 1);
    }

    function getFreezeAccountValues(address account) public view returns(uint256 fund,uint256 date, uint256 delivered){
        
        if(_freezes[_idFreezesIndex[account]].flag != 1 ) return (0,0,0);
        
        fund = _freezes[_idFreezesIndex[account]].fund;
        date = _freezes[_idFreezesIndex[account]].date;
        delivered = _freezes[_idFreezesIndex[account]].delivered;
    }

    function getInitialValues() external view returns(uint8, uint8, uint8){

        return (initDeliveryPerc, daymonthTrigger, totalMonthPeriod);

    }

    function getFreezeByIndex(uint256 index)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        if (!freezeIndexExist(index)) return (0, 0, 0);

        Freeze memory p = _freezes[index];

        return (p.fund, p.date, p.delivered);
    }



    function toTimestamp(uint16 year, uint8 month, uint8 day) external pure returns (uint timestamp) {
            return DateHelper.toTimestamp(year, month, day, 0, 0, 0);
    }





    function estimatePendingToDeliver(
            uint256 initialFund,
            uint256 depositDate,
            uint256 _delivered,
            uint256 releaseDate) internal view returns(uint256 pending,uint256 delivered,uint32 monthsQty){

        delivered = _delivered;

        uint256 initFundReleased = initialFund.mul(initDeliveryPerc).div(100);

        if(initFundReleased == 0 ) return (0,delivered,0);

        uint256 remainderFund = initialFund.sub(initFundReleased);

        monthsQty = DateHelper.countDay( depositDate,  releaseDate, daymonthTrigger);

        if(monthsQty > (totalMonthPeriod-1) ) monthsQty = totalMonthPeriod-1;

        uint256  toRelease = initFundReleased.add( remainderFund.mul(monthsQty).div(totalMonthPeriod-1) )   ;

        if(monthsQty == totalMonthPeriod-1){
            toRelease = initialFund  ;
        }

        if (delivered >= toRelease) return (0,delivered,monthsQty);

        pending = toRelease.sub(delivered) ;

        
    }











    function getPendingToDeliver(address account,uint256 releaseDate) public view returns(uint256 pending,uint256 delivered,uint32 monthsQty){
        
        
        if(!freezeExist( account) ) return (0,0,0);

        (uint256 initialFund,uint256 depositDate,uint256 _delivered) =getFreezeAccountValues(account);

        delivered = _delivered;

        uint256 initFundReleased = initialFund.mul(initDeliveryPerc).div(100);

        if(initFundReleased == 0 ) return (0,delivered,0);

        uint256 remainderFund = initialFund.sub(initFundReleased);

        monthsQty = DateHelper.countDay( depositDate,  releaseDate, daymonthTrigger);

        if(monthsQty > (totalMonthPeriod-1) ) monthsQty = totalMonthPeriod-1;

        uint256  toRelease = initFundReleased.add( remainderFund.mul(monthsQty).div(totalMonthPeriod-1) )   ;

        if(monthsQty == totalMonthPeriod-1){
            toRelease = initialFund  ;
        }

        if (delivered >= toRelease) return (0,delivered,monthsQty);

        pending = toRelease.sub(delivered) ;

        
    }






    function _newFreeze(
        address account,
        uint256 amount,
        uint256 date
    ) internal 
        onlyNewFreeze(account) 
    returns (uint256) {

        _lastIndexFreezes = _lastIndexFreezes.add(1);
        _freezeCount = _freezeCount.add(1);

        _freezes[_lastIndexFreezes].account = account;
        _freezes[_lastIndexFreezes].fund = amount;
        _freezes[_lastIndexFreezes].delivered = 0;
        _freezes[_lastIndexFreezes].date = date;
        _freezes[_lastIndexFreezes].flag = 1;

        _idFreezesIndex[account] = _lastIndexFreezes;

        _totalFunds = _totalFunds.add(amount);


        emit FreezeAdded(account, amount,_msgSender());
        return _lastIndexFreezes;
    }
    
    
    

    function newFreeze(address account, uint256 amount)
        external
        whenNotPaused
        nonReentrant
        onlyFundGuardian
        onlyNewFreeze(account) 
        returns (uint256 lastIndex)
    {
        require(account != address(0), "newFreeze: 0 address!");
        require(amount > 0, "newFreeze: 0 amount!");
        require(_tokenfund.balanceOf(_msgSender()) >= amount, "newFreeze: Insufficient funds");
        require(_tokenfund.allowance(_msgSender(), address(this)) >= amount, "newFreeze: Invalid allowance");
        
        lastIndex= _newFreeze(account, amount, now);
        
        TransferHelper.safeTransferFrom(
            address(_tokenfund),
            _msgSender(),
            address(this),
            amount
        );
        
    }



    function withdraw()
        external
        whenNotPaused
        nonReentrant
        onlyfreezeExist(_msgSender()) returns(bool){
            
            (uint256 pending,,) = getPendingToDeliver(_msgSender(),now);
            
            require(pending > 0, "withdraw: 0 pending!");

            require(_tokenfund.balanceOf( address(this)) >= pending, "withdraw: Insufficient funds");
     
            _freezes[_idFreezesIndex[_msgSender()]].delivered=_freezes[_idFreezesIndex[_msgSender()]].delivered.add(pending);

            _totalDelivered = _totalDelivered.add( pending);
            
        
            TransferHelper.safeTransfer(
                address(_tokenfund),
                _msgSender(),
                pending
            );
            
            emit Withdrawal(_msgSender(),pending);
            
            return true;
    }



    function _removeFreeze(address account) 
    internal 
    onlyfreezeExist(account) 
    {

        uint256 amount = _freezes[_idFreezesIndex[account]].fund;
        uint256 delivered = _freezes[_idFreezesIndex[account]].delivered;

        _totalFunds = _totalFunds.sub(amount);
        
        _totalDelivered = _totalDelivered.sub(delivered);

        _freezes[_idFreezesIndex[account]].flag = 2;
        _freezes[_idFreezesIndex[account]].account = address(0);
        _freezes[_idFreezesIndex[account]].fund = 0;
        _freezes[_idFreezesIndex[account]].date = 0;
        _freezes[_idFreezesIndex[account]].delivered = 0;

        _freezeCount = _freezeCount.sub(1);
        emit FreezeRemoved(account, amount, delivered, _msgSender());
    }



    function removeFreeze(address account) 
        external
        nonReentrant
        onlyFundGuardian
        onlyfreezeExist(account) 

     {
         
        (uint256 fund,,uint256 delivered) =getFreezeAccountValues(account);
        
        uint256 remanider=0;
        
        if(fund > delivered ){
            remanider=fund.sub(delivered);
        }
        
        _removeFreeze(account);

        
        if(remanider > 0 ){
        
            require(_tokenfund.balanceOf(address(this)) >= remanider, "newFreeze: Insufficient contract funds");    
            
            TransferHelper.safeTransfer(
                address(_tokenfund),
                _msgSender(),
                remanider
            );
            
        }
        
    }


    function updateDepositDate(address account,uint256 newDate) 
    external 
    onlyOwner 
    onlyfreezeExist(account) 
    {

        require( _freezes[_idFreezesIndex[account]].delivered == 0 ,"The transaction cannot be made" );

        uint256 oldDate = _freezes[_idFreezesIndex[account]].date;

        _freezes[_idFreezesIndex[account]].date = newDate;

        emit DateUpdated( account, oldDate, newDate, _msgSender());
    }


    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }








}