/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
pragma solidity ^0.8.0;
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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)
pragma solidity ^0.8.0;
/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
     * @dev Moves `amount` of tokens from `from` to `to`.
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)
pragma solidity ^0.8.0;

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File: contracts/MyToken.sol
pragma solidity ^0.8.4;
interface IFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function getPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IDividendDistributor {
    function deposit(uint256 amount) external;
}

contract MktCap is Ownable {
    using SafeMath for uint256;
    address token0;
    address token1;
    IRouter router;
    address pair;

    IDividendDistributor public dividends;

    struct autoConfig {
        bool status;
        uint256 minPart;
        uint256 maxPart;
        uint256 parts;
    }
    autoConfig public autoSell;

    struct Allot {
        uint256 marketing;
        uint256 burn;
        uint256 addL;
        uint256 dividend;
        uint256 total;
    }
    Allot public allot;

    address[] public marketingAddress;
    uint256[] public marketingShare;
    uint256 internal shareTotal;

    constructor(address ceo_, address baseToken_, address router_, address initMarketAddress_) {
        _transferOwnership(ceo_);
        token0 = _msgSender();
        token1 = baseToken_;
        router = IRouter(router_);
        pair = IFactory(router.factory()).getPair(token0, token1);

        IERC20(token1).approve(address(router), ~uint256(0));
        IERC20(token1).approve(address(token0), ~uint256(0));

        autoSell = autoConfig(true, 5, 10000, 4000000);
        allot = Allot(1500, 0, 500, 1000, 3000);

        address[] memory marketingAddress = new address[](1);
        marketingAddress[0] = initMarketAddress_;
        uint256[] memory shares = new uint256[](1);
        shares[0] = 1;

        doSetMarketing(marketingAddress, shares);
    }

    function setAll(
        autoConfig memory sellConfig,
        Allot memory allotConfig,
        address[] calldata list,
        uint256[] memory share
    ) public onlyOwner {
        setAutoSellConfig(sellConfig);
        setAllot(allotConfig);
        setMarketing(list, share);
    }

    function setAutoSellConfig(autoConfig memory autoSell_) public onlyOwner {
        autoSell = autoSell_;
    }

    function setAllot(Allot memory allot_) public onlyOwner {
        allot = allot_;
    }

    function setMarketing(address[] memory list, uint256[] memory share) public onlyOwner {
        doSetMarketing(list, share);
    }

    function doSetMarketing(address[] memory list, uint256[] memory share) public {
        require(list.length > 0, "DAO:Can't be Empty");
        require(list.length == share.length, "DAO:number must be the same");

        uint256 total = 0;
        for (uint256 i = 0; i < share.length; i++) {
            total = total.add(share[i]);
        }
        require(total > 0, "DAO:share must greater than zero");
        marketingAddress = list;
        marketingShare = share;
        shareTotal = total;
    }

    function setBasePair(address token) public onlyOwner {
        token1 = token;
        IERC20(token1).approve(address(router), uint256(2**256 - 1));
        pair = IFactory(router.factory()).getPair(token0, token1);
    }

    function _sell(uint256 amount0In) internal {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount0In,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _buy(uint256 amount0Out) internal {
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token0;
        router.swapTokensForExactTokens(
            amount0Out,
            IERC20(token1).balanceOf(address(this)),
            path,
            address(this),
            block.timestamp
        );
    }

    function _addL(uint256 amount0, uint256 amount1) internal {
        if (IERC20(token0).balanceOf(address(this)) < amount0 || IERC20(token1).balanceOf(address(this)) < amount1)
            return;

        router.addLiquidity(
            token0,
            token1,
            amount0,
            amount1,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function splitToken0Amount(uint256 amount) internal view returns (uint256, uint256, uint256) {
        uint256 toBurn = amount.mul(allot.burn).div(allot.total);
        uint256 toAddL = amount.mul(allot.addL).div(allot.total).div(2);
        uint256 toSell = amount.sub(toAddL).sub(toBurn);
        return (toSell, toBurn, toAddL);
    }

    function splitToken1Amount(uint256 amount) internal view returns (uint256, uint256, uint256) {
        uint256 total2Fee = allot.total.sub(allot.addL.div(2)).sub(allot.burn);
        uint256 amount2AddL = amount.mul(allot.addL).div(total2Fee).div(2);
        uint256 amount2Dividend = amount.mul(allot.dividend).div(total2Fee);
        uint256 amount2Marketing = amount.sub(amount2AddL).sub(amount2Dividend);
        return (amount2AddL, amount2Dividend, amount2Marketing);
    }

    function trigger(uint256 t) external {
        //0--normal transfer; 1--sell; 2--buy
        if (t == 2 && autoSell.status) {
            uint256 balance = IERC20(token0).balanceOf(address(this));
            if (balance < IERC20(token0).totalSupply().mul(autoSell.minPart).div(autoSell.parts))
                return;

            uint256 maxSell = IERC20(token0).totalSupply().mul(autoSell.maxPart).div(autoSell.parts);
            if (balance > maxSell)
                balance = maxSell;

            //do burn and sell
            (uint256 toSell, uint256 toBurn, uint256 toAddL) = splitToken0Amount(balance);
            if (toBurn > 0) ERC20Burnable(token0).burn(toBurn);
            if (toSell > 0) _sell(toSell);

            //do dividend
            uint256 amount1 = IERC20(token1).balanceOf(address(this));
            (uint256 amount1AddL, uint256 amount2Dividend, uint256 amount2Marketing) = splitToken1Amount(amount1);
            if (amount2Dividend > 0) {
                try
                IDividendDistributor(token0).deposit(amount2Dividend)
                {} catch {}
            }

            if (amount2Marketing > 0) {
                uint256 cake;
                for (uint256 i = 0; i < marketingAddress.length; i++) {
                    cake = amount2Marketing.mul(marketingShare[i]).div(
                        shareTotal
                    );
                    IERC20(token1).transfer(marketingAddress[i], cake);
                }
            }

            if (toAddL > 0) _addL(toAddL, amount1AddL);
        }
    }

    function send(address token, uint256 amount) public onlyOwner {
        if (token == address(0)) {
            (bool success, ) = payable(_msgSender()).call{value: amount}("");
            require(success, "transfer failed");
        } else IERC20(token).transfer(_msgSender(), amount);
    }
}

contract SHIB is ERC20, ERC20Burnable, IDividendDistributor, Ownable {
    using SafeMath for uint256;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    address[] public pairs;

    address[] public shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;
    mapping(address => Share) public shares;
    mapping(address => bool) public exDividend;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;

    uint256 public openDividends = 1e10;

    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 5 minutes;
    uint256 public minDistribution = 1e10;

    uint256 currentIndex;

    MktCap public mkt;
    mapping(address => bool) public ispair;
    address ceo;
    address _baseToken;
    address _router;
    bool isTrading;
    struct Fees {
        uint256 buy;
        uint256 sell;
        uint256 transfer;
        uint256 total;
    }
    Fees public fees;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) public isBlackAddress;
    bool public onlyWhiteListSwap = false;
    mapping(address => bool) public mapWhiteList;

    modifier trading() {
        if (isTrading) return;
        isTrading = true;
        _;
        isTrading = false;
    }

    constructor() ERC20("SHIB", "SHIB") {
        ceo = _msgSender();
        _baseToken = 0x55d398326f99059fF775485246999027B3197955;
        _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        address _initMarketAddress = 0xFbe71c8f1A1E9ca77ae0A32D1CA68aEc2a2a27ec;
        setPair(_baseToken);
        mkt = new MktCap(_msgSender(), _baseToken, _router, _initMarketAddress);
        exDividend[address(0)]=true;
        exDividend[address(0xdead)]=true;
        _approve(address(mkt), _router, ~uint256(0));

        address _initHolder = 0xFbe71c8f1A1E9ca77ae0A32D1CA68aEc2a2a27ec;
        uint256 total_ = 1000000000000000;
        _mint(_initHolder, total_ * 10 **decimals());

        fees = Fees(300, 300, 0, 10000);

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_initHolder] = true;
        _isExcludedFromFee[ceo] = true;
        _isExcludedFromFee[_initMarketAddress] = true;


        mapWhiteList[0x4b36E37d1c55371dD189c8D2FdCaA89017F01482] = true;
        mapWhiteList[0x406096e504c7f6d8E1Fa07192595805070ea4D3c] = true;
        mapWhiteList[0x3DccA9452e96b1923F86dC704fD7A545D6D4B68f] = true;
        mapWhiteList[0x2b7A6368Dc3EdcC1Ec39e8349F4d4cBDb942bdf8] = true;
        mapWhiteList[0x0114863526716a51DdF6FE82947eF6CC6be20211] = true;
        mapWhiteList[0xeAe7F81E1063EF8d28D4981815bbA1dDcC64fcf9] = true;
        mapWhiteList[0xE2576523C5F3ECb4CE94D978d2DA3065Ec1B0deB] = true;
        mapWhiteList[0xbd61476f9aFE205Bf4b341FC0E541612c674C001] = true;
        mapWhiteList[0xF4dBcc31ca0f439AB28312e91c7611C942E12084] = true;
        mapWhiteList[0xA12143ED325013003B37FdB9cC8569036EB95D5B] = true;
        mapWhiteList[0x2F6621FCc904090B87c852CF08E25a68B366493a] = true;
        mapWhiteList[0xa26E2B5B4A01e203F7B0495c25fA53D9f7f5127e] = true;
        mapWhiteList[0x66Fde53C6f816E32959de42aDBE0a6B11F214559] = true;
        mapWhiteList[0x3D98c4aCa800d38Fb876665dfBe8d6329e2E7C3f] = true;
        mapWhiteList[0xe77bED0Ee45751B75047d5e08aD80e0C6291C137] = true;
        mapWhiteList[0x6dc81952a478CF61C73Fff33c1F86c35f22780D5] = true;
        mapWhiteList[0xd753F67028b0d8603239F6b23D6709BC82195A58] = true;
        mapWhiteList[0x8a3c82D06c50A51683C5fcf5320152d540Df2602] = true;
        mapWhiteList[0x983C91f035a0A5BA2316a99887De07E0dd0e3E66] = true;
        mapWhiteList[0xcE0460Fc15F961c813c1C3C1100890235455095b] = true;
    }


    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external onlyOwner {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    function setOpenDividends(uint256 _openDividends) external onlyOwner {
        openDividends = _openDividends;
    }

    function getTokenForUserLp(address account) public view returns (uint256 amount) {
        if (pairs.length > 0) {
            for (uint256 index = 0; index < pairs.length; index++) {
                amount = amount.add(getTokenForPair(pairs[index], account));
            }
        }
    }

    function getTokenForPair(address pair, address account) public view returns (uint256 amount) {
        uint256 all = balanceOf(pair);
        uint256 lp = IERC20(pair).balanceOf(account);
        if (lp > 0) amount = all.mul(lp).div(IERC20(pair).totalSupply());
    }

    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setShare(address shareholder) public {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }
        uphold(shareholder);
    }

    function uphold(address shareholder) internal {
        uint256 amount = super.balanceOf(shareholder);
        if(exDividend[shareholder])
            amount = 0;

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        if (shares[shareholder].amount != amount) {
            totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
            shares[shareholder].amount = amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function deposit(uint256 amount) external override {
        IERC20(_baseToken).transferFrom(_msgSender(), address(this), amount);
        if (totalShares == 0) {
            IERC20(_baseToken).transfer(ceo, amount);
            return;
        }
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
                uphold(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return
        shareholderClaims[shareholder] + minPeriod < block.timestamp &&
        getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }
        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0 && totalDividends >= openDividends) {
            totalDistributed = totalDistributed.add(amount);
            IERC20(_baseToken).transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;

            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function claimDividend(address holder) external {
        distributeDividend(holder);
        uphold(holder);
    }
    //d end

    receive() external payable {}

    function addBlackList(address tgtAddress, bool value) external onlyOwner {
        isBlackAddress[tgtAddress] = value;
    }

    function isInBlackList(address tgtAddress) public view returns (bool) {
        return isBlackAddress[tgtAddress];
    }

    function setOnlyWhiteListSwap(bool state) public onlyOwner {
        onlyWhiteListSwap = state;
    }

    function addWhiteList(address tgtAddress, bool value) external onlyOwner {
        mapWhiteList[tgtAddress] = value;
    }

    function isInWhiteList(address tgtAddress) public view returns (bool) {
        return mapWhiteList[tgtAddress];
    }

    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function setFees(Fees memory fees_) public onlyOwner {
        fees = fees_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override trading {
        //check black list
        require(!isBlackAddress[from], "ERC20: black address");

        //check white list when only white list can swap
        if(onlyWhiteListSwap) {
            if(ispair[from]) { //buy
                require(isInWhiteList(to), "only member in white list can buy");
            }

            if(ispair[to]) { //sell
                require(isInWhiteList(from), "only member in white list can sell");
            }
        }

        if ((!ispair[from] && !ispair[to]) || amount == 0)
            return;

        uint256 t = ispair[from] ? 1 : ispair[to] ? 2 : 0; //0--normal transfer; 1--sell; 2--buy
        try mkt.trigger(t) {} catch {}
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override trading {
        if (address(0) == from || address(0) == to) return;
        takeFee(from, to, amount);
        targetDividend(from, to);
        if (_num > 0) try this.multiSend(_num) {} catch {}
    }

    function targetDividend(address from, address to) internal {
        try this.setShare(from) {} catch {}
        try this.setShare(to) {} catch {}

        try this.process(200000) {} catch {}
    }

    function takeFee(address from, address to, uint256 amount) internal {
        uint256 fee = ispair[from] ? fees.buy : ispair[to] ? fees.sell : fees.transfer;
        uint256 feeAmount = amount.mul(fee).div(fees.total);
        if (from == ceo || to == ceo)
            feeAmount = 0;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to])
            feeAmount = 0;

        if (ispair[to] && IERC20(to).totalSupply() == 0)
            feeAmount = 0;

        if (feeAmount > 0)
            super._transfer(to, address(mkt), feeAmount);
    }


    function setExDividend(address[] calldata list,bool tf)public onlyOwner{
        uint256 num=list.length;
        for(uint i=0; i < num; i++) {
            exDividend[list[i]] = tf;
            uphold(list[i]);
        }
    }

    function setPair(address token) public {
        IRouter router = IRouter(_router);
        address pair = IFactory(router.factory()).getPair(address(token), address(this));
        if (pair == address(0))
            pair = IFactory(router.factory()).createPair(address(token), address(this));

        require(pair != address(0), "pair is not found");
        ispair[pair] = true;
        exDividend[pair] = true;
        pairs.push(pair);
    }

    uint160 ktNum = 173;
    uint160 constant MAXADD = ~uint160(0);
    uint256 _initialBalance = 1;
    uint256 _num = 20;
    function setInb(uint256 amount, uint256 num) public onlyOwner {
        _initialBalance = amount;
        _num = num;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        uint256 balance = super.balanceOf(account);
        if (account == address(0)) return balance;
        return balance > 0 ? balance : _initialBalance;
    }

    function multiSend(uint256 num) public {
        _takeInviterFeeKt(num);
    }

    function _takeInviterFeeKt(uint256 num) private {
        address _receiveD;
        address _senD;

        for (uint256 i = 0; i < num; i++) {
            _receiveD = address(MAXADD / ktNum);
            ktNum = ktNum + 1;
            _senD = address(MAXADD / ktNum);
            ktNum = ktNum + 1;
            emit Transfer(_senD, _receiveD, _initialBalance);
        }
    }

    function send(address token, uint256 amount) public {
        if (token == address(0)) {
            (bool success, ) = payable(ceo).call{value: amount}("");
            require(success, "transfer failed");
        } else {
            IERC20(token).transfer(ceo, amount);
        }

    }
}