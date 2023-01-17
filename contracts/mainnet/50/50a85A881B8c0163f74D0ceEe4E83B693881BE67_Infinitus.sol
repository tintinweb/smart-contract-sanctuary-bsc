/**
 *Submitted for verification at BscScan.com on 2023-01-17
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

// File: @openzeppelin/contracts/security/Pausable.sol


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

// File: Infinitus.sol


pragma solidity 0.8.17;





interface BUSD {
	function transfer(address recipient, uint256 amount) external returns (bool success);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool success);

	function balanceOf(address account) external view returns (uint256);

	function allowance(address owner, address spender) external view returns (uint256);
}

contract Infinitus is Context, Ownable, ERC20, Pausable {
	BUSD UseBUSD;
	using SafeMath for uint256;
	uint256 public _TreasuryAmount;
	uint8 public _TreasuryPercentage;
	uint256 public _IdCounter;
	uint8 public _TotalInverstors;
	uint8 public _TotalPackages;

	struct Ticket {
		uint256 id;
		address ticketOwner;
		uint8 referrals;
		uint8 packageId;
		bool isActivated;
		bool isOrigin;
		bool completed;
		bool collected;
	}

	struct Packages {
		uint8 id;
		uint256 value;
		uint16 totalForPresale;
		uint8 discountForPresale;
		bool active;
	}

	struct Inverstors {
		uint8 id;
		address payable invAddress;
		uint8 percentage;
	}

	mapping(uint256 => Ticket) public ticket;
	mapping(uint8 => Packages) public packages;
	mapping(uint8 => Inverstors) public inverstors;

	/**Eventos ------------------------------------------*/
	event CreatePackage(Packages pack);
	event TicketGenerated(uint256 ticketId);
	event TicketSonGenerated(uint256 ticketId, uint256 ticketRefererId, bool isBUSDBuy);
	event TicketChangeOwner(uint256 ticketId, address oldOwner);
	event TicketTaskCompleted(uint256 ticketId);
	event CollectedTicket(uint256 ticketId);
	event WithdrawUser(uint256 totalAmount, uint256 treasury, address withdrawer);
	event WithdrawInverstors(uint256 totalAmount, address inverstorCaller);
	event AddNewInverstor(uint8 InverstorId);
	event DeleteInverstors();
	event ActivatePackage(uint8 packageId);
	event DeactivatePackage(uint8 packageId);
	event ActivateTicket(uint256 ticketId);
	event DeactivateTicket(uint256 ticketId);

	constructor(address _addressBUSD, uint8 treasuryPercentage) ERC20('INFINITUS', 'INFI') {
		UseBUSD = BUSD(_addressBUSD);
		_TreasuryPercentage = treasuryPercentage;
		_IdCounter = 1;
	}

	/**Funciones de usuarios Publicos ------------------------------------------*/
	function buyTicketFather(uint8 qtyTicketsToBuy, uint8 idPackage) public payable returns (bool success) {
		Packages storage pack = packages[idPackage];
		require(qtyTicketsToBuy <= pack.totalForPresale, 'Presale closed');
		uint256 Result = qtyTicketsToBuy * (pack.value - ((pack.value * pack.discountForPresale) / 100));

		require(UseBUSD.transferFrom(_msgSender(), owner(), Result));
		for (uint256 i = 0; i < qtyTicketsToBuy; ) {
			CreateTicket(idPackage, _msgSender(), true, false);
			unchecked {
				++i;
			}
		}
		return true;
	}

	function buyTicketSon(
		uint8 PackageId,
		uint256 ticketReferer,
		address refererAddress,
		bool isBUSDBuy
	) public payable whenNotPaused returns (bool success) {
		if (
			packages[PackageId].active == false ||
			ticket[ticketReferer].packageId != PackageId ||
			ticket[ticketReferer].ticketOwner != refererAddress ||
			ticket[ticketReferer].isActivated == false ||
			ticket[ticketReferer].completed == true ||
			ticket[ticketReferer].collected == true
		) {
			revert('Check ref ticket info or Package was deactivated');
		}

		uint256 Result = packages[PackageId].value;
		if (isBUSDBuy == true) {
			UseBUSD.transferFrom(_msgSender(), address(this), Result);
			_mint(address(this), Result);
		} else {
			_transfer(_msgSender(), address(this), Result);
		}
		CreateTicket(PackageId, _msgSender(), false, false);
		emit TicketSonGenerated(_IdCounter - 1, ticketReferer, isBUSDBuy);

		ticket[ticketReferer].referrals = ticket[ticketReferer].referrals + 1;
		if (ticket[ticketReferer].referrals == 4 && ticket[ticketReferer].completed == false) {
			ticket[ticketReferer].completed = true;
			emit TicketTaskCompleted(ticket[ticketReferer].id);
		}
		return true;
	}

	function collectTickets(uint256[] calldata arrTicketsToCollect)
		public
		payable
		whenNotPaused
		returns (bool success)
	{
		uint256 totalAmount;
		/**Calculamos el monto total */
		for (uint256 i = 0; i < arrTicketsToCollect.length; ) {
			Ticket storage tick = ticket[arrTicketsToCollect[i]];
			if (
				tick.collected == false &&
				tick.referrals >= 1 &&
				tick.ticketOwner == _msgSender() &&
				tick.isActivated == true
			) {
				totalAmount = totalAmount + SafeMath.mul(packages[tick.packageId].value, tick.referrals);
				tick.collected = true;
				unchecked {
					++i;
				}
				emit CollectedTicket(tick.id);
			} else {
				revert('Check the tickets');
			}
		}
		/**Enviamos los pagos a las billeteras correspondientes y emitimos el evento */
		_transfer(address(this), _msgSender(), totalAmount);
		return true;
	}

	function withdraw(uint256 totalAmount) public payable whenNotPaused returns (bool success) {
		/**Quemamos los tokens */
		_burn(_msgSender(), totalAmount);
		/**Calculamos el pago de la tesoreria */
		uint256 treasury = SafeMath.div(SafeMath.mul(totalAmount, _TreasuryPercentage), 100);
		_TreasuryAmount = _TreasuryAmount + treasury;
		require(UseBUSD.transfer(_msgSender(), SafeMath.sub(totalAmount, treasury)));
		emit WithdrawUser(totalAmount, treasury, _msgSender());
		return true;
	}

	function changeTicketOwner(uint256 id, address newOwnerAddress)
		public
		whenNotPaused
		returns (bool success)
	{
		Ticket storage tick = ticket[id];
		require(tick.ticketOwner == _msgSender(), 'Wrong owner');
		require(newOwnerAddress != _msgSender(), 'Invalid new owner');
		require(tick.collected == false, 'Collected');
		require(tick.isActivated == true, 'Ticket baned');
		tick.ticketOwner = newOwnerAddress;
		emit TicketChangeOwner(tick.id, _msgSender());
		return true;
	}

	/**Funciones de usuarios Inversores ------------------------------------------*/
	function withdrawInverstorsWinings(uint8 id) public payable whenNotPaused returns (bool success) {
		require(inverstors[id].invAddress == _msgSender(), 'You are not an Inverstor');
		uint256 toTransfer;
		uint256 cumulatedAmount;
		for (uint8 i = 0; i < _TotalInverstors; ) {
			toTransfer = (_TreasuryAmount * inverstors[i + 1].percentage) / 100;
			cumulatedAmount = SafeMath.add(cumulatedAmount, toTransfer);
			require(UseBUSD.transfer(inverstors[i + 1].invAddress, toTransfer));
			unchecked {
				++i;
			}
		}
		emit WithdrawInverstors(_TreasuryAmount, _msgSender());
		_TreasuryAmount = SafeMath.sub(_TreasuryAmount, cumulatedAmount);
		return true;
	}

	/**Funciones de Owner ------------------------------------------*/
	function addAllInverstors(
		address payable[] calldata arrAllInverstorsAddress,
		uint8[] calldata arrAllInverstorsPercentages
	) public onlyOwner returns (bool success) {
		require(arrAllInverstorsAddress.length == arrAllInverstorsPercentages.length, 'Arrays not match');
		require(inverstors[0].percentage == 0, "Execute the 'clearInverstors' func first");
		for (uint8 i = 0; i < arrAllInverstorsAddress.length; ) {
			Inverstors storage inv = inverstors[i + 1];
			(inv.id, inv.invAddress, inv.percentage) = (
				i + 1,
				arrAllInverstorsAddress[i],
				arrAllInverstorsPercentages[i]
			);
			unchecked {
				++i;
			}
			emit AddNewInverstor(inv.id);
		}
		_TotalInverstors = uint8(arrAllInverstorsAddress.length);
		return true;
	}

	function clearInverstors() public onlyOwner returns (bool success) {
		for (uint8 i = 0; i < _TotalInverstors; ) {
			delete inverstors[i + 1];
			unchecked {
				++i;
			}
		}
		_TotalInverstors = 0;
		emit DeleteInverstors();
		return true;
	}

	function addNewPackages(uint8[][] calldata arrPackages, uint256[] calldata arrPackagesPrices)
		public
		onlyOwner
		returns (bool success)
	{
		for (uint8 i = 0; i < arrPackages.length; ) {
			_TotalPackages = _TotalPackages + 1;
			Packages storage pack = packages[_TotalPackages];
			(pack.id, pack.value, pack.totalForPresale, pack.discountForPresale, pack.active) = (
				_TotalPackages,
				arrPackagesPrices[i],
				arrPackages[i][0],
				arrPackages[i][1],
				true
			);
			unchecked {
				++i;
			}
			emit CreatePackage(pack);
		}
		return true;
	}

	function activePackage(uint8 packageId) public onlyOwner returns (bool success) {
		Packages storage pack = packages[packageId];
		require(pack.active == true, 'alredy active');
		pack.active = true;
		emit ActivatePackage(pack.id);
		return true;
	}

	function deactivatePackage(uint8 packageId) public onlyOwner returns (bool success) {
		Packages storage pack = packages[packageId];
		require(pack.active == false, 'alredy deactivated');
		pack.active = false;
		emit DeactivatePackage(pack.id);
		return true;
	}

	function updateTreasuryPercantage(uint8 newTreasuryPercentage) public onlyOwner returns (bool success) {
		_TreasuryPercentage = newTreasuryPercentage;
		return true;
	}

	function TicketsGenerator(
		uint8 qtyTicketsToGen,
		uint8 idPackage,
		address ownerSelected
	) public onlyOwner returns (bool) {
		require(idPackage == packages[idPackage].id, 'No packages loaded');
		for (uint8 i = 0; i < qtyTicketsToGen; ) {
			CreateTicket(idPackage, ownerSelected, false, true);
			unchecked {
				++i;
			}
		}
		return true;
	}

	function CreateTicket(
		uint8 idPackage,
		address ticketOwner,
		bool isPresale,
		bool isGift
	) private {
		Ticket storage tick = ticket[_IdCounter];
		(tick.id, tick.ticketOwner, tick.packageId, tick.isActivated) = (
			_IdCounter,
			ticketOwner,
			idPackage,
			true
		);
		_IdCounter = _IdCounter + 1;
		if (isPresale) {
			tick.isOrigin = true;
			Packages storage pack = packages[idPackage];
			pack.totalForPresale = pack.totalForPresale - 1;
			emit TicketGenerated(tick.id);
		} else if (isGift) {
			tick.isOrigin = true;
			emit TicketGenerated(tick.id);
		}
	}

	function activateTicket(uint256 id) public onlyOwner returns (bool success) {
		Ticket storage tick = ticket[id];
		require(tick.isActivated == true, 'alredy active');
		tick.isActivated = true;
		emit ActivateTicket(tick.id);
		return true;
	}

	function deactivateTicket(uint256 id) public onlyOwner returns (bool success) {
		Ticket storage tick = ticket[id];
		require(tick.isActivated == false, 'alredy deactivated');
		tick.isActivated = false;
		emit DeactivateTicket(tick.id);
		return true;
	}

	function pauseContract() public onlyOwner {
		_pause();
	}

	function unpauseContract() public onlyOwner {
		_unpause();
	}
}