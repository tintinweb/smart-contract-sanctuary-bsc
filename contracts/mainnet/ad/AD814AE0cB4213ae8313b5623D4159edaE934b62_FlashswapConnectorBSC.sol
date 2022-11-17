// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/Math.sol';

import '../interfaces/IFlashswapConnectorBSC.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';

import '../../../../contracts/Fodl/connectors/SimplePosition/SimplePositionBaseConnector.sol';
import '../../../../contracts/Fodl/modules/Exchanger/ExchangerDispatcher.sol';
import '../../../../contracts/Fodl/modules/FundsManager/FundsManager.sol';
import '../../../../contracts/Fodl/core/interfaces/IExchangerAdapterProvider.sol';

import '../../modules/Lender/Venus/IVenus.sol';
import { LendingDispatcherBSC } from '../../modules/Lender/LendingDispatcherBSC.sol';

contract FlashswapConnectorBSC is
    IFlashswapConnectorBSC,
    SimplePositionBaseConnector,
    ExchangerDispatcher,
    LendingDispatcherBSC,
    FundsManager
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private constant BSCUSDT = 0x55d398326f99059fF775485246999027B3197955;
    address private constant BSCUSDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address private constant BSCDAI = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;
    address private constant BSCBUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address private constant BSCETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address private constant XRP = 0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE;
    address private constant ADA = 0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47;
    address private constant DOGE = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43;
    address private constant DOT = 0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402;
    address private constant CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address private constant XVS = 0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63;

    uint256 private constant PANCAKESWAP_FEE_NUM = 300;
    uint256 private constant PANCAKESWAP_FEE_DEN = 100000;

    uint256 public immutable rewardsFactor;
    address public immutable pancakeswapFactory;
    address private immutable SELF_ADDRESS;

    constructor(
        uint256 _principal,
        uint256 _profit,
        uint256 _rewardsFactor,
        address _holder,
        address _pancakeswapFactory
    ) public FundsManager(_principal, _profit, _holder) {
        rewardsFactor = _rewardsFactor;
        pancakeswapFactory = _pancakeswapFactory;
        SELF_ADDRESS = address(this);
    }

    /**
     * platform - The lender, ex. Venus Comptroller
     * supplyToken - The supplied token to platform in existing position
     * withdrawAmount - Amount of supplyToken to redeem and transferTo accountOwner
     * maxRedeemAmount - Decrease position by redeeming at most this amount of supplied token. Can be greater than supplied amount to support zero dust withdrawals
     * borrowToken - The borrowed token from platform in existing position
     * minRepayAmount - Repay debt of at least this amount of borrowToken or revert. Used to protect from unwanted slippage
     * exchangeData - ABI encoded (bytes1, address[]), for (getExchangerAdapter, swapPath). Required for swapping supplyToken to borrowToken, when not same token
     */
    function decreaseSimplePositionWithFlashswap(
        address platform,
        address supplyToken,
        uint256 withdrawAmount,
        uint256 maxRedeemAmount,
        address borrowToken,
        uint256 minRepayAmount,
        bytes calldata exchangeData
    ) external override onlyAccountOwner {
        requireSimplePositionDetails(platform, supplyToken, borrowToken);

        address lender = getLender(platform);

        accrueInterest(lender, platform, supplyToken);
        accrueInterest(lender, platform, borrowToken);

        uint256 startBorrowBalance = getBorrowBalance();
        uint256 startPositionValue = _getPositionValue(lender, platform, supplyToken, borrowToken);

        maxRedeemAmount = Math.min(maxRedeemAmount, getSupplyBalance()); // Cap maxRedeemAmount
        minRepayAmount = Math.min(minRepayAmount, getBorrowBalance()); // Cap minRepayAmount

        // Flashswap exactIn: maxRedeemAmount, then exchange back to debt token, repay debt, redeem and repay flash, then swap back the surplus
        if (minRepayAmount > 0) {
            if (supplyToken == borrowToken) flashloanInPancake(supplyToken, minRepayAmount);
            if (supplyToken != borrowToken && maxRedeemAmount > 0)
                flashswapInPancake(maxRedeemAmount, supplyToken, exchangeData);
        }

        require(startBorrowBalance.sub(getBorrowBalance()) >= minRepayAmount, 'SPFC02');

        if (supplyToken != borrowToken && getBorrowBalance() == 0) {
            _swapExcessBorrowTokens(supplyToken, borrowToken, exchangeData);
        }

        if (withdrawAmount > 0) {
            _redeemAndWithdraw(lender, platform, supplyToken, withdrawAmount, startPositionValue);
        }

        if (IERC20(supplyToken).balanceOf(address(this)) > 0) {
            supply(lender, platform, supplyToken, IERC20(supplyToken).balanceOf(address(this)));
        }

        if (getBorrowBalance() == 0) {
            _claimRewards(lender, platform);
        }
    }

    function flashloanInPancake(address token, uint256 repayAmount) internal {
        address flashpair;
        if (token == BSCUSDT) flashpair = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;
        if (token == BSCUSDC) flashpair = 0xEc6557348085Aa57C72514D67070dC863C0a5A8c;
        if (token == BSCDAI) flashpair = 0x66FDB2eCCfB58cF098eaa419e5EfDe841368e489;
        if (token == BSCBUSD) flashpair = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
        if (token == WBNB) flashpair = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
        if (token == BTCB) flashpair = 0xF45cd219aEF8618A92BAa7aD848364a158a24F33;
        if (token == BSCETH) flashpair = 0x74E4716E431f45807DCF19f284c7aA99F18a4fbc;
        if (token == XRP) flashpair = 0x03F18135c44C64ebFdCBad8297fe5bDafdBbdd86;
        if (token == ADA) flashpair = 0x28415ff2C35b65B9E5c7de82126b4015ab9d031F;
        if (token == DOGE) flashpair = 0xac109C8025F272414fd9e2faA805a583708A017f;
        if (token == DOT) flashpair = 0xDd5bAd8f8b360d76d12FdA230F8BAF42fe0022CF;
        if (token == CAKE) flashpair = 0x0eD7e52944161450477ee417DE9Cd3a859b14fD0;
        if (token == XVS) flashpair = 0x7EB5D86FD78f3852a3e0e064f2842d45a3dB6EA2;
        require(flashpair != address(0), 'Unavailable flashloan for token');
        require(IERC20(token).balanceOf(flashpair) >= repayAmount, 'Insufficient balance');

        setExpectedCallback();
        if (token == IUniswapV2Pair(flashpair).token0())
            IUniswapV2Pair(flashpair).swap(repayAmount, 0, address(this), abi.encodePacked(repayAmount, msg.data[4:]));
        else IUniswapV2Pair(flashpair).swap(0, repayAmount, address(this), abi.encodePacked(repayAmount, msg.data[4:]));
    }

    function flashswapInPancake(
        uint256 maxRedeemAmount,
        address supplyToken,
        bytes calldata exchangeData
    ) internal {
        address[] memory tokens = abi.decode(abi.encodePacked(bytes32(uint256(0x20)), exchangeData[64:]), (address[]));

        (address token0, address token1) = tokens[0] < tokens[1] ? (tokens[0], tokens[1]) : (tokens[1], tokens[0]);
        IUniswapV2Pair flashpair = IUniswapV2Pair(IUniswapV2Factory(pancakeswapFactory).getPair(token0, token1));

        uint256 amountOut0;
        uint256 amountOut1;
        {
            (uint256 reserve0, uint256 reserve1, ) = flashpair.getReserves();
            (amountOut0, amountOut1) = token0 == supplyToken
                ? (uint256(0), (getAmountOut(maxRedeemAmount, reserve0, reserve1)))
                : (getAmountOut(maxRedeemAmount, reserve1, reserve0), uint256(0));
        }
        setExpectedCallback();
        flashpair.swap(amountOut0, amountOut1, address(this), abi.encodePacked(maxRedeemAmount, msg.data[4:])); // Leave msg.sig out
    }

    function pancakeCall(
        address,
        uint256 amount0Out,
        uint256 amount1Out,
        bytes calldata callbackData
    ) external {
        require(amount0Out == 0 || amount1Out == 0);
        clearCallback();

        bytes calldata msgData = callbackData[32:];

        address supplyToken = abi.decode(msgData[32:64], (address));
        address borrowToken = abi.decode(msgData[128:160], (address));

        if (supplyToken == borrowToken) {
            uint256 repayAmount = amount0Out > 0 ? amount0Out : amount1Out;

            address platform = abi.decode(msgData[0:32], (address));
            address lender = getLender(platform);

            repayBorrow(lender, platform, borrowToken, repayAmount);

            uint256 flashRepayAmount = repayAmount.add(repayAmount.mul(PANCAKESWAP_FEE_NUM).div(PANCAKESWAP_FEE_DEN));
            redeemSupply(lender, platform, supplyToken, flashRepayAmount);

            IERC20(supplyToken).safeTransfer(msg.sender, flashRepayAmount);

            return;
        }

        (, , , , , , bytes memory exchangeData) = abi.decode(
            msgData,
            (address, address, uint256, uint256, address, uint256, bytes)
        );

        (, address[] memory tokens) = abi.decode(exchangeData, (bytes1, address[]));
        if (tokens.length > 2) {
            address[] memory restOfPath = new address[](tokens.length - 1);
            for (uint256 i = 1; i < tokens.length; ) {
                restOfPath[i - 1] = tokens[i];
                ++i;
            }

            exchange(
                IExchangerAdapterProvider(aStore().foldingRegistry).getExchangerAdapter(exchangeData[0]),
                restOfPath[0],
                borrowToken,
                amount0Out > amount1Out ? amount0Out : amount1Out,
                1,
                abi.encode(exchangeData[0], restOfPath)
            );
        }

        address platform = abi.decode(msgData[0:32], (address));
        address lender = getLender(platform);

        repayBorrow(
            lender,
            platform,
            borrowToken,
            Math.min(getBorrowBalance(), IERC20(borrowToken).balanceOf(address(this)))
        );

        uint256 maxRedeemAmount = abi.decode(callbackData[:32], (uint256));
        redeemSupply(lender, platform, supplyToken, maxRedeemAmount);
        IERC20(supplyToken).safeTransfer(msg.sender, maxRedeemAmount);
    }

    /**
     * @return Encoded exchange data (bytes1, address[]) with reversed path
     */
    function reversePath(bytes memory exchangeData) public pure returns (bytes memory) {
        (bytes1 flag, address[] memory path) = abi.decode(exchangeData, (bytes1, address[]));

        uint256 length = path.length;
        address[] memory reversed = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            reversed[length - 1 - i] = path[i];
        }

        return abi.encode(flag, reversed);
    }

    function _getPositionValue(
        address lender,
        address platform,
        address supplyToken,
        address borrowToken
    ) private returns (uint256) {
        uint256 borrowBalanceValue = getBorrowBalance().mul(getReferencePrice(lender, platform, borrowToken)).div(
            getReferencePrice(lender, platform, supplyToken)
        );
        uint256 supplyBalanceValue = getSupplyBalance();
        if (borrowBalanceValue > supplyBalanceValue) return 0;

        return supplyBalanceValue - borrowBalanceValue;
    }

    function _swapExcessBorrowTokens(
        address supplyToken,
        address borrowToken,
        bytes memory exchangeData
    ) private {
        uint256 borrowTokenBalance = IERC20(borrowToken).balanceOf(address(this));
        if (borrowTokenBalance > 0) {
            bytes memory reversedExchangeData = reversePath(exchangeData);
            exchange(
                IExchangerAdapterProvider(aStore().foldingRegistry).getExchangerAdapter(reversedExchangeData[0]),
                borrowToken,
                supplyToken,
                borrowTokenBalance,
                1,
                reversedExchangeData
            );
        }
    }

    function _redeemAndWithdraw(
        address lender,
        address platform,
        address supplyToken,
        uint256 withdrawAmount,
        uint256 startPositionValue
    ) private {
        uint256 supplyTokenBalance = IERC20(supplyToken).balanceOf(address(this));
        if (withdrawAmount > supplyTokenBalance) {
            uint256 redeemAmount = withdrawAmount - supplyTokenBalance;
            if (redeemAmount > getSupplyBalance()) {
                redeemAll(lender, platform, supplyToken); // zero dust redeem
            } else {
                redeemSupply(lender, platform, supplyToken, redeemAmount);
            }
        }

        withdrawAmount = Math.min(withdrawAmount, IERC20(supplyToken).balanceOf(address(this))); // zero dust withdraw
        withdraw(withdrawAmount, startPositionValue); // if position value = 0, fund smanager will throw with a division by 0
    }

    function _claimRewards(address lender, address platform) private {
        (address rewardsToken, uint256 rewardsAmount) = claimRewards(lender, platform);
        if (rewardsToken != address(0)) {
            uint256 subsidy = rewardsAmount.mul(rewardsFactor).div(MANTISSA);
            if (subsidy > 0) {
                IERC20(rewardsToken).safeTransfer(holder, subsidy);
            }
            if (rewardsAmount > subsidy) {
                IERC20(rewardsToken).safeTransfer(accountOwner(), rewardsAmount - subsidy);
            }
        }
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint256 amountInWithFee = amountIn * 99750;
        uint256 numerator = amountInWithFee * (reserveOut);
        uint256 denominator = (reserveIn * (100000)) + (amountInWithFee);
        amountOut = numerator / denominator;
    }

    function setExpectedCallback() internal {
        aStore().callbackTarget = SELF_ADDRESS;
        aStore().expectedCallbackSig = this.pancakeCall.selector;
    }

    function clearCallback() internal {
        delete aStore().callbackTarget;
        delete aStore().expectedCallbackSig;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IFlashswapConnectorBSC {
    function decreaseSimplePositionWithFlashswap(
        address platform,
        address supplyToken,
        uint256 withdrawAmount,
        uint256 maxRedeemAmount,
        address borrowToken,
        uint256 minRepayAmount,
        bytes calldata exchangeData
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/utils/Address.sol';

import '../../../Fodl/modules/Lender/LendingDispatcher.sol';

interface ILendingPlatformBSC {
    function redeemAll(address platform, address token) external;

    function getLiquidity(address platform, address token) external returns (uint256);

    function accrueInterest(address platform, address token) external;
}

//  Delegates the calls to adapter
contract LendingDispatcherBSC is LendingDispatcher {
    using Address for address;

    function redeemAll(
        address adapter,
        address platform,
        address token
    ) internal {
        adapter.functionDelegateCall(abi.encodeWithSelector(ILendingPlatformBSC.redeemAll.selector, platform, token));
    }

    function getLiquidity(
        address adapter,
        address platform,
        address token
    ) internal returns (uint256 liquidity) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatformBSC.getLiquidity.selector, platform, token)
        );
        return abi.decode(returnData, (uint256));
    }

    function accrueInterest(
        address adapter,
        address platform,
        address token
    ) internal {
        adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatformBSC.accrueInterest.selector, platform, token)
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IVComptroller {
    enum Action {
        MINT,
        REDEEM,
        BORROW,
        REPAY,
        SEIZE,
        LIQUIDATE,
        TRANSFER,
        ENTER_MARKET,
        EXIT_MARKET
    }

    function oracle() external view returns (address);

    function getXVSAddress() external view returns (address);

    function enterMarkets(address[] calldata vTokens) external returns (uint256[] memory);

    function markets(address vTokenAddress)
        external
        view
        returns (
            bool isListed,
            uint256 collateralFactorMantissa,
            bool isVenus
        );

    function actionPaused(address market, Action action) external view returns (bool);

    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256 err,
            uint256 liquidity,
            uint256 shortfall
        );

    function getAssetsIn(address account) external view returns (address[] memory);

    function venusSpeeds(address vToken) external view returns (uint256);

    function claimVenus(address holder) external;

    function borrowAllowed(
        address vToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);
}

interface IVToken is IERC20 {
    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function balanceOfUnderlying(address account) external returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function totalReserves() external view returns (uint256);

    function getCash() external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function accrueInterest() external returns (uint256);
}

interface IVBNB is IVToken {
    function mint() external payable;

    function repayBorrow() external payable;
}

interface IVenusPriceOracle {
    function getUnderlyingPrice(address vToken) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

import '../../modules/Lender/LendingDispatcher.sol';
import '../../modules/SimplePosition/SimplePositionStorage.sol';
import '../interfaces/ISimplePositionBaseConnector.sol';

contract SimplePositionBaseConnector is LendingDispatcher, SimplePositionStorage, ISimplePositionBaseConnector {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function getBorrowBalance() public override returns (uint256) {
        return
            getBorrowBalance(
                getLender(simplePositionStore().platform),
                simplePositionStore().platform,
                simplePositionStore().borrowToken
            );
    }

    function getSupplyBalance() public override returns (uint256) {
        return
            getSupplyBalance(
                getLender(simplePositionStore().platform),
                simplePositionStore().platform,
                simplePositionStore().supplyToken
            );
    }

    function getCollateralUsageFactor() public override returns (uint256) {
        return getCollateralUsageFactor(getLender(simplePositionStore().platform), simplePositionStore().platform);
    }

    function getPositionValue() public override returns (uint256 positionValue) {
        SimplePositionStore memory sp = simplePositionStore();
        address lender = getLender(sp.platform);

        uint256 debt = getBorrowBalance(lender, sp.platform, sp.borrowToken);
        uint256 deposit = getSupplyBalance(lender, sp.platform, sp.supplyToken);
        debt = debt.mul(getReferencePrice(lender, sp.platform, sp.borrowToken)).div(
            getReferencePrice(lender, sp.platform, sp.supplyToken)
        );
        if (deposit >= debt) {
            positionValue = deposit - debt;
        } else {
            positionValue = 0;
        }
    }

    function getPrincipalValue() public override returns (uint256) {
        return simplePositionStore().principalValue;
    }

    function getPositionMetadata() external override returns (SimplePositionMetadata memory metadata) {
        metadata.positionAddress = address(this);
        metadata.platformAddress = simplePositionStore().platform;
        metadata.supplyTokenAddress = simplePositionStore().supplyToken;
        metadata.borrowTokenAddress = simplePositionStore().borrowToken;
        metadata.supplyAmount = getSupplyBalance();
        metadata.borrowAmount = getBorrowBalance();
        metadata.collateralUsageFactor = getCollateralUsageFactor();
        metadata.principalValue = getPrincipalValue();
        metadata.positionValue = getPositionValue();
    }

    function getSimplePositionDetails()
        external
        view
        override
        returns (
            address,
            address,
            address
        )
    {
        SimplePositionStore storage sp = simplePositionStore();
        return (sp.platform, sp.supplyToken, sp.borrowToken);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

struct SimplePositionMetadata {
    uint256 supplyAmount;
    uint256 borrowAmount;
    uint256 collateralUsageFactor;
    uint256 principalValue;
    uint256 positionValue;
    address positionAddress;
    address platformAddress;
    address supplyTokenAddress;
    address borrowTokenAddress;
}

interface ISimplePositionBaseConnector {
    function getBorrowBalance() external returns (uint256);

    function getSupplyBalance() external returns (uint256);

    function getPositionValue() external returns (uint256);

    function getPrincipalValue() external returns (uint256);

    function getCollateralUsageFactor() external returns (uint256);

    function getSimplePositionDetails()
        external
        view
        returns (
            address,
            address,
            address
        );

    function getPositionMetadata() external returns (SimplePositionMetadata memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IExchangerAdapterProvider {
    function getExchangerAdapter(byte flag) external view returns (address exchangerAdapter);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ILendingPlatformAdapterProvider {
    function getPlatformAdapter(address platform) external view returns (address platformAdapter);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import '@openzeppelin/contracts/utils/Address.sol';

import './IExchanger.sol';

contract ExchangerDispatcher {
    using Address for address;

    function exchange(
        address adapter,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        bytes memory txData
    ) internal returns (uint256) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(IExchanger.exchange.selector, fromToken, toToken, fromAmount, minToAmount, txData)
        );
        return abi.decode(returnData, (uint256));
    }

    function swapToExact(
        address adapter,
        address fromToken,
        address toToken,
        uint256 maxFromAmount,
        uint256 toAmount
    ) internal returns (uint256) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(IExchanger.swapToExact.selector, fromToken, toToken, maxFromAmount, toAmount)
        );
        return abi.decode(returnData, (uint256));
    }

    function swapFromExact(
        address adapter,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount
    ) internal returns (uint256) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(IExchanger.swapFromExact.selector, fromToken, toToken, fromAmount, minToAmount)
        );
        return abi.decode(returnData, (uint256));
    }

    function getAmountOut(
        address adapter,
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) internal returns (uint256) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(IExchanger.getAmountOut.selector, fromToken, toToken, fromAmount)
        );
        return abi.decode(returnData, (uint256));
    }

    function getAmountIn(
        address adapter,
        address fromToken,
        address toToken,
        uint256 toAmount
    ) internal returns (uint256) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(IExchanger.getAmountIn.selector, fromToken, toToken, toAmount)
        );
        return abi.decode(returnData, (uint256));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IExchanger {
    function exchange(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        bytes calldata txData
    ) external returns (uint256 toAmount);

    function getAmountOut(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view returns (uint256 toAmount);

    function getAmountIn(
        address fromToken,
        address toToken,
        uint256 toAmount
    ) external view returns (uint256 fromAmount);

    function swapFromExact(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount
    ) external returns (uint256 toAmount);

    function swapToExact(
        address fromToken,
        address toToken,
        uint256 maxFromAmount,
        uint256 toAmount
    ) external returns (uint256 fromAmount);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

contract FoldingAccountStorage {
    bytes32 constant ACCOUNT_STORAGE_POSITION = keccak256('folding.account.storage');

    /**
     * entryCaller:         address of the caller of the account, during a transaction
     *
     * callbackTarget:      address of logic to be run when expecting a callback
     *
     * expectedCallbackSig: signature of function to be run when expecting a callback
     *
     * foldingRegistry      address of factory creating FoldingAccount
     *
     * nft:                 address of the nft contract.
     *
     * owner:               address of the owner of this FoldingAccount.
     */
    struct AccountStore {
        address entryCaller;
        address callbackTarget;
        bytes4 expectedCallbackSig;
        address foldingRegistry;
        address nft;
        address owner;
    }

    modifier onlyAccountOwner() {
        AccountStore storage s = aStore();
        require(s.entryCaller == s.owner, 'FA2');
        _;
    }

    modifier onlyNFTContract() {
        AccountStore storage s = aStore();
        require(s.entryCaller == s.nft, 'FA3');
        _;
    }

    modifier onlyAccountOwnerOrRegistry() {
        AccountStore storage s = aStore();
        require(s.entryCaller == s.owner || s.entryCaller == s.foldingRegistry, 'FA4');
        _;
    }

    function aStore() internal pure returns (AccountStore storage s) {
        bytes32 position = ACCOUNT_STORAGE_POSITION;
        assembly {
            s_slot := position
        }
    }

    function accountOwner() internal view returns (address) {
        return aStore().owner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

import '../SimplePosition/SimplePositionStorage.sol';
import '../FoldingAccount/FoldingAccountStorage.sol';

contract FundsManager is FoldingAccountStorage, SimplePositionStorage {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 internal constant MANTISSA = 1e18;

    uint256 public immutable principal;
    uint256 public immutable profit;
    address public immutable holder;

    event FundsWithdrawal(uint256 withdrawAmount, uint256 principalFactor);

    constructor(
        uint256 _principal,
        uint256 _profit,
        address _holder
    ) public {
        require(_principal < MANTISSA, 'ICP1');
        require(_profit < MANTISSA, 'ICP1');
        require(_holder != address(0), 'ICP0');
        principal = _principal;
        profit = _profit;
        holder = _holder;
    }

    function addPrincipal(uint256 amount) internal {
        IERC20(simplePositionStore().supplyToken).safeTransferFrom(accountOwner(), address(this), amount);
        simplePositionStore().principalValue += amount;
    }

    function withdraw(uint256 amount, uint256 positionValue) internal {
        SimplePositionStore memory sp = simplePositionStore();

        uint256 principalFactor = positionValue == 0 ? MANTISSA : sp.principalValue.mul(MANTISSA).div(positionValue);

        uint256 principalShare = amount;
        uint256 profitShare;

        if (principalFactor < MANTISSA) {
            principalShare = amount.mul(principalFactor) / MANTISSA;
            profitShare = amount.sub(principalShare);
        }

        uint256 subsidy = principalShare.mul(principal).add(profitShare.mul(profit)) / MANTISSA;

        if (sp.principalValue > principalShare) {
            simplePositionStore().principalValue = sp.principalValue - principalShare;
        } else {
            simplePositionStore().principalValue = 0;
        }

        IERC20(sp.supplyToken).safeTransfer(holder, subsidy);
        IERC20(sp.supplyToken).safeTransfer(accountOwner(), amount.sub(subsidy));
        emit FundsWithdrawal(amount, principalFactor);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/// @dev All factors or APYs are written as a number with mantissa 18.
struct AssetMetadata {
    address assetAddress;
    string assetSymbol;
    uint8 assetDecimals;
    uint256 referencePrice;
    uint256 totalLiquidity;
    uint256 totalSupply;
    uint256 totalBorrow;
    uint256 totalReserves;
    uint256 supplyAPR;
    uint256 borrowAPR;
    address rewardTokenAddress;
    string rewardTokenSymbol;
    uint8 rewardTokenDecimals;
    uint256 estimatedSupplyRewardsPerYear;
    uint256 estimatedBorrowRewardsPerYear;
    uint256 collateralFactor;
    uint256 liquidationFactor;
    bool canSupply;
    bool canBorrow;
}

interface ILendingPlatform {
    function getAssetMetadata(address platform, address asset) external returns (AssetMetadata memory assetMetadata);

    function getCollateralUsageFactor(address platform) external returns (uint256 collateralUsageFactor);

    function getCollateralFactorForAsset(address platform, address asset) external returns (uint256);

    function getReferencePrice(address platform, address token) external returns (uint256 referencePrice);

    function getBorrowBalance(address platform, address token) external returns (uint256 borrowBalance);

    function getSupplyBalance(address platform, address token) external returns (uint256 supplyBalance);

    function claimRewards(address platform) external returns (address rewardsToken, uint256 rewardsAmount);

    function enterMarkets(address platform, address[] memory markets) external;

    function supply(
        address platform,
        address token,
        uint256 amount
    ) external;

    function borrow(
        address platform,
        address token,
        uint256 amount
    ) external;

    function redeemSupply(
        address platform,
        address token,
        uint256 amount
    ) external;

    function repayBorrow(
        address platform,
        address token,
        uint256 amount
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/utils/Address.sol';

import './ILendingPlatform.sol';
import '../../core/interfaces/ILendingPlatformAdapterProvider.sol';
import '../../modules/FoldingAccount/FoldingAccountStorage.sol';

contract LendingDispatcher is FoldingAccountStorage {
    using Address for address;

    function getLender(address platform) internal view returns (address) {
        return ILendingPlatformAdapterProvider(aStore().foldingRegistry).getPlatformAdapter(platform);
    }

    function getCollateralUsageFactor(address adapter, address platform)
        internal
        returns (uint256 collateralUsageFactor)
    {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getCollateralUsageFactor.selector, platform)
        );
        return abi.decode(returnData, (uint256));
    }

    function getCollateralFactorForAsset(
        address adapter,
        address platform,
        address asset
    ) internal returns (uint256) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getCollateralFactorForAsset.selector, platform, asset)
        );
        return abi.decode(returnData, (uint256));
    }

    /// @dev precision and decimals are expected to follow Compound 's pattern (1e18 precision, decimals taken into account).
    /// Currency in which the price is expressed is different depending on the platform that is being queried
    function getReferencePrice(
        address adapter,
        address platform,
        address asset
    ) internal returns (uint256 referencePrice) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getReferencePrice.selector, platform, asset)
        );
        return abi.decode(returnData, (uint256));
    }

    function getBorrowBalance(
        address adapter,
        address platform,
        address token
    ) internal returns (uint256 borrowBalance) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getBorrowBalance.selector, platform, token)
        );
        return abi.decode(returnData, (uint256));
    }

    function getSupplyBalance(
        address adapter,
        address platform,
        address token
    ) internal returns (uint256 supplyBalance) {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.getSupplyBalance.selector, platform, token)
        );
        return abi.decode(returnData, (uint256));
    }

    function enterMarkets(
        address adapter,
        address platform,
        address[] memory markets
    ) internal {
        adapter.functionDelegateCall(abi.encodeWithSelector(ILendingPlatform.enterMarkets.selector, platform, markets));
    }

    function claimRewards(address adapter, address platform)
        internal
        returns (address rewardsToken, uint256 rewardsAmount)
    {
        bytes memory returnData = adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.claimRewards.selector, platform)
        );
        return abi.decode(returnData, (address, uint256));
    }

    function supply(
        address adapter,
        address platform,
        address token,
        uint256 amount
    ) internal {
        adapter.functionDelegateCall(abi.encodeWithSelector(ILendingPlatform.supply.selector, platform, token, amount));
    }

    function borrow(
        address adapter,
        address platform,
        address token,
        uint256 amount
    ) internal {
        adapter.functionDelegateCall(abi.encodeWithSelector(ILendingPlatform.borrow.selector, platform, token, amount));
    }

    function redeemSupply(
        address adapter,
        address platform,
        address token,
        uint256 amount
    ) internal {
        adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.redeemSupply.selector, platform, token, amount)
        );
    }

    function repayBorrow(
        address adapter,
        address platform,
        address token,
        uint256 amount
    ) internal {
        adapter.functionDelegateCall(
            abi.encodeWithSelector(ILendingPlatform.repayBorrow.selector, platform, token, amount)
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

contract SimplePositionStorage {
    bytes32 private constant SIMPLE_POSITION_STORAGE_LOCATION = keccak256('folding.simplePosition.storage');

    /**
     * platform:        address of the underlying platform (AAVE, COMPOUND, etc)
     *
     * supplyToken:     address of the token that is being supplied to the underlying platform
     *                  This token is also the principal token
     *
     * borrowToken:     address of the token that is being borrowed to leverage on supply token
     *
     * principalValue:  amount of supplyToken that user has invested in this position
     */
    struct SimplePositionStore {
        address platform;
        address supplyToken;
        address borrowToken;
        uint256 principalValue;
    }

    function simplePositionStore() internal pure returns (SimplePositionStore storage s) {
        bytes32 position = SIMPLE_POSITION_STORAGE_LOCATION;
        assembly {
            s_slot := position
        }
    }

    function isSimplePosition() internal view returns (bool) {
        return simplePositionStore().platform != address(0);
    }

    function requireSimplePositionDetails(
        address platform,
        address supplyToken,
        address borrowToken
    ) internal view {
        require(simplePositionStore().platform == platform, 'SP2');
        require(simplePositionStore().supplyToken == supplyToken, 'SP3');
        require(simplePositionStore().borrowToken == borrowToken, 'SP4');
    }
}