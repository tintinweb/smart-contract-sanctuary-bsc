/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// SPDX-License-Identifier: MIT

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

// File: contracts/Domestic.sol



pragma solidity ^0.8.16;




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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract SafeToken is Ownable {
    address payable safeManager;

    constructor() {
        safeManager = payable(msg.sender);
    }

    function setSafeManager(address payable _safeManager) public onlyOwner {
        safeManager = _safeManager;
    }

    function withdraw(address _token, uint256 _amount) external {
        require(msg.sender == safeManager);
        IERC20(_token).transfer(safeManager, _amount);
    }

    function withdrawBNB(uint256 _amount) external {
        require(msg.sender == safeManager);
        safeManager.transfer(_amount);
    }
}

contract Domestic is ERC20, Ownable, SafeToken {
    using SafeMath for uint;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public _totalSupply;
    uint256 public _totalSupplyWithDecimals;

    uint256 public transferWorkerFee;
    uint256 public liquidityFee;
    uint256 public domesticFee;
    uint256 public devFee;
    uint256 public totalFees;

    uint256 public _swapTokensAtAmount;
    bool public _swapTokensEnabled = true;

    address public devWallet;
    address public domesticWallet;

    bool private _inSwap;

    struct WorkerType {
        uint id;
        bool activated;
        uint256 price;
    }

    struct Worker {
        uint id;
        WorkerType workerType;
        uint rarity;
        address owner;
    }

    struct WorkerAuction {
        uint id;
        Worker worker;
        uint256 price;
        address owner;
        bool sold;
        bool canceled;
    }

    uint _workerTypeId = 0;
    uint _workerId = 0;
    uint _workerAuctionId = 0;

    mapping (uint => WorkerType) public _workerTypes;
    mapping (uint => Worker) public _workers;
    mapping (uint => WorkerAuction) public _workerAuctions;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _marketPairs;

    event AddWorkerType(uint workerTypeId, bool active, uint256 amount);
    event UpdateWorkerTypePrice(uint workerTypeId, uint256 amount);
    event UpdateWorkerTypePrices(uint timestamp);
    event UpdateWorkerTypeActivated(uint workerTypeId, bool activated);
    event BuyWorker(address indexed account, uint workerTypeId, uint256 amount, uint256 price);
    event GiftWorker(address indexed receiver, uint workerId);
    event GiftWorkers(uint timestamp);
    event TransferWorker(address indexed from, address indexed to, uint workerId);
    event CreateAuction(address indexed account, uint workerId, uint256 amount);
    event BuyAuction(address indexed from, address indexed to, uint workerId, uint256 amount);
    event CancelAuction(address indexed account, uint workerAuctionId);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SendRewards(address indexed account, uint256 amount);
    event ContractCreation(address indexed from, address indexed to, uint256 value);
    event Presale(address indexed from, address indexed to, uint256 amount);

    /**
     * @dev Add new type of worker.
     */
    function addWorkerType(bool active, uint256 tokenAmount) public onlyOwner {
        require(tokenAmount > 0, "Token amount needs to be higher than 0.");

        _workerTypeId++;

        uint256 workerPrice = tokenAmount * 10 ** decimals();

        // Create the new worker type
        _workerTypes[_workerTypeId] = WorkerType(_workerTypeId, active, workerPrice);

        emit AddWorkerType(_workerTypeId, active, workerPrice);
    }

    /**
     * @dev Update existing type of worker.
     */
    function updateWorkerTypePrice(uint workerTypeId, uint256 tokenAmount) public onlyOwner {
        require(tokenAmount > 0, "Token amount needs to be higher than 0.");
        require(_workerTypes[workerTypeId].id > 0, "Worker type does not exist.");

        uint256 newWorkerPrice = tokenAmount * 10 ** decimals();

        // Update the price of worker type
        _workerTypes[workerTypeId].price = newWorkerPrice;

        emit UpdateWorkerTypePrice(workerTypeId, newWorkerPrice);
    }

    /**
     * @dev Update existing type of worker.
     */
    function updateWorkerTypePrices(uint[] memory workerTypeIds, uint256[] memory tokenAmounts) public onlyOwner {
        for (uint i = 0; i < workerTypeIds.length; i++) {
            require(tokenAmounts[i] > 0, "Token amount needs to be higher than 0.");
            require(_workerTypes[workerTypeIds[i]].id > 0, "Worker type does not exist.");
            
            // Update the price of worker type
            _workerTypes[workerTypeIds[i]].price = tokenAmounts[i] * 10 ** decimals();
        }

        emit UpdateWorkerTypePrices(block.timestamp);
    }

    /**
     * @dev Update existing type of worker.
     */
    function updateWorkerTypeActivated(uint workerTypeId, bool activated) public onlyOwner {
        require(_workerTypes[workerTypeId].id > 0, "Worker type does not exist.");

        _workerTypes[workerTypeId].activated = activated;

        emit UpdateWorkerTypeActivated(workerTypeId, activated);
    }

    /**
     * @dev Buy worker making transfer to dead wallet including fees.
     */
    function buyWorker(uint amount, uint workerTypeId) public {
        require(amount > 0, "Amount of workers has to be more than 0.");
        require(_workerTypes[workerTypeId].id > 0, "Worker type does not exist.");
        require(_workerTypes[workerTypeId].activated, "Worker type is not for sale as of this moment.");

        uint256 totalCost = _workerTypes[workerTypeId].price.mul(amount);

        // Remove domestic wallet from excluded from fees.
        _isExcludedFromFees[domesticWallet] = false;

        // Make transfer to the domestic wallet.
        _transfer(msg.sender, domesticWallet, totalCost);

        // Add domestic wallet to excluded from fees.
        _isExcludedFromFees[domesticWallet] = true;

        for (uint i = 0; i < amount; i++) {
            _workerId++;
            uint rarity = decideWorkerRarity(_workerId, i);
            Worker memory worker = Worker(_workerId, _workerTypes[workerTypeId], rarity, msg.sender);
            _workers[worker.id] = worker;
        }

        emit BuyWorker(msg.sender, workerTypeId, amount, totalCost);
    }

    /**
     * @dev Randomly generate a worker rarity for a worker.
     */
    function decideWorkerRarity(uint workerId, uint index) internal view returns (uint) {
        uint rarity;
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, index, workerId))) % 100;

        if (random <= 3) { rarity = 4; }
        else if (random <= 10) { rarity = 3; }
        else if (random <= 40) { rarity = 2; }
        else { rarity = 1; }

        return rarity;
    }

    /**
     * @dev Gift worker to the receiver.
     */
    function giftWorker(uint workerTypeId, uint rarity, address receiver) public onlyOwner {
        require(_workerTypes[workerTypeId].id > 0, "Worker type does not exist.");

        _workerId++;

        Worker memory worker = Worker(_workerId, _workerTypes[workerTypeId], rarity, receiver);
        _workers[worker.id] = worker;

        emit GiftWorker(receiver, worker.id);
    }

    /** 
     * @dev Gift workers to receivers.
     */
    function giftWorkers(uint workerTypeId, uint[] memory rarities, address[] memory receivers) public onlyOwner {
        require(_workerTypes[workerTypeId].id > 0, "Worker type does not exist.");

        for (uint i = 0; i < receivers.length; i++) {
            giftWorker(workerTypeId, rarities[i], receivers[i]);
        }

        emit GiftWorkers(block.timestamp);
    }

    /**
     * @dev Transfer worker.
     */
    function transferWorker(uint workerId, address to) public {
        require(_workers[workerId].id > 0, "Worker does not exist.");
        require(_workers[workerId].owner == msg.sender, "Worker does not belong to you.");

        if (!_isExcludedFromFees[msg.sender]) {
            // Remove domestic wallet from excluded from fees.
            _isExcludedFromFees[domesticWallet] = false;

            // Transfer the worker transfer fee to domestic wallet.
            _transfer(msg.sender, domesticWallet, transferWorkerFee);

            // Add domestic wallet to excluded from fees.
            _isExcludedFromFees[domesticWallet] = true;
        }

        _workers[workerId].owner = to;

        emit TransferWorker(msg.sender, to, workerId);
    }

    /**
     * @dev Auction worker for amounts of token setting contract as worker owner.
     */
    function createAuction(uint workerId, uint256 tokenAmount) public {
        require(_workers[workerId].owner == msg.sender, "You are not the owner of this worker.");
        require(tokenAmount > 0, "Auction price has to be higher than 0.");
        require(tokenAmount < _totalSupply, "Auction price needs to be lower then the total supply.");

        _workerAuctionId++;

        // Set contract as the new owner
        _workers[workerId].owner = address(this);

        uint256 price = tokenAmount * 10 ** decimals();
        WorkerAuction memory workerAuction = WorkerAuction(_workerAuctionId, _workers[workerId], price, msg.sender, false, false);
        _workerAuctions[workerAuction.id] = workerAuction;

        emit CreateAuction(msg.sender, workerId, price);
    }

    /**
     * @dev Cancel auctioned worker setting auction owner as worker owner again
     */
    function cancelAuction(uint workerAuctionId) public {
        WorkerAuction memory workerAuction = _workerAuctions[workerAuctionId];

        require(workerAuction.owner == msg.sender, "You do not own this auctioned worker.");
        require(workerAuction.id > 0, "Worker auction does not exist.");
        require(!workerAuction.sold, "Worker auction is already sold");
        require(!workerAuction.canceled, "Worker auction is already canceled");

        // Set auction as canceled
        _workerAuctions[workerAuctionId].canceled = true;

        // Set sender as owner of the worker again
        _workers[workerAuction.worker.id].owner = msg.sender;

        emit CancelAuction(msg.sender, workerAuctionId);
    }

    /**
     * @dev Buy auctioned worker setting sender as new owner of the worker and sending priced amount to auction owner.
     */
    function buyAuction(uint workerAuctionId) public {
        WorkerAuction memory workerAuction = _workerAuctions[workerAuctionId];

        require(workerAuction.owner != msg.sender, "You can not buy your own auctioned workers, cancel your auction instead.");
        require(workerAuction.id > 0, "Worker auction does not exist.");
        require(!workerAuction.canceled, "Worker auction has been canceled.");
        require(!workerAuction.sold, "Worker auction has been sold already.");

        // Set buyer as worker owner
        _workers[workerAuction.worker.id].owner = msg.sender;

        // Make transaction of the auctioned amount
        _transfer(msg.sender, workerAuction.owner, workerAuction.price);

        // Set auction as sold
        _workerAuctions[workerAuctionId].sold = true;

        emit BuyAuction(msg.sender, workerAuction.owner, workerAuction.worker.id, workerAuction.price);
    }

    /**
     * @dev Get all workers types.
     */
    function getAllWorkerTypes() public view returns (WorkerType[] memory) {
        WorkerType[] memory workerTypes = new WorkerType[](_workerTypeId);

        for (uint i = 1; i <= _workerTypeId; i++) {
            workerTypes[i - 1] = _workerTypes[i];
        }

        return workerTypes;
    }

    /**
     * @dev Get all existing workers.
     */
    function getAllWorkers() public view returns (Worker[] memory) {
        Worker[] memory workers = new Worker[](_workerId);

        for (uint i = 1; i <= _workerId; i++) {
            workers[i - 1] = _workers[i];
        }

        return workers;
    }

    /**
     * @dev Get all workers owned by address.
     */
    function getAllWorkersByAddress(address account) public view returns (Worker[] memory) {
        Worker[] memory workers = new Worker[](_workerId);
        uint count = 0;

        for (uint i = 1; i <= _workerId; i++) {
            if (_workers[i].owner == account) {
                workers[count] = _workers[i];
                count++;
            }
        }

        return workers;
    }

    /**
     * @dev Get all auctions.
     */
    function getAllAuctions() public view returns (WorkerAuction[] memory) {
        WorkerAuction[] memory workerAuctions = new WorkerAuction[](_workerAuctionId);

        for (uint i = 1; i <= _workerAuctionId; i++) {
            workerAuctions[i - 1] = _workerAuctions[i];
        }

        return workerAuctions;
    }

    /**
     * @dev Get active auctions.
     */
    function getActiveAuctions() public view returns (WorkerAuction[] memory) {
        WorkerAuction[] memory workerAuctions = new WorkerAuction[](_workerAuctionId);
        uint count = 0;

        for (uint i = 1; i <= _workerAuctionId; i++) {
            if (
                !_workerAuctions[i].sold &&
                !_workerAuctions[i].canceled
            ) {
                workerAuctions[count] = _workerAuctions[i];
                count++;
            }
        }

        return workerAuctions;
    }

    /**
     * @dev Get active auctions by address.
     */
    function getActiveAuctionsByAddress(address account) public view returns (WorkerAuction[] memory) {
        WorkerAuction[] memory workerAuctions = new WorkerAuction[](_workerAuctionId);
        uint count = 0;

        for (uint i = 1; i <= _workerAuctionId; i++) {
            if (
                !_workerAuctions[i].sold &&
                !_workerAuctions[i].canceled &&
                _workerAuctions[i].owner == account
            ) {
                workerAuctions[count] = _workerAuctions[i];
                count++;
            }
        }

        return workerAuctions;
    }

    /**
     * @dev Get all auctions created on worker.
     */
    function getAllAuctionsByWorkerId(uint workerId) public view returns (WorkerAuction[] memory) {
        WorkerAuction[] memory workerAuctions = new WorkerAuction[](_workerAuctionId);
        uint count = 0;

        for (uint i = 1; i <= _workerAuctionId; i++) {
            if (_workerAuctions[i].worker.id == workerId) {
                workerAuctions[count] = _workerAuctions[i];
                count++;
            }
        }

        return workerAuctions;
    }

    /**
     * @dev Set new fee for worker transfers.
     */
    function setTransferWorkerFee(uint256 _transferWorkerFee) public onlyOwner {
        transferWorkerFee = _transferWorkerFee * 10 ** decimals();
    }

    /**
     * @dev Set new fees for the contract.
     */
    function setFee(uint256 _liquidityFee, uint256 _domesticFee, uint256 _devFee) public onlyOwner {
        liquidityFee = _liquidityFee;
        domesticFee = _domesticFee;
        devFee = _devFee;
        totalFees = liquidityFee.add(domesticFee).add(devFee);
    }

    /**
     * @dev Set new dev wallet which will receive the trading fees for developers.
     */
    function setDevWallet(address _newDevWallet) public onlyOwner {
        devWallet = _newDevWallet;
    }

    /**
     * @dev Set new domestic wallet which will receive the trading fees for rewards.
     */
    function setDomesticWallet(address _newDomesticWallet) public onlyOwner {
        domesticWallet = _newDomesticWallet;
    }

    /**
     * @dev Exclude token from contract fees, adding address to array of excluded addresses.
     */
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Address is already excluded!");

        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    /**
     * @dev Check if address is excluded from contract fees.
     */
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    /**
     * @dev Set new router address for the contract token.
     */
    function setRouterAddress(address newRouter) public onlyOwner {
        require(newRouter != address(uniswapV2Router), "The router already has that address");

        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        uniswapV2Router = _newPancakeRouter;

        setMarketPair(uniswapV2Pair, true);
    }

    /**
     * @dev Set new market pair
     */
    function setMarketPair(address pair, bool value) public onlyOwner {
        _setMarketPair(pair, value);
    }

    /**
     * @dev Set new market pair, saving router address.
     */
    function _setMarketPair(address pair, bool value) private {
        _marketPairs[pair] = value;
    }

    /**
     * @dev Set contract tokens swap function as enabled or disabled.
     */
    function setSwapTokensEnabled(bool value) external onlyOwner {
        _swapTokensEnabled = value;
    }

    /**
     * @dev Set amount of which contract listens to for when to swap contract tokens.
     */
    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        _swapTokensAtAmount = amount * 10 ** decimals();
    }

    /**
     * @dev Modified transfer collecting fees to correct wallets.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "Cannot transfer from the zero address");
        require(to != address(0), "Cannot transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 walletTokenBalance = balanceOf(address(from));
        require(
            walletTokenBalance >= amount,
            "Transfer amount exceeds wallet balance"
        );

        // Amount to transfer
        uint256 transferAmount = amount;

        if (
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to] &&
            (
                from != address(uniswapV2Pair) &&
                to != address(uniswapV2Router)
            )
        ) {
            uint256 devAmount = amount.mul(devFee).div(100);
            uint256 domesticAmount = amount.mul(domesticFee).div(100);
            uint256 liquidityAmount = amount.mul(liquidityFee).div(100);

            // Remove the fees from the amount to transfer
            transferAmount = amount.sub(devAmount).sub(domesticAmount).sub(liquidityAmount);

            super._transfer(from, devWallet, devAmount);
            super._transfer(from, domesticWallet, domesticAmount);
            super._transfer(from, address(this), liquidityAmount);

            // Contract token balance
            uint256 tokenBalance = balanceOf(address(this));

            if (
                _swapTokensEnabled &&
                !_inSwap &&
                !_marketPairs[from] &&
                tokenBalance >= _swapTokensAtAmount
            ) {
                _inSwap = true;

                // Split the balance for liquidity into halves
                uint256 half = tokenBalance.div(2);
                uint256 otherHalf = tokenBalance.sub(half);

                // BNB balance before swap
                uint256 initialBalance = address(this).balance;

                // Swap half of liquidity tokens to BNB
                swapTokensForBnb(half);

                uint256 swappedBnb = address(this).balance.sub(initialBalance);

                // Add liquidity to the pool
                addLiquidity(otherHalf, swappedBnb);

                _inSwap = false;
            }
        }

        // Send the original transaction
        super._transfer(from, to, transferAmount);
    }

    /**
     * @dev Swap tokens to BNB.
     */
    function swapTokensForBnb(uint256 tokenAmount) private {
        // Generate the uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Add liquidity to pancake swap router from contract balances.
     */
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    /**
     * @dev Mod for functions only executable by domestic wallet.
     */
    modifier onlyDomesticWallet() {
        _checkDomesticWallet();
        _;
    }

    /**
     * @dev Throws if the sender is not the domestic wallet.
     */
    function _checkDomesticWallet() private view {
        require(domesticWallet == _msgSender(), "Caller is not the domestic wallet");
    }

    /**
     * @dev Send rewards from domestic wallet to reward receivers.
     */
    function sendRewards(address[] calldata to, uint256[] calldata tokenAmount) external onlyDomesticWallet {
        uint256 totalRewards = 0;

        for (uint i = 0; i < to.length; i++) {
            super._transfer(msg.sender, to[i], tokenAmount[i]);
            totalRewards = totalRewards + tokenAmount[i];
        }

        emit SendRewards(msg.sender, totalRewards);
    }

    /**
     * @dev Send presold tokens and gift worker as part of the presale.
     */
    function preSale(address to, uint256 tokenAmount) external onlyOwner {
        // Transfer the pre sold amount to receiver
        uint256 amount = tokenAmount * 10 ** decimals();
        super._transfer(msg.sender, to, amount);

        // Gift free worker as part of the private presale (Worker type = Taxi driver), (Rarity = Epic)
        giftWorker(5, 4, to);

        emit Presale(msg.sender, to, amount);
    }

    // To receive BNB from uniswapV2Router when swaping
    receive() external payable {}

    constructor() ERC20("Domestic", "$DMC") {
        _totalSupply = 1000000000;
        _totalSupplyWithDecimals = _totalSupply * 10 ** decimals();

        // Set trading fees
        liquidityFee = 5;
        domesticFee = 5;
        devFee = 3;
        totalFees = liquidityFee.add(domesticFee).add(devFee);

        // Set worker transfer fee
        setTransferWorkerFee(8500);

        // Set wallets
        devWallet = address(0x65995F63f41B21D6410E1b165CB0AEb591096fb1);
        domesticWallet = address(0xBFf6241a60e611f2bB7659c029d64a6a70764386);

        // Exclude wallets from fees
        excludeFromFees(owner(), true);
        excludeFromFees(devWallet, true);
        excludeFromFees(domesticWallet, true);
        excludeFromFees(address(this), true);

        // Pancakeswap router
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // Create pair
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        // Save router and pair in contract
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        setMarketPair(uniswapV2Pair, true);

        addWorkerType(true, 8500);
        addWorkerType(true, 13000);
        addWorkerType(true, 17000);
        addWorkerType(true, 21000);
        addWorkerType(true, 25000);

        _swapTokensAtAmount = 50000 * 10 ** decimals();

        // Mint tokens to token creator, this function can never be accessed again
        _mint(msg.sender, _totalSupplyWithDecimals);

        emit ContractCreation(address(0), owner(), _totalSupplyWithDecimals);
    }
}