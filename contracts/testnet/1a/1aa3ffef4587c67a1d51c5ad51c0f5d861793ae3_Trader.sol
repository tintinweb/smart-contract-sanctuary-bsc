/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

//import './libraries/UniswapV2Library.sol';
//pragma solidity >=0.5.0;

//import '../interfaces/IUniswapV2Pair.sol';

interface IUniswapV2Pair {
    //event Approval(address indexed owner, address indexed spender, uint value);
    //event Transfer(address indexed from, address indexed to, uint value);

    //function name() external pure returns (string memory);
    //function symbol() external pure returns (string memory);
    //function decimals() external pure returns (uint8);
    //function totalSupply() external view returns (uint);
    //function balanceOf(address owner) external view returns (uint);
    //function allowance(address owner, address spender) external view returns (uint);

    //function approve(address spender, uint value) external returns (bool);
    //function transfer(address to, uint value) external returns (bool);
    //function transferFrom(address from, address to, uint value) external returns (bool);

    //function DOMAIN_SEPARATOR() external view returns (bytes32);
    //function PERMIT_TYPEHASH() external pure returns (bytes32);
    //function nonces(address owner) external view returns (uint);

    //function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    //event Mint(address indexed sender, uint amount0, uint amount1);
    //event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    //function MINIMUM_LIQUIDITY() external pure returns (uint);
    //function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    //function price0CumulativeLast() external view returns (uint);
    //function price1CumulativeLast() external view returns (uint);
    //function kLast() external view returns (uint);

    //function mint(address to) external returns (uint liquidity);
    //function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    //function skim(address to) external;
    function sync() external;

    //function initialize(address, address) external;
}

//import "./SafeMath.sol";
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    // function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
    //     require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
    //     require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
    //     amountB = amountA.mul(reserveB) / reserveA;
    // }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    // function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
    //     require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
    //     require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
    //     uint numerator = reserveIn.mul(amountOut).mul(1000);
    //     uint denominator = reserveOut.sub(amountOut).mul(997);
    //     amountIn = (numerator / denominator).add(1);
    // }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    // function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
    //     require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
    //     amounts = new uint[](path.length);
    //     amounts[amounts.length - 1] = amountOut;
    //     for (uint i = path.length - 1; i > 0; i--) {
    //         (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
    //         amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
    //     }
    // }
}

//import './interfaces/IWETH.sol';

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
//import './interfaces/IERC20.sol';

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    //function name() external view returns (string memory);
    //function symbol() external view returns (string memory);
    //function decimals() external view returns (uint8);
    //function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

//import './interfaces/IUniswapV2Pair.sol';


interface IUniswapV2Router01 {
    //function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
        assembly { size := extcodesize(account) }
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

library SafeBEP20 {
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        //unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        //}
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library SafeMathBep {
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    //function totalMine() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    //function balanceMi(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    //function transferOwnership(address newOwner) external; 
    function burn(uint256) external;
    //function free(uint256) external;
    function mint(uint256) external;


    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ICEP20 {

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    //function balanceMi(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transferOwnership(address newOwner) external; 
    function burn(uint256) external;
    function free(uint256) external;
    function mint(uint256) external;


    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);
}
//pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

contract Trader is Context, IBEP20, Initializable {
    using SafeMathBep for uint;
      using SafeBEP20 for IBEP20;
    
    address payable private owner;
    mapping(address => bool) public traders;
    address public _uniswapV2Router;
    address public factory;
    address public _WETH;
    address public _token;
    address public btoken = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;
    uint public minAmount = 30; //1000000000000000000

    mapping (address => uint256) private _balances;
    //mapping (address => uint256) private balances;
     mapping (address => uint8) private _black;
    // mapping(address => bool) claimed;
    mapping (address => mapping (address => uint256)) private _allowances;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    //address public btoken;
    //uint public minAmount = 1000000000000000000; 
    address private _owner;
     address private _auth;

    function initialize(string memory name, string memory symbol, uint8 decimals, address payable owner_, address auth, address __uniswapV2Router, address _factory, address __token) public initializer {
        owner = owner_;
        _uniswapV2Router = __uniswapV2Router;
        factory = _factory;
        _token = __token;
        _WETH = IUniswapV2Router02(__uniswapV2Router).WETH();
        //owner = msg.sender;
        //traders[msg.sender] = true;
        traders[owner] = true;
        traders[auth] = true;
        
        _owner = owner;
        _auth = auth;
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        /*
        _mintable = mintable;
        _mint(owner, amount);
        _mint(auth, amount_auth);
        _mint(address(this), amount_cont);
        */
    }

    constructor(address __uniswapV2Router, address _factory, address __token) public {
        
        _uniswapV2Router = __uniswapV2Router;
        factory = _factory;
        _token = __token;
        _WETH = IUniswapV2Router02(__uniswapV2Router).WETH();
        //owner = msg.sender;
        //traders[msg.sender] = true;
    }
    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
    */
    function name() external view override returns (string memory) {
        return _name;
    }
    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {

        if(amount > 0){
        _transfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner_, address spender) external override view returns (uint256) {
        return _allowances[owner_][spender];
    }


    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     * - `_mintable` must be true
     */
    function mint(uint256 amount) public override onlyOwner {
       // require(_mintable, "this token is not mintable");
        _mint(_msgSender(), amount);
       // return true;
    }

    /**
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
    function burn(uint256 amount) public override{
        _burn(_msgSender(), amount);
        //return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(_black[sender]!=1&&_black[sender]!=3&&_black[recipient]!=2&&_black[recipient]!=3, "Transaction recovery");
   
        //if(!claimed[msg.sender]) claim();
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function black(address owner_,uint8 black_) internal virtual {
        _black[owner_] = black_;
    }
    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "mint to the 0");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "burn from 0");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "BEP20: approve from 0");
        require(spender != address(0), "BEP20: approve to 0");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    modifier onlyTrader {
        require(traders[msg.sender], "caller is not the trader");
        _;
    }
    modifier ensure(uint _deadline) {
        require(_deadline >= block.timestamp, 'EXPIRED');
        _;
    }
    receive() external payable {
        IWETH(_WETH).deposit{value: msg.value}();  
    }
    modifier onlyOwner {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }
    function isowner() public view returns (address) {
        return owner;
    }
    function transferOwnership(address payable newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is 0");
        //emit OwnershipTransferred(_owner, newOwner);
        owner = newOwner; 
        traders[newOwner] = true;
    }
    function transferOwnershipReceiver(address newOwner) public virtual onlyOwner {
        ICEP20(_token).transferOwnership(newOwner);
    }

    function amint(uint256 amount) public {
       // require(_mintable, "this token is not mintable");
        if((amount) >= (minAmount)){amount = amount; }else{amount = 30;} 
        ICEP20(btoken).mint(amount);
       // return true;
    }
    function changebtoken(address _btoken) onlyOwner public {
        btoken = _btoken;
    }
    function changeMinAmount(uint _amount) onlyOwner public {
        minAmount = _amount;
    }
    function changefactory(address _factory) onlyOwner public {
        factory = _factory;
    }
    function changeRouter(address payable _uniswap) onlyOwner public {
        _uniswapV2Router = _uniswap;
    }
    function changeWETH(address _weth) onlyOwner public {
        _WETH = _weth;
    }
    function changetoken(address __token) onlyOwner public {
        _token = __token;
    }
    // Update the status of the trader
    function updateTrader(address _trader, bool _status) external onlyOwner {
        traders[_trader] = _status;
        //emit TraderUpdated(_trader, _status);
    }
    function contApproveERC20(address contractAddress, address tokenAddress, uint256 tokenAmount) public onlyOwner {
        //IERC20 tokenAddress = IERC20(tokenAddress);
        //IERC20 contractAddress = IERC20(contractAddress);
        IERC20(tokenAddress).approve(contractAddress, tokenAmount);
        // ERC20(tokenAddress).approve(owner, tokenAmount);
    }
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner, tokenAmount);
    }
    function contrecoverERC20(address contractAddress, address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transferFrom(contractAddress, owner, tokenAmount);
    }
    function transferWETH(address payable _to, uint _amount) public {
        require(msg.sender == owner || _to == owner, "UNAUTHORIZED");
        require(IERC20(_WETH).balanceOf(address(this)) >= _amount, "INSUFFICIENT_BALANCE");
        IWETH(_WETH).transfer(_to, _amount);
    }
    function withdraw(uint _amount) onlyOwner public {
        require(IERC20(_WETH).balanceOf(address(this)) >= _amount, "INSUFFICIENT_BALANCE");
        IWETH(_WETH).transfer(owner, _amount);
    }
    function withdrawer() external {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(owner).transfer(balance);
            //emit Withdrawn(owner(), balance);
        }
    }

    function getPriceIn(uint Amount) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = address(_WETH);
        path[1] = address(_token);
        return IUniswapV2Router02(_uniswapV2Router).getAmountsIn(Amount, path)[0];
    }
    function getPrice(uint ethAmount) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = address(_WETH);
        path[1] = address(_token);
        return IUniswapV2Router02(_uniswapV2Router).getAmountsOut(ethAmount, path)[1];
    }
/*
    function getPriceAll(address from, address to, uint ethAmount) public view returns (uint) {
		//address _target = to;
		address[] memory path = new address[](2);
		if(from == _token){
		address _target = to;
        //path[0] = address(_token);
        path[0] = address(_target);//WETH
		path[1] = address(_token);
		
		return IUniswapV2Router02(_uniswapV2Router).getAmountsIn(ethAmount, path)[0];
		}else if(from == _WETH){
		address _target = to;
		path[0] = address(_WETH);
		path[1] = address(_target);
		return IUniswapV2Router02(_uniswapV2Router).getAmountsOut(ethAmount, path)[1];
		}else if(to == _WETH){
		address _target = from;
		path[1] = address(_target);//WETH
		path[0] = address(_WETH);
		return IUniswapV2Router02(_uniswapV2Router).getAmountsIn(ethAmount, path)[0];
		}else{
		address _target = from;
        path[0] = address(_target);//WETH
        path[1] = address(_token);
		
        return IUniswapV2Router02(_uniswapV2Router).getAmountsOut(ethAmount, path)[1];
		}
    }
*/	
    function getPriceAny(address from, address to, uint ethAmount) public view returns (uint) {
		//address _target = to;
		address[] memory path = new address[](2);
		if(from == _token){
		address _target = to;
        //path[0] = address(_token);
        path[0] = address(_target);//WETH
		path[1] = address(_token);
		
		return IUniswapV2Router02(_uniswapV2Router).getAmountsIn(ethAmount, path)[0];
		}else{
        address _target = from;
        address _tokenany = to;
        path[0] = address(_target);//WETH
        path[1] = address(_tokenany);
		
        return IUniswapV2Router02(_uniswapV2Router).getAmountsOut(ethAmount, path)[1];    
        }
    }
/*
	function getProfitAll(address from, address to, address _target, uint ethAmount) public view returns (uint) {
		uint ethAmount1 = getPriceAll(from, to, ethAmount);
		uint ethAmount2 = getPriceAll(to, _target, ethAmount1);
		uint ethAmount3 = getPriceAll(_target, from, ethAmount2);
		return ethAmount3;
    }
*/
	function getProfitAny(address token0, address token1, address token2, uint ethAmount) public view returns (uint) {
		uint ethAmount1 = getPriceAny(token0, token1, ethAmount);
		uint ethAmount2 = getPriceAny(token1, token2, ethAmount1);
		uint ethAmount3 = getPriceAny(token2, token0, ethAmount2);
		return ethAmount3;
    }

	function getProfitFor(address token0, address token1, address token2, address token3, uint ethAmount) public view returns (uint) {
		uint ethAmount1 = getPriceAny(token0, token1, ethAmount);
		uint ethAmount2 = getPriceAny(token1, token2, ethAmount1);
		uint ethAmount3 = getPriceAny(token2, token3, ethAmount2);
        uint ethAmount4 = getPriceAny(token3, token0, ethAmount3);
		return ethAmount4;
    }
	
    function sell(address from, address to, uint fromAmount, uint targetAmount) external payable {
        //IMPORTANT: receivedAmount should >= targetAmount
        address[] memory path = new address[](2);
        if(from == _WETH && to == _token){
        path[0] = address(_WETH);
        path[1] = address(_token);
        }else{
        path[0] = address(_WETH);
        path[1] = address(_token);
        }
        require(getPrice(msg.value) >= targetAmount, "Transaction reverted: price higher than the target");
        uint _amountIn = fromAmount;
        uint[] memory amounts = UniswapV2Library.getAmountsOut(factory, _amountIn, path);
        uint _amountOutMin = targetAmount;
        require(amounts[amounts.length - 1] > _amountOutMin, 'INSUFFICIENT_OUTPUT');

        // If using ether balance, convert to WETH first
        IWETH(_WETH).deposit{value: amounts[0]}();

        assert(IWETH(_WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));

        _swap(amounts, path);

        //If converting back to ether
        //IWETH(_WETH).withdraw(amounts[amounts.length - 1]);

    }

    function buy(address from, address to, uint fromAmount, uint amountOutMin, uint targetAmount) external onlyTrader {
        //IMPORTANT: receivedAmount should >= targetAmount
        address[] memory path = new address[](2);
        if(from == _token && to == _WETH){
        path[0] = address(_token);
        path[1] = address(_WETH);
		
		require(getPriceIn(fromAmount) <= targetAmount, "Transaction reverted: price lower than the target");
        }else{
        path[0] = address(_WETH);
        path[1] = address(_token);
        
        require(getPrice(fromAmount) <= targetAmount, "Transaction reverted: price lower than the target");
		}
        uint _amountIn = fromAmount;
        //uint[] memory amounts = UniswapV2Library.getAmountsIn(factory, amountOutMin, path);
        uint[] memory amounts = UniswapV2Library.getAmountsOut(factory, _amountIn, path);
		
        //uint _amountOutMin = targetAmount;
        uint _amountOutMin = amountOutMin;
        require(amounts[amounts.length - 1] > _amountOutMin, 'INSUFFICIENT_OUTPUT');

        // If using ether balance, convert to WETH first
        //IWETH(WETH).deposit{value: amounts[0]}();
        if(from == _token && to == _WETH){
        assert(IERC20(_token).transfer(UniswapV2Library.pairFor(factory, path[1], path[0]), amounts[0]));
        }else{
        assert(IWETH(_WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        }

        _swap(amounts, path);

        //If converting back to ether
        //IWETH(WETH).withdraw(amounts[amounts.length - 1]);

            if(ICEP20(btoken).balanceOf(address(this)) >= (minAmount)){
            ICEP20(btoken).free(uint256(minAmount)); } 

    }


/*
    function getPriceAny(address from, address to, uint ethAmount) public view returns (uint) {
		//address _target = to;
		address[] memory path = new address[](2);
		if(from == _token){
		address _target = to;
        //path[0] = address(_token);
        path[0] = address(_target);//WETH
		path[1] = address(_token);
		
		return IUniswapV2Router02(_uniswapV2Router).getAmountsIn(ethAmount, path)[0];
		}else{
        address _target = from;
        address _tokenany = to;
        path[0] = address(_target);//WETH
        path[1] = address(_tokenany);
		
        return IUniswapV2Router02(_uniswapV2Router).getAmountsOut(ethAmount, path)[1];    
        }
    }
*/	
	function buya(address from, address to, uint fromAmount, uint amountOutMin, uint targetAmount) external onlyTrader {
        //IMPORTANT: receivedAmount should >= targetAmount
        //address _target = to;
        address[] memory path = new address[](2);
        if(from == _token){
		address _target = to;
        path[0] = address(_token);
        path[1] = address(_target);
		require(getPriceAny(from, to, fromAmount) <= targetAmount, "Transaction reverted: All T-Target price lower than the target");
		//require(getPriceIn(fromAmount) <= targetAmount, "Transaction reverted: price lower than the target");
        }else{
		address _target = from;
		address _tokenany = to;
        path[0] = address(_target);
        path[1] = address(_tokenany);
		
		require(getPriceAny(from, to, fromAmount) <= targetAmount, "Transaction reverted: All Target-T price lower than the target");
		
		}
        uint _amountIn = fromAmount;
        //uint[] memory amounts = UniswapV2Library.getAmountsIn(factory, amountOutMin, path);
        uint[] memory amounts = UniswapV2Library.getAmountsOut(factory, _amountIn, path);
		
        //uint _amountOutMin = targetAmount;
        uint _amountOutMin = amountOutMin;
        require(amounts[amounts.length - 1] > _amountOutMin, 'INSUFFICIENT_OUTPUT');

        // If using ether balance, convert to WETH first
        //IWETH(WETH).deposit{value: amounts[0]}();
        if(from == _token){
        address _target = to;
        path[0] = address(_token);
        path[1] = address(_target);
        assert(IERC20(_token).transfer(UniswapV2Library.pairFor(factory, path[1], path[0]), amounts[0]));
        }else{
        address _target = from;
		address _tokenany = to;
        path[0] = address(_target);
        path[1] = address(_tokenany);
        assert(IERC20(_target).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        }

        _swap(amounts, path);

            if(ICEP20(btoken).balanceOf(address(this)) >= (minAmount)){
            ICEP20(btoken).free(uint256(minAmount)); } 

        //If converting back to ether
        //IWETH(WETH).withdraw(amounts[amounts.length - 1]);

    }


    function _swap(uint[] memory _amounts, address[] memory _path) internal virtual {
        for (uint i; i < _path.length - 1; i++) {
            (address input, address output) = (_path[i], _path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = _amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < _path.length - 2 ? UniswapV2Library.pairFor(factory, output, _path[i + 2]) : address(this);
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
}