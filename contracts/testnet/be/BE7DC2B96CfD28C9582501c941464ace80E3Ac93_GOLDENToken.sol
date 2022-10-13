/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

pragma solidity ^0.8.0;

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
pragma solidity 0.8.13;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

// SPDX-License-Identifier: MIT
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


pragma solidity 0.8.13;


contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}


pragma solidity 0.8.13;

interface IUniswapV2Router {
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

    function addLiquidityAVAX(
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

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

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


pragma solidity 0.8.13;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB) external returns (address pair);
    
    function pairCodeHash() external pure returns (bytes32);
}


pragma solidity 0.8.13;

interface IOracle {
    function update() external;

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut);

    function twap(address _token, uint256 _amountIn) external view returns (uint144 _amountOut);

    function sync() external;
}

pragma solidity 0.8.13;

contract GOLDENToken is ERC20, Operator {
    using SafeMath for uint256;

    // Initial distribution for the first 24h genesis pools
    uint256 public constant INITIAL_GENESIS_POOL_DISTRIBUTION = 100000 ether;

    // Have the rewards been distributed to the pools
    bool public rewardPoolDistributed;

	
	uint256 public constant INITIAL_FRAGMENTS_SUPPLY = 1 ether;

    // Rebase
	uint256 private constant MAX_SUPPLY = ~uint128(0);
	uint256 public TOTAL_GONS;
	uint256 private _gonsPerFragment;

	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;
	mapping(address => bool) private _isExcluded;
	address[] public excluded;
	address private polWallet;
	address private daoFund;
	uint256 private _totalSupply;
	uint256 private constant maxExclusion = 20;
	address public oracle;

	// Tax
	address public taxOffice;
	uint256 private lastTimeRebase;
	uint256 public timeTaxAfterRebase;
	uint256 public taxRateAfterRebase;
	// Sender addresses excluded from Tax
    mapping(address => bool) public excludedTaxAddresses;
	mapping (address => bool) public marketLpPairs; // LP Pairs
	// Tax tiers
    uint256[] public taxTiersTwaps;
    uint256[] public taxTiersRates;
	// Taxes to be calculated using the tax tiers
    bool public enabledTax;
	bool public isSetOracle = false;

	uint256 public maximumAmountSellPercent = 10000; // 100%

    /* =================== Events =================== */
    event LogRebase(uint256 indexed epoch, uint256 totalSupply, uint256 prevTotalSupply, uint256 prevRebaseSupply);
    event GrantExclusion(address indexed account);
	event RevokeExclusion(address indexed account);
	event DisableRebase(address indexed account);
	event EnableRebase(address indexed account);
	event SetTaxTiersTwap(uint8 _index, uint256 _value);
    event SetTaxTiersRate(uint8 _index, uint256 _value);
	event SetTokenOracle(address oldOracle, address newOracle);
	event SetTaxRateAfterRebase(uint256 oldValue, uint256 newValue);
	event SetTimeTaxAfterRebase(uint256 oldValue, uint256 newValue);
	event EnableCalculateTax();
	event DisableCalculateTax();
	event SetPolWallet(address oldWallet, address newWallet);
	event SetMaximumAmountSellPercent(uint256 oldValue, uint256 newValue);

    constructor(address _polWallet, address _daoFundAddress, address _wbnbAddress, address _router) ERC20("Golden Inu", "GOLDEN") {
		require(_polWallet != address(0), "!_polWallet");
		require(_daoFundAddress != address(0), "!_daoFundAddress");
		require(_wbnbAddress != address(0), "!_wbnbAddress");
		require(_router != address(0), "!_router");
		_gonsPerFragment = 10**18;
		_totalSupply = 0;
		lastTimeRebase = 0;
		polWallet = _polWallet;
		taxTiersTwaps = [0, 8e17, 9e17, 1e18]; // twap with wbnb
		taxTiersRates = [800, 500, 300, 0];
		taxRateAfterRebase = 1000; // 10%
		timeTaxAfterRebase = 24 hours;

		taxOffice = msg.sender;
		daoFund = _daoFundAddress;
		IUniswapV2Router _dexRouter = IUniswapV2Router(_router);
		address dexPair = IUniswapV2Factory(_dexRouter.factory()).createPair(address(this), _wbnbAddress);
        setMarketLpPairs(dexPair, true);
        excludedTaxAddresses[msg.sender] = true;
        _mint(msg.sender, INITIAL_FRAGMENTS_SUPPLY);
    }

	modifier onlyTaxOffice() {
        require(taxOffice == msg.sender, "taxOffice: caller is not the taxOffice");
        _;
    }

    function getPolWallet() external view returns (address)
	{
		return polWallet;
	}

	function getDaoFund() external view returns (address)
	{
		return daoFund;
	}

	function getExcluded() external view returns (address[] memory)
	{
		return excluded;
	}
    
	function rebase(uint256 epoch, uint256 supplyDelta, bool negative) external onlyOperator returns (uint256)
	{
		uint256 prevRebaseSupply = rebaseSupply();
		uint256 prevTotalSupply = _totalSupply;
		uint256 total = _rebase(supplyDelta, negative);

		emit LogRebase(epoch, total, prevTotalSupply, prevRebaseSupply);
		return total;
	}

    /**
	 * @dev Notifies Fragments contract about a new rebase cycle.
	 * @param supplyDelta The number of new fragment tokens to add into circulation via expansion.
	 * @param negative check increase or decrease token
	 * Return The total number of fragments after the supply adjustment.
	*/
	function _rebase(uint256 supplyDelta, bool negative) internal virtual returns (uint256) {
		// if supply delta is 0 nothing to rebase
		// if rebaseSupply is 0 nothing can be rebased
		if (supplyDelta == 0 || rebaseSupply() == 0) {
			return _totalSupply;
		}
		require(_totalSupply > supplyDelta, 'SupplyDelta must be lower than totalSupply');

		uint256[] memory excludedBalances = _burnExcludedAccountTokens();
		if (negative) {
			_totalSupply = _totalSupply.sub(uint256(supplyDelta));
		} else {
			_totalSupply = _totalSupply.add(uint256(supplyDelta));
		}

		if (_totalSupply > MAX_SUPPLY) {
			_totalSupply = MAX_SUPPLY;
		}

		_gonsPerFragment = TOTAL_GONS.div(_totalSupply);
		lastTimeRebase = block.timestamp;
		_mintExcludedAccountTokens(excludedBalances);

		return _totalSupply;
	}

    /**
	* @dev Exposes the supply available for rebasing. Essentially this is total supply minus excluded accounts
	* @return rebaseSupply The supply available for rebase
	*/
	function rebaseSupply() public view returns (uint256) {
		uint256 excludedSupply = 0;
		uint256 excludedLength = excluded.length;
		for (uint256 i = 0; i < excludedLength; i++) {
			excludedSupply = excludedSupply.add(balanceOf(excluded[i]));
		}
		return _totalSupply.sub(excludedSupply);
	}

    /**
	* @dev Burns all tokens from excluded accounts
	* @return excludedBalances The excluded account balances before burn
	*/
	function _burnExcludedAccountTokens() private returns (uint256[] memory excludedBalances)
	{
		uint256 excludedLength = excluded.length;
		excludedBalances = new uint256[](excludedLength);
		for (uint256 i = 0; i < excludedLength; i++) {
			address account = excluded[i];
			uint256 balance = balanceOf(account);
			excludedBalances[i] = balance;
			if (balance > 0) _burn(account, balance);
		}

		return excludedBalances;
	}

    /**
	* @dev Mints tokens to excluded accounts
	* @param excludedBalances The amount of tokens to mint per address
	*/
	function _mintExcludedAccountTokens(uint256[] memory excludedBalances) private
	{
		uint256 excludedLength = excluded.length;
		for (uint256 i = 0; i < excludedLength; i++) {
			if (excludedBalances[i] > 0)
				_mint(excluded[i], excludedBalances[i]);
		}
	}

    /**
	 * @dev Grant an exclusion from rebases
	 * @param account The account to grant exclusion
	*/
	function grantRebaseExclusion(address account) external onlyOperator
	{
        if (_isExcluded[account]) return;
		require(excluded.length <= maxExclusion, 'Too many excluded accounts');
		_isExcluded[account] = true;
		excluded.push(account);
		emit GrantExclusion(account);
	}

	/**
	 * @dev Revokes an exclusion from rebases
	 * @param account The account to revoke
	*/
	function revokeRebaseExclusion(address account) external onlyOperator
	{
		require(_isExcluded[account], 'Account is not already excluded');
		uint256 excludedLength = excluded.length;
		for (uint256 i = 0; i < excludedLength; i++) {
			if (excluded[i] == account) {
				excluded[i] = excluded[excludedLength - 1];
				_isExcluded[account] = false;
				excluded.pop();
				emit RevokeExclusion(account);
				return;
			}
		}
	}

    //---OVERRIDE FUNCTION---
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        if (_gonsPerFragment == 0) return 0;
		return _balances[who].div(_gonsPerFragment);
    }
        
    function _mint(address account, uint256 amount) internal virtual override {
		require(account != address(0), 'ERC20: transfer to the zero address');
		require(amount > 0, "ERC20: Can't mint 0 tokens");

		TOTAL_GONS = TOTAL_GONS.add(_gonsPerFragment.mul(amount));
		_totalSupply = _totalSupply.add(amount);

		_balances[account] = _balances[account].add(
			amount.mul(_gonsPerFragment)
		);

		emit Transfer(address(0), account, amount);
	}

    function _burn(address account, uint256 amount) internal virtual override {
		require(account != address(0), 'ERC20: burn from the zero address');
		uint256 accountBalance = _balances[account];
		require(
			accountBalance >= amount.mul(_gonsPerFragment),
			'ERC20: burn amount exceeds balance'
		);
		unchecked {
			_balances[account] = _balances[account].sub(
				amount.mul(_gonsPerFragment)
			);
		}

		TOTAL_GONS = TOTAL_GONS.sub(_gonsPerFragment.mul(amount));
		_totalSupply = _totalSupply.sub(amount);

		emit Transfer(account, address(0), amount);
	}

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual override {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transferBase(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);

        uint256 gonValue = amount.mul(_gonsPerFragment);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= gonValue, "ERC20: transfer amount exceeds balance");
        _balances[from] = _balances[from].sub(gonValue);
        _balances[to] = _balances[to].add(gonValue);
        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

	function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
		require(from != address(0), "zero address");
        require(to != address(0), "zero address");
        require(polWallet != address(0),"require to set polWallet address");
				
		// Selling token
		if(marketLpPairs[to] && !excludedTaxAddresses[from]) {
			uint256 maxAmountSell = rebaseSupply().mul(maximumAmountSellPercent).div(10000);
			require(amount <= maxAmountSell, "Over max selling amount");
			if (enabledTax) {
				uint256 taxAmount = 0;
				_updatePrice();
				uint256 currentTokenPrice = _getTokenPrice();
				uint256 currentTaxRate = calculateTaxRate(currentTokenPrice);
				if (currentTaxRate > 0) {
					taxAmount = amount.mul(currentTaxRate).div(10000);
				}
				if(taxAmount > 0)
				{
					amount = amount.sub(taxAmount);
					_transferBase(from, polWallet, taxAmount);
				}
			}
		}

        _transferBase(from, to, amount);
    }

    /**
     * @notice Operator mints Token to a recipient
     * @param recipient_ The address of recipient
     * @param amount_ The amount of Token to mint to
     * @return whether the process has been done
    */
    function mint(address recipient_, uint256 amount_) external onlyOperator returns (bool) {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);
        return balanceAfter > balanceBefore;
    }

	function burn(uint256 amount) external {
		if (amount > 0) _burn(_msgSender(), amount);
    }

    function burnFrom(address from, uint256 amount) external onlyOperator{
        require(from != address(0), "Zero address");
        if(amount > 0) _burn(from, amount);
    }
    //---END OVERRIDE FUNCTION---

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
		_transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance(sender, _msgSender()).sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

	function isPolWallet(address _address) external view returns (bool) {
		return _address == polWallet;
	}

	function isDaoFund(address _address) external view returns (bool) {
		return _address == daoFund;
	}

    function distributeReward(
        address _genesisPool,
        address _daoFundAddress
    ) external onlyOperator {
        require(!rewardPoolDistributed, "only can distribute once");
        require(_genesisPool != address(0), "!_genesisPool");
        require(_daoFundAddress != address(0), "!_daoFundAddress");
		rewardPoolDistributed = true;
        
		_mint(_genesisPool, INITIAL_GENESIS_POOL_DISTRIBUTION);
		daoFund = _daoFundAddress;
    }

	function _getTokenPrice() internal view returns (uint256 _tokenPrice) {
        try IOracle(oracle).consult(address(this), 1e18) returns (uint144 _price) {
            return uint256(_price).mul(1000);
        } catch {
            revert("Error: Failed to fetch token price from Oracle");
        }
    }
	
    function _updatePrice() internal {
        try IOracle(oracle).update() {} catch {
            revert("Error: failed to update price from the oracle");
        }
    }

	function setTokenOracle(address _oracle) external onlyTaxOffice {
		require(!isSetOracle, "Only can setTokenOracle once");
        require(_oracle != address(0), "Oracle address cannot be 0 address");
		emit SetTokenOracle(oracle, _oracle);
        oracle = _oracle;
		isSetOracle= true;
    }
	
	function setPolWallet(address _polWallet) external onlyTaxOffice {
        require(_polWallet != address(0), "_polWallet address cannot be 0 address");
		emit SetPolWallet(polWallet, _polWallet);
        polWallet = _polWallet;
    }

	function calculateTaxRate(uint256 _tokenPrice) public view returns (uint256) {
		uint256 taxTiersTwapsCount = taxTiersTwaps.length;
		uint256 taxRate = 0;
		if (block.timestamp >= lastTimeRebase && block.timestamp < lastTimeRebase.add(timeTaxAfterRebase)) {
			return taxRateAfterRebase;
		} 
		for (uint8 tierId = uint8(taxTiersTwapsCount.sub(1)); tierId >= 0; --tierId) {
			if (_tokenPrice >= taxTiersTwaps[tierId]) {
				taxRate = taxTiersRates[tierId];
				break;
			}
		}

		return taxRate;
    }

	function setTaxTiersTwap(uint8 _index, uint256 _value) external onlyTaxOffice returns (bool) {
		uint256 taxTiersTwapsCount = taxTiersTwaps.length;
        require(_index < uint8(taxTiersTwapsCount), "Index has to lower than count of tax tiers");
        if (_index > 0) {
            require(_value > taxTiersTwaps[_index - 1], "taxTiersTwaps[i] has to be lower than taxTiersTwaps[i + 1]");
        }
        if (_index < uint8(taxTiersTwapsCount.sub(1))) {
            require(_value < taxTiersTwaps[_index + 1], "taxTiersTwaps[i] has to be lower than taxTiersTwaps[i + 1]");
        }
        taxTiersTwaps[_index] = _value;
		emit SetTaxTiersTwap(_index, _value);
        return true;
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) external onlyTaxOffice returns (bool) {
		uint8 taxTiersRatesCount = uint8(taxTiersRates.length);
        require(_index < taxTiersRatesCount, "Index has to lower than count of tax tiers");
		require(_value <= 5000, "Tax equal or bigger to 50%");

        taxTiersRates[_index] = _value;
		emit SetTaxTiersRate(_index, _value);
        return true;
    }

	function setTaxRateAfterRebase(uint256 _value) external onlyTaxOffice returns (bool) {
		require(_value <= 5000, "Tax equal or bigger to 50%");
		emit SetTaxRateAfterRebase(taxRateAfterRebase, _value);
        taxRateAfterRebase = _value;
        return true;
    }

	function setTimeTaxAfterRebase(uint256 _value) external onlyTaxOffice returns (bool) {
		require(_value <= 24 hours, "Time equal or bigger to 24h");
		emit SetTimeTaxAfterRebase(timeTaxAfterRebase, _value);
        timeTaxAfterRebase = _value;
        return true;
    }

	function excludeTaxAddress(address _address) external onlyTaxOffice returns (bool) {
        require(!excludedTaxAddresses[_address], "Address can't be excluded");
        excludedTaxAddresses[_address] = true;
        return true;
    }

    function includeTaxAddress(address _address) external onlyTaxOffice returns (bool) {
        require(excludedTaxAddresses[_address], "Address can't be included");
        excludedTaxAddresses[_address] = false;
        return true;
    }

	function isAddressExcluded(address _address) external view returns (bool) {
        return _isExcluded[_address];
    }

	function enableCalculateTax() external onlyTaxOffice {
        enabledTax = true;
		emit EnableCalculateTax();
    }

    function disableCalculateTax() external onlyTaxOffice {
        enabledTax = false;
		emit DisableCalculateTax();
    }

	function setMaximumAmountSellPercent(uint256 _value) external onlyTaxOffice returns (bool) {
		require(_value <= 10000 && _value >= 10, "Value range [0.1-100%]");
		emit SetMaximumAmountSellPercent(maximumAmountSellPercent, _value);
        maximumAmountSellPercent = _value;
        return true;
    }

	//Add new LP's for selling / buying fees
    function setMarketLpPairs(address _pair, bool _value) public onlyTaxOffice {
        marketLpPairs[_pair] = _value;
    }
}