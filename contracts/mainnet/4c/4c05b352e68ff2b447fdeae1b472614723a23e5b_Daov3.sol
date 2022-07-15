/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT
// File: contract/Swap.sol


pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// Dependency file: contracts/interfaces/IUniswapV2Router02.sol

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

// File: contract/Daov3.sol


pragma solidity ^0.8.0;





interface IRank{
     function getAddressRank(address _address) external view returns(uint);
}


contract  Daov3  is ERC20,  Ownable  {
    using SafeMath for uint256;

   

    IRank iRank;
    address payable public marketAddress;//项目方||回流地址
    address public jiAddress;//基金会地址
    address public topAddress;//顶部地址
    address public nftContract;
    address public _swapV2Pair; //lp地址
    address public _swapV2Router; //路由地址
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public uniswapV2Pair;
    address private usdt;

    struct user{
        address userid;//用户
        address pid;//父级
        uint256 layerAll;//伞下数激活数
        uint256 zhiLp;//直推lp标准户
        uint256 lpall;//伞下LP标准户数量
        uint256 lockNum;//总锁仓
        uint256 unLockNum;//已释放
        // uint256 totalAir;//总空头数量
        uint256 lastTime;//最后领取锁仓释放的时间
        uint256 rank;//等级0普通用户1推广达人2节点用户3联创
        // uint256 canColNum;//可以提取的币
        bool isMore50;
    }

    

    struct pledgeRecord{
        uint index;
        uint lp;
        uint usdt;
        uint token;
        uint lastTime;
        uint state;
        address userid;
    }

    //lp推广奖励
    struct lpBonus{
        uint canColNum;
        uint totalNum;
    }
    //节点奖励
    struct nodeBonus{
        uint canColNum;
        uint totalNum;
    }
    //合伙人奖励
    struct partnerBonus{
        uint canColNum;
        uint totalNum;
    }

    
    
    mapping (address => address[]) public children;//所有直推子账号
    mapping (address => user) public userInfo;//用户详情
    mapping (address => address[]) public userPath;//用户路径
    mapping (address => uint256) public userPledge;//用户质押
    mapping (address => uint256) public userPledgeCount;//用户质押次数
    pledgeRecord[] public pledgeRecords;//用户质押
    //mapping (address => uint256) private lp50;//用户质押
    mapping (address => uint256) public nodeShiNum;//节点或者联创自己添加LP是否释放过500币
    // mapping (address => uint256) public nodeShiLpNum;//节点或者联创推荐LP用户是否释放过500币
    mapping (address => lpBonus) public lpBonuses;//LP推广奖励
    mapping (address => nodeBonus) public nodeBonuses;//节点奖励
    mapping (address => partnerBonus) public partnerBonuses;//合伙人奖励
    mapping (address => uint) public colDayBonus;//用户已经领取每日释放的币
    
    address[] public partners;
    address[] public nodes;
    uint256[] private step;
    //uint256 public jiStartTime;//开始时间
    
    uint256 public allUser;
    address[] public allLpUsers;
    uint private unlocked = 1;
   

    constructor(
        
       address rankContract,//rankaddress
       address _marketAddress,
       address _jiAddress
    ) ERC20("FIREDAO4", "FIREDAO4") {
        _mint(msg.sender, 8000000 * 1 ether *60/1000 );
        _mint(address(this), 8000000 * 1 ether *940/1000 );
        //jiStartTime=block.timestamp;
       
        topAddress =msg.sender;
        marketAddress=payable(_marketAddress);
        jiAddress=_jiAddress;
        iRank = IRank(rankContract);
        step = [300,200,100,100,100,100,200,200,300,300];
        usdt= 0xeDfa2FF20B7DA5e7ba525713718AE8DBea1F3F82;
        //_swapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _swapV2Router= 0x3E2b14680108E8C5C45C3ab5Bc04E01397af14cB;
        // uniswapV2Router = IUniswapV2Router02(_swapV2Router);//路由合约实例
        // _swapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
        //     address(this),
        //     usdt
        // );//配对LP地址
        _swapV2Pair=0xeDfa2FF20B7DA5e7ba525713718AE8DBea1F3F82;
        //uniswapV2Pair=IUniswapV2Pair(_swapV2Pair);//配对合约实例化
        

    }


    //0激活时父级奖励1个币 推荐收益
    //1节点添加LP后伞下新增用户释放1个币 节点推荐收益
    //11联创添加LP后伞下新增用户释放1个币 联创推荐收益
    //2节点添加LP满足数量 300释放币  节点收益
    //22联创添加LP满足数量 500释放币 联创收益
    //3每天签到释放4%   
    //4 签到释放 产生的团队将   团队收益
    //5 lp分红           LP分红
    //6 极差        级差收益
    //7 平级         平级收益
    //8 节点推荐100LP用户释放200币  节点推荐收益
    //9 联创推荐100LP用户释放300币  联创推荐收益

   
    event log(address indexed userid,uint lastTime,uint classes, uint num);

    //0 提取LP推广
    //1 提取节点奖励
    //2 提取合伙人奖励
    //3 提取锁仓每日释放
    event drawlog(address indexed userid,uint lastTime, uint classes,uint num);


    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    //获取用户提取lpBonuses
    function colLpBonus() public {
            require(lpBonuses[msg.sender].canColNum>0 && balanceOf(address(this))>=lpBonuses[msg.sender].canColNum);
            super._transfer(address(this),msg.sender,lpBonuses[msg.sender].canColNum);
            emit drawlog(msg.sender,getTime(),0,lpBonuses[msg.sender].canColNum);
            lpBonuses[msg.sender].canColNum=0;
            
    }
     //获取用户提取nodeBonus
    function colNodeBonus() public {
            require(nodeBonuses[msg.sender].canColNum>0 && balanceOf(address(this))>=nodeBonuses[msg.sender].canColNum);
            super._transfer(address(this),msg.sender,nodeBonuses[msg.sender].canColNum);
            emit drawlog(msg.sender,getTime(),1,nodeBonuses[msg.sender].canColNum);
            nodeBonuses[msg.sender].canColNum=0;
    }

    //获取用户提取nodeBonus
    function colPartnerBonus() public {
            require(partnerBonuses[msg.sender].canColNum>0 && balanceOf(address(this))>=partnerBonuses[msg.sender].canColNum);
            super._transfer(address(this),msg.sender,partnerBonuses[msg.sender].canColNum);
            emit drawlog(msg.sender,getTime(),2,partnerBonuses[msg.sender].canColNum);
            partnerBonuses[msg.sender].canColNum=0;
    }

    //获取用户提取每日释放
    function colDayBonusFun() public {
            require(getColDayBonus(msg.sender)>0 && balanceOf(address(this))>=getColDayBonus(msg.sender));
            uint _bonus=getColDayBonus(msg.sender);
            super._transfer(address(this),msg.sender,_bonus);
            emit drawlog(msg.sender,getTime(),3,_bonus);
            colDayBonus[msg.sender]+=_bonus;
            if(userPath[msg.sender].length>1){
                uint rand =0;
                for(uint i = userPath[msg.sender].length-1 ; i>0 ; i--){
                    rand+=1;
                    if(rand==11){
                        break;
                    }
                    // [a,b,c,d]
                    // 0 1 2 3

                    // [10,20,30,40,50,60,70]
                    // 0 1 2 3

                    // 3-i(i-3 2 1 ) level>=3-i+1
                    if(userInfo[userPath[msg.sender][i]].zhiLp >=  userPath[msg.sender].length-1+1-i && userPath[msg.sender].length-1-i<=9){
                        if(getLimit(userPath[msg.sender][i],_bonus.mul(step[userPath[msg.sender].length-1-i]).div(1000))>0){
                            lpBonuses[userPath[msg.sender][i]].canColNum+=getLimit(userPath[msg.sender][i],_bonus.mul(step[userPath[msg.sender].length-1-i]).div(1000));
                            lpBonuses[userPath[msg.sender][i]].totalNum+=getLimit(userPath[msg.sender][i],_bonus.mul(step[userPath[msg.sender].length-1-i]).div(1000));
                            userInfo[userPath[msg.sender][i]].unLockNum+=getLimit(userPath[msg.sender][i],_bonus.mul(step[userPath[msg.sender].length-1-i]).div(1000));
                            
                            emit log(userPath[msg.sender][i],getTime(),4,_bonus.mul(step[userPath[msg.sender].length-1-i]).div(1000));
                        }
                       
                    }
                    
                }
            }
    }

    //获取用户可以提取的释放多少币40%的
    function getColDayBonus(address _address) public view returns(uint){
            if(getDayBonus(_address)<=0){
                return 0;
            }else{
                return getLimit(_address,getDayBonus(_address).sub(colDayBonus[_address]));
            }
            
    }

    //获取用户累积可以释放多少币40%的
    function getDayBonus(address _address) public view returns(uint){
        uint  bonus;
        uint firstDay;
        bool _bool=true;
        for(uint i=0 ; i<pledgeRecords.length;i++){
            if(pledgeRecords[i].userid==_address && pledgeRecords[i].state==0){
                if(_bool){
                    firstDay=pledgeRecords[i].lastTime;
                    _bool=false;
                }
                if(getTime().sub(pledgeRecords[i].lastTime)<=0){
                    break;
                }else{
                    if(getTime().sub(pledgeRecords[i].lastTime).div(3*60)<=0){
                        break;
                    }else{
                        bonus+=pledgeRecords[i].usdt.mul(40).mul((getTime().sub(pledgeRecords[i].lastTime)).div(3*60)).div(1000);
                    }
                    
                }
            }
        }
        //总天数
        if(getTime().sub(firstDay).div(3*60)>0){
            if(bonus > getTime().sub(firstDay).div(3*60).mul(5 ether)){
                bonus = getTime().sub(firstDay).div(3*60).mul(5 ether);
            }
            
        }

        return u2token(bonus);

    }

    function u2token(uint _u) public pure returns(uint){
        // uint _token;
        // uint _usdt;
        // // 定义部分参数进行接收，未接收的参数，直接用逗号","分割即可。
        // (_token,_usdt,) = uniswapV2Pair.getReserves();
        // if(_token==0 || _usdt==0){
        //     return 0;
        // }else{
        //     return _u.mul(_token).div(_usdt);
        // }

        return _u;
        
    }

    function setNft(address _nft) public{
        require(msg.sender==marketAddress);
        nftContract=_nft;
    }

    function addLockNum(address _address,uint256 _num) public{
        require(msg.sender==nftContract);
        userInfo[_address].lockNum+=_num;
    }

    function getIsUser(address _address) public view returns (bool){
        if(userInfo[_address].lastTime>0){
            return true;
        }else{
            return false;
        }
    }

    function getLimit(address _address,uint _num) private view returns(uint){
        uint left = (userInfo[_address].lockNum.sub(userInfo[_address].unLockNum).sub(getDayBonus(_address)));
        if(left<=0){
            return 0;
        }else{
            if(left>=_num){
                return _num;
            }else{
                return _num.sub(left);
            }
        }
    }

    //register
    function register(address pid) public payable{
         require(msg.value>=0.031 ether,"1001");
         require(msg.sender!=topAddress,"1002");
         require(pid != msg.sender,"1003");
        // require( userInfo[msg.sender].userid == address(0) &&  !isContract(msg.sender) && !isContract(pid));
        require( userInfo[msg.sender].userid == address(0),"1004");
        require( !isContract(msg.sender),"1005");
        require( !isContract(pid),"1006");
        if(pid!=topAddress){
            require(userInfo[pid].userid != address(0));
            
            userPath[msg.sender]=userPath[pid];
            userPath[msg.sender].push(pid);
            children[pid].push(msg.sender);
        }else{
            userPath[msg.sender].push(topAddress);
        }
        allUser=allUser.add(1);
        //bnb转给项目方
        marketAddress.transfer(msg.value);
        //添加用户信息
        uint256 _num ;
        uint256 _getRank;
        _getRank=iRank.getAddressRank(msg.sender);
        if(_getRank==0){
            _num=500 ether;
        }else if(_getRank==1){
            _num=0;
        }else if(_getRank==2){
            _num=6000 ether;
        }else if(_getRank==3){
            _num=10000 ether;
        }
        userInfo[msg.sender]=user(
            msg.sender,
            pid,
            0,
            0,
            0,
           _num,0,
            block.timestamp,
            iRank.getAddressRank(msg.sender),
            false
            );
    
        //添加合伙人记录
        if(iRank.getAddressRank(msg.sender)==3){
            partners.push(msg.sender);
        }else if(iRank.getAddressRank(msg.sender)==2){
            nodes.push(msg.sender);
        }
        
        //父级直推+1
        if(pid!=topAddress){
            //添加父级用户送一个币

            if(getLimit(pid,1 ether)>0){
                lpBonuses[pid].canColNum+=getLimit(pid,1 ether);
                lpBonuses[pid].totalNum+=getLimit(pid,1 ether);
                userInfo[pid].unLockNum+=getLimit(pid,1 ether);
                emit log(pid,getTime(),0,1 ether);
            }
            
            
            //所有父级团队数+1
            for(uint i ; i<userPath[msg.sender].length;i++){
                if(i==50){
                    break;
                }
                if(userPath[msg.sender][i]!=topAddress){
                    userInfo[userPath[msg.sender][i]].layerAll+=1;
                    if(userInfo[userPath[msg.sender][i]].layerAll>=100 && userInfo[userPath[msg.sender][i]].layerAll==0 ){
                        userInfo[userPath[msg.sender][i]].rank=1;
                    }
                }
                
            }
        }
    }

    //获取用户质押时候的USDT总和
    function getRealUsdt(address _address) public view returns (uint){
        uint _res =0;
        for(uint i ; i<pledgeRecords.length ;i++){
            if(pledgeRecords[i].userid==_address && pledgeRecords[i].state==0){
                _res+=pledgeRecords[i].usdt;
            }
        }
        return _res;
    }

    //获取用户质押时候的token总和
    function getRealToken(address _address) public view returns (uint){
        uint _res =0;
        for(uint i ; i<pledgeRecords.length ;i++){
            if(pledgeRecords[i].userid==_address && pledgeRecords[i].state==0){
                _res+=pledgeRecords[i].token;
            }
        }
        return _res;
    }

    // //质押lp
    function pledge(uint256 num) public {
        require(userInfo[msg.sender].userid!=address(0));
        IERC20(_swapV2Pair).transferFrom(msg.sender,address(this),num);
        if(getRealUsdt(msg.sender)==0){
                allLpUsers.push(msg.sender);
        }
        userPledge[msg.sender]=userPledge[msg.sender].add(num);//增加用户累积质押Lp数
        pledgeRecords.push(pledgeRecord(userPledgeCount[msg.sender],num,_getLp2u(num),_getLp2Token(num),block.timestamp,0,msg.sender));//增加用户质押记录
        userPledgeCount[msg.sender]+=1;//增加用户质押次数
        
        
        //如果自己时节点或者联创 是否增加了LP 时的话第一次增加空投币

        if(userInfo[msg.sender].rank==2 && _getRandReal(msg.sender,2) && nodeShiNum[msg.sender]==0){
            if(getLimit(msg.sender,300 ether)>0){
                nodeBonuses[msg.sender].canColNum+=getLimit(msg.sender,300 ether);
                nodeBonuses[msg.sender].totalNum+=getLimit(msg.sender,300 ether);
                userInfo[msg.sender].unLockNum+=getLimit(msg.sender,300 ether);
                nodeShiNum[msg.sender]+=300 ether;
                emit log(msg.sender,getTime(),2,300 ether);
            }
        }

        if(userInfo[msg.sender].rank==3 && _getRandReal(msg.sender,3) && nodeShiNum[msg.sender]<500 ether){
            if(getLimit(msg.sender,500 ether)>0){
                partnerBonuses[msg.sender].canColNum+=getLimit(msg.sender,500 ether);
                partnerBonuses[msg.sender].totalNum+=getLimit(msg.sender,500 ether);
                userInfo[msg.sender].unLockNum+=getLimit(msg.sender,500 ether);
                nodeShiNum[msg.sender]+=500 ether;
                emit log(msg.sender,getTime(),22,500 ether);
            }
        }
        
        //判断用户是否达到过标准LP用户
        if(getRealUsdt(msg.sender)>=50 ether){

            
            if(userInfo[msg.sender].pid!=topAddress){
                userInfo[userInfo[msg.sender].pid].zhiLp+=1;
                for(uint i ; i<userPath[msg.sender].length;i++){
                    if(userPath[msg.sender][i]!=topAddress){
                        //所有父级伞下LP标准户+1
                        userInfo[userPath[msg.sender][i]].lpall+=1;
                        if(userInfo[userPath[msg.sender][i]].lpall>=100 && userInfo[userPath[msg.sender][i]].rank==0){
                            userInfo[userPath[msg.sender][i]].rank=1;
                        }
                        //判断所有父级是否升级
                        if(_newLevel(userPath[msg.sender][i])>userInfo[userPath[msg.sender][i]].rank){
                            userInfo[userPath[msg.sender][i]].rank=_newLevel(userPath[msg.sender][i]);
                        }

                        //如果父级是节点   释放200币
                        if(userInfo[userPath[msg.sender][i]].lpall>=100 && userInfo[userPath[msg.sender][i]].rank==2 && userInfo[msg.sender].isMore50==false){
                            if(getLimit(userPath[msg.sender][i],200 ether)>0){
                                nodeBonuses[userPath[msg.sender][i]].canColNum+=getLimit(userPath[msg.sender][i],200 ether);
                                nodeBonuses[userPath[msg.sender][i]].totalNum+=getLimit(userPath[msg.sender][i],200 ether);
                                userInfo[userPath[msg.sender][i]].unLockNum+=getLimit(userPath[msg.sender][i],200 ether);
                                emit log(userPath[msg.sender][i],getTime(),8,200 ether);
                            }
                       
                        }

                        //如果父级是合伙人   释放300币
                        if(userInfo[userPath[msg.sender][i]].lpall>=100 && userInfo[userPath[msg.sender][i]].rank==3 && userInfo[msg.sender].isMore50==false){
                            if(getLimit(userPath[msg.sender][i],300 ether)>0){
                                partnerBonuses[userPath[msg.sender][i]].canColNum+=getLimit(userPath[msg.sender][i],300 ether);
                                partnerBonuses[userPath[msg.sender][i]].totalNum+=getLimit(userPath[msg.sender][i],300 ether);
                                userInfo[userPath[msg.sender][i]].unLockNum+=getLimit(userPath[msg.sender][i],300 ether);
                                emit log(userPath[msg.sender][i],getTime(),9,300 ether);
                            }
                        }


                        //所有父级是否达到节点和联创是否添加了LP 是的话释放1个币
                        if(userInfo[msg.sender].isMore50==false){
                            // if(_getRandReal(userPath[msg.sender][i],2) || _getRandReal(userPath[msg.sender][i],3)){
                            // }
                                if(getLimit(userPath[msg.sender][i],1 ether)>0){
                                    if(userInfo[userPath[msg.sender][i]].rank==2){
                                        nodeBonuses[userPath[msg.sender][i]].canColNum+=getLimit(userPath[msg.sender][i],1 ether);
                                        nodeBonuses[userPath[msg.sender][i]].totalNum+=getLimit(userPath[msg.sender][i],1 ether);
                                        userInfo[userPath[msg.sender][i]].unLockNum+=getLimit(userPath[msg.sender][i],1 ether);
                                        emit log(userPath[msg.sender][i],getTime(),1,1 ether);
                                    }

                                    if(userInfo[userPath[msg.sender][i]].rank==3){
                                        partnerBonuses[userPath[msg.sender][i]].canColNum+=getLimit(userPath[msg.sender][i],1 ether);
                                        partnerBonuses[userPath[msg.sender][i]].totalNum+=getLimit(userPath[msg.sender][i],1 ether);
                                        userInfo[userPath[msg.sender][i]].unLockNum+=getLimit(userPath[msg.sender][i],1 ether);
                                        emit log(userPath[msg.sender][i],getTime(),11,1 ether);
                                    }
                                
                                }
                             
                            
                        }
                        
                    }
                }
            }
            
            userInfo[msg.sender].isMore50=true;//是否已经达到过50

        }
    }

    //是否升级
    function _newLevel(address _address) private view returns(uint){
        uint newLevel = userInfo[_address].rank;
        if(userInfo[_address].layerAll>=300 && userInfo[_address].lpall>=200){
            newLevel=2;
        }
        if(userInfo[_address].layerAll>=2000 && userInfo[_address].lpall>=1000){
            newLevel=3;
        }
        return newLevel;
    }

    //获取用户质押记录
    function getPledgeRecords(address _address) public view returns(pledgeRecord[] memory){
        pledgeRecord[] memory res;
        res=new pledgeRecord[](userPledgeCount[_address]);
        uint index=0;
        for(uint i=0 ; i<pledgeRecords.length;i++){
            if(pledgeRecords[i].userid==_address){
                res[index]=pledgeRecords[i];
                index+=1;
            }
        }
        return res;
    }

    

    // //解押lp
    function unPledge() public lock{
        require(userInfo[msg.sender].userid!=address(0));
        require(userPledge[msg.sender]>0 && IERC20(_swapV2Pair).balanceOf(address(this))>=userPledge[msg.sender]);
        
        
        if(getRealUsdt(msg.sender)>50 ether){
            if(userInfo[msg.sender].pid!=topAddress){
                userInfo[userInfo[msg.sender].pid].zhiLp=userInfo[userInfo[msg.sender].pid].zhiLp.sub(1);
            }
            for(uint i ; i<userPath[msg.sender].length;i++){
                if(userPath[msg.sender][i]!=topAddress){
                    //所有父级伞下LP标准户-1
                    userInfo[userPath[msg.sender][i]].lpall=userInfo[userPath[msg.sender][i]].lpall.sub(1);
                    if(userInfo[userPath[msg.sender][i]].lpall<100 && userInfo[userPath[msg.sender][i]].rank==1){
                        userInfo[userPath[msg.sender][i]].rank=0;
                    }

                    //判断所有父级是否降级
                        if(_newLevel(userPath[msg.sender][i])<userInfo[userPath[msg.sender][i]].rank){
                            userInfo[userPath[msg.sender][i]].rank=_newLevel(userPath[msg.sender][i]);
                        }
                }
            }
            
        }
       
        IERC20(_swapV2Pair).transfer(msg.sender,userPledge[msg.sender].mul(95).div(1000));
        IERC20(_swapV2Pair).transfer(jiAddress,userPledge[msg.sender].sub(userPledge[msg.sender].mul(95).div(1000)));
        userPledge[msg.sender]=0;
        for(uint i ; i<pledgeRecords.length;i++){
            if(pledgeRecords[i].userid==msg.sender){
                pledgeRecords[i].state=1;
            }
        }
        
    }

    //是否满足节点或者联创的所有条件
    function _getRandReal(address _address,uint _rank) private view returns(bool){
        if(_rank==2){
            return getRealToken(_address)>=200 ether;
        }else if(_rank==3){
            return getRealToken(_address)>=300 ether;
        }else{
            return false;
        }
    }
    // //当前用户质押的LP=>u部分
    // function _getLp2u(uint _lp) private view returns(uint256){
    //     if(IERC20(_swapV2Pair).totalSupply() ==0 || _lp==0){
    //         return 0;
    //     }
    //     return  IERC20(usdt).balanceOf(_swapV2Pair).mul(_lp).div(IERC20(_swapV2Pair).totalSupply());
    // }

    // //当前用户质押的LP=>token部分
    // function _getLp2Token(uint _lp) private view returns(uint256){
    //     if(IERC20(_swapV2Pair).totalSupply() ==0 || _lp==0){
    //         return 0;
    //     }else{
    //         return  balanceOf(_swapV2Pair).mul(_lp).div(IERC20(_swapV2Pair).totalSupply());
    //     }
        
        
    // }

     function _getLp2u(uint _lp) private pure returns(uint256){
       
        return  _lp;
    }

    //当前用户质押的LP=>token部分
    function _getLp2Token(uint _lp) private pure returns(uint256){
       
            return  _lp;
        
        
        
    }



  
        
        
    // }

    //系统时间
    function getTime() public view returns(uint){
        // if(block.number.sub(_jiBlockNum)==0){
        //     return jiStartTime;
        // }else{
        //     return jiStartTime+3*(block.number.sub(_jiBlockNum));
        // }
        return block.timestamp;
       
    }

    //获取所有子账户//ok
    function getChildren(address _address) public view returns(user[] memory){
        user[] memory result ;
        result= new user[](children[_address].length);
        for(uint i=0;i<children[_address].length;i++){
            result[i]=userInfo[children[_address][i]];
        }
        return result;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(from==_swapV2Pair ||from==_swapV2Router ){
            //买 进6%，市场奖励4%，LP标准户全网加权分红2%
            uint256 marketAmount = amount.mul(40).div(1000);
            uint256 lpAmount = amount.mul(20).div(1000);
            super._transfer(from,to,amount.sub(marketAmount).sub(lpAmount));


            //_getFee(marketAmount,to);
            uint edu = 0;
            uint preRank =0;
            
            if(userPath[to].length>1){
                for(uint i = userPath[to].length-1; i>0 ; i--){
                    if(userInfo[userPath[to][i]].rank>preRank){
                        
                        if(userInfo[userPath[to][i]].rank== userInfo[userInfo[userPath[to][i]].pid].rank && userInfo[userPath[to][i]].rank !=3){
                            super._transfer(from,userPath[to][i],marketAmount.mul(1000).div(_getJIchaRate(userPath[to][i])-edu));
                            super._transfer(from,userInfo[userPath[to][i]].pid,marketAmount.mul(1000).div(5));
                            edu=_getJIchaRate(userPath[to][i]).add(5);
                            preRank=userInfo[userPath[to][i]].rank;
                        }else{
                            super._transfer(from,userPath[to][i],marketAmount.mul(1000).div(_getJIchaRate(userPath[to][i])-edu));
                            edu=_getJIchaRate(userPath[to][i]);
                            preRank=userInfo[userPath[to][i]].rank;
                        }
                    
                        
                    }
                    
                    if(edu==40){
                        break;
                    }
                }
            }


            if(allLpUsers.length>0){
                if(lpAmount.div(allLpUsers.length)>0){
                    for(uint i ; i<allLpUsers.length;i++){
                        super._transfer(from,allLpUsers[i],lpAmount.div(allLpUsers.length));
                    }
                }
            }
            
            

        }else if(to==_swapV2Pair ||to==_swapV2Router){

            //卖 风险基金4%，回流底池2%
            uint256 jiAmount = amount.mul(40).div(1000);
            uint256 marketAmount = amount.mul(20).div(1000);
            super._transfer(from, marketAddress, marketAmount);
            super._transfer(from, jiAddress,jiAmount ); 
            super._transfer(from, to, amount.sub(jiAmount).sub(marketAmount));
        }else{
            super._transfer(from,to,amount); 
        }
       

     
    }

   

    function _getJIchaRate(address _address) private view returns(uint){
        if(userInfo[_address].rank==0){
            return 0;
        }else if(userInfo[_address].rank==1){
            return 20;
        }else if(userInfo[_address].rank==2){
            return 30;
        }else if(userInfo[_address].rank==3){
            return 40;
        }else{
            return 0;
        }
    }

    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }


    function getAllPartners() public view returns(address[] memory){
        address[] memory res = new address[](partners.length);
        for(uint i=0;i<partners.length;i++){
            res[i]=partners[i];
        }
        return res;
    }

    function getAllNodes() public view returns(address[] memory){
        address[] memory res = new address[](nodes.length);
        for(uint i=0;i<nodes.length;i++){
            res[i]=nodes[i];
        }
        return res;
    }

 

  




    


}