// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./utils/Babylonian.sol";
import "./interfaces/IBeefyVault.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IBeefyZap.sol";
import "./interfaces/IFactory.sol";

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract PeghubZap is Context {
    modifier onlyOwner() {
        require(dev == _msgSender(), "operator: caller is not the operator");
        _;
    }

    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    struct VaultInfo {
        IBeefyVault beefyVault; // Address of vault.
        address wantAddress; // Address of LP pair for vault.
        address zapToken; // Address of other asset in pair.
        address zapTokenIntermediary; // Address of intermediate asset in pair.
        address zapTokenPair; // Address of basetoken pair.
        IRouter zapTokenRouter; // Address of router to get the base token
        bool isEnabled;
    }

    struct TokenInfo {
        IERC20 token; // Address of token.
        IUniswapV2Pair pairAddress; // Address of LP pair.
        address tokenRouter; // Address of alternative router
        bool isEnabled;
    }

    IRouter public pcsRouter;
    address public WETH;
    address public feeReceiver;
    IBeefyZap public beefyUniV2Zap;
    address public dev;

    uint256 public totalVaults;
    uint256 public totalInputTokens;

    TokenInfo[] public inputTokens;

    VaultInfo[] public vaultInfo;

    mapping(address => uint256) private zapTokenLookup;

    mapping(address => uint256) private tokenLookup;

    mapping(address => uint256) private vaultLookup;

    constructor(address _dev, address _beefyUniZapV2) {
        dev = _dev;
        WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        pcsRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        beefyUniV2Zap = IBeefyZap(_beefyUniZapV2);
        feeReceiver = _dev;
        totalVaults = 0;
        totalInputTokens = 0;
    }

    receive() external payable {}

    function beefOutAndSwap(
        address beefyVault,
        uint256 withdrawAmount,
        address desiredToken,
        uint256 desiredTokenOutMin
    ) external {
        (IBeefyVault vault, address want) = _getVaultPair(beefyVault);

        vault.transferFrom(msg.sender, address(this), withdrawAmount);

        VaultInfo memory basePairInfo = vaultInfo[vaultLookup[beefyVault]];
        address zapToken = basePairInfo.zapToken;
        if (basePairInfo.zapToken == want) {
            vault.withdraw(withdrawAmount);
        } else {
            _approveTokenIfNeeded(beefyVault, address(beefyUniV2Zap));
            beefyUniV2Zap.beefOutAndSwap(
                beefyVault,
                withdrawAmount,
                zapToken,
                0
            );
            if (zapToken == WETH) {
                IWETH(WETH).deposit{value: address(this).balance}();
            }
            if (desiredToken != zapToken) {
                uint256 swapAmount = IERC20(zapToken).balanceOf(address(this));
                swap(desiredToken, 0, zapToken, swapAmount);
            }
            // IUniswapV2Pair pair = IUniswapV2Pair(want);
            // address token0 = pair.token0();
            // address token1 = pair.token1();
            // require(
            //     token0 == desiredToken || token1 == desiredToken,
            //     "Beefy: desired token not present in liqudity pair"
            // );
            uint256 desiredTokenBalance = IERC20(desiredToken).balanceOf(
                address(this)
            );
            require(
                desiredTokenBalance >= desiredTokenOutMin,
                "not enough desired token balance"
            );
            IERC20(desiredToken).transfer(_msgSender(), desiredTokenBalance);
        }
    }

    function beefInETH(address beefyVault, uint256 tokenAmountOutMin)
        external
        payable
    {
        IWETH(WETH).deposit{value: msg.value}();
        uint256 _baseBalance = IERC20(WETH).balanceOf(address(this));
        _swapAndStake(beefyVault, tokenAmountOutMin, WETH, _baseBalance);
    }

    function beefIn(
        address beefyVault,
        uint256 tokenAmountOutMin,
        address tokenIn,
        uint256 tokenInAmount
    ) public {
        require(tokenInAmount >= 1000, "PegHubzap: Insignificant input amount");
        IERC20(tokenIn).transferFrom(
            _msgSender(),
            address(this),
            tokenInAmount
        );
        _swapAndStake(beefyVault, tokenAmountOutMin, tokenIn, tokenInAmount);
    }

    function _swapAndStake(
        address beefyVault,
        uint256 tokenAmountOutMin,
        address tokenIn,
        uint256 tokenInAmount
    ) internal {
        (IBeefyVault vault, address want) = _getVaultPair(beefyVault);
        VaultInfo memory basePairInfo = vaultInfo[vaultLookup[beefyVault]];
        address zapToken = basePairInfo.zapToken;
        uint256 _baseBalance;
        // This means this is a single stake
        if (zapToken == want) {
            if (tokenIn != zapToken) {
                _baseBalance = swap(zapToken, 0, tokenIn, tokenInAmount);
            } else {
                _baseBalance = tokenInAmount;
            }
            _approveTokenIfNeeded(want, address(vault));
            vault.deposit(_baseBalance);
            // } else if (tokenIn == zapToken) {
            //     beefyUniV2Zap.beefIn(
            //         beefyVault,
            //         tokenAmountOutMin,
            //         zapToken,
            //         tokenInAmount
            //     );
        } else {
            _baseBalance = swap(zapToken, 0, tokenIn, tokenInAmount);
            _approveTokenIfNeeded(zapToken, address(beefyUniV2Zap));
            beefyUniV2Zap.beefIn(
                beefyVault,
                tokenAmountOutMin,
                zapToken,
                _baseBalance
            );
        }
        vault.transfer(_msgSender(), vault.balanceOf(address(this)));
        address[] memory _returnAssetTokens;
        if (zapToken != want) {
            IUniswapV2Pair _pairAddress = IUniswapV2Pair(
                basePairInfo.wantAddress
            );
            _returnAssetTokens = new address[](2);
            _returnAssetTokens[0] = _pairAddress.token0();
            _returnAssetTokens[1] = _pairAddress.token1();
        } else {
            _returnAssetTokens = new address[](1);
            _returnAssetTokens[0] = zapToken;
        }
        _returnAssets(_returnAssetTokens);
    }

    function swap(
        address tokenOut,
        uint256 tokenAmountOutMin,
        address tokenIn,
        uint256 tokenInAmount
    ) public returns (uint256 _baseBalance) {
        if (tokenIn != tokenOut) {
            _swap(tokenOut, tokenAmountOutMin, tokenIn, tokenInAmount);
        }
        uint256 baseBalance = IERC20(tokenOut).balanceOf(address(this));

        if (baseBalance > 0) {
            uint256 baseFeeTotal = baseBalance.mul(5).div(1000);
            IERC20(tokenOut).safeTransfer(feeReceiver, baseFeeTotal);
            _baseBalance = baseBalance.sub(baseFeeTotal);
        } else {
            _baseBalance = 0;
        }
    }

    function _returnAssets(address[] memory tokens) private {
        uint256 balance;
        for (uint256 i; i < tokens.length; i++) {
            balance = IERC20(tokens[i]).balanceOf(address(this));
            if (balance > 0) {
                if (tokens[i] == WETH) {
                    IWETH(WETH).withdraw(balance);
                    (bool success, ) = _msgSender().call{value: balance}(
                        new bytes(0)
                    );
                    require(success, "Beefy: ETH transfer failed");
                } else {
                    IERC20(tokens[i]).safeTransfer(_msgSender(), balance);
                }
            }
        }
    }

    function estimateSwap(
        address beefyVault,
        address tokenIn,
        uint256 fullInvestmentIn
    )
        public
        view
        returns (
            uint256 swapAmountIn,
            uint256 swapAmountOut,
            address swapTokenOut
        )
    {
        // Dont need this if source token is WETH

        VaultInfo memory basePairInfo = vaultInfo[vaultLookup[beefyVault]];
        address zapToken = basePairInfo.zapToken;
        uint256 zapTokenAmount;
        if (tokenIn == WETH) {
            if (zapToken == WETH) {
                zapTokenAmount = fullInvestmentIn;
            } else {
                zapTokenAmount = estimateSwapToBaseToken(
                    WETH,
                    zapToken,
                    fullInvestmentIn
                );
            }
        } else if (tokenIn == zapToken) {
            zapTokenAmount = fullInvestmentIn;
        } else if (zapToken == WETH) {
            zapTokenAmount = estimateSwapToWETH(tokenIn, fullInvestmentIn);
        } else {
            zapTokenAmount = estimateSwapToBaseToken(
                tokenIn,
                zapToken,
                fullInvestmentIn
            );
        }

        (swapAmountIn, swapAmountOut, swapTokenOut) = beefyUniV2Zap
            .estimateSwap(beefyVault, zapToken, zapTokenAmount);
    }

    function estimateSwapToWETH(address tokenIn, uint256 fullInvestmentIn)
        public
        view
        returns (uint256)
    {
        TokenInfo memory tokenInfo = inputTokens[tokenLookup[tokenIn]];
        IUniswapV2Pair pair = tokenInfo.pairAddress;
        bool isInputA = pair.token0() == tokenIn;
        require(
            isInputA || pair.token1() == tokenIn,
            "PegHubZap: Input token not present in liqudity pair"
        );
        (uint256 reserveA, uint256 reserveB, ) = pair.getReserves();
        (reserveA, reserveB) = isInputA
            ? (reserveA, reserveB)
            : (reserveB, reserveA);

        return
            _getQuote(fullInvestmentIn, reserveA, reserveB, address(pcsRouter));
    }

    function estimateSwapToBaseToken(
        address tokenIn,
        address beefyVault,
        uint256 fullInvestmentIn
    ) public view returns (uint256) {
        uint256 wethAmount;

        if (tokenIn == WETH) {
            wethAmount = fullInvestmentIn;
        } else {
            TokenInfo memory tokenInfo = inputTokens[tokenLookup[tokenIn]];
            IUniswapV2Pair pair = tokenInfo.pairAddress;
            bool isInputA = pair.token0() == tokenIn;
            require(
                isInputA || pair.token1() == tokenIn,
                "PegHubZap: Input token not present in input pair"
            );
            (uint256 reserveA, uint256 reserveB, ) = pair.getReserves();
            (reserveA, reserveB) = isInputA
                ? (reserveA, reserveB)
                : (reserveB, reserveA);

            wethAmount = _getQuote(
                fullInvestmentIn,
                reserveA,
                reserveB,
                address(pcsRouter)
            );
        }

        VaultInfo memory basePairInfo = vaultInfo[vaultLookup[beefyVault]];
        address zapToken = basePairInfo.zapToken;
        IUniswapV2Pair basePair = IUniswapV2Pair(basePairInfo.zapTokenPair);
        bool isBaseInputA = basePair.token1() == zapToken;
        require(
            isBaseInputA || basePair.token0() == zapToken,
            "PegHubZap: Input token not present in liqudity pair"
        );
        (uint256 baseReserveA, uint256 baseReserveB, ) = basePair.getReserves();
        (baseReserveA, baseReserveB) = isBaseInputA
            ? (baseReserveA, baseReserveB)
            : (baseReserveB, baseReserveA);

        return
            _getQuote(
                wethAmount,
                baseReserveA,
                baseReserveB,
                address(basePairInfo.zapTokenRouter)
            );
    }

    /** wallet addresses setters **/
    function transferDev(address value) public onlyOwner {
        dev = value;
    }

    // Add a new token to the pool. Can only be called by the owner.
    function addVault(
        address _beefyVault,
        address _zapToken,
        address _zapTokenIntermediary,
        address _zapTokenRouter,
        bool _isEnabled
    ) public onlyOwner {
        checkVaultDuplicate(_beefyVault);

        (IBeefyVault vault, address want) = _getVaultPair(_beefyVault);
        address zapTokenPair;
        address zapTokenRouter;
        if (_zapToken == want) {
            zapTokenPair = address(0);
        } else {
            address _factory = IRouter(_zapTokenRouter).factory();
            zapTokenPair = IFactory(_factory).getPair(WETH, _zapToken);
        }
        zapTokenRouter = _zapTokenRouter;
        VaultInfo memory _vaultInfo = VaultInfo({
            beefyVault: vault,
            wantAddress: want,
            zapToken: _zapToken,
            zapTokenIntermediary: _zapTokenIntermediary,
            zapTokenPair: zapTokenPair,
            zapTokenRouter: IRouter(zapTokenRouter),
            isEnabled: _isEnabled
        });
        vaultInfo.push(_vaultInfo);
        zapTokenLookup[_zapToken] = totalVaults;
        vaultLookup[_beefyVault] = totalVaults;
        // give allowance to the right contract
        if (_zapToken == want) {
            _giveAllowance(want, _beefyVault);
        } else {
            _giveAllowance(_zapToken, address(beefyUniV2Zap));
        }
        totalVaults++;
    }

    // Add a new token to to be used as input. Can only be called by the owner.
    function addToken(
        address _token,
        address _tokenRouter,
        bool _isEnabled
    ) public onlyOwner {
        checkTokenDuplicate(_token);
        address pair;
        if (_token == WETH) {
            pair = address(0);
        } else {
            address _factory = IRouter(_tokenRouter).factory();
            pair = IFactory(_factory).getPair(WETH, _token);
        }

        TokenInfo memory _tokenInfo = TokenInfo({
            token: IERC20(_token),
            tokenRouter: _tokenRouter,
            pairAddress: IUniswapV2Pair(pair),
            isEnabled: _isEnabled
        });
        inputTokens.push(_tokenInfo);
        tokenLookup[_token] = totalInputTokens;
        _giveAllowance(_token, address(pcsRouter));
        totalInputTokens++;
    }

    function setPcsRouter(address _pcsRouter) external onlyOwner {
        pcsRouter = IRouter(_pcsRouter);
    }

    function setBeefyUniV2Zap(address _beefyUniV2Zap) external onlyOwner {
        beefyUniV2Zap = IBeefyZap(_beefyUniV2Zap);
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        feeReceiver = _feeReceiver;
    }

    function _swap(
        address tokenOut,
        uint256 tokenAmountOutMin,
        address tokenIn,
        uint256 tokenInAmount
    ) internal returns (uint256[] memory amounts) {
        uint256 wethAmount;

        if (tokenIn == WETH) {
            wethAmount = tokenInAmount;
        } else {
            TokenInfo memory tokenInfo = inputTokens[tokenLookup[tokenIn]];
            IUniswapV2Pair pair = tokenInfo.pairAddress;
            bool isInputA = pair.token0() == tokenIn;
            require(
                isInputA || pair.token1() == tokenIn,
                "PegHubZap: Input token not present in input pair"
            );
            address[] memory path;
            // if (tokenInfo.tokenIntermediary != address(0)) {
            //     path = new address[](3);
            //     path[0] = WETH;
            //     path[1] = tokenInfo.tokenIntermediary;
            //     path[2] = tokenOut;
            // } else {
            IRouter tokenInRouter = IRouter(tokenInfo.tokenRouter);
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = WETH;
            // }
            _approveTokenIfNeeded(path[0], address(tokenInRouter));
            amounts = tokenInRouter.swapExactTokensForTokens(
                tokenInAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
            wethAmount = IERC20(WETH).balanceOf(address(this));
        }
        VaultInfo memory basePairInfo = vaultInfo[zapTokenLookup[tokenOut]];

        if (tokenOut != WETH) {
            IRouter baseRouter = basePairInfo.zapTokenRouter;
            address[] memory basePath;
            if (basePairInfo.zapTokenIntermediary != address(0)) {
                basePath = new address[](3);
                basePath[0] = WETH;
                basePath[1] = basePairInfo.zapTokenIntermediary;
                basePath[2] = tokenOut;
            } else {
                basePath = new address[](2);
                basePath[0] = WETH;
                basePath[1] = tokenOut;
            }

            _approveTokenIfNeeded(basePath[0], address(baseRouter));
            amounts = baseRouter.swapExactTokensForTokens(
                wethAmount,
                tokenAmountOutMin,
                basePath,
                address(this),
                block.timestamp
            );
        }
    }

    function _giveAllowance(address _address, address _router) internal {
        IERC20(_address).approve(_router, 0);
        IERC20(_address).approve(_router, uint256(1e50));
    }

    function _removeAllowance(address _address, address _router) internal {
        IERC20(_address).approve(_router, 0);
    }

    function _approveTokenIfNeeded(address token, address spender) private {
        if (IERC20(token).allowance(address(this), spender) == 0) {
            IERC20(token).approve(spender, type(uint256).max);
        }
    }

    function _getVaultPair(address beefyVault)
        private
        pure
        returns (IBeefyVault vault, address pair)
    {
        vault = IBeefyVault(beefyVault);
        pair = vault.want();
    }

    function _getSwapAmount(
        uint256 investmentA,
        uint256 reserveA,
        uint256 reserveB,
        address router
    ) private pure returns (uint256 swapAmount) {
        uint256 halfInvestment = investmentA / 2;
        uint256 nominator = IRouter(router).getAmountOut(
            halfInvestment,
            reserveA,
            reserveB
        );
        uint256 denominator = IRouter(router).quote(
            halfInvestment,
            reserveA.add(halfInvestment),
            reserveB.sub(nominator)
        );
        swapAmount = investmentA.sub(
            Babylonian.sqrt(
                (halfInvestment * halfInvestment * nominator) / denominator
            )
        );
    }

    function _getQuote(
        uint256 investmentA,
        uint256 reserveA,
        uint256 reserveB,
        address router
    ) private pure returns (uint256 amountB) {
        amountB = IRouter(router).quote(investmentA, reserveA, reserveB);
    }

    function checkVaultDuplicate(address _beefyVault) internal view {
        uint256 length = totalVaults;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(
                address(vaultInfo[pid].beefyVault) != _beefyVault,
                "PeghubZap: existing vault?"
            );
        }
    }

    function checkTokenDuplicate(address _token) internal view {
        uint256 length = totalInputTokens;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(
                address(inputTokens[pid].token) != _token,
                "PeghubZap: existing token?"
            );
        }
    }
}

pragma solidity 0.8.9;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBeefyVault is IERC20 {
    function deposit(uint256 amount) external;

    function withdraw(uint256 shares) external;

    function want() external pure returns (address);
}

pragma solidity 0.8.9;

// SPDX-License-Identifier: MIT

interface IBeefyZap {
    function beefIn(
        address beefyVault,
        uint256 tokenAmountOutMin,
        address tokenIn,
        uint256 tokenInAmount
    ) external;

    function estimateSwap(
        address beefyVault,
        address tokenIn,
        uint256 fullInvestmentIn
    )
        external
        view
        returns (
            uint256 swapAmountIn,
            uint256 swapAmountOut,
            address swapTokenOut
        );

    function beefOutAndSwap(
        address beefyVault,
        uint256 withdrawAmount,
        address desiredToken,
        uint256 desiredTokenOutMin
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IFactory {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IRouter {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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

pragma solidity 0.8.9;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

library Babylonian {
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0
    }
}