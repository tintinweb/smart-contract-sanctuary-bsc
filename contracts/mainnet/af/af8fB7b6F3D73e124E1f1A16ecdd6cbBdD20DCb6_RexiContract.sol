/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function sender() internal view virtual returns (address) {
        return msg.sender;
    }

    function data() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
        _setOwner(sender());
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
        require(owner() == sender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Blacklist is Ownable {
    event AddedBlackList(address indexed wallet);
    event RemovedBlackList(address indexed wallet);
    mapping(address => bool) private blacklisted;

    constructor() {}

    // Blacklisted
    function addBlacklist(address wallet) external onlyOwner {
        blacklisted[wallet] = true;
        emit AddedBlackList(wallet);
    }

    function removeBlacklist(address wallet) external onlyOwner {
        blacklisted[wallet] = false;
        emit RemovedBlackList(wallet);
    }

    function isBlacklist(address wallet) public view returns (bool) {
        return blacklisted[wallet];
    }
}

abstract contract Whitelist is Ownable {
    event AddedWhitelist(address indexed wallet);
    event RemovedWhitelist(address indexed wallet);
    mapping(address => bool) private fromwhitelisted;
    mapping(address => bool) private towhitelisted;

    constructor() {}

    function addFromWhitelist(address wallet) external onlyOwner {
        fromwhitelisted[wallet] = true;
        emit AddedWhitelist(wallet);
    }

    function removeFromWhitelist(address wallet) external onlyOwner {
        fromwhitelisted[wallet] = false;
        emit RemovedWhitelist(wallet);
    }

    function addToWhitelist(address wallet) external onlyOwner {
        towhitelisted[wallet] = true;
        emit AddedWhitelist(wallet);
    }

    function removeToWhitelist(address wallet) external onlyOwner {
        towhitelisted[wallet] = false;
        emit RemovedWhitelist(wallet);
    }

    function isFromWhitelist(address wallet) public view returns (bool) {
        return fromwhitelisted[wallet];
    }

    function isToWhitelist(address wallet) public view returns (bool) {
        return towhitelisted[wallet];
    }
}

abstract contract Tradable is Ownable {
    // Sovle Problems when hacked, to stop trading
    bool private tradable = true;

    event SetTradable(address indexed sender, bool status);

    constructor() {
        tradable = true;
    }

    // Sovle problems
    function setTradable(bool status) external onlyOwner {
        tradable = status;
        emit SetTradable(sender(), status);
    }

    function isTradable() public view returns (bool) {
        return tradable;
    }
}

abstract contract FundControl is Ownable {
    address private _fundWallet = address(0);
    uint256 private _fundPercent = 2;

    event FundWalletTransferred(address indexed previousOwner, address indexed newOwner);
    event SetFundPercent(address indexed sender, uint256 percent);

    constructor() {}

    function setFundWallet(address wallet) external onlyOwner {
        require(wallet != address(0), "FundControl: new fund wallet is the zero address");
        address oldOwner = _fundWallet;
        _fundWallet = wallet;
        emit FundWalletTransferred(oldOwner, wallet);
    }

    function setFundPercent(uint256 percent) external onlyOwner{
        _fundPercent = percent;
        emit SetFundPercent(sender(), percent);
    }

    function fundWallet() public view virtual returns (address) {
        return _fundWallet;
    }

    function fundPercent() public view virtual returns (uint256) {
        return _fundPercent;
    }

    function fundAmount(uint256 amount) internal view virtual returns (uint256) {
        uint256 fundValue = amount * _fundPercent / 100;
        return fundValue;
    }
}

abstract contract TokenControl is Ownable {
    using SafeMath for uint256;

    uint256 private _lockPercent = 100;

    mapping(address => uint) private totalBalances;
    mapping(address => uint) private availableBalances;
    mapping(address => mapping(address => uint)) private allowed;

    event UnlockedTokens(address indexed sender, address indexed wallet, uint256 amount);
    event LockedTokens(address indexed sender, address indexed wallet, uint256 amount);
    event SetLockPercent(address indexed sender, uint256 percent);

    function addBalance(address wallet, uint256 amount, bool isLock) internal{
        uint256 availableAmount = amount;

        if (isLock) availableAmount = amount * (100 - _lockPercent) / 100;
        availableBalances[wallet] = availableBalances[wallet].add(availableAmount);
        totalBalances[wallet] = totalBalances[wallet].add(amount);
    }

    function lockPercent() public view virtual returns (uint256) {
        return _lockPercent;
    }

    function subBalance(address wallet, uint256 amount) internal{
        availableBalances[wallet] = availableBalances[wallet].sub(amount);
        totalBalances[wallet] = totalBalances[wallet].sub(amount);
    }

    function t(address wallet) internal view virtual returns (uint256){
        return totalBalances[wallet];
    }

    function a(address wallet) internal view virtual returns (uint256){
        return availableBalances[wallet];
    }

    // For Uphold
    function unlockToken(address wallet, uint256 amount) external onlyOwner {
        require(amount <= (t(wallet) - a(wallet)), "Quantity exceeded limit");
        availableBalances[wallet] = availableBalances[wallet].add(amount);
        emit UnlockedTokens(sender(), wallet, amount);
    }

    function lockToken(address wallet, uint256 amount) external onlyOwner {
        require(amount <= a(wallet), "Quantity exceeded limit");
        availableBalances[wallet] = availableBalances[wallet].sub(amount);
        emit LockedTokens(sender(), wallet, amount);
    }

    function setLockPercent(uint256 percent) external onlyOwner{
        _lockPercent = percent;
        emit SetLockPercent(sender(), percent);
    }

    // Allowance
    function allowSpender(address owner, address spender, uint256 amount) internal{
        allowed[owner][spender] = amount;
    }

    function subAllowSpender(address owner, address spender, uint256 amount) internal{
        allowed[owner][spender] = allowed[owner][spender].sub(amount);
    }

    function allowedAmount(address owner, address spender) internal view virtual returns (uint256){
        return allowed[owner][spender];
    }

    // Info
    function availableBalanceOf(address wallet) public view returns (uint256 balance) {
        return a(wallet);
    }

    function lockedBalanceOf(address wallet) public view returns (uint256 balance) {
        return t(wallet) - a(wallet);
    }
}

// --------------------------------
// Class Contract
// --------------------------------
contract RexiContract is IERC20, Context, Ownable, Blacklist, Whitelist, Tradable, FundControl, TokenControl {
    using SafeMath for uint256;

    // Token information
    string public constant symbol = "REXI";
    string public constant name = "Rexibot";
    uint256 public constant decimals = 8;
    uint256 private constant maxSupply = 2 * (10 ** 9) * (10 ** decimals);
    uint256 private currentSupply = 200 * (10 ** 6) * (10 ** decimals);
    
    // Manager for holders
    address private constant deadWallet = address(0x000000000000000000000000000000000000dEaD);
    
    // Event
    event BurnDead(address indexed sender, uint256 amount);
    event BurnSupply(address indexed sender, uint256 amount);
    event MintSupply(address indexed sender, uint256 amount);

    constructor() {
        addBalance(sender(), currentSupply, false);
        emit Transfer(address(0), sender(), currentSupply);
    }
    
    // For transaction
    function totalSupply() external view override returns (uint256) {
        return currentSupply;
    }

    function balanceOf(address wallet) public view override returns (uint256 balance) {
        return t(wallet);
    }

    function approve(address spender, uint256 amount) external override returns (bool success) {
        allowSpender(sender(), spender, amount);
        emit Approval(sender(), spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external override returns (bool success) {
        require(isTradable(), "TEMPORARY STOP TRADING TO SOLVE PROBLEM");
        require(!isBlacklist(sender()), "ADDRESS IS BLACKLISTED");
        require(to != address(0), "RECEIVE ADDRESS IS A ZERO ADDRESS");
        require(a(sender()) >= amount, "You have transferred in excess of the available quantity. Go to https://token.rexibot.com to unlock more");

        subBalance(sender(), amount);
        addBalance(to, amount, false);

        emit Transfer(sender(), to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool success) {
        require(isTradable(), "TEMPORARY STOP TRADING TO SOLVE PROBLEM");
        require(!isBlacklist(from), "ADDRESS IS BLACKLISTED");
        require(to != address(0), "RECEIVE ADDRESS IS A ZERO ADDRESS");
        require(a(from) >= amount, "You have transferred in excess of the available quantity. Go to https://token.rexibot.com to check more");
        require(allowedAmount(from, sender()) >= amount, "ALLOWANCE IS NOT ENOUGH");

        subAllowSpender(from, sender(), amount);
        subBalance(from, amount);

        // Check if is send from exchange wallet
        if (isFromWhitelist(from) || isToWhitelist(to)) {
            addBalance(to, amount, false);
            emit Transfer(from, to, amount);
        } else {
            uint256 fundValue = fundAmount(amount);
            addBalance(fundWallet(), fundValue, false);
            addBalance(to, amount - fundValue, true);
            emit Transfer(from, to, amount - fundValue);
            emit Transfer(from, fundWallet(), fundValue);
        }

        return true;
    }

    function allowance(address tokenOwner, address spender) external override view returns (uint256 remaining) {
        return allowedAmount(tokenOwner, spender);
    }

    // For supply
    function burnDead(uint256 amount) external onlyOwner {
        require(a(sender()) >= amount, "BALANCE IS NOT ENOUGH");
        addBalance(deadWallet, amount, false);
        subBalance(sender(), amount);
        emit BurnDead(sender(), amount);
        emit Transfer(sender(), deadWallet, amount);
    }

    function burnSupply(uint256 amount) external onlyOwner {
        require(a(sender()) >= amount, "BALANCE IS NOT ENOUGH");
        subBalance(sender(), amount);
        currentSupply -= amount;
        emit BurnSupply(sender(), amount);
        emit Transfer(sender(), address(0), amount);
    }

    function mintSupply(uint256 amount) external onlyOwner{
        require(maxSupply - currentSupply >= amount, "Exceeding the permitted limits");
        addBalance(sender(), amount, false);
        currentSupply += amount;
        emit MintSupply(sender(), amount);
        emit Transfer(address(0), sender(), amount);
    }
}