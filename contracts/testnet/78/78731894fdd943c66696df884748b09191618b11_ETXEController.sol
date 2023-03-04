/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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

// File: ETXEController.sol



pragma solidity ^0.8.0;





interface IPair {
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IETXE {
    function getPairPrices(uint256 amount)
        external
        view
        returns (uint256[] memory pairPrices);

    function getTokenPriceSum(uint256 start, uint256 end)
        external
        view
        returns (uint256 tokenPriceSum);

    function getTokenPriceByOneDay(uint256 dayTime)
        external
        view
        returns (uint256 time);
}

contract ETXEController is Ownable {
    using SafeMath for uint256;
    using Strings for address;

    event PaymentReceived(address from, uint256 amount);
    event BindRecommender(address account, address recommender);
    event UserInvest(
        address account,
        uint256 investType,
        uint256 tokenEqualsToUsdt,
        uint256 investETXE
    );
    event UserDraw(
        address account,
        uint256 totalDraw,
        uint256 release,
        uint256 recommendAward,
        uint256 teamAward
    );

    struct User {
        uint256 drawRelease;
        uint256 drawRecommendAward;
        uint256 drawTeamAward;
        uint256 drawTime; //上次提取时间
        bool disable;
        uint256 bindTime;
        address recommender;
        address[] invitees;
        uint256[] grades; //等级
        uint256[] upgradeTimes;
    }

    struct Invest {
        address userAddress;
        uint256 tokenEqualsToUsdt;
        uint256 investToken;
        uint256 investTime;
    }

    struct RecommenderAward {
        address userAddress;
        address inviteeAddress;
        uint256 awardToken;
        uint256 awardTime; //day
    }

    mapping(address => User) users;
    mapping(address => uint256) userIndexs;
    address[] userAddresses;

    Invest[] invests;
    mapping(address => uint256[]) userInvestIndexs;

    RecommenderAward[] recommenderAwards;
    mapping(address => uint256[]) userRecommenderAwardIndexs;

    address receiveAddress;
    uint256[11] investLimits; //团队等级对应最高投资限额
    uint256[11] releaseRates; //静态释放费率
    uint256[11] bigAreaGradeLimits; //大区
    uint256[11] smallAreaGradeLimits; //小区
    uint256[11] teamGradeTokenAwards; //团队等级奖励
    uint256[3] recommenderAwardRates; //推荐奖励费率

    string public baseLink;
    address private deadWallet = 0x000000000000000000000000000000000000dEaD;

    ERC20 ETXE;
    ERC20 USDT;
    IPair public Pair;
    IETXE public ETXEI;

    uint256 private constant MAX = ~uint256(0);

    modifier permit(address operator) {
        require(
            !isContract(operator) || !users[operator].disable,
            "Not allowed"
        );
        _;
    }

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "Pancake: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        ETXE = ERC20(address(0x8fC5E1d5e30492912754542f13a0eFe9e5c51271));
        USDT = ERC20(address(0x31912d5f654634E7a6A216FfCFdF23C682476fC2)); //0x55d398326f99059fF775485246999027B3197955
        Pair = IPair(address(0xa7f05d7bBA43b824a03C4BcDD08C4A3ed58D57FB));
        ETXEI = IETXE(address(0x8fC5E1d5e30492912754542f13a0eFe9e5c51271));

        receiveAddress = address(0x28c5945f2201FF2735d7ba4b9f012bb5d8203532);
        investLimits = [
            100,
            200,
            500,
            1000,
            2000,
            3000,
            5000,
            10000,
            30000,
            50000,
            100000
        ];
        releaseRates = [100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200];
        bigAreaGradeLimits = [
            500,
            1000,
            2000,
            5000,
            10000,
            30000,
            50000,
            100000,
            300000,
            800000,
            3000000
        ];
        smallAreaGradeLimits = [
            500,
            1000,
            2000,
            5000,
            10000,
            30000,
            50000,
            100000,
            300000,
            800000,
            3000000
        ];
        teamGradeTokenAwards = [
            10,
            20,
            30,
            50,
            70,
            100,
            150,
            200,
            400,
            600,
            1500
        ];
        recommenderAwardRates = [2000, 1000, 500];

        userIndexs[address(0xf5D350F720283C98aBfC747C29E450A60CbFEef0)] = 0;
        userAddresses.push(address(0xf5D350F720283C98aBfC747C29E450A60CbFEef0));

        invests.push(
            Invest(0xf5D350F720283C98aBfC747C29E450A60CbFEef0, 1, 1, 1)
        );
        userInvestIndexs[0xf5D350F720283C98aBfC747C29E450A60CbFEef0].push(0);
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function updateETXE(address _ETXE) public onlyOwner {
        ETXE = ERC20(_ETXE);
    }

    function updateUSDT(address _usdt) public onlyOwner {
        USDT = ERC20(_usdt);
    }

    function updatePair(address _pair) public onlyOwner {
        Pair = IPair(_pair);
    }

    function updateETXEI(address _ETXE) public onlyOwner {
        ETXEI = IETXE(_ETXE);
    }

    function setBaseLink(string memory base) public onlyOwner {
        baseLink = base;
    }

    function withdraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function updateReceiveAddress(address _receiveAddress) public onlyOwner {
        receiveAddress = _receiveAddress;
    }

    function setInvestLimits(uint256 _index, uint256 _limit) public onlyOwner {
        investLimits[_index - 1] = _limit;
    }

    function setReleaseRates(uint256 _index, uint256 _rate) public onlyOwner {
        releaseRates[_index - 1] = _rate;
    }

    function setRegionGradeLimits(uint256 _index, uint256 _limit)
        public
        onlyOwner
    {
        bigAreaGradeLimits[_index - 1] = _limit;
    }

    function setResidentialsGradeLimits(uint256 _index, uint256 _limit)
        public
        onlyOwner
    {
        smallAreaGradeLimits[_index - 1] = _limit;
    }

    function setTeamGradeTokenProfits(uint256 _index, uint256 _tokenProfit)
        public
        onlyOwner
    {
        teamGradeTokenAwards[_index - 1] = _tokenProfit;
    }

    function setRecommenderProfitRates(uint256 _index, uint256 _rate)
        public
        onlyOwner
    {
        recommenderAwardRates[_index - 1] = _rate;
    }

    function rescueToken(address tokenAddress, uint256 tokens)
        public
        onlyOwner
        returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function bindRecommender(address recommender) public permit(msg.sender) {
        User memory user = users[msg.sender];

        require(user.recommender == address(0), "You have bound a recommender");
        require(msg.sender != recommender, "You can't bind yourself");
        require(
            recommender != address(0) &&
                recommender != deadWallet &&
                !isContract(recommender),
            "You can't bind address 0"
        );
        require(
            !isContract(recommender) && queryMyInvestsNum(recommender) > 0,
            "The recommender you bind is invalid"
        );

        user.recommender = recommender;
        user.bindTime = block.timestamp;
        users[msg.sender] = user;

        users[recommender].invitees.push(msg.sender);

        emit BindRecommender(msg.sender, recommender);
    }

    function userInvest(uint256 investType) public permit(msg.sender) {
        uint256 grade = queryMyTeamGradeByTeamInvest(msg.sender);
        require(
            (investType > 0 && investType < 5) ||
                (investType > 4 && investType <= grade),
            "Error in type of invest"
        );
        require(
            users[msg.sender].recommender != address(0),
            "You have not bound the recommender"
        );

        uint256 canInvestUsdtNum = queryCanInvestUsdtNum(msg.sender);

        require(
            canInvestUsdtNum >= investLimits[0].mul(10**18),
            "Your investment quota has been used up, please upgrade the team"
        );
        uint256 toInvestUsdtNum = queryToInvestUsdtNum(msg.sender, investType);

        uint256 tokenAmount = usdtEqualsToETXE(toInvestUsdtNum);
        require(
            ETXE.balanceOf(msg.sender) >= tokenAmount,
            "Your balance is insufficient"
        );

        if (userIndexs[msg.sender] == 0) {
            userIndexs[msg.sender] = userAddresses.length;
            userAddresses.push(msg.sender);
        }

        ETXE.transferFrom(msg.sender, receiveAddress, tokenAmount);

        Invest memory inv = Invest(
            msg.sender,
            toInvestUsdtNum,
            tokenAmount,
            block.timestamp
        );

        userInvestIndexs[msg.sender].push(invests.length);

        invests.push(inv);

        _upgrade(msg.sender);

        emit UserInvest(msg.sender, investType, toInvestUsdtNum, tokenAmount);
    }

    function userDraw() public permit(msg.sender) {
        User memory user = users[msg.sender];

        uint256 tokenRelease = queryMyTotalInvestRelease(msg.sender);
        uint256 recommenderAward = queryMyRecommenderAward(msg.sender);
        uint256 teamAward = queryMyTeamGradeAward(msg.sender);

        uint256 tokens = tokenRelease.add(recommenderAward).add(teamAward);

        require(tokens >= 0, "You have no token to claim");

        // require(
        //     block.timestamp.div(24 hours) > user.drawTime.div(24 hours),
        //     "You have withdrawn it today"
        // );

        user.drawRelease = user.drawRelease.add(tokenRelease);
        user.drawRecommendAward = user.drawRecommendAward.add(recommenderAward);
        user.drawTeamAward = user.drawTeamAward.add(teamAward);

        user.drawTime = block.timestamp;

        users[msg.sender] = user;

        ETXE.transfer(msg.sender, tokens);

        _recommenderAward(msg.sender, tokenRelease);

        emit UserDraw(
            msg.sender,
            tokens,
            tokenRelease,
            recommenderAward,
            teamAward
        );
    }

    function _recommenderAward(address user, uint256 tokenRelease) private {
        address recommender;
        uint256 awardToken;
        uint256 awardTime = block.timestamp;
        address user0 = user;
        uint256 i;

        for (i = 0; i < 3; i++) {
            recommender = users[user0].recommender;

            if (address(0) == recommender) {
                break;
            }

            awardToken = tokenRelease.mul(recommenderAwardRates[i]).div(10000);

            user0 = recommender;

            RecommenderAward memory rec = RecommenderAward(
                recommender,
                user,
                awardToken,
                awardTime
            );

            userRecommenderAwardIndexs[recommender].push(
                recommenderAwards.length
            );
            recommenderAwards.push(rec);
        }
    }

    function _upgrade(address user) private {
        uint256 grade = queryMyTeamGrade(msg.sender);
        uint256 currentGrade = queryMyGrade(user);

        if (grade > currentGrade) {
            users[user].grades.push(grade);
            users[user].upgradeTimes.push(block.timestamp);
        }
    }

    function queryReleaseRates() public view returns (uint256[11] memory) {
        return releaseRates;
    }

    function queryReleaseRate(uint256 index) public view returns (uint256) {
        return releaseRates[index];
    }

    function queryTeamGradeTokenAwards()
        public
        view
        returns (uint256[11] memory)
    {
        return teamGradeTokenAwards;
    }

    function queryTeamGradeTokenAward(uint256 index)
        public
        view
        returns (uint256)
    {
        return teamGradeTokenAwards[index];
    }

    function queryUserIndex(address user) public view returns (uint256) {
        return userIndexs[user];
    }

    function queryUserAddresses() public view returns (address[] memory) {
        return userAddresses;
    }

    function queryUsers(address user) public view returns (User memory) {
        return users[user];
    }

    function queryUsersbatch(address[] memory userAddresss)
        public
        view
        returns (User[] memory userss)
    {
        userss = new User[](userAddresss.length);

        uint256 i;

        for (i = 0; i < userAddresss.length; i++) {
            userss[i] = users[userAddresss[i]];
        }

        return userss;
    }

    function queryInvests() public view returns (Invest[] memory) {
        return invests;
    }

    function queryInvestsNum() public view returns (uint256) {
        return invests.length;
    }

    function queryInvest(uint256 index) public view returns (Invest memory) {
        return invests[index];
    }

    function queryInvestsbatch(uint256[] memory indexs)
        public
        view
        returns (Invest[] memory investss)
    {
        investss = new Invest[](indexs.length);

        uint256 i;

        for (i = 0; i < indexs.length; i++) {
            investss[i] = invests[indexs[i]];
        }

        return investss;
    }

    function queryMyInvitees(address user)
        public
        view
        returns (address[] memory)
    {
        return users[user].invitees;
    }

    function queryMyInviteesNum(address user) public view returns (uint256) {
        return users[user].invitees.length;
    }

    function queryMyGrades(address user)
        public
        view
        returns (uint256[] memory)
    {
        return users[user].grades;
    }

    function queryMyUpgradeTimes(address user)
        public
        view
        returns (uint256[] memory)
    {
        return users[user].upgradeTimes;
    }

    function queryMyGrade(address user) public view returns (uint256) {
        if (users[user].grades.length == 0) return 0;
        return users[user].grades[users[user].grades.length - 1];
    }

    function queryMyGradesNum(address user) public view returns (uint256) {
        return users[user].grades.length;
    }

    function queryMyGradesAndUpgradeTimes(address user)
        public
        view
        returns (uint256[] memory, uint256[] memory)
    {
        return (users[user].grades, users[user].upgradeTimes);
    }

    function queryMyInvestIndexs(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userInvestIndexs[user];
    }

    function queryMyInvestsNum(address user) public view returns (uint256) {
        return userInvestIndexs[user].length;
    }

    function queryRecommenderAwards()
        public
        view
        returns (RecommenderAward[] memory)
    {
        return recommenderAwards;
    }

    function queryRecommenderAwardsNum() public view returns (uint256) {
        return recommenderAwards.length;
    }

    function queryRecommenderAward(uint256 index)
        public
        view
        returns (RecommenderAward memory)
    {
        return recommenderAwards[index];
    }

    function queryMyRecommenderAwardIndexs(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userRecommenderAwardIndexs[user];
    }

    function queryMyRecommenderAwardsNum(address user)
        public
        view
        returns (uint256)
    {
        return userRecommenderAwardIndexs[user].length;
    }

    function queryMyTotalInvestRelease(address user)
        public
        view
        returns (uint256 totalTokenRelease)
    {
        uint256[] memory indexs = userInvestIndexs[user];

        if (indexs.length == 0) {
            return 0;
        }

        uint256 i;

        for (i = 0; i < indexs.length; i++) {
            totalTokenRelease = totalTokenRelease.add(
                queryMySingleInvestRelease(user, indexs[i])
            );
        }

        return totalTokenRelease;
    }

    function queryMySingleInvestRelease(address user, uint256 index)
        public
        view
        returns (uint256 tokenRelease)
    {
        Invest memory inv = invests[index];

        if (inv.userAddress != user) {
            return 0;
        }

        uint256 start = inv.investTime > users[user].drawTime
            ? inv.investTime
            : users[user].drawTime;

        uint256 pairPriceSum = ETXEI.getTokenPriceSum(start, block.timestamp);

        tokenRelease = inv
            .tokenEqualsToUsdt
            .mul(queryMyYield(user))
            .mul(pairPriceSum)
            .div(10**22);

        return tokenRelease;
    }

    function queryMyTeamGradeAward(address user)
        public
        view
        returns (uint256 teamAwardToken)
    {
        User memory u = users[user];

        if (u.grades.length == 0) {
            return 0;
        }

        uint256 grade;
        uint256 start;
        uint256 endTime = block.timestamp;

        uint256 i;

        for (i = u.grades.length; i > 0; i--) {
            grade = u.grades[i - 1];

            if (endTime <= users[user].drawTime) {
                break;
            }

            start = u.upgradeTimes[i - 1] > users[user].drawTime
                ? u.upgradeTimes[i - 1]
                : users[user].drawTime;

            uint256 pairPriceSum = ETXEI.getTokenPriceSum(start, endTime);

            teamAwardToken = teamAwardToken.add(
                teamGradeTokenAwards[grade - 1].mul(10**18).mul(pairPriceSum)
            );

            endTime = u.upgradeTimes[i - 1];
        }

        return teamAwardToken;
    }

    function queryMyRecommenderAward(address user)
        public
        view
        returns (uint256 recommenderAward)
    {
        uint256[] memory indexs = userRecommenderAwardIndexs[user];

        RecommenderAward memory rec;
        uint256 i;

        // for (i = indexs.length; i > 0; i--) {
        for (i = 0; i < indexs.length; i++) {
            rec = recommenderAwards[indexs[i]];
            if (rec.userAddress == user) {
                if (rec.awardTime > users[user].drawTime) {
                    recommenderAward = recommenderAward.add(rec.awardToken);
                }
            }
        }

        return recommenderAward;
    }

    function queryMyTeamInvitees(address user, uint256 levelLimit)
        public
        view
        returns (address[] memory teamInvitees)
    {
        if (levelLimit == 0) {
            return teamInvitees;
        }

        // address[] memory invitees0;
        // address[] memory invitees2;
        address[] memory invitees2 = new address[](3000);

        uint256 count;
        uint256 i;
        uint256 j;

        // for (i = 0; i < invitees0.length; i++) {
        //     if (count > 2999) break;

        //     invitees1[count] = invitees0[i];
        //     count++;
        // }

        for (i = 0; i < levelLimit; i++) {
            address[] memory invitees0;
            address[] memory invitees1;

            if(i == 0){
                invitees0 = users[user].invitees;
            }else{
                invitees0 = queryUsersInvitees(invitees1);
            }

            for (j = 0; j < invitees0.length; j++) {
                if (count > 2999) break;

                invitees2[count] = invitees0[i];
                count++;
            }
            invitees1 = invitees0;
        }

        // for (i = 0; i < invitees0.length; i++) {
        //     if (count > 2999) break;

        //     invitees1[count] = invitees0[i];
        //     count++;

        //     if (i + 1 == invitees0.length && level < levelLimit) {
        //         address[] memory invitees2 = queryUsersInvitees(invitees0);
        //         level++;
        //         i = 0;

        //         // for (j = 0; j < invitees2.length; j++) {

        //         // }
        //     }
        // }

        teamInvitees = new address[](count);

        for (i = 0; i < count; i++) {
            teamInvitees[i] = invitees2[i];
        }

        return teamInvitees;
    }

    function queryMyTeamInviteesNum(address user)
        public
        view
        returns (uint256 teamInviteesNum)
    {
        address[] memory teamInvitees = queryMyTeamInvitees(user, 12);
        teamInviteesNum = teamInvitees.length;
    }

    function queryUsersInvitees(address[] memory userAddrs)
        public
        view
        returns (address[] memory)
    {
        address[] memory invitees1 = new address[](3000);

        uint256 count;
        uint256 i;
        uint256 j;

        for (i = 0; i < userAddrs.length; i++) {
            address[] memory invitees0 = users[userAddrs[i]].invitees;

            for (j = 0; j < invitees0.length; j++) {
                if (count < 3000) {
                    invitees1[count] = invitees0[j];
                    count++;
                }
            }
        }

        address[] memory invitees = new address[](count);

        for (i = 0; i < count; i++) {
            invitees[i] = invitees1[i];
        }

        return invitees;
    }

    function queryMyTotalUsdtInvest(address user)
        public
        view
        returns (uint256 totalUsdtInvest)
    {
        uint256[] memory indexs = userInvestIndexs[user];

        Invest memory inv;
        uint256 i;

        for (i = 0; i < indexs.length; i++) {
            inv = invests[indexs[i]];
            if (inv.userAddress == user) {
                totalUsdtInvest += inv.tokenEqualsToUsdt;
            }
        }

        return totalUsdtInvest;
    }

    function queryCanInvestUsdtNum(address user)
        public
        view
        returns (uint256 canInvestUsdtNum)
    {
        uint256 grade = queryMyTeamGradeByTeamInvest(user);
        // if (investType == 0 || investType > grade) return 0;
        // uint256 toInvest = investLimits[investType - 1].mul(10**18);
        uint256 maxInvest = grade < 5
            ? investLimits[3].mul(10**18)
            : investLimits[grade - 1].mul(10**18);
        uint256 totalUsdtInvest = queryMyTotalUsdtInvest(user);

        if (totalUsdtInvest < maxInvest) {
            canInvestUsdtNum = maxInvest.sub(totalUsdtInvest);
            // canInvestUsdtNum = toInvest < canInvestUsdtNum
            //     ? toInvest
            //     : canInvestUsdtNum;
        }

        return canInvestUsdtNum;
    }

    function queryToInvestUsdtNum(address user, uint256 investType)
        public
        view
        returns (uint256 toInvestUsdtNum)
    {
        uint256 canInvestUsdtNum = queryCanInvestUsdtNum(user);

        uint256 toInvest = investLimits[investType - 1].mul(10**18);

        if (toInvest <= canInvestUsdtNum) {
            return toInvest;
        }

        return canInvestUsdtNum;
    }

    function queryMyYield(address user) public view returns (uint256) {
        uint256 totalUsdtInvest = queryMyTotalUsdtInvest(user);

        uint256 i;

        for (i = 11; i > 0; i--) {
            if (totalUsdtInvest >= investLimits[i - 1].mul(10**18)) {
                return releaseRates[i - 1];
            }
        }

        return 0;
    }

    function queryMyTeamBigAreaTotalInvest(address user)
        public
        view
        returns (uint256 bigAreaTotalInvest)
    {
        address[] memory invitees = users[user].invitees;

        uint256 teamTotalUsdtInvest;
        uint256 i;

        for (i = 0; i < invitees.length; i++) {
            teamTotalUsdtInvest = queryMyTeamTotalInvestByGrade(
                invitees[i],
                11
            );
            if (teamTotalUsdtInvest > bigAreaTotalInvest) {
                bigAreaTotalInvest = teamTotalUsdtInvest;
            }
        }

        return bigAreaTotalInvest;
    }

    function queryMyTeamSmallAreaTotalInvest(address user)
        public
        view
        returns (uint256 smallAreaTotalInvest)
    {
        uint256 teamTotalUsdtInvest = queryMyTeamTotalInvestByGrade(user, 12);

        uint256 bigAreaTotalInvest = queryMyTeamBigAreaTotalInvest(user);

        smallAreaTotalInvest = teamTotalUsdtInvest.sub(bigAreaTotalInvest);

        return smallAreaTotalInvest;
    }

    function queryMyTeamTotalInvestByGrade(address user, uint256 levelLimit)
        public
        view
        returns (uint256 teamTotalInvest)
    {
        address[] memory teamInvitees = queryMyTeamInvitees(user, levelLimit);

        uint256 totalUsdtInvest;
        uint256 i;

        for (i = 0; i < teamInvitees.length; i++) {
            totalUsdtInvest = queryMyTotalUsdtInvest(teamInvitees[i]);
            teamTotalInvest = teamTotalInvest.add(totalUsdtInvest);
        }

        return teamTotalInvest;
    }

    function queryMyTeamTotalInvest(address user)
        public
        view
        returns (uint256 teamTotalInvest)
    {
        teamTotalInvest = queryMyTeamTotalInvestByGrade(user, 12);
        return teamTotalInvest;
    }

    function queryMyTeamGradeByTeamInvest(address user)
        public
        view
        returns (uint256)
    {
        uint256 smallAreaTotalInvest = queryMyTeamSmallAreaTotalInvest(user);
        uint256 bigAreaTotalInvest = queryMyTeamBigAreaTotalInvest(user);

        uint256 i;

        for (i = 11; i > 0; i--) {
            if (
                bigAreaTotalInvest >= bigAreaGradeLimits[i - 1].mul(10**18) &&
                smallAreaTotalInvest >= smallAreaGradeLimits[i - 1].mul(10**18)
            ) {
                return i;
            }
        }

        return 0;
    }

    function queryMyTeamGrade(address user) public view returns (uint256) {
        uint256 totalUsdtInvest = queryMyTotalUsdtInvest(user);
        uint256 smallAreaTotalInvest = queryMyTeamSmallAreaTotalInvest(user);
        uint256 bigAreaTotalInvest = queryMyTeamBigAreaTotalInvest(user);

        uint256 i;

        for (i = 11; i > 0; i--) {
            if (
                totalUsdtInvest >= investLimits[i - 1].mul(10**18) &&
                bigAreaTotalInvest >= bigAreaGradeLimits[i - 1].mul(10**18) &&
                smallAreaTotalInvest >= smallAreaGradeLimits[i - 1].mul(10**18)
            ) {
                return i;
            }
        }

        return 0;
    }

    function queryUserTeamGradeAwardRecords(address user)
        public
        view
        returns (uint256[] memory teamAwardTokens, uint256[] memory awardTimes)
    {
        User memory u = users[user];

        if (u.grades.length == 0) {
            return (teamAwardTokens, awardTimes);
        }

        uint256 grade;
        uint256 upgradeTime;
        uint256 endTime = block.timestamp;

        uint256 intervalDays = endTime.div(24 hours) - u.upgradeTimes[0];
        teamAwardTokens = new uint256[](intervalDays);
        awardTimes = new uint256[](intervalDays);
        uint256 count;

        uint256 i;
        uint256 j;

        for (i = u.grades.length; i > 0; i--) {
            grade = u.grades[i - 1];
            upgradeTime = u.upgradeTimes[i - 1];

            intervalDays = endTime.div(24 hours) - upgradeTime.div(24 hours);

            for (j = 0; j < intervalDays; j++) {
                if (count < teamAwardTokens.length) {
                    teamAwardTokens[count] = teamGradeTokenAwards[grade - 1]
                        .mul(10**18);
                    awardTimes[count] = endTime - (j + 1).mul(24 hours);
                    count++;
                }
            }

            endTime = upgradeTime;
        }

        return (teamAwardTokens, awardTimes);
    }

    function queryIsBindRecommender(address user) public view returns (bool) {
        if (users[user].recommender == address(0)) {
            return false;
        }
        return true;
    }

    function queryInviteLink(address user)
        public
        view
        returns (string memory inviteLink)
    {
        if (queryMyInviteesNum(user) > 0) {
            string memory addr = user.toHexString();

            if (user != address(0)) {
                inviteLink = string(abi.encodePacked(baseLink, addr));
            }
        }

        return inviteLink;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function tokenEqualsToUsdt(uint256 tokenAmount)
        public
        view
        returns (uint256 usdtAmount)
    {
        (uint256 reserve0, uint256 reserve1, ) = Pair.getReserves();

        if (reserve0 > 0 && reserve1 > 0) {
            usdtAmount = tokenAmount.mul(reserve0).div(reserve1);
        }

        return usdtAmount;
    }

    function usdtEqualsToETXE(uint256 usdtAmount)
        public
        view
        returns (uint256 tokenAmount)
    {
        (uint256 reserve0, uint256 reserve1, ) = Pair.getReserves();

        if (reserve0 > 0 && reserve1 > 0) {
            tokenAmount = usdtAmount.mul(reserve1).div(reserve0);
        }

        return tokenAmount;
    }

    function checkBindRecommender(address user, address recommender)
        public
        view
        returns (uint256)
    {
        User memory u = users[user];

        // require(user.recommender == address(0), "You have bound a recommender");
        // require(msg.sender != recommender, "You can't bind yourself");
        // require(
        //     recommender != address(0) &&
        //         recommender != deadWallet &&
        //         !isContract(recommender),
        //     "You can't bind address 0"
        // );
        // require(
        //     !isContract(recommender) && queryMyInvestsNum(recommender) > 0,
        //     "The recommender you bind is invalid"
        // );
        if (u.recommender != address(0)) return 1;
        if (user == recommender) return 2;
        if (recommender == address(0) || recommender == deadWallet) return 3;
        if (isContract(recommender) || queryMyInvestsNum(recommender) == 0)
            return 4;

        return 0;
    }

    function checkUserInvest(address user, uint256 investType)
        public
        view
        returns (uint256)
    {
        // uint256 grade = queryMyTeamGradeByTeamInvest(msg.sender);
        // require(
        //     (investType > 0 && investType < 5) || (investType > 0 && investType <= grade),
        //     "Error in type of invest"
        // );
        // require(
        //     users[msg.sender].recommender != address(0),
        //     "You have not bound the recommender"
        // );

        // uint256 canInvestUsdtNum = queryCanInvestUsdtNum(
        //     msg.sender,
        //     investType
        // );
        // uint256 toInvest = investLimits[investType - 1].mul(10**18);

        // require(
        //     toInvest <= canInvestUsdtNum,
        //     "Your investment quota has been used up, please upgrade the team"
        // );
        // uint256 tokenAmount = usdtEqualsToETXE(canInvestUsdtNum);
        // require(
        //     ETXE.balanceOf(msg.sender) >= tokenAmount,
        //     "Your balance is insufficient"
        // );
        uint256 grade = queryMyTeamGradeByTeamInvest(user);
        if (
            investType == 0 ||
            investType > 11 ||
            (investType > 4 && investType > grade)
        ) return 1;
        if (users[user].recommender == address(0)) return 2;
        uint256 canInvestUsdtNum = queryCanInvestUsdtNum(user);
        if (canInvestUsdtNum < investLimits[0].mul(10**18)) return 3;
        uint256 tokenAmount = usdtEqualsToETXE(canInvestUsdtNum);
        if (ETXE.balanceOf(user) < tokenAmount) return 4;

        return 0;
    }

    function checkUserDraw(address user) public view returns (uint256) {
        // User memory user = users[msg.sender];

        // uint256 tokenRelease = queryMyTotalInvestRelease(msg.sender);
        // uint256 recommenderAward = queryMyRecommenderAward(msg.sender);
        // uint256 teamAward = queryMyTeamGradeAward(msg.sender);

        // uint256 tokens = tokenRelease.add(recommenderAward).add(teamAward);

        // require(tokens >= 0, "You have no token to claim");

        // require(
        //     block.timestamp.div(24 hours) > user.drawTime.div(24 hours),
        //     "You have withdrawn it today"
        // );
        User memory u = users[user];

        uint256 tokenRelease = queryMyTotalInvestRelease(user);
        uint256 recommenderAward = queryMyRecommenderAward(user);
        uint256 teamAward = queryMyTeamGradeAward(user);

        uint256 tokens = tokenRelease.add(recommenderAward).add(teamAward);
        if (tokens == 0) return 1;
        if (block.timestamp.div(24 hours) <= u.drawTime.div(24 hours)) return 2;

        return 0;
    }
}