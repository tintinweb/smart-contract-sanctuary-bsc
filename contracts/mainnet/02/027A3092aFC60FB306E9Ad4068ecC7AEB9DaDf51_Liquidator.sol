/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// File: contracts/annex/ABep20.sol


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface ABep20 {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, address collateral) external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function balanceOfUnderlying(address account) external returns (uint);
}

interface ABep20Storage {
    function underlying() external view returns (address);
}

// File: contracts/annex/ABnb.sol


pragma solidity 0.6.12;

interface ABnb {
    function mint() external payable;
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow() external payable;
    function repayBorrowBehalf(address borrower) external payable;
    function liquidateBorrow(address borrower, address aTokenCollateral) external payable;
    function balanceOfUnderlying(address account) external returns (uint);
}

// File: contracts/annex/Comptroller.sol


pragma solidity 0.6.12;

interface Comptroller {
    function enterMarkets(address[] calldata aTokens) external returns (uint[] memory);
    function exitMarket(address aToken) external returns (uint);
    function getAssetsIn(address account) external view returns (address[] memory);
    function markets(address aTokenAddress) external view returns (bool, uint);
    function getAccountLiquidity(address account) external view returns (uint, uint, uint);
    function closeFactorMantissa() external view returns (uint);
    function liquidationIncentiveMantissa() external view returns (uint);

    function oracle() external view returns (address);
}

// File: contracts/annex/PriceOracle.sol


pragma solidity 0.6.12;
// For PriceOracle postPrices()


interface PriceOracle {
    function getUnderlyingPrice(address aToken) external view returns (uint);
    function postPrices(bytes[] calldata messages, bytes[] calldata signatures, string[] calldata symbols) external;
}

// File: contracts/IERC20.sol



pragma solidity ^0.6.0;

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

// File: contracts/SafeMath.sol



pragma solidity ^0.6.0;

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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/Address.sol



pragma solidity ^0.6.2;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
}

// File: contracts/SafeERC20.sol



pragma solidity ^0.6.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
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
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/pancake/IPancakePair.sol


pragma solidity 0.6.12;

interface IPancakePair {
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

// File: contracts/pancake/PancakeLibrary.sol


pragma solidity 0.6.12;

// Import the ERC20 interface and and SafeMath library



library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getReservesWithPair(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB, address pair) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pair = pairFor(factory, tokenA, tokenB);

        // check that pair exists
        uint32 size;
        assembly {
            size := extcodesize(pair)
        }
        if (size == 0) return (0, 0, pair);

        (uint reserve0, uint reserve1,) = IPancakePair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// File: contracts/pancake/IPancakeFactory.sol


pragma solidity 0.6.12;

interface IPancakeFactory {
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

// File: contracts/pancake/IPancakeRouter.sol


pragma solidity 0.6.12;

interface IPancakeRouter {
    function factory() external pure returns (address);
    function WBNB() external pure returns (address);

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
    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityBNB(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);
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
    function removeLiquidityBNBWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountBNB);
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
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactBNB(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapBNBForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountBNB);
    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountBNB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: contracts/pancake/IPancakeCallee.sol


pragma solidity 0.6.12;

interface IPancakeCallee {
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

// File: contracts/pancake/IWBNB.sol


pragma solidity 0.6.12;

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
    function withdraw(uint) external;
}

// File: contracts/LiquidatorBSC.sol


pragma solidity 0.6.12;
// For PriceOracle postPrices()


// Import Annex components




// Import Pancake components






contract Liquidator is IPancakeCallee {
    struct RecipientChange {
        address payable recipient;
        uint waitingPeriodEnd;
        bool pending;
    }

    using SafeERC20 for IERC20;

    address constant private BNB = address(0);
    address constant private ABNB = 0xC5a83aD9f3586e143D2C718E8999206887eF9dDc;
    address constant private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant private ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant private FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    uint constant private RECIP_CHANGE_WAIT_PERIOD = 24 hours;
    // Coefficient = (1 - 1/sqrt(1.02)) for 2% slippage. Multiply by 100000 to get integer
    uint constant private SLIPPAGE_THRESHOLD_FACT = 985;

    address payable private recipient;
    RecipientChange public recipientChange;

    Comptroller public comptroller;
    PriceOracle public priceOracle;

    uint private closeFact;
    uint private liqIncent;

    event RevenueWithdrawn(
        address recipient,
        address token,
        uint amount
    );
    event RecipientChanged(
        address recipient
    );

    modifier onlyRecipient() {
        require(
            msg.sender == recipient,
            "Unauthorized"
        );
        _;
    }

    constructor() public {
        recipient = msg.sender;

        comptroller = Comptroller(0xb13026Db8aAfA2fd6d23355533dcCccbD4442f4c);
        priceOracle = PriceOracle(comptroller.oracle());
        closeFact = comptroller.closeFactorMantissa();
        liqIncent = comptroller.liquidationIncentiveMantissa();
        
    }

    receive() external payable {}

    function kill() external onlyRecipient {
        // Delete the contract and send any available Avax to recipient
        selfdestruct(recipient);
    }

    function initiateRecipientChange(address payable _recipient) external onlyRecipient returns (address) {
        recipientChange = RecipientChange(_recipient, now + RECIP_CHANGE_WAIT_PERIOD, true);
        return recipientChange.recipient;
    }

    function confirmRecipientChange() external onlyRecipient {
        require(recipientChange.pending, "Initiate change first");
        require(now > recipientChange.waitingPeriodEnd, "Wait longer");
        
        recipient = recipientChange.recipient;
        emit RecipientChanged(recipient);

        // Clear the recipientChange struct. Equivalent to re-declaring it without initialization
        delete recipientChange;
    }

    function setComptroller(address _comptrollerAddress) external onlyRecipient {
        comptroller = Comptroller(_comptrollerAddress);
        priceOracle = PriceOracle(comptroller.oracle());
        closeFact = comptroller.closeFactorMantissa();
        liqIncent = comptroller.liquidationIncentiveMantissa();
    }

    function liquidateSNWithPrice(
        bytes[] calldata _messages,
        bytes[] calldata _signatures,
        string[] calldata _symbols,
        address[] calldata _borrowers,
        address[] calldata _aTokens
    ) external {
        priceOracle.postPrices(_messages, _signatures, _symbols);
        liquidateSN(_borrowers, _aTokens);
    }

    function liquidateSN(address[] calldata _borrowers, address[] calldata _aTokens) public {
        uint i;

        for (i = 0; i < _borrowers.length; i++) {
            liquidateS(_borrowers[i], _aTokens[i * 2], _aTokens[i * 2 + 1]);
        }
    }

    function liquidateSWithPrice(
        bytes[] calldata _messages,
        bytes[] calldata _signatures,
        string[] calldata _symbols,
        address _borrower,
        address _repayAToken,
        address _seizeAToken
    ) external {
        priceOracle.postPrices(_messages, _signatures, _symbols);
        liquidateS(_borrower, _repayAToken, _seizeAToken);
    }

    /**
     * Liquidate a Annex user with a flash swap, auto-computing liquidation amount
     *
     * @param _borrower (address): the Annex user to liquidate
     * @param _repayAToken (address): a AToken for which the user is in debt
     * @param _seizeAToken (address): a AToken for which the user has a supply balance
     */
    function liquidateS(address _borrower, address _repayAToken, address _seizeAToken) public {
        ( , uint liquidity, ) = comptroller.getAccountLiquidity(_borrower);
        if (liquidity != 0) return;
        // uint(10**18) adjustments ensure that all place values are dedicated
        // to repay and seize precision rather than unnecessary closeFact and liqIncent decimals
        uint repayMax = ABep20(_repayAToken).borrowBalanceCurrent(_borrower) * closeFact / uint(10**18);
        uint seizeMax = ABep20(_seizeAToken).balanceOfUnderlying(_borrower) * uint(10**18) / liqIncent;

        uint uPriceRepay = priceOracle.getUnderlyingPrice(_repayAToken);
        // Gas savings -- instead of making new vars `repayMax_Avax` and `seizeMax_Avax` just reassign
        repayMax *= uPriceRepay;
        seizeMax *= priceOracle.getUnderlyingPrice(_seizeAToken);

        // Gas savings -- instead of creating new var `repay_Avax = repayMax < seizeMax ? ...` and then
        // converting to underlying units by dividing by uPriceRepay, we can do it all in one step
        liquidate(_borrower, _repayAToken, _seizeAToken, ((repayMax < seizeMax) ? repayMax : seizeMax) / uPriceRepay);
    }

    /**
     * Liquidate a Annex user with a flash swap
     *
     * @param _borrower (address): the Annex user to liquidate
     * @param _repayAToken (address): a AToken for which the user is in debt
     * @param _seizeAToken (address): a AToken for which the user has a supply balance
     * @param _amount (uint): the amount (specified in units of _repayAToken.underlying) to flash loan and pay off
     */
    function liquidate(address _borrower, address _repayAToken, address _seizeAToken, uint _amount) public {
        address pair;
        address r;

        if (_repayAToken == _seizeAToken || _seizeAToken == ABNB) {
            r = ABep20Storage(_repayAToken).underlying();
            pair = PancakeLibrary.pairFor(FACTORY, r, WBNB);
        }
        else if (_repayAToken == ABNB) {
            r = WBNB;
            pair = PancakeLibrary.pairFor(FACTORY, WBNB, ABep20Storage(_seizeAToken).underlying());
        }
        else {
            r = ABep20Storage(_repayAToken).underlying();
            uint maxBorrow;
            (maxBorrow, , pair) = PancakeLibrary.getReservesWithPair(FACTORY, r, ABep20Storage(_seizeAToken).underlying());

            if (_amount * 100000 > maxBorrow * SLIPPAGE_THRESHOLD_FACT) pair = IPancakeFactory(FACTORY).getPair(r, WBNB);
        }

        // Initiate flash swap
        bytes memory data = abi.encode(_borrower, _repayAToken, _seizeAToken);
        uint amount0 = IPancakePair(pair).token0() == r ? _amount : 0;
        uint amount1 = IPancakePair(pair).token1() == r ? _amount : 0;

        IPancakePair(pair).swap(amount0, amount1, address(this), data);
    }

    /**
     * The function that gets called in the middle of a flash swap
     *
     * @param sender (address): the caller of `swap()`
     * @param amount0 (uint): the amount of token0 being borrowed
     * @param amount1 (uint): the amount of token1 being borrowed
     * @param data (bytes): data passed through from the caller
     */
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) override external {
        // Unpack parameters sent from the `liquidate` function
        // NOTE: these are being passed in from some other contract, and cannot necessarily be trusted
        (address borrower, address repayAToken, address seizeAToken) = abi.decode(data, (address, address, address));

        address token0 = IPancakePair(msg.sender).token0();
        address token1 = IPancakePair(msg.sender).token1();
        require(msg.sender == IPancakeFactory(FACTORY).getPair(token0, token1));

        if (repayAToken == seizeAToken) {
            uint amount = amount0 != 0 ? amount0 : amount1;
            address estuary = amount0 != 0 ? token0 : token1;

            // Perform the liquidation
            IERC20(estuary).safeApprove(repayAToken, amount);
            ABep20(repayAToken).liquidateBorrow(borrower, amount, seizeAToken);

            // Redeem aTokens for underlying ERC20
            ABep20(seizeAToken).redeem(IERC20(seizeAToken).balanceOf(address(this)));

            // Compute debt and pay back pair
            IERC20(estuary).transfer(msg.sender, (amount * 1000 / 997) + 1);
            return;
        }

        if (repayAToken == ABNB) {
            uint amount = amount0 != 0 ? amount0 : amount1;
            address estuary = amount0 != 0 ? token1 : token0;

            // Convert WBNB to BNB
            IWBNB(WBNB).withdraw(amount);

            // Perform the liquidation
            ABnb(repayAToken).liquidateBorrow{value: amount}(borrower, seizeAToken);

            // Redeem aTokens for underlying ERC20
            ABep20(seizeAToken).redeem(IERC20(seizeAToken).balanceOf(address(this)));

            // Compute debt and pay back pair
            (uint reserveOut, uint reserveIn) = PancakeLibrary.getReserves(FACTORY, WBNB, estuary);
            IERC20(estuary).transfer(msg.sender, PancakeLibrary.getAmountIn(amount, reserveIn, reserveOut));
            return;
        }

        if (seizeAToken == ABNB) {
            uint amount = amount0 != 0 ? amount0 : amount1;
            address source = amount0 != 0 ? token0 : token1;

            // Perform the liquidation
            IERC20(source).safeApprove(repayAToken, amount);
            ABep20(repayAToken).liquidateBorrow(borrower, amount, seizeAToken);

            // Redeem aTokens for underlying ERC20 or BNB
            ABep20(seizeAToken).redeem(IERC20(seizeAToken).balanceOf(address(this)));

            // Convert BNB to WBNB
            IWBNB(WBNB).deposit{value: address(this).balance}();

            // Compute debt and pay back pair
            (uint reserveOut, uint reserveIn) = PancakeLibrary.getReserves(FACTORY, source, WBNB);
            IERC20(WBNB).transfer(msg.sender, PancakeLibrary.getAmountIn(amount, reserveIn, reserveOut));
            return;
        }

        uint amount;
        address source;
        address estuary;
        if (amount0 != 0) {
            amount = amount0;
            source = token0;
            estuary = token1;
        } else {
            amount = amount1;
            source = token1;
            estuary = token0;
        }

        // Perform the liquidation
        IERC20(source).safeApprove(repayAToken, amount);
        ABep20(repayAToken).liquidateBorrow(borrower, amount, seizeAToken);

        // Redeem aTokens for underlying ERC20 or BNB
        uint seized_uUnits = ABep20(seizeAToken).balanceOfUnderlying(address(this));
        ABep20(seizeAToken).redeem(IERC20(seizeAToken).balanceOf(address(this)));
        address seizeUToken = ABep20Storage(seizeAToken).underlying();

        // Compute debt
        (uint reserveOut, uint reserveIn) = PancakeLibrary.getReserves(FACTORY, source, estuary);
        uint debt = PancakeLibrary.getAmountIn(amount, reserveIn, reserveOut);

        if (seizeUToken == estuary) {
            // Pay back pair
            IERC20(estuary).transfer(msg.sender, debt);
            return;
        }

        IERC20(seizeUToken).safeApprove(ROUTER, seized_uUnits);

        // Define swapping path
        address[] memory path = new address[](2);
        path[0] = seizeUToken;
        path[1] = estuary;

        uint256 minReceiveDebt = debt * 95 / 100;
        //                                                  sent, min desired, ,   path, recipient,     deadline
        IPancakeRouter(ROUTER).swapExactTokensForTokens(seized_uUnits, minReceiveDebt, path, address(this), now + 1 minutes);

        IERC20(seizeUToken).safeApprove(ROUTER, 0);

        // Pay back pair
        IERC20(estuary).transfer(msg.sender, debt);
    }

    function withdraw(address _assetAddress) external {
        uint assetBalance;
        if (_assetAddress == BNB) {
            address self = address(this); // workaround for a possible solidity bug
            assetBalance = self.balance;
            recipient.transfer(assetBalance);
        } else {
            assetBalance = IERC20(_assetAddress).balanceOf(address(this));
            IERC20(_assetAddress).safeTransfer(recipient, assetBalance);
        }
    }
}