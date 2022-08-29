// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./GovernableImplementation.sol";
import "./ProxyImplementation.sol";

// Part: IRouter : Dystopia

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface IDystRouter01 {
    struct Route {
        address from;
        address to;
        bool stable;
    }

    function UNSAFE_swapExactTokensForTokens(
        uint256[] memory amounts,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory);

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
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

    function addLiquidityMATIC(
        address token,
        bool stable,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountMATICMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountMATIC,
        uint256 liquidity
    );

    function factory() external view returns (address);

    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 amount, bool stable);

    function getAmountsOut(uint256 amountIn, Route[] memory routes)
    external
    view
    returns (uint256[] memory amounts);

    function getExactAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut,
        bool stable
    ) external view returns (uint256);

    function getReserves(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (uint256 reserveA, uint256 reserveB);

    function isPair(address pair) external view returns (bool);

    function pairFor(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (address pair);

    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired
    )
    external
    view
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function quoteLiquidity(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function quoteRemoveLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity
    ) external view returns (uint256 amountA, uint256 amountB);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityMATIC(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountMATICMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountMATIC);

    function removeLiquidityMATICSupportingFeeOnTransferTokens(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountFTMMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountFTM);

    function removeLiquidityMATICWithPermit(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountMATICMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountMATIC);

    function removeLiquidityMATICWithPermitSupportingFeeOnTransferTokens(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountFTMMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountFTM);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        bool stable,
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

    function sortTokens(address tokenA, address tokenB)
    external
    pure
    returns (address token0, address token1);

    function swapExactMATICForTokens(
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactMATICForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForMATIC(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForMATICSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSimple(
        uint256 amountIn,
        uint256 amountOutMin,
        address tokenFrom,
        address tokenTo,
        bool stable,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external;

    function wmatic() external view returns (address);
}

// Part: IDystPair

interface IDystPair {
    // Structure to capture time period obervations every 30 minutes, used for local oracles
    struct Observation {
        uint256 timestamp;
        uint256 reserve0Cumulative;
        uint256 reserve1Cumulative;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function mint(address to) external returns (uint256 liquidity);

    function getReserves()
    external
    view
    returns (
        uint112 _reserve0,
        uint112 _reserve1,
        uint32 _blockTimestampLast
    );

    function getAmountOut(uint256, address) external view returns (uint256);

    function claimFees() external returns (uint256, uint256);

    function tokens() external returns (address, address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function stable() external view returns (bool);
}

// Part: IUniswapV2Router01

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

// Part: OpenZeppelin/[email protected]/IERC20

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
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// Part: OpenZeppelin/[email protected]/Address

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
    {
        return
        functionStaticCall(
            target,
            data,
            "Address: low-level static call failed"
        );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return
        functionDelegateCall(
            target,
            data,
            "Address: low-level delegate call failed"
        );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// Part: OpenZeppelin/[email protected]/SafeMath

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
    function tryAdd(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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

// Part: TransferHelper

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
    unchecked {
        uint256 oldAllowance = token.allowance(address(this), spender);
        require(
            oldAllowance >= value,
            "SafeERC20: decreased allowance below zero"
        );
        uint256 newAllowance = oldAllowance - value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// File: Context.sol

pragma solidity ^0.8.0;

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.4.0;

// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method
library Babylonian {
    // credit for this implementation goes to
    // https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol#L687
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        // this block is equivalent to r = uint256(1) << (BitMath.mostSignificantBit(x) / 2);
        // however that code costs significantly more gas
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}

// File: contracts/BIFI/zap/IUniswapV2Router02.sol

pragma solidity >=0.6.2;

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

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

interface IUserProxyInterface {
    function depositLpAndStake(address, uint256) external;

    function penLensAddress() external view returns (address);
}

interface IPenLens {
    function penPoolByDystPool(address dystPoolAddress)
    external
    view
    returns (address);
}

// File: PenroseZapper.sol

contract PenroseZapper is GovernableImplementation, ProxyImplementation {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    uint256 private constant minimumAmount = 1000;

    address private WNATIVE;
    address public penroseInterface;
    address public dystRouter;
    address public ownerAddress;
    mapping(address => mapping(address => address))
    private tokenBridgeForRouter;

    mapping(address => bool) public tokenIsAllowedMap;

    mapping(address => address) public specialTokensWithRouters;

    struct AddLiquidityArgs {
        address token0;
        address token1;
        bool stable;
        uint256 token0Amount;
        uint256 token1Amount;
        uint256 token0Min;
        uint256 token1Min;
        address recipient;
        uint256 deadline;
    }

    mapping(address => bool) public tokenBlacklistToZap;
    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Only user proxy owner is allowed");
        _;
    }

    struct OptimumStability {
        bool tokenToNative;
        bool nativeToToken0;
        bool nativeToToken1;
    }

    function initializeProxyStorage(
        address _penroseInterface,
        address _WNATIVE,
        address _dystRouter
    ) public checkProxyInitialized {
        penroseInterface = _penroseInterface;
        WNATIVE = _WNATIVE;
        dystRouter = _dystRouter;
        ownerAddress = msg.sender;
    }

    event ZapAmount(uint256 poolAmount);

    /* ========== External Functions ========== */

    receive() external payable {}

    function tokenToDystLp(
        address _from,
        uint256 amount,
        address _to,
        address routerAddr,
        address _recipient,
        OptimumStability calldata stability
    ) external {
        require(!tokenBlacklistToZap[_from], 'Trade off');
        // From an ERC20 to an LP token, through specified router, going through base asset if necessary
        IERC20(_from).safeTransferFrom(msg.sender, address(this), amount);
        uint256 poolAmount;
        // if has a special router, need to first convert it to native then zap  using native
        if (specialTokensWithRouters[_from] != address(0)) {
            // Approve this contract to be able to transact the given ERC20 token with the router
            address specialRouterAddr = specialTokensWithRouters[_from];
            _approveTokenIfNeeded(_from, specialRouterAddr);
            // first, use the special token's special router to swap to Native
            uint256 nativeAmount = _swapTokenForNative(
                _from,
                amount,
                stability.tokenToNative,
                address(this),
                specialRouterAddr
            );
            // then swap native to LP
            poolAmount = _swapNativeToLP(
                _to,
                nativeAmount,
                stability,
                _recipient,
                routerAddr
            );
        } else {
            // Otherwise, can directly use 1 router to do entire swap
            // Approve this contract to be able to transact the given ERC20 token with the router
            _approveTokenIfNeeded(_from, routerAddr);
            poolAmount = _swapTokenToLP(
                _from,
                amount,
                stability,
                _to,
                _recipient,
                routerAddr
            );
        }
        IDystPair pair = IDystPair(_to);
        address[] memory tokens;
        tokens = new address[](2);
        tokens[0] = pair.token0();
        tokens[1] = pair.token1();
        _returnAssets(tokens);
    }

    // function estimateZapInTokenToLP(
    //     address _from,
    //     address _to,
    //     address _router,
    //     uint256 _amt
    // ) public view returns (uint256, uint256) {
    //     // estimate total amount of each LP token received (i.e. amount of final LP token0 and token1 received)
    //     if (_from == IDystPair(_to).token0() || _from == IDystPair(_to).token1()) {
    //         // check if we already have one of the assets
    //         // if so, we're going to sell half of _from for the other token we need
    //         // figure out which token we need, and approve
    //         address other = _from == IDystPair(_to).token0() ? IDystPair(_to).token1() : IDystPair(_to).token0();
    //         // calculate amount of _from to sell
    //         uint256 sellAmount = _amt.div(2);
    //         // execute swap
    //         uint256 otherAmount = _estimateSwap(_from, sellAmount, other, _router);
    //         if (_from == IDystPair(_to).token0()) {
    //             return (sellAmount, otherAmount);
    //         } else {
    //             return (otherAmount, sellAmount);
    //         }
    //     } else {
    //         // go through native token for highest liquidity
    //         uint256 nativeAmount = 0;
    //         // determine amount of native token received in all cases
    //         if (_from == WNATIVE) {
    //             nativeAmount = _amt;
    //         } else if (specialTokensWithRouters[_from] != address(0)) {
    //             nativeAmount = _estimateSwap(_from, _amt, WNATIVE, specialTokensWithRouters[_from]);
    //         } else {
    //             nativeAmount = _estimateSwap(_from, _amt, WNATIVE, _router);
    //         }
    //         return estimateZapInToLP(_to, _router, nativeAmount);
    //     }
    // }

    function nativeToDystLp(
        address _to,
        OptimumStability calldata stability,
        address routerAddr,
        address _recipient
    ) external payable {
        // from Native to an LP token through the specified router
        uint256 poolAmount = _swapNativeToLP(
            _to,
            msg.value,
            stability,
            _recipient,
            routerAddr
        );
        emit ZapAmount(poolAmount);
        IDystPair pair = IDystPair(_to);
        address[] memory tokens;
        tokens = new address[](2);
        tokens[0] = pair.token0();
        tokens[1] = pair.token1();
        _returnAssets(tokens);
    }

    function lpToPenrose(address _to, uint256 amount) external {
        // from Native to an LP token through the specified router
        IERC20(_to).safeTransferFrom(msg.sender, address(this), amount);

        _approveTokenIfNeeded(_to, penroseInterface);
        IUserProxyInterface(penroseInterface).depositLpAndStake(_to, amount);
    }

    // function estimateZapInToLP(
    //     address _LP,
    //     address _router,
    //     uint256 _amt
    // ) public view returns (uint256, uint256) {
    //     uint256 zapAmt = _amt.div(2);

    //     IDystPair pair = IDystPair(_LP);
    //     address token0 = pair.token0();
    //     address token1 = pair.token1();

    //     if (token0 == WNATIVE || token1 == WNATIVE) {
    //         address token = token0 == WNATIVE ? token1 : token0;
    //         uint256 tokenAmt = _estimateSwap(WNATIVE, zapAmt, token, _router);
    //         if (token0 == WNATIVE) {
    //             return (zapAmt, tokenAmt);
    //         } else {
    //             return (tokenAmt, zapAmt);
    //         }
    //     } else {
    //         uint256 token0Amt = _estimateSwap(WNATIVE, zapAmt, token0, _router);
    //         uint256 token1Amt = _estimateSwap(WNATIVE, zapAmt, token1, _router);

    //         return (token0Amt, token1Amt);
    //     }
    // }

    /* ========== Private Functions ========== */

    function _approveTokenIfNeeded(address token, address router) private {
        if (IERC20(token).allowance(address(this), router) == 0) {
            IERC20(token).safeApprove(router, type(uint256).max);
        }
    }

    function _swapTokenToLP(
        address _from,
        uint256 amount,
        OptimumStability calldata stability,
        address _to,
        address recipient,
        address routerAddr
    ) private returns (uint256) {
        // Swap any ERC20 Token to LP
        // get pairs for desired lp
        if (
            _from == IDystPair(_to).token0() || _from == IDystPair(_to).token1()
        ) {
            // check if we already have one of the assets
            // if so, we're going to sell half of _from for the other token we need
            // figure out which token we need, and approve
            AddLiquidityArgs memory addLiquidityArguments;
            addLiquidityArguments.token1 = _from == IDystPair(_to).token0()
            ? IDystPair(_to).token1()
            : IDystPair(_to).token0();
            _approveTokenIfNeeded(addLiquidityArguments.token1, routerAddr);
            // calculate amount of _from to sell
            uint256 sellAmount = amount.div(2);
            // execute swap
            addLiquidityArguments.token1Amount = _swap(
                _from,
                sellAmount,
                addLiquidityArguments.token1,
                stability.tokenToNative,
                _from == IDystPair(_to).token0()
                ? stability.nativeToToken1
                : stability.nativeToToken0,
                address(this),
                routerAddr
            );
            addLiquidityArguments.stable = IDystPair(_to).stable();
            uint256 liquidity;
            (, , liquidity) = IDystRouter01(routerAddr).addLiquidity(
                _from,
                addLiquidityArguments.token1,
                addLiquidityArguments.stable,
                amount.sub(sellAmount),
                addLiquidityArguments.token1Amount,
                0,
                0,
                recipient,
                block.timestamp
            );
            return liquidity;
        } else {
            // go through native token for highest liquidity
            uint256 nativeAmount = _swapTokenForNative(
                _from,
                amount,
                stability.tokenToNative,
                address(this),
                routerAddr
            );
            return
            _swapNativeToLP(
                _to,
                nativeAmount,
                stability,
                recipient,
                routerAddr
            );
        }
    }

    function _swapNativeToLP(
        address _LP,
        uint256 amount,
        OptimumStability calldata stability,
        address recipient,
        address routerAddress
    ) internal returns (uint256) {
        // Swap Native token to LP
        // LP
        IDystPair pair = IDystPair(_LP);
        address token0 = pair.token0();
        address token1 = pair.token1();
        bool stable = pair.stable();
        uint256 liquidity;
        if (token0 == WNATIVE || token1 == WNATIVE) {
            address token = token0 == WNATIVE ? token1 : token0;
            bool swapStability = token0 == WNATIVE
            ? stability.nativeToToken1
            : stability.nativeToToken0;
            (, , liquidity) = _swapHalfNativeAndProvide(
                token,
                amount,
                swapStability,
                stable,
                routerAddress,
                recipient
            );
        } else {
            (, , liquidity) = _swapNativeToEqualTokensAndProvide(
                token0,
                token1,
                stability,
                stable,
                amount,
                routerAddress,
                recipient
            );
        }
        return liquidity;
    }

    function _swapHalfNativeAndProvide(
        address token,
        uint256 amount,
        bool swapStability,
        bool poolStability,
        address routerAddress,
        address recipient
    )
    private
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        // Swap Half of Native token to ERC20 Token used in LP, then make LP token using half native and half token
        uint256 swapValue = amount.div(2);
        uint256 tokenAmount = _swapNativeForToken(
            token,
            swapValue,
            swapStability,
            address(this),
            routerAddress
        );
        _approveTokenIfNeeded(token, dystRouter);
        IDystRouter01 router = IDystRouter01(dystRouter);
        return
        router.addLiquidityMATIC{value: amount.sub(swapValue)}(
            token,
            poolStability,
            tokenAmount,
            0,
            0,
            recipient,
            block.timestamp
        );
    }

    function _swapNativeToEqualTokensAndProvide(
        address token0,
        address token1,
        OptimumStability calldata stability,
        bool poolStability,
        uint256 amount,
        address routerAddress,
        address recipient
    )
    private
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        // Swap for ERC20 Tokens using half of total native token, then make LP token
        AddLiquidityArgs memory addLiquidityArguments;
        uint256 swapValue = amount.div(2);
        addLiquidityArguments.token0Amount = _swapNativeForToken(
            token0,
            swapValue,
            stability.nativeToToken0,
            address(this),
            routerAddress
        );
        addLiquidityArguments.token1Amount = _swapNativeForToken(
            token1,
            amount.sub(swapValue),
            stability.nativeToToken1,
            address(this),
            routerAddress
        );

        _approveTokenIfNeeded(token0, dystRouter);
        _approveTokenIfNeeded(token1, dystRouter);
        IDystRouter01 router = IDystRouter01(dystRouter);
        return
        router.addLiquidity(
            token0,
            token1,
            poolStability,
            addLiquidityArguments.token0Amount,
            addLiquidityArguments.token1Amount,
            0,
            0,
            recipient,
            block.timestamp + 100
        );
    }

    function _swapNativeForToken(
        address token,
        uint256 value,
        bool swapStability,
        address recipient,
        address routerAddr
    ) internal returns (uint256) {
        if (routerAddr != dystRouter) {
            address[] memory path;
            IUniswapV2Router01 router = IUniswapV2Router01(routerAddr);
            if (tokenBridgeForRouter[token][routerAddr] != address(0)) {
                path = new address[](3);
                path[0] = WNATIVE;
                path[1] = tokenBridgeForRouter[token][routerAddr];
                path[2] = token;
            } else {
                path = new address[](2);
                path[0] = WNATIVE;
                path[1] = token;
            }
            uint256[] memory minAmtArray = router.getAmountsOut(value, path);
            uint256 minAmt = minAmtArray[minAmtArray.length - 1];
            uint256[] memory amounts = router.swapExactETHForTokens{
            value: value
            }(minAmt, path, recipient, block.timestamp);
            return amounts[amounts.length - 1];
        } else {
            IDystRouter01.Route[] memory path;
            IDystRouter01 router = IDystRouter01(routerAddr);
            path = new IDystRouter01.Route[](1);
            path[0].from = WNATIVE;
            path[0].to = token;
            path[0].stable = swapStability;
            uint256[] memory minAmtArray = router.getAmountsOut(value, path);
            uint256 minAmt = minAmtArray[minAmtArray.length - 1];
            uint256[] memory amounts = router.swapExactMATICForTokens{
            value: value
            }(minAmt, path, recipient, block.timestamp);
            return amounts[amounts.length - 1];
        }
    }

    function _swapTokenForNative(
        address token,
        uint256 amount,
        bool stable,
        address recipient,
        address routerAddr
    ) private returns (uint256) {
        if (routerAddr != dystRouter) {
            address[] memory path;
            IUniswapV2Router01 router = IUniswapV2Router01(routerAddr);
            if (tokenBridgeForRouter[token][routerAddr] != address(0)) {
                path = new address[](3);
                path[0] = token;
                path[1] = tokenBridgeForRouter[token][routerAddr];
                path[2] = router.WETH();
            } else {
                path = new address[](2);
                path[0] = token;
                path[1] = router.WETH();
            }
            uint256[] memory minAmtArray = router.getAmountsOut(amount, path);
            uint256 minAmt = minAmtArray[minAmtArray.length - 1];
            uint256[] memory amounts = router.swapExactTokensForETH(
                amount,
                minAmt,
                path,
                recipient,
                block.timestamp
            );
            return amounts[amounts.length - 1];
        } else {
            IDystRouter01.Route[] memory path;
            IDystRouter01 router = IDystRouter01(routerAddr);
            path = new IDystRouter01.Route[](1);
            path[0].from = token;
            path[0].to = router.wmatic();
            path[0].stable = stable;
            uint256[] memory minAmtArray = router.getAmountsOut(amount, path);
            uint256 minAmt = minAmtArray[minAmtArray.length - 1];
            uint256[] memory amounts = router.swapExactTokensForMATIC(
                amount,
                minAmt,
                path,
                recipient,
                block.timestamp
            );
            return amounts[amounts.length - 1];
        }
    }

    function _swap(
        address _from,
        uint256 amount,
        address _to,
        bool tokenToNative,
        bool nativeToToken,
        address recipient,
        address routerAddr
    ) private returns (uint256) {
        address fromBridge = tokenBridgeForRouter[_from][routerAddr];
        address toBridge = tokenBridgeForRouter[_to][routerAddr];

        if (routerAddr != dystRouter) {
            IUniswapV2Router01 router = IUniswapV2Router01(routerAddr);
            address[] memory path;
            if (fromBridge != address(0) && toBridge != address(0)) {
                if (fromBridge != toBridge) {
                    path = new address[](5);
                    path[0] = _from;
                    path[1] = fromBridge;
                    path[2] = WNATIVE;
                    path[3] = toBridge;
                    path[4] = _to;
                } else {
                    path = new address[](3);
                    path[0] = _from;
                    path[1] = fromBridge;
                    path[2] = _to;
                }
            } else if (fromBridge != address(0)) {
                if (_to == WNATIVE) {
                    path = new address[](3);
                    path[0] = _from;
                    path[1] = fromBridge;
                    path[2] = WNATIVE;
                } else {
                    path = new address[](4);
                    path[0] = _from;
                    path[1] = fromBridge;
                    path[2] = WNATIVE;
                    path[3] = _to;
                }
            } else if (toBridge != address(0)) {
                path = new address[](4);
                path[0] = _from;
                path[1] = WNATIVE;
                path[2] = toBridge;
                path[3] = _to;
            } else if (_from == WNATIVE || _to == WNATIVE) {
                path = new address[](2);
                path[0] = _from;
                path[1] = _to;
            } else {
                // Go through WNative
                path = new address[](3);
                path[0] = _from;
                path[1] = WNATIVE;
                path[2] = _to;
            }
            uint256[] memory minAmtArray = router.getAmountsOut(amount, path);
            uint256 minAmt = minAmtArray[minAmtArray.length - 1];
            uint256[] memory amounts = router.swapExactTokensForTokens(
                amount,
                minAmt,
                path,
                recipient,
                block.timestamp
            );
            return amounts[amounts.length - 1];
        } else {
            IDystRouter01 router = IDystRouter01(routerAddr);
            IDystRouter01.Route[] memory path;
            if (_from == WNATIVE) {
                path = new IDystRouter01.Route[](1);
                path[0].from = _from;
                path[0].to = _to;
                path[0].stable = nativeToToken;
            } else if (_to == WNATIVE) {
                path = new IDystRouter01.Route[](1);
                path[0].from = _from;
                path[0].to = _to;
                path[0].stable = tokenToNative;
            } else {
                // Go through WNative
                path = new IDystRouter01.Route[](2);
                path[0].from = _from;
                path[0].to = WNATIVE;
                path[0].stable = nativeToToken;
                path[1].from = WNATIVE;
                path[1].to = _to;
                path[1].stable = tokenToNative;
            }
            uint256[] memory minAmtArray = router.getAmountsOut(amount, path);
            uint256 minAmt = minAmtArray[minAmtArray.length - 1];
            uint256[] memory amounts = router.swapExactTokensForTokens(
                amount,
                minAmt,
                path,
                recipient,
                block.timestamp
            );
            return amounts[amounts.length - 1];
        }
    }

    // function _estimateSwap(
    //     address _from,
    //     uint256 amount,
    //     address _to,
    //     address routerAddr
    // ) public view returns (uint256) {
    //     IUniswapV2Router01 router = IUniswapV2Router01(routerAddr);

    //     address fromBridge = tokenBridgeForRouter[_from][routerAddr];
    //     address toBridge = tokenBridgeForRouter[_to][routerAddr];

    //     address[] memory path;

    //     if (fromBridge != address(0) && toBridge != address(0)) {
    //         if (fromBridge != toBridge) {
    //             path = new IDystRouter01.Route[](5);
    //             path[0] = _from;
    //             path[1] = fromBridge;
    //             path[2] = WNATIVE;
    //             path[3] = toBridge;
    //             path[4] = _to;
    //         } else {
    //             path = new IDystRouter01.Route[](3);
    //             path[0] = _from;
    //             path[1] = fromBridge;
    //             path[2] = _to;
    //         }
    //     } else if (fromBridge != address(0)) {
    //         if (_to == WNATIVE) {
    //             path = new IDystRouter01.Route[](3);
    //             path[0] = _from;
    //             path[1] = fromBridge;
    //             path[2] = WNATIVE;
    //         } else {
    //             path = new IDystRouter01.Route[](4);
    //             path[0] = _from;
    //             path[1] = fromBridge;
    //             path[2] = WNATIVE;
    //             path[3] = _to;
    //         }
    //     } else if (toBridge != address(0)) {
    //         path = new IDystRouter01.Route[](4);
    //         path[0] = _from;
    //         path[1] = WNATIVE;
    //         path[2] = toBridge;
    //         path[3] = _to;
    //     } else if (_from == WNATIVE || _to == WNATIVE) {
    //         path = new IDystRouter01.Route[](2);
    //         path[0] = _from;
    //         path[1] = _to;
    //     } else {
    //         // Go through WNative
    //         path = new IDystRouter01.Route[](3);
    //         path[0] = _from;
    //         path[1] = WNATIVE;
    //         path[2] = _to;
    //     }

    //     uint256[] memory amounts = router.getAmountsOut(amount, path);
    //     return amounts[amounts.length - 1];

    // }

    // function estimateSwapToken(
    //     address _from,
    //     uint256 amount,
    //     address _to,
    //     address routerAddr
    // ) public view returns (uint256) {
    //     if (specialTokensWithRouters[_from] != address(0)) {

    //         address specialRouter = specialTokensWithRouters[_from];
    //         uint256 nativeAmount = _estimateSwap(_from, amount, WNATIVE, specialRouter);

    //         if (_to != WNATIVE && !isLpToken[_to]) {
    //             return _estimateSwap(WNATIVE, nativeAmount, _to, routerAddr);
    //         }
    //         else if (_to == WNATIVE){
    //             return nativeAmount;
    //         }
    //         else if (isLpToken[_to]){
    //             (uint256 token0,) = estimateZapInToLP(_to, routerAddr, nativeAmount);
    //             return token0;
    //         }
    //     }
    //     else if (isLpToken[_to]){
    //         if (_from != WNATIVE) {
    //             (uint256 token0,) = estimateZapInTokenToLP(_from, _to, routerAddr, amount);
    //             return token0;
    //         }
    //         else {
    //             (uint256 token0,) = estimateZapInToLP(_to, routerAddr, amount);
    //             return token0;
    //         }
    //     }

    //     return _estimateSwap(_from, amount, _to, routerAddr);
    // }

    function _returnAssets(address[] memory tokens) private {
        uint256 balance;
        for (uint256 i; i < tokens.length; i++) {
            balance = IERC20(tokens[i]).balanceOf(address(this));
            if (balance > 0) {
                if (tokens[i] == WNATIVE) {
                    IWETH(WNATIVE).withdraw(balance);
                    (bool success, ) = msg.sender.call{value: balance}(
                        new bytes(0)
                    );
                    require(success, "MATIC transfer failed");
                } else {
                    IERC20(tokens[i]).safeTransfer(msg.sender, balance);
                }
            }
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setAllowedTokenAddress(address _token, bool _isAllowed)
    external
    onlyGovernance
    {
        tokenIsAllowedMap[_token] = _isAllowed;
    }

    function setTokenBlacklistToZapAddress(address _token, bool _isAllowed) external onlyOwner {
        tokenBlacklistToZap[_token] = _isAllowed;
    }

    function setSpecialTokenWithRouter(address _token, address _router)
    external
    onlyGovernance
    {
        specialTokensWithRouters[_token] = _router;
    }

    function setTokenBridgeForRouter(
        address token,
        address router,
        address bridgeToken
    ) external onlyGovernance {
        tokenBridgeForRouter[token][router] = bridgeToken;
    }

    function setPenroseInterface(address _penroseInterface)
    external
    onlyGovernance
    {
        penroseInterface = _penroseInterface;
    }

    function withdraw(address token) external onlyGovernance {
        if (token == address(0)) {
            payable(governanceAddress()).transfer(address(this).balance);
            return;
        }

        IERC20(token).transfer(
            governanceAddress(),
            IERC20(token).balanceOf(address(this))
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;

/**
 * @title Ownable contract which allows governance to be killed, adapted to be used under a proxy
 * @author Penrose
 */
contract GovernableImplementation {
    address internal doNotUseThisSlot; // used to be governanceAddress, but there's a hash collision with the proxy's governanceAddress
    bool public governanceIsKilled;

    /**
     * @notice legacy
     * @dev public visibility so it compiles for 0.6.12
     */
    constructor() public {
        doNotUseThisSlot = msg.sender;
    }

    /**
     * @notice Only allow governance to perform certain actions
     */
    modifier onlyGovernance() {
        require(msg.sender == governanceAddress(), "Only governance");
        _;
    }

    /**
     * @notice Set governance address
     * @param _governanceAddress The address of new governance
     */
    function setGovernanceAddress(address _governanceAddress)
        public
        onlyGovernance
    {
        require(msg.sender == governanceAddress(), "Only governance");
        assembly {
            sstore(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                _governanceAddress
            ) // keccak256('eip1967.proxy.admin')
        }
    }

    /**
     * @notice Allow governance to be killed
     */
    function killGovernance() external onlyGovernance {
        setGovernanceAddress(address(0));
        governanceIsKilled = true;
    }

    /**
     * @notice Fetch current governance address
     * @return _governanceAddress Returns current governance address
     * @dev directing to the slot that the proxy would use
     */
    function governanceAddress()
        public
        view
        returns (address _governanceAddress)
    {
        assembly {
            _governanceAddress := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
            ) // keccak256('eip1967.proxy.admin')
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;

/**
 * @title Implementation meant to be used with a proxy
 * @author Penrose
 */
contract ProxyImplementation {
    bool public proxyStorageInitialized;

    /**
     * @notice Nothing in constructor, since it only affects the logic address, not the storage address
     * @dev public visibility so it compiles for 0.6.12
     */
    constructor() public {}

    /**
     * @notice Only allow proxy's storage to be initialized once
     */
    modifier checkProxyInitialized() {
        require(
            !proxyStorageInitialized,
            "Can only initialize proxy storage once"
        );
        proxyStorageInitialized = true;
        _;
    }
}