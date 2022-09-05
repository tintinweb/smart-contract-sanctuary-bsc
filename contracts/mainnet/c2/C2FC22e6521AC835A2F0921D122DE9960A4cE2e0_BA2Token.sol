/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-17
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
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

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

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

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol



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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract BA2Token is IERC20, Ownable {
    using SafeMath for uint256;
    IERC20 public UsdtContract;
    IERC20 public BNBContract;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    address private sat = 0xD36f3317987ee23de1078640eDF3015744f71b5D;
    address private projectAddress = 0x59F10E3Eb6E900BF31Ca46E0C27EEAB1119343a3;
    address public foundationAddress=0x98de241FbCa727F041391A5C9Fc714Ab8eF86742;
    address private USDTAddress=0x55d398326f99059fF775485246999027B3197955;
    uint256 private _tFeeTotal;

    string private _name = "LYC";
    string private _symbol = "LYC";
    uint8 private _decimals = 18;

    uint256 public Controltime;
    uint256 public _LPFee = 200;
    uint256 public _satFee = 0;
    uint256 currentIndex;  
    uint256 private _tTotal = 10 * 10**7 * 10**18;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 1 hours;
    uint256 public LPFeefenhong;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public immutable uniswapV2Pair1;
    uint256 public _buyFee=100;
     uint256 public _usellFee=10;  //卖出滑点
     uint256 public _bsellFee=10;  //卖出滑点
     uint256 public _sellFlowFee=500;
     uint256 public _sellBurnFee=500;
     uint256 public _sellFlowFee1=500;
     uint256 public _sellLPFee1=1000;
     uint256 public _sellBurnFee1=1500;
    uint constant internal SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant internal SECONDS_PER_HOUR = 60 * 60;
    uint constant internal SECONDS_PER_MINUTE = 60;
    uint constant internal OFFSET19700101 = 2440588;
    uint public  uLastYear;
    uint public uLastMonth;
    uint public uLastDay;
    uint public  bLastYear;
    uint public bLastMonth;
    uint public bLastDay;
    uint public  zidi;
    uint256  public uTodayFirstPrice=100;
    uint256  public bTodayFirstPrice=100;
    uint256  public productRio=10**18;
    mapping(address => address) public inviter;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    

    constructor() {
        _tOwned[msg.sender] = _tTotal;
       
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Pair1 = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this),USDTAddress);
        UsdtContract = IERC20(USDTAddress);
        BNBContract = IERC20(_uniswapV2Router.WETH());    
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[projectAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

   function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function setfoundationAddress(address newfoundationAddress) external onlyOwner {
        foundationAddress = newfoundationAddress;
    }

    function setChangeFee(uint256 newbuyFee,uint256 newsellFlowFee,uint256 newsellBurnFee,uint256 newsellFlowFee1,uint256 newsellLPFee1,uint256 newsellBurnFee1) external onlyOwner{
        _buyFee=newbuyFee;
        _sellFlowFee = newsellFlowFee;
        _sellBurnFee = newsellBurnFee;
        _sellFlowFee1 = newsellFlowFee1;
        _sellLPFee1 = newsellLPFee1;
        _sellBurnFee1 = newsellBurnFee1;
    }

    
    function setControltime(uint256 _Controltime) external onlyOwner {
        Controltime = _Controltime;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

        // 指定用户地址，查询多少BNB
    function getUserDepositBNBAmounts(address user) public view returns (uint256) {
        return BNBContract.balanceOf(user);
    }
    
     // 指定用户地址，查询用户多少USDT
    function getTotalDepositUsdtAmounts(address user) public view returns (uint256) {
        return UsdtContract.balanceOf(user);
    }

    //时间戳转日期
    function daysToDate(uint timestamp, int8 timezone) public pure returns (uint year, uint month, uint day){
        (year,month,day) =  _daysToDate(int(timestamp) + timezone * int(SECONDS_PER_HOUR));
        return ( year,month,day);
    }

    //时间戳转日期，UTC时区
    function _daysToDate(int timestamp) private pure returns (uint year, uint month, uint day) {
            uint _days = uint(timestamp) / SECONDS_PER_DAY;
            uint L = _days + 68569 + OFFSET19700101;
            uint N = 4 * L / 146097;
            L = L - (146097 * N + 3) / 4;
            year = 4000 * (L + 1) / 1461001;
            L = L - 1461 * year / 4 + 31;
            month = 80 * L / 2447;
            day = L - 2447 * month / 80;
            L = month / 11;
            month = month + 2 - 12 * L;
            year = 100 * (N - 49) + year + L;
    }

    function gain_new_price(address swapaddress) public view  returns(uint256){
        uint256   ybc = balanceOf(swapaddress);
        uint256 newfee;
            if(swapaddress == uniswapV2Pair){
             uint256  Bbalance = getUserDepositBNBAmounts(swapaddress);
                if(ybc !=0){
                    newfee = Bbalance * productRio /ybc;
                }
            }else{
          uint256   uBalance = getTotalDepositUsdtAmounts(swapaddress);
                if(ybc !=0){
                    newfee =uBalance * productRio /ybc;
                }
            
            }
         return newfee;
    }


    function setuTodayFirstPrice(uint256 _uTodayFirstPrice) external onlyOwner {
        uTodayFirstPrice = _uTodayFirstPrice;
    }

    function setbTodayFirstPrice(uint256 _bTodayFirstPrice) external onlyOwner {
        bTodayFirstPrice = _bTodayFirstPrice;
    }

    function setuSellFee(uint256 usellfee) public {
        _usellFee = usellfee;
    }

    function setbSellFee(uint256 bsellfee) public {
        _bsellFee = bsellfee;
    }

    function gainData(uint timestamp,address swapaddress) public { 
        int8 timezone=8;
        // uint timestamp=block.timestamp;
        (uint year, uint month,uint day)=daysToDate(timestamp,timezone);
        uint256 newPice=gain_new_price(swapaddress);

        if(uLastYear== year && uLastMonth==month && uLastDay==day){  //当天
            zidi=1;
            if(newPice >uTodayFirstPrice){   //当前价格比今天首单大
                if(_usellFee==30){ //此时卖出滑点30%
                      uint256 cha=(productRio *(newPice - uTodayFirstPrice)) / uTodayFirstPrice;
                      zidi=cha;
                       if(cha >= 0.1*10**18){
                           _usellFee=10;
                       } 
                }
            }else{  //当前价格比今天首单小
                if(_usellFee==10){ //此时卖出滑点10%
                     uint256 cha=(productRio *(uTodayFirstPrice -newPice)) / uTodayFirstPrice;
                     zidi=cha;
                     if(cha >= 0.1*10**18){
                           _usellFee=30;
                       } 
                }
            }
        }else{ //第二天
            zidi=2;
           uLastYear=year;
           uLastMonth=month;
           uLastDay=day;
           uTodayFirstPrice=newPice;
           _usellFee=10;
        }

    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        //indicates if fee should be deducted from transfer

        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            from != uniswapV2Pair;

        if(block.timestamp < Controltime){
            if(!_isExcludedFromFee[from]){
                require(amount < 1000000000,"trading excess");
            }
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount);

        if (shouldSetInviter) {
            inviter[to] = from;
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _transferStandard(sender, recipient, amount);
    }


    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        uint256 recipientRate;
        if (sender == uniswapV2Pair  || sender == uniswapV2Pair1) { //买入
             _takeSlippageFee(sender,address(foundationAddress),tAmount.div(10000).mul(_buyFee));
            recipientRate = 10000 -_buyFee;
               _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(10000).mul(recipientRate));
         emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
        }else if(recipient == uniswapV2Pair  || recipient==uniswapV2Pair1){  //卖出
             int8 timezone=8;
            uint timestamp=block.timestamp;
            (uint year, uint month,uint day)=daysToDate(timestamp,timezone);
            uint256 newPice=gain_new_price(recipient);
            if(recipient == uniswapV2Pair){ //LYC-BNB
                    if(bLastYear== year && bLastMonth==month && bLastDay==day){  
                        zidi=1;
                        if(newPice==0 || bTodayFirstPrice==0){
                            newPice=1;
                            bTodayFirstPrice=1;
                        }
                        if(newPice >= bTodayFirstPrice){   
                                if(_bsellFee==30){ 
                                    uint256 cha=(productRio *(newPice - bTodayFirstPrice)) / bTodayFirstPrice;
                                    zidi=cha;
                                    if(cha >= 0.1*10**18){
                                        _bsellFee=10;
                                    } 
                                }
                        }else{ 
                                if(_bsellFee==10){ 
                                    uint256 cha=(productRio *(bTodayFirstPrice -newPice)) / bTodayFirstPrice;
                                    zidi=cha;
                                    if(cha >= 0.1*10**18){
                                        _bsellFee=30;
                                    } 
                                }
                        }
                    }else{ 
                        zidi=2;
                        if(newPice !=0){
                            bLastYear=year;
                            bLastMonth=month;
                            bLastDay=day;
                            bTodayFirstPrice=newPice;
                        }
                        _bsellFee=10;
                    }
                    if(_bsellFee==10){
                        recipientRate = 10000 -
                        _sellFlowFee -
                        _sellBurnFee;
                        _takeSlippageFee(sender,address(foundationAddress),tAmount.div(10000).mul(_sellFlowFee));
                        _takeburnFee(sender, tAmount.div(10000).mul(_sellBurnFee));
                    }else{
                        recipientRate = 10000 -
                        _sellFlowFee1 -
                        _sellLPFee1 -
                        _sellBurnFee1;
                        _takeSlippageFee(sender,address(foundationAddress),tAmount.div(10000).mul(_sellFlowFee1));
                        _takeSlippageFee(sender,address(foundationAddress),tAmount.div(10000).mul(_sellLPFee1));
                        _takeburnFee(sender, tAmount.div(10000).mul(_sellBurnFee1));
                    }
                    _tOwned[recipient] = _tOwned[recipient].add(
                        tAmount.div(10000).mul(recipientRate)
                    );
                    emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));   
            }else{  //LYC-USDT
                 if(uLastYear== year && uLastMonth==month && uLastDay==day){  
                        zidi=1;
                        if(newPice==0 || uTodayFirstPrice==0){
                            newPice=1;
                            uTodayFirstPrice=1;
                        }
                        if(newPice >= uTodayFirstPrice){   
                                if(_usellFee==30){ 
                                    uint256 cha=(productRio *(newPice - uTodayFirstPrice)) / uTodayFirstPrice;
                                    zidi=cha;
                                    if(cha >= 0.1*10**18){
                                        _usellFee=10;
                                    } 
                                }
                        }else{  
                                if(_usellFee==10){ 
                                    uint256 cha=(productRio *(uTodayFirstPrice -newPice)) / uTodayFirstPrice;
                                    zidi=cha;
                                    if(cha >= 0.1*10**18){
                                        _usellFee=30;
                                    } 
                                }
                        }
                }else{ 
                    zidi=2;
                    if(newPice !=0){
                        uLastYear=year;
                        uLastMonth=month;
                        uLastDay=day;
                        uTodayFirstPrice=newPice;
                    }
                    _usellFee=10;
                }
                if(_usellFee==10){
                    recipientRate = 10000 -
                    _sellFlowFee -
                    _sellBurnFee;
                     _takeSlippageFee(sender,address(foundationAddress),tAmount.div(10000).mul(_sellFlowFee));
                    _takeburnFee(sender, tAmount.div(10000).mul(_sellBurnFee));
                }else{
                     recipientRate = 10000 -
                    _sellFlowFee1 -
                    _sellLPFee1 -
                    _sellBurnFee1;
                    _takeSlippageFee(sender,address(foundationAddress),tAmount.div(10000).mul(_sellFlowFee1));
                    _takeSlippageFee(sender,address(foundationAddress),tAmount.div(10000).mul(_sellLPFee1));
                     _takeburnFee(sender, tAmount.div(10000).mul(_sellBurnFee1));
                }
                 _tOwned[recipient] = _tOwned[recipient].add(
                    tAmount.div(10000).mul(recipientRate)
                );
                emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));   
            }
        }else { 
              _tOwned[recipient] = _tOwned[recipient].add(tAmount);
               emit Transfer(sender, recipient, tAmount);
        }

    }

    function _takeSlippageFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        emit Transfer(sender,recipient , tAmount);
    }

    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }


    function _takeLPFee(address sender,uint256 tAmount) private {
        if (_LPFee == 0 && _satFee ==0) return;
        _tOwned[address(this)] = _tOwned[address(this)].add(tAmount);
        emit Transfer(sender, address(this), tAmount);
    }


  
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        // emit AddLp(path[0], path[1]);//这里错误后面解开
    }

    function swapEthForToken(uint256 ethAmount,address receiver) private{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        IERC20 TestE = IERC20(0xD36f3317987ee23de1078640eDF3015744f71b5D);//sat代币地址--
        path[1] = address(TestE);//代币地址
        path[0] = uniswapV2Router.WETH();//主币地址

        // make the swap
        uniswapV2Router.swapExactETHForTokens{value:ethAmount}(
            0, // accept any amount of token
            path,
            receiver,
            block.timestamp
        );

        // emit AddLp(path[0], path[1]);//这里错误后面解开
    }

    function swapThisTokenForToken(uint256 thisTokenAmount,address receiver) private{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        IERC20 SAT = IERC20(0xD36f3317987ee23de1078640eDF3015744f71b5D);//sat代币地址--
        path[0] = address(this);//本币地址
        path[1] = address(SAT);//代币地址
        

        _approve(address(this), address(uniswapV2Router), thisTokenAmount);
        
        // make the swap
        uniswapV2Router.swapExactTokensForTokens(
            thisTokenAmount,
            0, // accept any amount of token
            path,
            receiver,
            block.timestamp
        );

    }


}