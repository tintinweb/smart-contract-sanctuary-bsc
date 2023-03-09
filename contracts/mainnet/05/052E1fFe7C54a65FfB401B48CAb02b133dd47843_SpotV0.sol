// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

interface IMasterChef2 {
  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
    uint256 boostMultiplier;
  }

  struct PoolInfo {
    uint256 accCakePerShare;
    uint256 lastRewardBlock;
    uint256 allocPoint;
    uint256 totalBoostedShare;
    bool isRegular;
  }

  function totalRegularAllocPoint() external view returns (uint256);

  function totalSpecialAllocPoint() external view returns (uint256);

  function cakePerBlock(bool _isRegular) external view returns (uint256 amount);

  // solhint-disable-next-line func-name-mixedcase
  function CAKE() external view returns (address);

  function poolLength() external view returns (uint256);

  function poolInfo(uint256 pool) external view returns (PoolInfo memory);

  function lpToken(uint256 pool) external view returns (address);

  function userInfo(uint256 pool, address user) external view returns (UserInfo memory);

  function pendingCake(uint256 pool, address user) external view returns (uint256);

  function deposit(uint256 pool, uint256 amount) external;

  function withdraw(uint256 pool, uint256 amount) external;

  function emergencyWithdraw(uint256 pool) external;
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// solhint-disable func-name-mixedcase
interface IUniswapV2Pair is IERC20 {
  function nonces(address owner) external view returns (uint256);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

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

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IUniswapV2Router {
  function factory() external view returns (address);

  function WETH() external view returns (address);

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

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

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

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Pair.sol";

library SafeUniswapV2Router {
  using SafeERC20 for IERC20;

  function safeSwapExactTokensForTokens(
    IUniswapV2Router router,
    uint256 amountIn,
    uint256 amountOutMin,
    address[] memory path,
    address to,
    uint256 deadline
  ) internal returns (uint256[] memory amounts) {
    if (path[0] != path[path.length - 1])
      amounts = router.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
  }

  function addAllLiquidity(
    IUniswapV2Router router,
    address tokenA,
    address tokenB,
    address to,
    uint256 deadline
  )
    internal
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256 amountA = IERC20(tokenA).balanceOf(address(this));
    if (IERC20(tokenA).allowance(address(this), address(router)) > 0) {
      IERC20(tokenA).safeApprove(address(router), 0);
    }
    IERC20(tokenA).safeApprove(address(router), amountA);

    uint256 amountB = IERC20(tokenB).balanceOf(address(this));
    if (IERC20(tokenB).allowance(address(this), address(router)) > 0) {
      IERC20(tokenB).safeApprove(address(router), 0);
    }
    IERC20(tokenB).safeApprove(address(router), amountB);

    return router.addLiquidity(tokenA, tokenB, amountA, amountB, 0, 0, to, deadline);
  }

  function removeAllLiquidity(
    IUniswapV2Router router,
    address pair,
    address to,
    uint256 deadline
  )
    internal
    returns (
      address tokenA,
      address tokenB,
      uint256 amountA,
      uint256 amountB
    )
  {
    tokenA = IUniswapV2Pair(pair).token0();
    tokenB = IUniswapV2Pair(pair).token1();

    uint256 balance = IERC20(pair).balanceOf(address(this));
    if (IERC20(pair).allowance(address(this), address(router)) > 0) {
      IERC20(pair).safeApprove(address(router), 0);
    }
    IERC20(pair).safeApprove(address(router), balance);

    (amountA, amountB) = router.removeLiquidity(tokenA, tokenB, balance, 0, 0, to, deadline);
  }
}

pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IMasterChef2.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router.sol";
import "./SafeUniswapV2Router.sol";
import "../../RDN/RDNOwnable.sol";

contract SpotV0 is RDNOwnable, IERC20 {
    using SafeERC20 for IERC20;
    using SafeUniswapV2Router for IUniswapV2Router;

    // todo
    // RDN user as owner
    // any lowlevel call by admin
    // is ERC20, only for RDN owner. Deposit / withdraw based on strategy tokens (minting/burning)
    // return remained
    // swap token0 to token0
    // swap fees support
    // safeERC20
    // BNB support
    // withdraw any
    // call any
    // restake rules
    // transfers logs to userId
    // informative name and symbol
    // owner should be active
    // deposit / withdraw without restake ??
    // APR / APY
    // StableSwap support
    // separated ERC20 implementation
    // What if NOT initRDNOwnable / basic init for implementation

    // ERC20 implementation
    mapping(uint => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    uint private _totalSupply;
    string private _name;
    string private _symbol;

    struct Swap {
        address[] path;
        uint outMin;
    }

    address public pool;
    address public router;
    address public stakingToken;
    address public rewardToken;
    uint public poolIndex;

    address public factory;

    constructor() {

    }

    function init(
        address _pool,
        address _router,
        address _stakingToken,
        address _rewardToken,
        uint _poolIndex,
        uint _ownerId,
        address _registry,
        address _factory
    ) external {
        pool = _pool;
        router = _router;
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
        poolIndex = _poolIndex;

        initRDNOwnable(_registry, _ownerId);
        factory = _factory;

        _symbol = 'SPOT0';
        _name = "SPOTv0 Share Token";
    }

    function deposit(
        uint amount,
        Swap memory swap0,
        Swap memory swap1,
        Swap memory swapReward0,
        Swap memory swapReward1,
        uint deadline
    ) public {
        address _stakingToken = stakingToken; // gas savings
        address _pool = pool; // gas savings
        uint _poolIndex = poolIndex; //gas savings

        if (IMasterChef2(pool).pendingCake(poolIndex, address(this)) > 0) {
            _restake(deadline, swapReward0, swapReward1);
        }

        // prepare to mint
        uint beforeDepositSupply = _totalSupply;
        IMasterChef2.UserInfo memory userInfo = IMasterChef2(_pool).userInfo(_poolIndex, address(this));
        uint beforeDepositBalance = userInfo.amount;

        // buy liquidity and stake
        IERC20(swap0.path[0]).safeTransferFrom(msg.sender, address(this), amount);
        _buyLiquidity(amount, swap0, swap1, deadline);
        _stake(IERC20(_stakingToken).balanceOf(address(this)));

        // mint
        userInfo = IMasterChef2(_pool).userInfo(_poolIndex, address(this));
        uint afterDepositBalance = userInfo.amount;
        uint amountToMint;
        if (beforeDepositBalance == 0) {
            amountToMint = afterDepositBalance;
        } else {
            amountToMint = ((afterDepositBalance - beforeDepositBalance) * beforeDepositSupply) / beforeDepositBalance;
        }

        _mint(ownerId, amountToMint);
    }

    function withdraw(
        uint amountToBurn,
        Swap memory swap0,
        Swap memory swap1,
        Swap memory swapReward0,
        Swap memory swapReward1,
        uint deadline
    ) public onlyRDNOwner(msg.sender) {
        address _pool = pool; // gas savings
        uint _poolIndex = poolIndex; //gas savings
        address tokenToWithdraw = swap0.path[swap0.path.length - 1];

        if (IMasterChef2(pool).pendingCake(poolIndex, address(this)) > 0) {
            _restake(deadline, swapReward0, swapReward1);
        }

        // prepare to burn
        uint beforeWithdrawSupply = _totalSupply;
        IMasterChef2.UserInfo memory userInfo = IMasterChef2(_pool).userInfo(_poolIndex, address(this));
        uint beforeWithdrawBalance = userInfo.amount;

        // sell liquidity
        // refactor to strategy tokens base calculation
        uint amountToWithdraw = ((amountToBurn * beforeWithdrawBalance)) / beforeWithdrawSupply;
        _unStake(amountToWithdraw);

        _sellLiquidity(amountToWithdraw, swap0, swap1, deadline);

        // withdraw tokens swap[0].path[swap.path.length - 1]
        IERC20(tokenToWithdraw).transfer(msg.sender, IERC20(tokenToWithdraw).balanceOf(address(this)));

        //burn
        _burn(ownerId, amountToBurn);
    }

    function callAny(address payable _addr, bytes memory _data) public payable onlyRDNOwner(msg.sender) returns(bool success, bytes memory data){
        (success, data) = _addr.call{value: msg.value}(_data);
    }
    
    function restake(
        Swap memory swapReward0,
        Swap memory swapReward1,
        uint deadline
    ) public {
        _restake(deadline, swapReward0, swapReward1);
    }

    function info() public view returns (uint, address, uint, uint) {
        address _pool = pool; // gas savings
        uint _poolIndex = poolIndex; //gas savings

        uint reward = IMasterChef2(_pool).pendingCake(_poolIndex, address(this));
        IMasterChef2.UserInfo memory userInfo = IMasterChef2(_pool).userInfo(_poolIndex, address(this));
        uint staking = userInfo.amount;

        return (poolIndex, stakingToken, reward, staking);
    }

    function _restake(
        uint deadline,
        Swap memory swap0,
        Swap memory swap1
    ) internal {
        IMasterChef2 _pool = IMasterChef2(pool); // gas savings
        IERC20 _rewardToken = IERC20(rewardToken); // gas savings

        require(_pool.pendingCake(poolIndex, address(this)) > 0, "nothing to claim");

        _pool.deposit(poolIndex, 0); // get all reward
        uint amount = _rewardToken.balanceOf(address(this));
        _buyLiquidity(amount, swap0, swap1, deadline);
        _stake(IERC20(stakingToken).balanceOf(address(this)));
    }

    function _buyLiquidity(
        uint amount,
        Swap memory swap0,
        Swap memory swap1,
        uint deadline
    ) internal returns(address token0, address token1) {
        require(swap0.path[0] == swap1.path[0], "start tokens should be equal");
        
        IUniswapV2Pair to = IUniswapV2Pair(stakingToken);

        // prepare tokens
        token0 = to.token0();
        token1 = to.token1();
        require(swap0.path[swap0.path.length - 1] == token0, "token0 is invalid");
        require(swap1.path[swap1.path.length - 1] == token1, "token1 is invalid");

        // swap input tokens
        _approve(IERC20(swap0.path[0]), address(router), amount);
        uint amount0In = amount / 2;
        _swap(amount0In, swap0.outMin, swap0.path, deadline);
        uint amount1In = amount - amount0In;
        _swap(amount1In, swap1.outMin, swap1.path, deadline);

        _addLiquidity(token0, token1, deadline);

        // todo: return remained

    }

    function _sellLiquidity(
        uint amount,
        Swap memory swap0,
        Swap memory swap1,
        uint deadline
    ) internal returns(address token0, address token1) {
        require(swap0.path[swap0.path.length-1] == swap1.path[swap1.path.length-1], "end tokens should be equal");
        
        IUniswapV2Pair from = IUniswapV2Pair(stakingToken);

        // prepare tokens / remove liquidity
        token0 = from.token0();
        token1 = from.token1();
        _removeLiquidity(amount, token0, token1, deadline);
        require(swap0.path[0] == token0, "token0 is invalid");
        require(swap1.path[0] == token1, "token1 is invalid");
        uint amount0 = IERC20(token0).balanceOf(address(this));
        uint amount1 = IERC20(token1).balanceOf(address(this));

        // swap from tokens
        _approve(IERC20(token0), address(router), amount0);
        _approve(IERC20(token1), address(router), amount1);
        _swap(amount0, swap0.outMin, swap0.path, deadline);
        _swap(amount1, swap1.outMin, swap1.path, deadline);

        // todo: return remained

    }

    function _addLiquidity(
        address token0,
        address token1,
        uint deadline
    ) internal {
        address _router = router; // gas savings
        uint amountIn0 = IERC20(token0).balanceOf(address(this));
        uint amountIn1 = IERC20(token1).balanceOf(address(this));
        _approve(IERC20(token0), _router, amountIn0);
        _approve(IERC20(token1), _router, amountIn1);
        IUniswapV2Router(_router).addLiquidity(
            token0,
            token1,
            amountIn0,
            amountIn1,
            0,
            0,
            address(this),
            deadline
        );
    }

    function _removeLiquidity(
        uint amount,
        address token0,
        address token1,
        uint deadline
    ) internal {
        address _router = router; // gas savings
        address _stakingToken = stakingToken; // gas savings

        require(amount <= IERC20(_stakingToken).balanceOf(address(this)), "not enough liquidity to remove");

        _approve(IERC20(_stakingToken), _router, amount);
        IUniswapV2Router(_router).removeLiquidity(
            token0,
            token1,
            amount,
            0,
            0,
            address(this),
            deadline
        );
    }

    function _approve(
        IERC20 token,
        address spender,
        uint amount
    ) internal {
        if (token.allowance(address(this), spender) != 0) {
            token.safeApprove(spender, 0);
        }
        token.safeApprove(spender, amount);
    }

    function _swap(
        uint amount,
        uint outMin,
        address[] memory path,
        uint deadline
    ) internal {
        if (path[0] == path[path.length - 1]) return;

        // IUniswapV2Router(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
        IUniswapV2Router(router).swapExactTokensForTokens(
            amount,
            outMin,
            path,
            address(this),
            deadline
        );
    }

    function _stake(uint amount) internal {
        _approve(IERC20(stakingToken), pool, amount);
        IMasterChef2(pool).deposit(poolIndex, amount);
    }

    function _unStake(uint amount) internal {
        IMasterChef2(pool).withdraw(poolIndex, amount);
    }


    // ERC20 implementation

    function balanceOf(address _account) public view returns (uint) {
        uint userId = IRDNRegistry(registry).getUserIdByAddress(_account);
        return _balances[userId];
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function transfer(address to, uint amount) external returns (bool) {
        return false;
    }

    function approve(address spender, uint amount) external returns (bool) {
        return false;
    }

    function transferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool) {
        return false;
    }

    function _mint(uint userId, uint amount) internal {
        address account = IRDNRegistry(registry).getUserAddress(userId);
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[userId] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(uint userId, uint amount) internal {
        address account = IRDNRegistry(registry).getUserAddress(userId);
        require(account != address(0), "ERC20: burn from zero address");

        uint accountBalance = _balances[userId];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[userId] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }


}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IRDNRegistry {
    
    struct User {
        uint level;
        address userAddress;
        uint parentId;
        uint tariff;
        uint activeUntill;
        uint created;
    }

    function getUser(uint) external view returns(User memory);

    function getUserIdByAddress(address _userAddress) external view returns(uint);

    function usersCount() external view returns(uint);
    
    function getChildren(uint _userId) external view returns(uint[] memory);

    function isRegistered(uint _userId) external view returns(bool);
    
    function isValidUser(uint _userId) external view returns(bool);
    
    function isRegisteredByAddress(address _userAddress) external view returns(bool);

    function isActive(uint _userId) external view returns(bool);

    function factorsAddress() external view returns(address);

    function getParentId(uint _userId) external view returns(uint);

    function getLevel(uint _userId) external view returns(uint);

    function getTariff(uint _userId) external view returns(uint);

    function getActiveUntill(uint _userId) external view returns(uint);

    function getUserAddress(uint _userId) external view returns(address);

    function getDistributor(address _token) external view returns(address);

    function setTariff(uint _userId, uint _tariff) external;
    
    function setActiveUntill(uint _userId, uint _activeUntill) external;

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IRDNRegistry} from "./interfaces/IRDNRegistry.sol";

contract RDNOwnable {
    address public registry;
    uint public ownerId;

    function initRDNOwnable(address _registry, uint _ownerId) internal {
        registry = _registry;
        require(IRDNRegistry(registry).isValidUser(_ownerId));
        ownerId = _ownerId;
    }

    // modifier RDNOnly(address _sender) {
    //     require(isRegistered)
    // }

    modifier onlyRDNOwner(address _userAddress) {
        require(IRDNRegistry(registry).getUserIdByAddress(_userAddress) == ownerId, "RDNOwnable: access denied");
        _;
    }

}