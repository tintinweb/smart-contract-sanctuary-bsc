/**
 *Submitted for verification at BscScan.com on 2022-07-24
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
    address public marketAddress;
    address payable public bnbReceive;
    address public jiAddress;
    address public topAddress;
    address public nftContract;
    address public _swapV2Pair; 
    address public _swapV2Router; 
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public uniswapV2Pair;
    address private usdt;
    bool canReg = true;
    uint baseAirNum = 500 ether;
     uint lpSafeNum = 5000;

    struct user{
        address userid;
        address pid;
        uint256 layerAll;
        uint256 zhiLp;
        uint256 lpall;
        uint256 lockNum;
        uint256 unLockNum;
        uint256 lastTime;
        uint256 rank;
        bool isMore50;
        bool isPro;
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

    
    struct lpBonus{
        uint canColNum;
        uint totalNum;
    }
    
    struct nodeBonus{
        uint canColNum;
        uint totalNum;
    }
    
    struct partnerBonus{
        uint canColNum;
        uint totalNum;
    }

    
    
    mapping (address => address[]) public children;
    mapping (address => user) public userInfo;
    mapping (address => address[]) public userPath;
    mapping (address => uint256) public userPledge;
    mapping (address => uint256) public userPledgeCount;
    pledgeRecord[] public pledgeRecords;
    
    mapping (address => uint256) public nodeShiNum;
    mapping (address => lpBonus) public lpBonuses;
    mapping (address => nodeBonus) public nodeBonuses;
    mapping (address => partnerBonus) public partnerBonuses;
    mapping (address => uint) public colDayBonus;
    
    address[] public partners;
    address[] public nodes;
    uint256[] private step;
    
    
    uint256 public allUser;
    address[] public allLpUsers;
    uint private unlocked = 1;
    uint pastTime = 24*60*60;
   

    constructor(
        
       address rankContract,
       address _marketAddress,
       address _jiAddress,
       address _bnbReceive
    ) ERC20("FIRE", "FIRE") {
        _mint(msg.sender, 50000000 * 1 ether );
        
 
       
        topAddress =msg.sender;
        marketAddress=_marketAddress;
        jiAddress=_jiAddress;
        bnbReceive= payable(_bnbReceive);
        iRank = IRank(rankContract);
        step = [300,200,100,100,100,100,200,200,300,300];
        usdt= 0x55d398326f99059fF775485246999027B3197955; //BSC56
        _swapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //bsc56
         uniswapV2Router = IUniswapV2Router02(_swapV2Router);
         _swapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
             usdt,
             address(this)
             
         );

        uniswapV2Pair=IUniswapV2Pair(_swapV2Pair);
        

    }


  
    event log(address indexed userid,uint lastTime,uint classes, uint num);

    event drawlog(address indexed userid,uint lastTime, uint classes,uint num);


    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function colLpBonus() public {
            require(lpBonuses[msg.sender].canColNum>0 && balanceOf(address(this))>=lpBonuses[msg.sender].canColNum);
            super._transfer(address(this),msg.sender,lpBonuses[msg.sender].canColNum);
            emit drawlog(msg.sender,getTime(),0,lpBonuses[msg.sender].canColNum);
            lpBonuses[msg.sender].canColNum=0;
            
    }
     
    function colNodeBonus() public {
            require(nodeBonuses[msg.sender].canColNum>0 && balanceOf(address(this))>=nodeBonuses[msg.sender].canColNum);
            super._transfer(address(this),msg.sender,nodeBonuses[msg.sender].canColNum);
            emit drawlog(msg.sender,getTime(),1,nodeBonuses[msg.sender].canColNum);
            nodeBonuses[msg.sender].canColNum=0;
    }

    
    function colPartnerBonus() public {
            require(partnerBonuses[msg.sender].canColNum>0 && balanceOf(address(this))>=partnerBonuses[msg.sender].canColNum);
            super._transfer(address(this),msg.sender,partnerBonuses[msg.sender].canColNum);
            emit drawlog(msg.sender,getTime(),2,partnerBonuses[msg.sender].canColNum);
            partnerBonuses[msg.sender].canColNum=0;
    }

   
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

    
    function getColDayBonus(address _address) public view returns(uint){
        uint _bonus=getDayBonus(_address).sub(colDayBonus[_address]);
            if(_bonus<=0){
                return 0;
            }else{
                
                return getLimit(_address,_bonus);
            }
            
    }

    
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
                    if(getTime().sub(pledgeRecords[i].lastTime).div(pastTime)<=0){
                        break;
                    }else{
                        bonus+=pledgeRecords[i].usdt.mul(40).mul((getTime().sub(pledgeRecords[i].lastTime)).div(pastTime)).div(1000);
                    }
                    
                }
            }
        }
        
        if(getTime().sub(firstDay).div(pastTime)>0){
            if(bonus > getTime().sub(firstDay).div(pastTime).mul(5 ether)){
                bonus = getTime().sub(firstDay).div(pastTime).mul(5 ether);
            }
            
        }

       if(u2token(bonus)>userInfo[_address].lockNum){
           return userInfo[_address].lockNum;
       }else{
           return u2token(bonus);
       }
        

    }

    function u2token(uint _u) public view returns(uint){
        uint _token;
        uint _usdt;
        
        (_token,_usdt,) = uniswapV2Pair.getReserves();
        if(_token==0 || _usdt==0){
            return 0;
        }else{
            if(uniswapV2Pair.token1()==usdt){
                return _u.mul(_token).div(_usdt);
            }else{
                return _u.mul(_usdt).div(_token);
            }

        }
        
    }

    function setNft(address _nft) public onlyOwner{
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
        if( (userInfo[_address].unLockNum + colDayBonus[_address]) >= userInfo[_address].lockNum){
            return 0;
        }else{
            uint left = userInfo[_address].lockNum.sub(userInfo[_address].unLockNum).sub(colDayBonus[_address]);
            if(left>=_num){
                return _num;
            }else{
                return _num.sub(left);
            }
        }
    }

    

    
    function register(address pid) public payable{
        require(canReg==true);
        if(pid==topAddress){
            require(iRank.getAddressRank(pid)==3);
        }
        
         require(msg.value>=0.031 ether,"1001");
         require(msg.sender!=topAddress,"1002");
         require(pid != msg.sender,"1003");
        require( userInfo[msg.sender].userid == address(0),"1004");
        require( !isContract(msg.sender),"1005");
        if(pid!=topAddress){
            require(userInfo[pid].userid != address(0));
            
            userPath[msg.sender]=userPath[pid];
            userPath[msg.sender].push(pid);
            children[pid].push(msg.sender);
        }else{
            userPath[msg.sender].push(topAddress);
        }
        allUser=allUser.add(1);
        
        bnbReceive.transfer(msg.value);
        
        uint256 _num ;
        uint256 _getRank;
        _getRank=iRank.getAddressRank(msg.sender);
        if(_getRank==0){
            _num=baseAirNum;
        }else if(_getRank==1){
            _num=0;
        }else if(_getRank==2){
            _num=6000 ether;
        }else if(_getRank==3){
            _num=10000 ether;
        }
        bool _isPro= false;
        if(_getRank==2 || _getRank==3){
            _isPro=true;
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
            false,
            _isPro
            );
    
        
        if(iRank.getAddressRank(msg.sender)==3){
            partners.push(msg.sender);
        }else if(iRank.getAddressRank(msg.sender)==2){
            nodes.push(msg.sender);
        }
        
        
        if(pid!=topAddress){
            
            uint pAddNum=getLimit(pid,1 ether);
            if(pAddNum>0){
                lpBonuses[pid].canColNum+=pAddNum;
                lpBonuses[pid].totalNum+=pAddNum;
                userInfo[pid].unLockNum+=pAddNum;
                emit log(pid,getTime(),0,1 ether);
            }
            
            
           
            for(uint i ; i<userPath[msg.sender].length;i++){
                if(i==50){
                    break;
                }
                if(userPath[msg.sender][i]!=topAddress){
                    userInfo[userPath[msg.sender][i]].layerAll+=1;
                    if(userInfo[userPath[msg.sender][i]].layerAll>=100 && userInfo[userPath[msg.sender][i]].rank==0 ){
                        userInfo[userPath[msg.sender][i]].rank=1;
                    }
                }
            }
        }
    }

    
    function getRealUsdt(address _address) public view returns (uint){
        uint _res =0;
        for(uint i ; i<pledgeRecords.length ;i++){
            if(pledgeRecords[i].userid==_address && pledgeRecords[i].state==0){
                _res+=pledgeRecords[i].usdt;
            }
        }
        return _res;
    }

    
    function getRealToken(address _address) public view returns (uint){
        uint _res =0;
        for(uint i ; i<pledgeRecords.length ;i++){
            if(pledgeRecords[i].userid==_address && pledgeRecords[i].state==0){
                _res+=pledgeRecords[i].token;
            }
        }
        return _res;
    }

   
    function pledge(uint256 num) public {
        require(userInfo[msg.sender].userid!=address(0));
        IERC20(_swapV2Pair).transferFrom(msg.sender,address(this),num);
        
        if(getRealUsdt(msg.sender)==0){
            bool hasAllLp = false;
            for(uint i ; i<allLpUsers.length;i++){
                if(allLpUsers[i]==msg.sender){
                    hasAllLp=true;
                    break;
                }
                        
            }
            if(hasAllLp==false){
                allLpUsers.push(msg.sender);
            }
                
        }
        userPledge[msg.sender]=userPledge[msg.sender].add(num);
        pledgeRecords.push(pledgeRecord(userPledgeCount[msg.sender],num,_getLp2u(num),_getLp2Token(num),block.timestamp,0,msg.sender));
        userPledgeCount[msg.sender]+=1;
        
        
     
        uint _addNum;
        if(userInfo[msg.sender].rank==2 && _getRandReal(msg.sender,2) && nodeShiNum[msg.sender]==0 && userInfo[msg.sender].isPro){
            _addNum =getLimit(msg.sender,300 ether);
            if(_addNum>0){
                nodeBonuses[msg.sender].canColNum+=_addNum;
                nodeBonuses[msg.sender].totalNum+=_addNum;
                userInfo[msg.sender].unLockNum+=_addNum;
                nodeShiNum[msg.sender]+=300 ether;
                emit log(msg.sender,getTime(),2,300 ether);
            }
        }

        if(userInfo[msg.sender].rank==3 && _getRandReal(msg.sender,3) && nodeShiNum[msg.sender]<500 ether && userInfo[msg.sender].isPro){
            _addNum =getLimit(msg.sender,500 ether);
            if(_addNum>0){
                partnerBonuses[msg.sender].canColNum+=_addNum;
                partnerBonuses[msg.sender].totalNum+=_addNum;
                userInfo[msg.sender].unLockNum+=_addNum;
                nodeShiNum[msg.sender]+=500 ether;
                emit log(msg.sender,getTime(),22,500 ether);
            }
        }
        
       
        if(getRealUsdt(msg.sender)>=49 ether){

            
            if(userInfo[msg.sender].pid!=topAddress){
                userInfo[userInfo[msg.sender].pid].zhiLp+=1;
                uint _newLevelValue;
                for(uint i ; i<userPath[msg.sender].length;i++){
                    if(userPath[msg.sender][i]!=topAddress){
                       
                        userInfo[userPath[msg.sender][i]].lpall+=1;
                       
                        _newLevelValue = _newLevel(userPath[msg.sender][i]);
                        if(_newLevelValue>userInfo[userPath[msg.sender][i]].rank){
                            userInfo[userPath[msg.sender][i]].rank=_newLevelValue;
                            if(_newLevelValue==2){
                                nodes.push(userPath[msg.sender][i]);
                            }
                            if(_newLevelValue==3){
                                partners.push(userPath[msg.sender][i]);
                            }

                        }

                        uint _addNum1;
                       
                        if(userInfo[userPath[msg.sender][i]].lpall==100 && userInfo[userPath[msg.sender][i]].rank==2 && userInfo[msg.sender].isMore50==false && userInfo[userPath[msg.sender][i]].isPro){
                            _addNum1=getLimit(userPath[msg.sender][i],200 ether);
                            if(_addNum1>0){
                                nodeBonuses[userPath[msg.sender][i]].canColNum+=_addNum1;
                                nodeBonuses[userPath[msg.sender][i]].totalNum+=_addNum1;
                                userInfo[userPath[msg.sender][i]].unLockNum+=_addNum1;
                                emit log(userPath[msg.sender][i],getTime(),8,_addNum1);
                            }
                       
                        }

                       
                        if(userInfo[userPath[msg.sender][i]].lpall==100 && userInfo[userPath[msg.sender][i]].rank==3 && userInfo[msg.sender].isMore50==false && userInfo[userPath[msg.sender][i]].isPro){
                            _addNum1 = getLimit(userPath[msg.sender][i],300 ether);
                            if(_addNum1>0){
                                partnerBonuses[userPath[msg.sender][i]].canColNum+=_addNum1;
                                partnerBonuses[userPath[msg.sender][i]].totalNum+=_addNum1;
                                userInfo[userPath[msg.sender][i]].unLockNum+=_addNum1;
                                emit log(userPath[msg.sender][i],getTime(),9,_addNum1);
                            }
                        }


                      
                        if(userInfo[msg.sender].isMore50==false){
                           
                             uint _addNum2 =  getLimit(userPath[msg.sender][i],1 ether);
                                if(_addNum2>0){
                                    if(userInfo[userPath[msg.sender][i]].rank==2 ){
                                        nodeBonuses[userPath[msg.sender][i]].canColNum+=_addNum2;
                                        nodeBonuses[userPath[msg.sender][i]].totalNum+=_addNum2;
                                        userInfo[userPath[msg.sender][i]].unLockNum+=_addNum2;
                                        emit log(userPath[msg.sender][i],getTime(),1,1 ether);
                                    }

                                    if(userInfo[userPath[msg.sender][i]].rank==3){
                                        partnerBonuses[userPath[msg.sender][i]].canColNum+=_addNum2;
                                        partnerBonuses[userPath[msg.sender][i]].totalNum+=_addNum2;
                                        userInfo[userPath[msg.sender][i]].unLockNum+=_addNum2;
                                        emit log(userPath[msg.sender][i],getTime(),11,1 ether);
                                    }
                                
                                }
                             
                            
                        }
                        
                    }
                }
            }
            
            userInfo[msg.sender].isMore50=true;

        }
    }

   
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

    

    
    function unPledge() public lock{
        require(userInfo[msg.sender].userid!=address(0));
        require(userPledge[msg.sender]>0 && IERC20(_swapV2Pair).balanceOf(address(this))>=userPledge[msg.sender]);
        
        
        if(getRealUsdt(msg.sender)>49 ether){
            if(userInfo[msg.sender].pid!=topAddress){
                userInfo[userInfo[msg.sender].pid].zhiLp=userInfo[userInfo[msg.sender].pid].zhiLp.sub(1);
            }
            address pid;
            for(uint i ; i<userPath[msg.sender].length;i++){
                pid =userPath[msg.sender][i];
                if(pid!=topAddress){
                   
                    userInfo[pid].lpall=userInfo[pid].lpall.sub(1);
                    if(userInfo[pid].lpall<100 && userInfo[pid].rank==1){
                        userInfo[pid].rank=0;
                    }

                  
                        if(_newLevel(pid)<userInfo[pid].rank  && !userInfo[pid].isPro){
                            userInfo[pid].rank=_newLevel(pid);
                            if(_newLevel(pid)<3 ){
                                delPartner(pid);
                            }
                            if(_newLevel(pid)<2){
                                delPartner(pid);
                            }
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
        for(uint i ; i<allLpUsers.length;i++){
            if(allLpUsers[i]==msg.sender){
                delete allLpUsers[i];
            }
        }
        
    }

    
    function _getRandReal(address _address,uint _rank) private view returns(bool){
        if(_rank==2){
            return getRealToken(_address)>=200 ether;
        }else if(_rank==3){
            return getRealToken(_address)>=300 ether;
        }else{
            return false;
        }
    }


    
    function _getLp2u(uint _lp) private view returns(uint256){
        if(IERC20(_swapV2Pair).totalSupply() ==0 || _lp==0){
            return 0;
        }
        return  IERC20(usdt).balanceOf(_swapV2Pair).mul(_lp).div(IERC20(_swapV2Pair).totalSupply());
    }

   
    function _getLp2Token(uint _lp) private view returns(uint256){
        if(IERC20(_swapV2Pair).totalSupply() ==0 || _lp==0){
            return 0;
        }else{
            return  balanceOf(_swapV2Pair).mul(_lp).div(IERC20(_swapV2Pair).totalSupply());
        }
        
        
    }


        
  

   
    function getTime() public view returns(uint){
   
        return block.timestamp;
       
    }

   
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
        require(balanceOf(from)>=0.001 ether, "ERC20: balance less 0.001");

        if(from==_swapV2Pair ||from==_swapV2Router ){
            
            uint256 marketAmount = amount.mul(40).div(1000);
            uint256 lpAmount = amount.mul(20).div(1000);
            super._transfer(from,to,amount.sub(marketAmount).sub(lpAmount));


            
            uint edu = 0;
            uint preRank =0;
            
            if(userPath[to].length>1){
                for(uint i = userPath[to].length-1; i>0 ; i--){
                    if(userInfo[userPath[to][i]].rank>preRank){
                        
                        if(userInfo[userPath[to][i]].rank== userInfo[userInfo[userPath[to][i]].pid].rank && userInfo[userPath[to][i]].rank !=3){
                            uint toNum= amount.mul(_getJIchaRate(userPath[to][i])-edu).div(1000);
                            super._transfer(from,userPath[to][i],toNum);
                            super._transfer(from,userInfo[userPath[to][i]].pid,amount.mul(5).div(1000));
                            edu=_getJIchaRate(userPath[to][i]).add(5);
                            preRank=userInfo[userPath[to][i]].rank;
                        }else{
                            uint toNum= amount.mul(_getJIchaRate(userPath[to][i])-edu).div(1000);
                            super._transfer(from,userPath[to][i],toNum);
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
                        if(i>=lpSafeNum){
                            break;
                        }
                        if(allLpUsers[i] != address(0)){
                            super._transfer(from,allLpUsers[i],lpAmount.div(allLpUsers.length));
                        }
                        
                    }
                }
            }
            
            

        }else if(to==_swapV2Pair ||to==_swapV2Router){

           
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

    function delNode(address _address) private {
        for(uint i=0;i<nodes.length;i++){
            _address=nodes[i];
            delete nodes[i];
        }
    }

    function delPartner(address _address) private {
        for(uint i=0;i<partners.length;i++){
            _address=partners[i];
            delete partners[i];
        }

    }

    function setCanReg(bool _canReg) public onlyOwner{
        canReg = _canReg;
    }
    function setBaseAirNum(uint _baseAirNum) public onlyOwner{
        baseAirNum = _baseAirNum;
    }

    function setRank(uint _rank,address _address) public onlyOwner{
        userInfo[_address].rank = _rank;
    }

    function setLpSafeNum(uint _newLpSafeNum) public onlyOwner{
       lpSafeNum=_newLpSafeNum;
    }

    function getALLLp() public view returns(uint,uint){
        uint _sumLp;
        uint _sumUsdt;
        for(uint i=0;i<pledgeRecords.length;i++){
           if(pledgeRecords[i].state==0){
               _sumLp+=pledgeRecords[i].lp;
               _sumUsdt+=pledgeRecords[i].usdt;
           }
        }
        return(_sumLp,_sumUsdt);
    }

    // function getLpUserIndex(uint x, uint y) public view returns(address[] memory){
    //     address[] memory _arr = new address[](y-x);
    //     uint _index;
    //     for(uint i=x;i<y;i++){
    //        _arr[_index]=allLpUsers[i];
    //        _index+=1;
    //     }
    //     return _arr;
    // }

    

    

 

  




    


}