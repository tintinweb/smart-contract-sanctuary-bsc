/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
library SignedSafeMath {
    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

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
    function max(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a >= b ? a : b; 
    }
}

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

/*
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
/* PancakeSwap Interface */
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
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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

/**
 * @dev Implementation of the {IERC20} interface.
 
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        _setOwner(_msgSender());
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
     
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
*/
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}


/// @title Reward-Paying Token Optional Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev OPTIONAL functions for a reward-paying token contract.
interface RewardPayingTokenOptionalInterface {
  /// @notice View the amount of reward in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of reward in wei that `_owner` can withdraw.
  function withdrawableRewardOf(address _owner) external view returns(uint256);

  /// @notice View the amount of reward in wei that an address has withdrawn.
  /// @param _owner The address of a token holder.
  /// @return The amount of reward in wei that `_owner` has withdrawn.
  function withdrawnRewardOf(address _owner) external view returns(uint256);

  /// @notice View the amount of reward in wei that an address has earned in total.
  /// @dev accumulativeRewardOf(_owner) = withdrawableRewardOf(_owner) + withdrawnRewardOf(_owner)
  /// @param _owner The address of a token holder.
  /// @return The amount of reward in wei that `_owner` has earned in total.
  function accumulativeRewardOf(address _owner) external view returns(uint256);
}


/// @title Reward-Paying Token Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev An interface for a reward-paying token contract.
interface RewardPayingTokenInterface {
  /// @notice View the amount of reward in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of reward in wei that `_owner` can withdraw.
  function rewardOf(address _owner) external view returns(uint256);

  /// @notice Distributes ether to token holders as rewards.
  /// @dev SHOULD distribute the paid ether to token holders as rewards.
  ///  SHOULD NOT directly transfer ether to token holders in this function.
  ///  MUST emit a `RewardsDistributed` event when the amount of distributed ether is greater than 0.
  function distributeRewards(uint256 _token) external ;//RIO EX payable

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev SHOULD transfer `rewardOf(msg.sender)` wei to `msg.sender`, and `rewardOf(msg.sender)` SHOULD be 0 after the transfer.
  ///  MUST emit a `RewardWithdrawn` event if the amount of ether transferred is greater than 0.
  function withdrawReward() external;

  /// @dev This event MUST emit when ether is distributed to token holders.
  /// @param from The address which sends ether to this contract.
  /// @param weiAmount The amount of distributed ether in wei.
  event RewardsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  /// @dev This event MUST emit when an address withdraws their reward.
  /// @param to The address which withdraws ether from this contract.
  /// @param weiAmount The amount of withdrawn ether in wei.
  event RewardWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}


/// @title Reward-Paying Token
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev A mintable ERC20 token that allows anyone to pay and distribute ether
///  to token holders as rewards and allows token holders to withdraw their rewards.
///  Reference: the source code of PoWH3D: https://etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
contract RewardPayingToken is ERC20, RewardPayingTokenInterface, RewardPayingTokenOptionalInterface {
  using SafeMath for uint256;
  using SignedSafeMath for int256;
  using SafeCast for uint256;
  using SafeCast for int256;

  // With `magnitude`, we can properly distribute rewards even if the amount of received ether is small.
  // For more discussion about choosing the value of `magnitude`,
  //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
  uint256 constant internal magnitude = 2**128;

  uint256 internal magnifiedRewardPerShare;

    address public AXN_TOKEN;
  // About rewardCorrection:
  // If the token balance of a `_user` is never changed, the reward of `_user` can be computed with:
  //   `rewardOf(_user) = rewardPerShare * balanceOf(_user)`.
  // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
  //   `rewardOf(_user)` should not be changed,
  //   but the computed value of `rewardPerShare * balanceOf(_user)` is changed.
  // To keep the `rewardOf(_user)` unchanged, we add a correction term:
  //   `rewardOf(_user) = rewardPerShare * balanceOf(_user) + rewardCorrectionOf(_user)`,
  //   where `rewardCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
  //   `rewardCorrectionOf(_user) = rewardPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
  // So now `rewardOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
  mapping(address => int256) internal magnifiedRewardCorrections;
  mapping(address => uint256) internal withdrawnRewards;
  mapping(address => uint256) internal withdrawnNum;

  uint256 public totalRewardsDistributed;

  uint256 public totalRewardsCreated;

  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
      AXN_TOKEN = msg.sender;
  }

  /// @dev Distributes rewards whenever ether is paid to this contract.
  receive() external payable {
  }
  
  /// @notice Distributes ether to token holders as rewards.
  /// @dev It reverts if the total supply of tokens is 0.
  /// It emits the `RewardsDistributed` event if the amount of received ether is greater than 0.
  /// About undistributed ether:
  ///   In each distribution, there is a small amount of ether not distributed,
  ///     the magnified amount of which is
  ///     `(msg.value * magnitude) % totalSupply()`.
  ///   With a well-chosen `magnitude`, the amount of undistributed ether
  ///     (de-magnified) in a distribution can be less than 1 wei.
  ///   We can actually keep track of the undistributed ether in a distribution
  ///     and try to distribute it in the next distribution,
  ///     but keeping track of such data on-chain costs much more than
  ///     the saved ether, so we don't do that.
  function distributeRewards(uint256 _token) public override {// FROM VALUE TO TOKENS
   require(msg.sender == AXN_TOKEN,"only from AXN contract");
    require(totalSupply() > 0);

    if (_token > 0) {
      magnifiedRewardPerShare = magnifiedRewardPerShare.add(
        (_token).mul(magnitude) / totalSupply()
      );
      totalRewardsCreated = totalRewardsCreated.add(_token);
      emit RewardsDistributed(msg.sender, _token);
    }
  }

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev It emits a `RewardWithdrawn` event if the amount of withdrawn ether is greater than 0.
  function withdrawReward() public virtual override {
    _withdrawRewardOfUser(msg.sender);//RIO EX payable(
  }

  /// @notice Withdraws the ether distributed to the sender.
  /// @dev It emits a `RewardWithdrawn` event if the amount of withdrawn ether is greater than 0.
  function _withdrawRewardOfUser(address  user) internal returns (uint256) {//RIO EX payable
    uint256 _withdrawableReward = withdrawableRewardOf(user);
    if (_withdrawableReward > 0) {
      withdrawnRewards[user] = withdrawnRewards[user].add(_withdrawableReward);
    
      withdrawnNum[user]++;
            
        IERC20(address(AXN_TOKEN)).transfer( user, _withdrawableReward);
        totalRewardsDistributed = totalRewardsDistributed.add(_withdrawableReward);
       
      emit RewardWithdrawn(user, _withdrawableReward);
      return _withdrawableReward;
    }

    return 0;
  }

  /// @notice View the amount of reward in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of reward in wei that `_owner` can withdraw.
  function rewardOf(address _owner) public view override returns(uint256) {
    return withdrawableRewardOf(_owner);
  }

  /// @notice View the amount of reward in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of reward in wei that `_owner` can withdraw.
  function withdrawableRewardOf(address _owner) public view override returns(uint256) {
    return accumulativeRewardOf(_owner).sub(withdrawnRewards[_owner]);
  }

  /// @notice View the amount of reward in wei that an address has withdrawn.
  /// @param _owner The address of a token holder.
  /// @return The amount of reward in wei that `_owner` has withdrawn.
  function withdrawnRewardOf(address _owner) public view override returns(uint256) {
    return withdrawnRewards[_owner];
  }


  /// @notice View the amount of reward in wei that an address has earned in total.
  /// @dev accumulativeRewardOf(_owner) = withdrawableRewardOf(_owner) + withdrawnRewardOf(_owner)
  /// = (magnifiedRewardPerShare * balanceOf(_owner) + magnifiedRewardCorrections[_owner]) / magnitude
  /// @param _owner The address of a token holder.
  /// @return The amount of reward in wei that `_owner` has earned in total.
  function accumulativeRewardOf(address _owner) public view override returns(uint256) {
      
      uint256 balance = balanceOf(_owner);

    return magnifiedRewardPerShare.mul(balance).toInt256()
      .add(magnifiedRewardCorrections[_owner]).toUint256() / magnitude;
  }

  /// @dev Internal function that transfer tokens from one address to another.
  /// Update magnifiedRewardCorrections to keep rewards unchanged.
  /// @param from The address to transfer from.
  /// @param to The address to transfer to.
  /// @param value The amount to be transferred.
  function _transfer(address from, address to, uint256 value) internal virtual override {
    require(false);

    int256 _magCorrection = magnifiedRewardPerShare.mul(value).toInt256();
    magnifiedRewardCorrections[from] = magnifiedRewardCorrections[from].add(_magCorrection);
    magnifiedRewardCorrections[to] = magnifiedRewardCorrections[to].sub(_magCorrection);
  }

  /// @dev Internal function that mints tokens to an account.
  /// Update magnifiedRewardCorrections to keep rewards unchanged.
  /// @param account The account that will receive the created tokens.
  /// @param value The amount that will be created.
  function _mint(address account, uint256 value) internal override {
    super._mint(account, value);

    magnifiedRewardCorrections[account] = magnifiedRewardCorrections[account]
      .sub( (magnifiedRewardPerShare.mul(value)).toInt256() );
  }

  /// @dev Internal function that burns an amount of the token of a given account.
  /// Update magnifiedRewardCorrections to keep rewards unchanged.
  /// @param account The account whose tokens will be burnt.
  /// @param value The amount that will be burnt.
  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);

    magnifiedRewardCorrections[account] = magnifiedRewardCorrections[account]
      .add( (magnifiedRewardPerShare.mul(value)).toInt256() );
  }

  function _setBalance(address account, uint256 newBalance) internal returns (uint256){
    uint256 currentBalance = balanceOf(account);
    if(newBalance > currentBalance) {
      uint256 mintAmount = newBalance.sub(currentBalance);
      _mint(account, mintAmount);
    } else if(newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(newBalance);
      _burn(account, burnAmount);
    }
    return currentBalance;
  }
}
contract AXN_Reward_Token is RewardPayingToken, Ownable {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromRewards;

    mapping (address => uint256) public lastClaimTimes;
    mapping (address => uint256) public numClaimsAccount;

    uint256 public rewardInterval;
    uint256 public minimumTokenBalanceForRewards;

    event ExcludeFromRewards(address indexed account);
    event RewardIntervalUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount);


    constructor() RewardPayingToken("GEN", "GEN") {
        rewardInterval = 1 days;
        minimumTokenBalanceForRewards =  10 * (10**18);
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "AXN_Reward_Tracker: No transfers allowed");
    }

    function withdrawReward() public pure override {
        require(false, "AXN_Reward_Tracker: withdrawReward disabled. Use the 'claim' function on the main AXN contract.");
    }

    function excludeFromRewards(address account, bool value) external onlyOwner {
    	excludedFromRewards[account] = value;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromRewards(account);
    }
    
    function isExcludedFromRewards(address account) public view returns(bool) {
        return excludedFromRewards[account];
    }

    function updateRewardInterval(uint256 newRewardInterval) external onlyOwner {
        require(newRewardInterval != rewardInterval, "AXN_Reward_Tracker: Cannot update RewardInterval to same value");
        emit RewardIntervalUpdated(newRewardInterval, rewardInterval);
        rewardInterval = newRewardInterval;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function setMinimumTokenBalanceForRewards(uint256 _minimumTokenBalanceWei) public onlyOwner {
        minimumTokenBalanceForRewards = _minimumTokenBalanceWei;
    }

    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableRewards,
            uint256 totalRewards,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 numClaims,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableRewards = withdrawableRewardOf(account);
        totalRewards = accumulativeRewardOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(rewardInterval) :
                                    0;

        numClaims = numClaimsAccount[account];

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256, uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function setBuyTime(address _holder, uint256 _time) public onlyOwner {

        lastClaimTimes[_holder] = _time;
    }

    function getLastClaimRewardTime(address _holder) public view returns (uint256) {
       return lastClaimTimes[_holder];
    }
    
    function getNumClaimDays(address _holder) public view returns (uint256) {
       return numClaimsAccount[_holder];
    }
    function canClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= rewardInterval;
    }

    function setBalance(address account, uint256 newBalance) external onlyOwner {
    	if(excludedFromRewards[account]) {
    		return;
    	}

        uint256 numClaims = numClaimsAccount[account];
        if(numClaims >=  365 * 2){newBalance = newBalance.div(4);}
        else if(numClaims >= 365){newBalance = newBalance.div(2);}

            if(newBalance >= minimumTokenBalanceForRewards) {
                _setBalance(account, newBalance);
                tokenHoldersMap.set(account, newBalance);
            }
            else {
                _setBalance(account, 0);
                tokenHoldersMap.remove(account);
            }
    }


    function processAccount(address account, uint256 lastDistributionDay) public onlyOwner returns (bool) {
        uint256 iniTime = lastClaimTimes[account];
        if(canClaim(iniTime)) {
        uint256 amount = _withdrawRewardOfUser(account);

    	if(amount > 0) {
            uint256 dias = (block.timestamp.sub(iniTime)).div(rewardInterval);
            numClaimsAccount[account] = numClaimsAccount[account].add(dias);

    		lastClaimTimes[account] = lastDistributionDay;
            

            emit Claim(account, amount);
    		return true;
    	}
    }
        
    return false;
    }

}

contract SafeToken is Ownable {
    address payable safeManager;

    constructor() {
        safeManager = payable(owner());
    }

    function setSafeManager(address payable _safeManager) public onlyOwner {
        safeManager = _safeManager;
    }

}

contract LockToken is Ownable {
    bool public isOpen = true;
    mapping(address => bool) private _whiteList;
    modifier open(address from, address to) {
        require(isOpen || _whiteList[from] || _whiteList[to], "Not Open");
        _;
    }

    constructor() {
        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;
    }

    function openTrade(bool _isOpen) external onlyOwner {
        isOpen = _isOpen;
    }

    function includeToWhiteList(address[] memory _users) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            _whiteList[_users[i]] = true;
        }
    }
    
}

contract AXN is ERC20, Ownable, SafeToken, LockToken {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public uniswapV2PairUSDT;

    bool public inRewardsPaused;

    bool public sendAndLiquifyEnabled = true;

    bool mintingIsLive = true;

    AXN_Reward_Token public rewardTracker;

    uint256 public maxSellTransactionAmount = 1_000_000 * (10**18);

    uint256 public rewardRate = 4219472133;//with 12 decimals divider -> 0,4219472133%
    
    bool public isOpenToMarket = false;//Trading with PancakeSwap & Co. is disabled

    address payable public  projectWallet;

    address public deadWallet = address(0x000000000000000000000000000000000000dEaD);

    uint256 public lastSentToContract;
    
    // use by default 350,000 gas to auto-process reward distribution
    //uint256 public gasForProcessing = 300000;
    
    mapping(address => bool) private _isExcludedFromMaxTx;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to specific rules
    mapping (address => bool) public automatedMarketMakerPairs;

    //FEES
    uint256 public projectFeeRate = 50 ;//5%
    uint256 divider = 1000;
    uint256 public withdrawns;
    uint256 public deposits;
    uint256 public numDayRewarded;

    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;// main 
    IERC20 public USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);//usdt main 

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    //event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event sendAndLiquifyEnabledUpdated(bool enabled);

    event SendAndLiquify(
        uint256 tokensIntoLiqudity,
        uint256 ethReceived
    );

    event SendRewards(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedRewardTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

 
    constructor() ERC20("AXENCOIN", "AXN") {
               
        projectWallet = payable(msg.sender);

    	rewardTracker = new AXN_Reward_Token();

    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a PancakeSwap pair for this new token ->mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from send rewards
        rewardTracker.excludeFromRewards(address(rewardTracker), true);
        rewardTracker.excludeFromRewards(address(this),true);
        rewardTracker.excludeFromRewards(owner(),true);
        rewardTracker.excludeFromRewards(address(_uniswapV2Router),true);
        rewardTracker.excludeFromRewards(0x000000000000000000000000000000000000dEaD,true);
        
        // exclude from max tx
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[projectWallet] = true;

        setSendAndLiquifyEnabled(true);
        lastSentToContract = 1658206800;//hoy 00.00
    }
    
    function setMintingIsLive(bool _isOn) public onlyOwner returns (bool )  {
        mintingIsLive = _isOn;
        return _isOn;
    }

    function setinRewardsPaused(bool _bool) public onlyOwner {
        inRewardsPaused = _bool;
    }

    function setLastSentToContract(uint256 _date) public onlyOwner {
        lastSentToContract = _date;
    }

    function setBuyTimeOf(address[] memory _holders, uint256 _date) public onlyOwner {
        for (uint i=0; i < _holders.length; i++) {
        rewardTracker.setBuyTime(_holders[i], _date);
        }
    }

    function openTradeToMarket(bool _isOpen) public onlyOwner {
        isOpenToMarket = _isOpen;
    }
    // NOT USEFULL
    function distributeRewards(uint256 _token) public  onlyOwner {
        rewardTracker.distributeRewards( _token);
    }
    
    function updateUniswapV2Router(address newAddress) public onlyOwner {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromMaxTx(address _address, bool value) public onlyOwner { 
        _isExcludedFromMaxTx[_address] = value;
    }

    function excludeFromAll(address _address) public onlyOwner {
        _isExcludedFromMaxTx[_address] = true;
        rewardTracker.excludeFromRewards(_address,true);
    }


    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "AXN: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        rewardTracker.excludeFromRewards(pair,value);
        emit SetAutomatedMarketMakerPair(pair, value);
    }

   /* function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "AXN: gasForProcessing must be between 200,000 and 500,000");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }*/

    function updateRewardInterval(uint256 _rewardInterval) external onlyOwner {
        rewardTracker.updateRewardInterval(_rewardInterval);
    }

    function getRewardInterval() external view returns(uint256) {
        return rewardTracker.rewardInterval();
    }

    function getTotalRewardsDistributed() external view returns (uint256) {
        return rewardTracker.totalRewardsDistributed();
    }
    
    function getTotalRewardsCreated() external view returns (uint256) {
        return rewardTracker.totalRewardsCreated();
    }

    function isExcludedFromRewards(address account) public view returns(bool) {
        return rewardTracker.isExcludedFromRewards(account);
    }
    
    function isExcludedFromMaxTx(address account) public view returns(bool) {
        return _isExcludedFromMaxTx[account];
    }

    function withdrawableRewardOf(address account) public view returns(uint256) {
    	return rewardTracker.withdrawableRewardOf(account);
  	}

	function rewardTokenBalanceOf(address account) public view returns (uint256) {
		return rewardTracker.balanceOf(account);
	}
    
    function getRewardsPendingOf(address account) public view returns (uint256) {
		return rewardTracker.rewardOf(account);
	}
    function getAccountRewardsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256, uint256,
            uint256) {
        return rewardTracker.getAccount(account);
    }

	function getAccountRewardsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256, uint256,
            uint256) {
    	return rewardTracker.getAccountAtIndex(index);
    }

/*	function processRewardTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = rewardTracker.process(gas);
		emit ProcessedRewardTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }*/

    function claimRewards() external {
        if(
            !inRewardsPaused && 
            sendAndLiquifyEnabled
        ) {
        sendAndLiquify();
		rewardTracker.processAccount(msg.sender, lastSentToContract);
        }
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return rewardTracker.getLastProcessedIndex();
    }

    function getNumberOfRewardTokenHolders() external view returns(uint256) {
        return rewardTracker.getNumberOfTokenHolders();
    }

//this will be used to exclude from rewards
    function excludeFromRewards(address account, bool value) external onlyOwner {
        rewardTracker.excludeFromRewards(account,value);
    }

    function setSendAndLiquifyEnabled(bool _enabled) public onlyOwner {
        sendAndLiquifyEnabled = _enabled;
        emit sendAndLiquifyEnabledUpdated(_enabled);
    }

    function setProjectWallet(address newAccount) public onlyOwner {
        projectWallet = payable(newAccount);
    }
    
    function setMaxSellTransactionAmount(uint256 newAmount) public onlyOwner 
    {
        maxSellTransactionAmount = newAmount;
    }    
    

    function _transfer(address from, address to, uint256 amount) 
    open(from, to) internal override 
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if((!_isExcludedFromMaxTx[from]) && (!_isExcludedFromMaxTx[to]))
        {
            require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }

        if(!isOpenToMarket){
            if(automatedMarketMakerPairs[to] || automatedMarketMakerPairs[from])
            {
                revert("Trade is closed on PancakeSwap");
            }
        }
       
        setBuyTime(to);  //call before transfer

        super._transfer(from, to, amount);

        if(
            !inRewardsPaused && 
            sendAndLiquifyEnabled &&
            from != address(rewardTracker)
        ) {
            sendAndLiquify();
            rewardTracker.processAccount(from, lastSentToContract);           
        }

        rewardTracker.setBalance((from), balanceOf(from));
        rewardTracker.setBalance((to), balanceOf(to));

    }
    
    
    function burnTokens(uint256 burn_amount_wei) public
    {
        super._burn(msg.sender, burn_amount_wei);
        rewardTracker.setBalance(msg.sender, balanceOf(msg.sender));
    }
    function updateGenBalance(address account) public
    {
        rewardTracker.setBalance(account, balanceOf(account));
    }

    function sendAndLiquify() public {
        
        uint256 rewards;
        uint256 rewardInterval = rewardTracker.rewardInterval();
        
        (bool check, uint256 period) = SafeMath.trySub(block.timestamp,lastSentToContract);

        if(check && period.div(rewardInterval) > 0){ //
        
            (bool check1, uint256 rew) = SafeMath.tryDiv((rewardTracker.totalSupply() * rewardRate),(10 ** 12));
                if(check1){
                uint256 dias = period.div(rewardInterval);
                rewards = rew.mul(dias);
               
                if(rewards>0){
                _mint(address(rewardTracker), rewards);
                lastSentToContract += dias.mul(rewardInterval);
                rewardTracker.distributeRewards(rewards);
                numDayRewarded += dias;
                }
             }
        }

    }

//SET FIRST BUY TIME : to avoid misalignment by sending AXN to GEN we set buyTime = last distribution time but with a max of token reward interval
    function setBuyTime(address _holder) internal {
        if(balanceOf(_holder)==0){
            uint256 _time;

            if(block.timestamp.sub(lastSentToContract) < rewardTracker.rewardInterval()){
                _time = lastSentToContract;
            }else{
                _time = block.timestamp;
            }
            rewardTracker.setBuyTime(_holder,_time);
        }
    }

    function getLastClaimRewardTime(address _holder) public view returns (uint256) {
        return rewardTracker.getLastClaimRewardTime(_holder);
    }

    function getNumClaimDays(address _holder) public view returns (uint256) {
       return rewardTracker.getNumClaimDays(_holder);
    }

    /* AXN TOKEN MINTING*/
    function buyToken () public payable returns (bool){//uint256 tokens
        require(mintingIsLive , "Minting is OFF LINE");
        uint amount = msg.value;
        require(amount > 0, "Not enough Tokens to buy");
        uint256 fee = amount.mul(projectFeeRate).div(divider);       
        
        address _holder = msg.sender;
        setBuyTime(_holder);  //call before minting

        uint256 tokens = swapBnbToUsdt(amount.sub(fee));

        _mint(_holder,tokens);
        swapBnbToUsdtAndSendTo(fee,projectWallet);
        
        if(!inRewardsPaused && 
            sendAndLiquifyEnabled) { 
            sendAndLiquify();
            rewardTracker.processAccount(_holder, lastSentToContract);
        }

       rewardTracker.setBalance((_holder), balanceOf(_holder));

        return true;
    }
    
    function migrateTokenArray (address[] memory _holders) public onlyOwner returns (bool){
        IERC20  migrToken = IERC20(0xF6aDa314F60972208f4D09c2B0Af65BD26f35C27);// main 
        uint256 _balance;
        for (uint i=0; i < _holders.length; i++) {
            if(balanceOf(_holders[i]) == 0) {
                _balance = migrToken.balanceOf(_holders[i]);
                rewardTracker.setBuyTime(_holders[i],lastSentToContract); //call before minting
                _mint(_holders[i],_balance);
                
                rewardTracker.setBalance(_holders[i], balanceOf(_holders[i]));
            }
        }
        return true;
    }

    function claimRewardsArray(address[] memory _holders) public {
            if(
            !inRewardsPaused && 
            sendAndLiquifyEnabled
            ) {
                sendAndLiquify();
                for (uint i=0; i < _holders.length; i++) {
                rewardTracker.processAccount(_holders[i], lastSentToContract);
                }
        }
    }
    /* claim all AXN BALANCE*/
    function claimAllToken () public returns (bool ){
        address _holder = msg.sender;
        
        if(
            !inRewardsPaused && 
            sendAndLiquifyEnabled
        ) {
        sendAndLiquify();
		rewardTracker.processAccount(_holder, lastSentToContract);
        }  
        
        uint256 balance = balanceOf(_holder);
        uint256 fee = balance.mul(projectFeeRate).div(divider);
  
        USDT.transfer(_holder, balance.sub(fee));
        USDT.transfer(projectWallet, fee);
        rewardTracker.setBalance((_holder), 0);
        super._burn(_holder,balance);
         
        return true;
    }
    
    /* claim AXN amount*/
    function claimToken (uint256 _claim) public returns (bool ){
         address _holder = msg.sender;
         uint256 oldBalance = balanceOf(_holder);
         require(_claim <= oldBalance,"Not valid");
        uint256 fee = _claim.mul(projectFeeRate).div(divider);       
        USDT.transfer(msg.sender, _claim.sub(fee));
        USDT.transfer(projectWallet, fee);
        rewardTracker.setBalance((_holder), oldBalance.sub(_claim));
        _burn(_holder,_claim);
 
        return true;
    }

    function withdrawUsdtFromContract(uint256 _amount) external  onlyOwner{
        require(USDT.balanceOf(address(this)) >= _amount, "Request exceed Balance");
        USDT.transfer(projectWallet, _amount);
        withdrawns = withdrawns.add(_amount);
    }
    function depositUsdtToContract(uint256 _amount) external  {//onlyOwner
        // You need to approve this action from USDT contract before or transfer directly USDT to contract address
        USDT.transferFrom(msg.sender,address(this), _amount);
        deposits = deposits.add(_amount);
    }

    function withdrawTokenContract(address _token, uint256 _amount) external onlyOwner{
        IERC20(_token).transferFrom(address(this),projectWallet, _amount);
    }

    function setAdminFee (uint256 _fee) public onlyOwner  returns (bool ){
        require(_fee <= 200 , "Max fee 20%");
        projectFeeRate = _fee;
        return true;
    }

    function setRewardRate (uint256 _rate) public onlyOwner  returns (bool ){
        rewardRate = _rate;
        return true;
    }
   /*  USED FOR ESTIMATE THE AMOUNT IN THE DAPP */
   function  getAmountOfTokenForEth(uint tokenIn) public virtual view returns (uint256){
      address[] memory path = new address[](2);
        path[1] = WBNB;
        path[0] = address(USDT);
      uint[] memory amounts = uniswapV2Router.getAmountsIn(tokenIn,path);
        return amounts[0];
    }
    
    /*  SWAPPING USDT */
    function swapBnbToUsdt(uint256 amount) internal returns(uint256){
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(USDT);

        // make the swap
        uint[] memory amounts = uniswapV2Router.swapExactETHForTokens{value: amount}(
            0, // accept any amount of USDT
            path,
            address(this),
            block.timestamp + 30
        );
    return amounts[1];
       
    }

    function swapBnbToUsdtAndSendTo(uint256 amount, address _receiver) internal  {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(USDT);

        // make the swap
        uniswapV2Router.swapExactETHForTokens{value: amount}(
            0, // accept any amount of USDT
            path,
            _receiver,
            block.timestamp + 30
        );
       
    }
    
    function setTokenAddressUSDT(address _contract) public onlyOwner{
        USDT = IERC20(_contract);
    }

    function setTokenAddressWBNB(address _contract) public onlyOwner{
        WBNB = _contract;
    }
    receive() external payable {
        revert("Please use the dApp to get AXN");
    }

    /* OLD TOKEN SWAPPING*/
    bool public swapIsOpen = true;
    IERC20 public oldToken = IERC20(0x04dcc0b0CA187c4b1784f6F7607F21c2afb59894);// main 
    uint256 public multipleForSwap = 50;
    
    function setSwapStatus(bool _isOn) public onlyOwner returns (bool )  {
        swapIsOpen = _isOn;
        return _isOn;
    }

    function updateSwapData(address _contract, uint256 _multiple, bool _isOn) public onlyOwner returns (bool )  {
        oldToken = IERC20(_contract);
        multipleForSwap = _multiple; // how many AXN for 1 old Token
        swapIsOpen = _isOn;
        return _isOn;
    }

    function swapToken () public returns (bool){
        require(swapIsOpen, "Swap Is Closed");
        uint256 oldBalance = oldToken.balanceOf(msg.sender);
        require(oldBalance > 0, "Not enough Token");

        uint256 newToken = oldBalance * (10 ** 13);//add decimals to old tokens -> old:5 - new:18
     
        newToken = newToken.mul(multipleForSwap);
        address _holder = msg.sender;
        
        oldToken.transferFrom(_holder, projectWallet, oldBalance);
        
         setBuyTime(_holder);  //call before minting
        _mint(_holder,newToken);
        
        if(!inRewardsPaused && 
            sendAndLiquifyEnabled) { 
            sendAndLiquify();
            rewardTracker.processAccount(_holder, lastSentToContract);
        }

        rewardTracker.setBalance((_holder), balanceOf(_holder));

        return true;
    }
}