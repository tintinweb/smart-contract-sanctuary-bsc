/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Strings.sol
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/TokenAllocation.sol


pragma solidity ^0.8.12;





contract TokenAllocation is Ownable {
    using Strings for uint256;
    using SafeMath for uint256;
    IERC20 public ColtisToken;
    struct WStruct{
        address WalletAddress;
        uint256 TotalAmount;
        uint256 StartDate;    
        uint256 TotalTime;
        uint256 Interval;
    }
    enum WType {
        PublicPresale,
        PrivatePresale,
        Team,
        Marketing,
        Partners,
        Reserve,
        Staking,
        BattleRewards,
        FarmingRewards
    }
    struct DateDeposit{
        uint256 Date;
        uint256 Token;
        bool Deposit;
    }
    
    mapping(WType => WStruct) public WalletStruct;
    mapping(WType => mapping (uint256=>DateDeposit)) public WalletSettings;
    mapping(WType => uint256) public quantity;
    mapping(WType => uint256) public quantityTransferred;
    mapping(WType => uint256) public tokenTransferred;
    mapping(WType => mapping (uint256 => uint256)) public tokenPercentageYear;
    mapping(WType => bool) public percentageYearState;
    mapping(WType => uint256) public WTransferred;
    uint256 private _timeMonth = 30 days;
    event TransferTokensEvent(address _account, uint256 _value);

    constructor (){    
        WalletStruct[WType.PublicPresale]=WStruct(address(0),10500000*(10**18),1659312000,1,1);
        WalletStruct[WType.PrivatePresale]=WStruct(address(0),10500000*(10**18),1659312000,1,1);
        WalletStruct[WType.Team]=WStruct(address(0),21000000*(10**18),1659312000,48,6);
        WalletStruct[WType.Marketing]=WStruct(address(0),12000000*(10**18),1659312000,48,1);
        WalletStruct[WType.Partners]=WStruct(address(0),4500000*(10**18),1659312000,48,6);
        WalletStruct[WType.Reserve]=WStruct(address(0),3000000*(10**18),1659312000,48,1);
        WalletStruct[WType.Staking]=WStruct(address(0),28500000*(10**18),1659312000,48,3);
        WalletStruct[WType.BattleRewards]=WStruct(address(0),18000000*(10**18),1659312000,48,2);
        WalletStruct[WType.FarmingRewards]=WStruct(address(0),42000000*(10**18),1659312000,48,2);        
    }
    function CoinSettings(IERC20 _ColtisToken)external onlyOwner{
        ColtisToken = _ColtisToken;
    }
    function SetWalletSettings( WType _WType, address _address,  uint256 _startDate, uint256 _totalTime,uint256 _interval) external onlyOwner{
        require(WalletStruct[_WType].StartDate <= _startDate, "Date required");
        require(((_totalTime/_interval)*_interval) == _totalTime, "Wrong total time");
        WalletStruct[_WType] = WStruct(_address,WalletStruct[_WType].TotalAmount,_startDate,_totalTime,_interval);
        quantity[_WType] = WalletStruct[_WType].TotalAmount;
        if (WalletStruct[_WType].TotalTime != _totalTime || WalletStruct[_WType].Interval != _interval) {
            percentageYearState[_WType] = false;
        }
    }
    function SetWalletAddressSettings(WType _WType, address _address)external onlyOwner{
        WalletStruct[_WType] = WStruct(_address,WalletStruct[_WType].TotalAmount,WalletStruct[_WType].StartDate,WalletStruct[_WType].TotalTime,WalletStruct[_WType].Interval);
        quantity[_WType] = WalletStruct[_WType].TotalAmount;
    }
    function SetWalletStartDateSettings(WType _WType, uint256 _startDate)external onlyOwner{
        require(WalletStruct[_WType].StartDate <= _startDate, "Date required");
        WalletStruct[_WType] = WStruct(WalletStruct[_WType].WalletAddress,WalletStruct[_WType].TotalAmount,_startDate,WalletStruct[_WType].TotalTime,WalletStruct[_WType].Interval);
    }
    function setTokenPercentageYear (WType _WType, uint256[] memory percentage) external onlyOwner{
        uint256 num = WalletStruct[_WType].TotalTime/12 == 0 ? 1 : WalletStruct[_WType].TotalTime/12;
        uint256 totalPercentage = 0;
        require(num == percentage.length, "Wrong number of years");
        for (uint256 i = 0; i < num; i++) {
            totalPercentage = totalPercentage + percentage[i];
        }
        require(totalPercentage == 100, "Percentage no accepted");
        for (uint256 i = 0; i < num; i++) {
           tokenPercentageYear[_WType][i] = percentage[i];
        }
        percentageYearState[_WType] = true;
    }
    function WalletLockedSettings(WType _WType)external onlyOwner{
        require(percentageYearState[_WType], "Percentage not available");
        require(WalletStruct[_WType].WalletAddress!=address(0),"No deposit address");
        require(WalletStruct[_WType].StartDate !=0 ,"No date deposit");
        uint256 sumDepositTrue;
        uint256 num = WalletStruct[_WType].TotalTime/WalletStruct[_WType].Interval;
        uint256 timeYears = (WalletStruct[_WType].TotalTime/12) == 0 ? 1 : (WalletStruct[_WType].TotalTime/12);
        uint256 numYears = num/timeYears;
        for(uint i = 0; i < num;i++){
            if (!WalletSettings[_WType][i].Deposit) {
                uint256 numYearsAux = numYears*10**18 - (SafeMath.div(sumDepositTrue*10**18, WalletStruct[_WType].TotalAmount - quantityTransferred[_WType])*numYears);
                uint256 timesPerYear = SafeMath.div(SafeMath.div((num-1)*10**18, num), numYears);
                uint256 date = WalletStruct[_WType].StartDate + _timeMonth*((i+1)*(WalletStruct[_WType].Interval));
                uint256 percentageVesting = SafeMath.div(tokenPercentageYear[_WType][SafeMath.div((i+1)*timesPerYear, 10**18)]*10**18, numYears);
                uint256 percentageVestingAux = numYearsAux == 0 ? 0 : (SafeMath.div(tokenPercentageYear[_WType][SafeMath.div((i+1)*timesPerYear, 10**18)]*10**36, (numYearsAux)));
                uint256 tokenAvailable= WalletStruct[_WType].TotalAmount - quantityTransferred[_WType];
                uint256 TokenVesting = (percentageVesting*tokenAvailable) + (percentageVestingAux * sumDepositTrue);
                WalletSettings[_WType][i] = DateDeposit(date, SafeMath.div(TokenVesting, 100*10**18),false);
            }
            if (WalletSettings[_WType][i].Deposit) {
                uint256 timesPerYear = SafeMath.div(SafeMath.div((num-1)*10**18, num), numYears);
                uint256 percentageVesting = SafeMath.div(tokenPercentageYear[_WType][SafeMath.div((i+1)*timesPerYear, 10**18)]*10**18, numYears);
                uint256 tokenAvailable= (SafeMath.div(WalletStruct[_WType].TotalAmount - quantityTransferred[_WType], 100*10**18));
                uint256 TokenVesting = percentageVesting*tokenAvailable;
                sumDepositTrue = sumDepositTrue + TokenVesting;
            }
        }
    }    
    function WalletDeposit(WType _WType) external onlyOwner{
        require(WalletStruct[_WType].WalletAddress!=address(0),"No address");
        require(WalletSettings[_WType][WTransferred[_WType]].Date !=0 ,"No date deposit");
        require(block.timestamp>WalletSettings[_WType][WTransferred[_WType]].Date, "invalid Date");
        uint256 TimePass = (block.timestamp - WalletStruct[_WType].StartDate)/_timeMonth;
        uint256 timeAmount = (TimePass/WalletStruct[_WType].Interval) - WTransferred[_WType];
        for(uint256 i=0;i<timeAmount;i++){
            quantityTransferred[_WType] += WalletSettings[_WType][WTransferred[_WType]+i].Token;
            quantity[_WType] -= WalletSettings[_WType][WTransferred[_WType]+i].Token;
            WalletSettings[_WType][WTransferred[_WType]+i].Deposit = true;
        }
        WTransferred[_WType] += timeAmount;
    }
    function WalletTransfer(WType _WType, uint256 DepositAmount) external onlyOwner{
        require(DepositAmount<=quantityTransferred[_WType]-tokenTransferred[_WType],"No tokens transfered");
        ColtisToken.transfer(WalletStruct[_WType].WalletAddress,DepositAmount);
        tokenTransferred[_WType] += DepositAmount;
        emit TransferTokensEvent(WalletStruct[_WType].WalletAddress,DepositAmount);
    }
    function DatesDepositView(WType _WType)view external returns(DateDeposit[]memory){
        uint256 num=WalletStruct[_WType].TotalTime/WalletStruct[_WType].Interval;
        DateDeposit[]memory DateSettings = new DateDeposit[](num);
        for(uint256 i=0;i<num;i++){
            DateSettings[i] = WalletSettings[_WType][i];
        }
        return DateSettings;
    }
    function WalletDepositAmountView(WType _WType) external view returns(uint256){
        require(WalletStruct[_WType].WalletAddress != address(0),"Address not config");
        require(WalletSettings[_WType][WTransferred[_WType]].Date !=0 ,"No date deposit");
        uint256 TimePass = (block.timestamp - WalletStruct[_WType].StartDate)/_timeMonth;
        uint256 timeAmount = (TimePass/WalletStruct[_WType].Interval) - WTransferred[_WType];
        uint256 DepositAmount =  0;
        DepositAmount = (WalletStruct[_WType].TotalAmount * WalletStruct[_WType].Interval * timeAmount)/WalletStruct[_WType].TotalTime;
        return DepositAmount;
    }
}