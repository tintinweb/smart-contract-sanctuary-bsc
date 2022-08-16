/**
 *Submitted for verification at BscScan.com on 2022-08-16
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


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




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

// File: contracts/RockyNeko18pub.sol



//███╗   ███╗███████╗ ██████╗ ██╗    ██╗    ██████╗  ██████╗  ██████╗██╗  ██╗██╗   ██╗███╗   ██╗███████╗██╗  ██╗ ██████╗     ██╗   ██╗ ██╗
//████╗ ████║██╔════╝██╔═══██╗██║    ██║    ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝╚██╗ ██╔╝████╗  ██║██╔════╝██║ ██╔╝██╔═══██╗    ██║   ██║███║
//██╔████╔██║█████╗  ██║   ██║██║ █╗ ██║    ██████╔╝██║   ██║██║     █████╔╝  ╚████╔╝ ██╔██╗ ██║█████╗  █████╔╝ ██║   ██║    ██║   ██║╚██║
//██║╚██╔╝██║██╔══╝  ██║   ██║██║███╗██║    ██╔══██╗██║   ██║██║     ██╔═██╗   ╚██╔╝  ██║╚██╗██║██╔══╝  ██╔═██╗ ██║   ██║    ╚██╗ ██╔╝ ██║
//██║ ╚═╝ ██║███████╗╚██████╔╝╚███╔███╔╝    ██║  ██║╚██████╔╝╚██████╗██║  ██╗   ██║   ██║ ╚████║███████╗██║  ██╗╚██████╔╝     ╚████╔╝  ██║
//╚═╝     ╚═╝╚══════╝ ╚═════╝  ╚══╝╚══╝     ╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝       ╚═══╝   ╚═╝
                                                                                                                                                                                                                                                                     
pragma solidity 0.8.16;





interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
	function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
	
	function swapExactTokensForTokensSupportingFeeOnTransferTokens (
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
	
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
	function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface ILottery{
	function LotteryHolderBalance(address shareholder) external view returns (uint256);
	function setShareHolders(address shareholder, uint256 amount) external;
	function pickWinner(address shareholderTOP) external;
	function payWinner (uint256 MEOWamount, uint256 BUSDamount) external payable;
	function setLotteryStatus(bool _value) external;
	function clearStuckBalanceMEOW(uint256 _amount, address payable _receiver) external;
	function clearStuckBalanceBUSD(uint256 _amount, address payable _receiver) external;
}
//*** IMPORTANT CONFIGURATION FIELDS FOR SMART CONTRACT DEPLOY 
contract MEOW is ERC20, Ownable
{
    using SafeMath for uint256;
    uint public maxWalletAmount;
    mapping(address => bool) public isMaxTxExempt;
    uint public wallet_a_collected;
    uint public LotteryReceiver_collected;
	uint public LotteryReceiver_collectedWBNB;  //BNB balance of lottery
    uint public wallet_liq_collected; //liquidity wallet balance 
    bool public paused=false; //*** trade not paused
    bool public Wautoliquidity=true; //*** auto liquidity automatic swap enabled
	bool public SwapLotteryBNB=true; //*** auto swap to bnb lottery fees collected
	bool public isLotteryEnabled = false;  //*** lottery NOT enabled
    address public wallet_a = 0x1E9f89B5e13F2C39931202314f93E5349AB94875;   //*** MC1 Team wallet
    address public wallet_marketing = 0x14e5c221538b153454B32Be7bDf1F2F547f14b9b;  //*** Marketing team wallet
    address public wallet_charity = 0xfB856d10F77d83b79CDA43bB19B0e4AB1A9b9486;   //*** MC2 Donations Charity wallet
    address public wallet_liq = 0x978658c406f8eF69388f80e626f81D489689E7FE;   //*** autoliquidity wallet
	address public orouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;   //*** ROUTER PANCAKE SWAP
    address public LotteryReceiver;  //lottery smart contract address
    address public presaleAddress; // Presale address DXsale, Pinksale
    IUniswapV2Router02 router;
	ILottery lottery;
    address public pair;
    uint256 public minTokensBeforeSwap = 1400 ether; //*** autoliquidity trigger minimum collected tokens
    enum FeesIndex{ BUY, SELL, P2P }
    uint[] public wallet_a_fee_percentages;
    uint[] public LotteryReceiver_fee_percentages;
    uint[] public wallet_liq_fee_percentages;
    uint public fee_decimal = 2;
    mapping(address => bool) public is_taxless;
    bool private is_in_fee_transfer;
    bool private isLocked;  
    IERC20 BUSD;

    constructor (address Lotteryaddress) ERC20("Rocky Neko MEOW", "MEOW")
    {
		BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // BUSD token address
        LotteryReceiver = Lotteryaddress;   //Lottery contract address		
		lottery=ILottery(LotteryReceiver);  //lottery object
        router = IUniswapV2Router02(orouter);
        pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        isMaxTxExempt[msg.sender] = true;   
        isMaxTxExempt[pair] = true;
        isMaxTxExempt[wallet_a] = true;
        isMaxTxExempt[wallet_marketing] = true;
        isMaxTxExempt[wallet_charity] = true;		
        isMaxTxExempt[LotteryReceiver] = true;
		isMaxTxExempt[wallet_liq] = true;
		isMaxTxExempt[address(this)] = true;
        isMaxTxExempt[address(0)] = true;
        is_taxless[msg.sender] = true;  
        is_taxless[wallet_a] = true;
		is_taxless[wallet_marketing] = true;
		is_taxless[wallet_charity] = true;
        is_taxless[LotteryReceiver] = true;
		is_taxless[wallet_liq] = true;
        is_taxless[address(this)] = true;
        is_taxless[address(0)] = true;
        wallet_a_fee_percentages.push(0); //*** Buy  fee 250 is 2.50%
        wallet_a_fee_percentages.push(0); //*** Sell fee 500 is 5%
        wallet_a_fee_percentages.push(0);  //*** P2P  fee
        LotteryReceiver_fee_percentages.push(0); //*** Buy  fee 250 is 2.50%
        LotteryReceiver_fee_percentages.push(0); //*** Sell fee 500 is 5%
        LotteryReceiver_fee_percentages.push(0);  //*** P2P  fee
        wallet_liq_fee_percentages.push(0); //*** Buy  fee 500 is 5.00%
        wallet_liq_fee_percentages.push(0); //*** Sell fee 1000 is 10.00%
        wallet_liq_fee_percentages.push(0);  //*** P2P  fee
        _mint(msg.sender, 673_000 ether); //to liquidity and presales pool
        _mint(wallet_a, 99_000 ether); //to team wallet
        _mint(LotteryReceiver, 180_000 ether); //to lottery rewards contract
        _mint(wallet_marketing, 28_000 ether); //to marketing and advisers wallet
	    _mint(wallet_charity, 20_000 ether); //to charity wallet
        setMaxWalletPercentage(400); //*** Max wallet ammount transfer allowed up to 4%
        uint256 MAX_INT = 2**256 - 1;
        BUSD.approve(address(router), MAX_INT);
        BUSD.approve(address(pair), MAX_INT);
		BUSD.approve(LotteryReceiver, MAX_INT);
        BUSD.approve(address(this), MAX_INT);		
    }

function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual override(ERC20)
    {
        require(paused == false, "Trade Paused");
        require(isMaxTxExempt[to] || balanceOf(to) + amount <= maxWalletAmount, "Max Wallet Limit Exceeds!");
        super._beforeTokenTransfer(from, to, amount);
        if(!isLocked)
        {
            if(wallet_liq_collected >= minTokensBeforeSwap && to == pair) { 
				isLocked = true;             
				autoLiquidity();
				isLocked = false;
			}
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual override(ERC20)
    {
        super._afterTokenTransfer(from, to, amount);
		if (!isLocked){
			if(!is_in_fee_transfer)
			{
				uint fees_collected;				
				bool sell = to == pair;
				bool p2p = from != pair && to != pair;
				bool buy = !sell && !p2p;
 				bool buypresale = from == presaleAddress;
				
				if (!is_taxless[from] && !is_taxless[to]) {
					uint wallet_a_fee;
					uint LotteryReceiver_fee;
					uint wallet_liq_fee;
					(wallet_a_fee, LotteryReceiver_fee, wallet_liq_fee) = calculateFee(p2p ? FeesIndex.P2P : sell ? FeesIndex.SELL : FeesIndex.BUY, amount);
					wallet_a_collected += wallet_a_fee;
					LotteryReceiver_collected += LotteryReceiver_fee;
					wallet_liq_collected += wallet_liq_fee;
					fees_collected += wallet_a_fee + LotteryReceiver_fee + wallet_liq_fee;
				}

				if(fees_collected > 0)
				{
					is_in_fee_transfer = true;
					_transfer(to, address(this), fees_collected);
					is_in_fee_transfer = false;
				}
				if (isLotteryEnabled && !is_in_fee_transfer){
					if (sell){
						uint256 balancelott= lottery.LotteryHolderBalance(from);
						if (balancelott>0 && amount<balancelott){ //sell ammount is down to lottery balance
							uint nb = SafeMath.sub(balancelott, amount);
							lottery.setShareHolders(from, nb);
						}
						else{
							lottery.setShareHolders(from, 0);
						}
					}
					else if (p2p){
						uint256 balancelott_from = lottery.LotteryHolderBalance(from);
						uint256 balancelott_to = lottery.LotteryHolderBalance(to);
						if (balancelott_from>0 && amount<balancelott_from){ //from
							uint nb_from = SafeMath.sub(balancelott_from, amount);
							uint nb_to = SafeMath.add(balancelott_to, amount);
							lottery.setShareHolders(from, nb_from);
							lottery.setShareHolders(to, nb_to);
						}
						else{
							uint nb_to = SafeMath.add(balancelott_to, balancelott_from);
							lottery.setShareHolders(from, 0);
							lottery.setShareHolders(to, nb_to);
						}
						if (buypresale){ //transfer from presale contract
							uint nb_to = SafeMath.add(balancelott_to, amount);
							lottery.setShareHolders(to, nb_to);
						}
					}
					else if (buy){
						uint balancelott_to = lottery.LotteryHolderBalance(to);
						uint FinalTokens = SafeMath.sub(amount, fees_collected); //Only on PANCAKE buy, no presale, no p2p
						uint nb_to = SafeMath.add(balancelott_to, FinalTokens);
						lottery.setShareHolders(to, nb_to);
					}					
				}
			}
		}
    }

    function autoLiquidity() internal
    {
        uint initialBalance = address(this).balance;
		address[] memory sellPath = new address[](2);
		sellPath[0] = address(this);
		sellPath[1] = router.WETH();
		if (Wautoliquidity){ //check if auto liquidity is enabled
		    uint amountToSwap = SafeMath.div( wallet_liq_collected, 2);  //add the lottery collected for swap to BNB					
			_approve(address(this), address(router), amountToSwap);
			router.swapExactTokensForETHSupportingFeeOnTransferTokens(
				amountToSwap,
				0,
				sellPath,
				address(this),
				block.timestamp
			);

			wallet_liq_collected = SafeMath.sub(wallet_liq_collected, amountToSwap);
			uint amountETHLiquidity = SafeMath.sub(address(this).balance, initialBalance);
			if(wallet_liq_collected > 0) {
				_approve(address(this), address(router), wallet_liq_collected);
				router.addLiquidityETH{value: amountETHLiquidity}(
					address(this),
					wallet_liq_collected,
					0,
					0,
					wallet_liq,
					block.timestamp
				);
			}
			wallet_liq_collected=0;
		}
		if (SwapLotteryBNB && LotteryReceiver_collected>0){  //swap lottery balance
			initialBalance = address(this).balance;  //saving initial BNB balance			
			_approve(address(this), address(router), LotteryReceiver_collected);
			router.swapExactTokensForETHSupportingFeeOnTransferTokens(
				LotteryReceiver_collected,
				0,
				sellPath,
				address(this),
				block.timestamp
			);
			uint finalbalance = SafeMath.sub(address(this).balance, initialBalance);
			LotteryReceiver_collectedWBNB = SafeMath.add(LotteryReceiver_collectedWBNB, finalbalance);
			LotteryReceiver_collected=0;
		}
    }
	 
    function calculateFee(FeesIndex fee_index, uint amount) internal view returns(uint, uint, uint) {
        uint wallet_a_fee = (amount * wallet_a_fee_percentages[uint(fee_index)])  / (10**(fee_decimal + 2));
        uint LotteryReceiver_fee = (amount * LotteryReceiver_fee_percentages[uint(fee_index)])  / (10**(fee_decimal + 2));
		uint wallet_liq_fee = (amount * wallet_liq_fee_percentages[uint(fee_index)])  / (10**(fee_decimal + 2));
        return (wallet_a_fee, LotteryReceiver_fee, wallet_liq_fee);
    }

    function setRouter(address routera)  external onlyOwner {
        orouter = routera;
		router = IUniswapV2Router02(orouter);
		pair = IUniswapV2Factory(router.factory()).getPair(address(this), router.WETH());
		if (pair == address(0)) {
			pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        }
    }
	
    function setWalletA(address wallet)  external onlyOwner {
        wallet_a = wallet;
    }

    function setWalletLiq(address wallet)  external onlyOwner {
        wallet_liq = wallet;
    }

    function setWalletAFee(uint buy, uint sell, uint p2p) external onlyOwner {
        wallet_a_fee_percentages[0] = buy;
        wallet_a_fee_percentages[1] = sell;
        wallet_a_fee_percentages[2] = p2p;
    }

    function setLotteryReceiverFee(uint buy, uint sell, uint p2p) external onlyOwner {
        LotteryReceiver_fee_percentages[0] = buy;
        LotteryReceiver_fee_percentages[1] = sell;
        LotteryReceiver_fee_percentages[2] = p2p;
    }

    function setWalletLiqFee(uint buy, uint sell, uint p2p) external onlyOwner {
        wallet_liq_fee_percentages[0] = buy;
        wallet_liq_fee_percentages[1] = sell;
        wallet_liq_fee_percentages[2] = p2p;
    }
	
	function setpresaleAddress(address _address) public onlyOwner{
		presaleAddress=_address;
		is_taxless[presaleAddress] = true;
		isMaxTxExempt[presaleAddress] = true;
	}

    function setIsTaxless(address _address, bool value) external onlyOwner {
        is_taxless[_address] = value;
    }

    function setMaxWalletPercentage(uint256 percentage) public onlyOwner {
        maxWalletAmount = (totalSupply() * percentage) / 10000;
    }

    function setMaxTxExempt(address account, bool value) external onlyOwner {  //exception for limit transfer.
        isMaxTxExempt[account] = value;
    }

    function setMinTokenLiqSwap(uint256 NumTokens) public onlyOwner {
        minTokensBeforeSwap = NumTokens;
    }
	
	function setPaused(bool _paused)  public onlyOwner { //pause trading
        paused = _paused;
   }
	
	function setWautoliquidity(bool _autoliq)  public onlyOwner {
        Wautoliquidity = _autoliq;
   }
   
	function TransferLotteryFeeSWAPBUSD() external payable onlyOwner { //transfer Lottery Fee in BUSD
        if (LotteryReceiver_collectedWBNB > 0 && address(this).balance >= LotteryReceiver_collectedWBNB ){
			uint initialBalance = BUSD.balanceOf(address(this));
			address[] memory sellPath = new address[](2);
			sellPath[0] = router.WETH();
			sellPath[1] = address(BUSD);			
			router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: LotteryReceiver_collectedWBNB}(
				0,
				sellPath,
				address(this),
				block.timestamp
			);			
			LotteryReceiver_collectedWBNB=0;
			uint finalBalance = BUSD.balanceOf(address(this)); //final balance of BUSD
			uint BUSDtotransfer = SafeMath.sub(finalBalance, initialBalance);
			BUSD.transfer(LotteryReceiver, BUSDtotransfer);			
		}
    }
	
	function TransferLotteryFeeToAddress(address Addr, uint NumTokens) external onlyOwner {
			_transfer(address(this), Addr, NumTokens);
			LotteryReceiver_collected = SafeMath.sub(LotteryReceiver_collected, NumTokens);
    }
   
	function collectWalletAFee() external {
		require(msg.sender == wallet_a, "Sender must be valid address");
		_transfer(address(this), wallet_a, wallet_a_collected);
		wallet_a_collected = 0;
	}
	
	function SetBUSDAddress (address BUSDTokenAdress) external onlyOwner {
		BUSD = IERC20(BUSDTokenAdress);
	}
	
    function SetLotteryContract(address Lotteryaddress) external onlyOwner {
		LotteryReceiver = Lotteryaddress;   //Lottery contract address		
		lottery=ILottery(LotteryReceiver);  //lottery object
		isMaxTxExempt[LotteryReceiver] = true;
		is_taxless[LotteryReceiver] = true;
	}

	function triggerLottery(address shareholderTOP) external onlyOwner { //extract one winner
		require(isLotteryEnabled, "Rocky Neko Lottery not enabled");
		lottery.pickWinner(shareholderTOP);
	}

	function PayLottery(uint256 MEOWamount, uint256 BUSDamount) external onlyOwner {  //pay to the selected winner on bellow step
		require(isLotteryEnabled, "Rocky Neko Lottery not enabled");
		lottery.payWinner(MEOWamount, BUSDamount);
	}
	
	function setLotteryStatus(bool _value) external onlyOwner {
		lottery.setLotteryStatus(_value);
		isLotteryEnabled = _value;
    }   
	
	//new functions
	function setSwapLotteryBNB(bool _autoSwap)  public onlyOwner {
		SwapLotteryBNB = _autoSwap;
	}
	
	function getBNBbalance() public view returns (uint256) { //returns the BNB balance of contract
		return (address(this).balance);
	}
	
	function TransferBNBbalance(uint256 _amount, address payable _receiver) external payable onlyOwner { 
		_receiver.transfer(_amount);
	}

	function resetcollectors (uint256 _walleta, uint256 _lottery, uint256 _liquidity, uint256 _lotteryBNB) public onlyOwner {
		wallet_a_collected=_walleta;
		LotteryReceiver_collected=_lottery;
	    wallet_liq_collected=_liquidity; 
		LotteryReceiver_collectedWBNB=_lotteryBNB;  
	}	
	
	fallback() external payable {}
    receive() external payable {}	
}