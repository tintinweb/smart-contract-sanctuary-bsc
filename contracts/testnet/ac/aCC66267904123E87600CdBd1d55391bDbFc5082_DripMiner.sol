/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface DripFountain { 

    /**
     * @notice  Convert BNB to Tokens
     * @dev     User Specifies Exact BNB Amount (msg.value) and Minimum Tokens to Purchase
     * @param   min_tokens Minimum Tokens Bought.
     * @return  Amount of Tokens Bought
     */
    function bnbToTokenSwapInput(uint256 min_tokens) payable external returns (uint256);

}

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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;
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
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

pragma solidity ^0.8.0;

// Contract Interfaces
// Contract Modifiers
// Contract Libraries
contract DripMiner is Ownable, Pausable { 

    using SafeMath for uint256;

    bool public initialized;

    address public dripTaxVault;
    address payable public dripFountain;

    uint8 public feePercentage;
    uint8 public feeBreakdowns;
    uint8 public feeBreakdownTotal;

    // User Information
    struct User {
        uint256 started;
        uint256 deposits;
        uint256 depositsCount;
        uint256 lastDeposited;
        uint256 claims;
        uint256 claimsCount;
        uint256 lastClaimed;
        uint256 taxes;
        uint256 balance;
        bool active;
    }

    struct FeeBreakdown { 
        uint8 percentage;
        address feeAddress;
        bool active;
    }

    mapping(address => User) public users;
    mapping(string => FeeBreakdown) public fees;

    /**
     * @notice  Drip Miner Contract Constructor 
     * @dev     Set Contract to Paused on Creation
     */
    constructor() {

        _pause();

    }

    /**
     * @notice  Drip Miner Initialization Function 
     * @dev     Set DRIP Network Fountain Contract Address
     * @param   _dripFountain   DRIP Network Fountain Contract Address
     */
    function initialize(address payable _dripFountain, uint8 _feePercentage) public onlyOwner whenPaused {

        require(setDripFountainAddress(_dripFountain), "Drip Fountain Address Not Set");
        require(setTransactionFeePercentages(_feePercentage), "Error Setting Fee Percentages");

        require(addTransactionFeeBreakdown("Tax Vault", 70), "Error Setting Fee Breakdown Percentages");
        require(addTransactionFeeBreakdown("Drip Reservoir", 20), "Error Setting Fee Breakdown Percentages");
        require(addTransactionFeeBreakdown("Development", 10), "Error Setting Fee Breakdown Percentages");
        
        _unpause();

        initialized = true;

    }

    /**
     * @notice  Set DRIP Network Fountain Contract Address Function  
     * @dev     Set DRIP Network Fountain Contract Address, Cannot be 0, Must Be Contract
     * @param   _dripFountain DRIP Network Fountain Contract Address
     * @return  Success Indicator
     */
    function setDripFountainAddress(address payable _dripFountain) public onlyOwner whenPaused returns (bool Success) {

        require(_dripFountain != address(0), "Address Cannot be 0");
        require(isContract(_dripFountain), "Address is Not a Contract");

        dripFountain = _dripFountain;
        Success = true;

    }

    /**
     * @notice  Set Transaction Fee Percentages Function  
     * @dev     Set Transaction Fee Percentages
     * @param   _feePercentage Transaction Tax Percentage
     * @return  Success Indicator
     */
    function setTransactionFeePercentages(uint8 _feePercentage) public onlyOwner whenPaused returns (bool Success) {

        require(_feePercentage <= 12, "Fee Cannot Exceed 12 Percent");

        feePercentage = _feePercentage;

        Success = true;

    }

    /**
     * @notice  Add Transaction Fee Breakdown Percentages  
     * @dev     Add Transaction Fee Breakdown Percentages
     * @param   _feeDescription Transaction Fee Description 
     * @param   _feePercentage Transaction Fee Percentage of Overall Transaction Tax
     * @return  Success Indicator
     */
    function addTransactionFeeBreakdown(string memory _feeDescription, uint8 _feePercentage) public onlyOwner whenPaused returns (bool Success) {

        require(!fees[_feeDescription].active, "Fee Breakdown Already Active");
        require((feeBreakdownTotal + _feePercentage) <= 100, "Fee Breakdown Exceeds 100 Percent");

        fees[_feeDescription].percentage = _feePercentage;
        fees[_feeDescription].active = true;

        feeBreakdowns += 1;
        feeBreakdownTotal += _feePercentage;

        Success = true;

    }

    /**
     * @notice  DripMiner IsContract Function    
     * @dev     Check if an Address is a Contract or Not
     * @param   _address to Check if it is a Contract or Not 
     * @return  Contract Indicator
     */
	function isContract(address _address) internal view returns (bool) {

        /*
        /* This function relies on extcodesize/address.code.length, which returns 1
        /* once a contract's constructor method is executed.
         */
        return _address.code.length > 0;

    }

    /**
     * @notice  Drip Miner Initialization Function 
     * @dev     Set DRIP Network Fountain Contract Address
     */
    function Deposit(address _user) payable public whenNotPaused {

        // Calculate Transaction Fee and Adjusted Balance
        uint256 depositAmount   = msg.value;
        uint256 transactionFee  = depositAmount.mul(feePercentage).div(100);
        uint256 adjustedAmount  = SafeMath.sub(depositAmount, transactionFee);

        // Purchase DRIP Token with BNB Supplied
        uint256 dripPurchased   = adjustedAmount;

        //uint256 dripPurchased = DripFountain(dripFountain).bnbToTokenSwapInput(adjustedAmount);

        if(!users[_user].active) {
            users[_user].started = block.timestamp;
        }

        users[_user].deposits       = users[_user].deposits.add(depositAmount);
        users[_user].depositsCount  = users[_user].depositsCount.add(1);
        users[_user].lastDeposited  = block.timestamp;
        users[_user].taxes          = users[_user].taxes.add(transactionFee);
        users[_user].balance        = users[_user].balance.add(dripPurchased);
        users[_user].active         = true;

    }

}