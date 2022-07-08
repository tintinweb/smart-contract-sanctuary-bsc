/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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

interface IUniswapV2Router02 {
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

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external
        returns (
            uint256[] memory amounts
        );

    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) external view
        returns (
            uint[] memory amounts
        );

    function getAmountsIn(
        uint amountOut,
        address[] memory path
    ) external view
        returns (
            uint[] memory amounts
        );
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);
}

interface IEconomyBond {
    function reserveBalance(
        address tokenAddress
    ) external view returns (
        uint256 reserveBalance
    );

    function getMusingReward(
        address tokenAddress,
        uint256 reserveAmount
    ) external view returns (
        uint256 toMint, // token amount to be minted
        uint256 taxAmount
    );

    function getBurnRefund(
        address tokenAddress,
        uint256 tokenAmount
    ) external view returns (
        uint256 mintToRefund,
        uint256 mintTokenTaxAmount
    );

    function buy(
        address tokenAddress,
        uint256 reserveAmount,
        uint256 minReward,
        address beneficiary
    ) external;

    function sell(
        address tokenAddress,
        uint256 tokenAmount,
        uint256 minRefund,
        address beneficiary
    ) external;

    function createToken(
        string memory name,
        string memory symbol,
        uint256 maxTokenSupply
    ) external returns (
        address tokenAddress
    );
}

interface IWAVAX {
    function deposit() external payable;
    function withdraw(uint) external;
}

library Math {
    /**
     * @dev returns the largest integer smaller than or equal to the square root of a positive integer
     *
     * @param _num a positive integer
     *
     * @return the largest integer smaller than or equal to the square root of the positive integer
     */
    function floorSqrt(uint256 _num) internal pure returns (uint256) {
        uint256 x = _num / 2 + 1;
        uint256 y = (x + _num / x) / 2;
        while (x > y) {
            x = y;
            y = (x + _num / x) / 2;
        }
        return x;
    }
}

/**
 * @title MusingZap v1.0.0
 */

contract MusingZap is Context {
    using SafeERC20 for IERC20;

    uint256 private constant BUY_TAX = 3;
    uint256 private constant SELL_TAX = 13;
    uint256 private constant MAX_TAX = 1000;

    address private constant DEFAULT_BENEFICIARY =
        0x292eC696dEc44222799c4e8D90ffbc1032D1b7AC;

    IUniswapV2Factory private constant PANCAKE_FACTORY =
        IUniswapV2Factory(0x6725F303b657a9451d8BA641348b6761A6CC7a17);
    IUniswapV2Router02 private constant PANCAKE_ROUTER =
        IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    IEconomyBond private constant BOND =
        IEconomyBond(0x1c743Bf869CcfE1f043A185C30aC1278ae7F7d8b);
    uint256 private constant DEAD_LINE =
        0xf000000000000000000000000000000000000000000000000000000000000000;
    address private constant WAVAX_CONTRACT =
        address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);

    constructor() {
        _approveToken(WAVAX_CONTRACT, address(BOND));
    }

    receive() external payable {}

    // Other tokens -> Economy Tokens
    function estimateZapIn(
        address from,
        address to,
        uint256 fromAmount
    )
        external
        view
        returns (uint256 tokensToReceive, uint256 mintTokenTaxAmount)
    {
        uint256 mintAmount;

        if (from == WAVAX_CONTRACT) {
            mintAmount = fromAmount;
        } else {
            address[] memory path = _getPathToWavax(from);

            mintAmount = PANCAKE_ROUTER.getAmountsOut(fromAmount, path)[
                path.length - 1
            ];
        }

        return BOND.getMusingReward(to, mintAmount);
    }

    function estimateZapInInitial(address from, uint256 fromAmount)
        external
        view
        returns (uint256 tokensToReceive, uint256 mintTokenTaxAmount)
    {
        uint256 mintAmount;

        if (from == WAVAX_CONTRACT) {
            mintAmount = fromAmount;
        } else {
            address[] memory path = _getPathToWavax(from);

            mintAmount = PANCAKE_ROUTER.getAmountsOut(fromAmount, path)[
                path.length - 1
            ];
        }

        uint256 taxAmount = (mintAmount * BUY_TAX) / MAX_TAX;
        uint256 newSupply = Math.floorSqrt(20 * 1e18 * (mintAmount - taxAmount));

        return (newSupply, taxAmount);
    }

    // Get required WAVAX token amount to buy X amount of Economy tokens
    function getReserveAmountToBuy(address tokenAddress, uint256 tokensToBuy)
        public
        view
        returns (uint256)
    {
        IERC20 token = IERC20(tokenAddress);

        uint256 newTokenSupply = token.totalSupply() + tokensToBuy;
        uint256 reserveRequired = (newTokenSupply**2 - token.totalSupply()**2) /
            (20 * 1e18);
        reserveRequired = (reserveRequired * MAX_TAX) / (MAX_TAX - BUY_TAX); // Deduct tax amount

        return reserveRequired;
    }

    // WAVAX and others -> Economy Tokens (parameter)
    function estimateZapInReverse(
        address from,
        address to,
        uint256 tokensToReceive
    )
        external
        view
        returns (uint256 fromAmountRequired, uint256 wavaxTokenTaxAmount)
    {
        uint256 reserveRequired = getReserveAmountToBuy(to, tokensToReceive);

        if (from == WAVAX_CONTRACT) {
            fromAmountRequired = reserveRequired;
        } else {
            address[] memory path = _getPathToWavax(from);

            fromAmountRequired = PANCAKE_ROUTER.getAmountsIn(
                reserveRequired,
                path
            )[0];
        }

        wavaxTokenTaxAmount = (reserveRequired * BUY_TAX) / MAX_TAX;
    }

    function estimateZapInReverseInitial(address from, uint256 tokensToReceive)
        external
        view
        returns (uint256 fromAmountRequired, uint256 wavaxTokenTaxAmount)
    {
        uint256 reserveRequired = tokensToReceive**2 / 20e18;

        if (from == WAVAX_CONTRACT) {
            fromAmountRequired = reserveRequired;
        } else {
            address[] memory path = _getPathToWavax(from);

            fromAmountRequired = PANCAKE_ROUTER.getAmountsIn(
                reserveRequired,
                path
            )[0];
        }

        wavaxTokenTaxAmount = (reserveRequired * BUY_TAX) / MAX_TAX;
    }

    // Economy Tokens (parameter) -> WAVAX and others
    function estimateZapOut(
        address from,
        address to,
        uint256 fromAmount
    )
        external
        view
        returns (uint256 toAmountToReceive, uint256 wavaxTokenTaxAmount)
    {
        uint256 wavaxToRefund;
        (wavaxToRefund, wavaxTokenTaxAmount) = BOND.getBurnRefund(
            from,
            fromAmount
        );

        if (to == WAVAX_CONTRACT) {
            toAmountToReceive = wavaxToRefund;
        } else {
            address[] memory path = _getPathFromWavax(to);

            toAmountToReceive = PANCAKE_ROUTER.getAmountsOut(
                wavaxToRefund,
                path
            )[path.length - 1];
        }
    }

    // Get amount of Economy tokens to receive X amount of WAVAX tokens
    function getTokenAmountFor(address tokenAddress, uint256 wavaxTokenAmount)
        public
        view
        returns (uint256)
    {
        IERC20 token = IERC20(tokenAddress);

        uint256 reserveAfterSell = BOND.reserveBalance(tokenAddress) -
            wavaxTokenAmount;
        uint256 supplyAfterSell = Math.floorSqrt(20 * 1e18 * reserveAfterSell);

        return token.totalSupply() - supplyAfterSell;
    }

    // Economy Tokens -> WAVAX and others (parameter)
    function estimateZapOutReverse(
        address from,
        address to,
        uint256 toAmount
    )
        external
        view
        returns (uint256 tokensRequired, uint256 wavaxTokenTaxAmount)
    {
        uint256 wavaxTokenAmount;
        if (to == WAVAX_CONTRACT) {
            wavaxTokenAmount = toAmount;
        } else {
            address[] memory path = _getPathFromWavax(to);
            wavaxTokenAmount = PANCAKE_ROUTER.getAmountsIn(toAmount, path)[0];
        }

        wavaxTokenTaxAmount = (wavaxTokenAmount * SELL_TAX) / MAX_TAX;
        tokensRequired = getTokenAmountFor(
            from,
            wavaxTokenAmount + wavaxTokenTaxAmount
        );
    }

    function zapInAVAX(
        address to,
        uint256 minAmountOut,
        address beneficiary
    ) public payable {
        uint256 mintAmount = msg.value;
        // Wrap AVAX to WAVAX
        IWAVAX(WAVAX_CONTRACT).deposit{value: mintAmount}();

        // Buy target tokens with swapped WAVAX
        _buyWavaxTokenAndSend(
            to,
            mintAmount,
            minAmountOut,
            _getBeneficiary(beneficiary)
        );
    }

    function zapIn(
        address from,
        address to,
        uint256 amountIn,
        uint256 minAmountOut,
        address beneficiary
    ) public {
        // First, pull tokens to this contract
        IERC20 token = IERC20(from);
        require(
            token.allowance(_msgSender(), address(this)) >= amountIn,
            "NOT_ENOUGH_ALLOWANCE"
        );
        IERC20(from).safeTransferFrom(_msgSender(), address(this), amountIn);

        // Swap to WAVAX if necessary
        uint256 mintAmount;
        if (from == WAVAX_CONTRACT) {
            mintAmount = amountIn;
        } else {
            mintAmount = _swap(from, WAVAX_CONTRACT, amountIn);
        }

        // Finally, buy target tokens with swapped WAVAX
        _buyWavaxTokenAndSend(
            to,
            mintAmount,
            minAmountOut,
            _getBeneficiary(beneficiary)
        );
    }

    function createAndZapIn(
        string memory name,
        string memory symbol,
        uint256 maxTokenSupply,
        address token,
        uint256 tokenAmount,
        uint256 minAmountOut,
        address beneficiary
    ) external {
        address newToken = BOND.createToken(name, symbol, maxTokenSupply);

        // We need `minAmountOut` here token->WAVAX can be front ran and slippage may happen
        zapIn(
            token,
            newToken,
            tokenAmount,
            minAmountOut,
            _getBeneficiary(beneficiary)
        );
    }

    function createAndZapInAVAX(
        string memory name,
        string memory symbol,
        uint256 maxTokenSupply,
        uint256 minAmountOut,
        address beneficiary
    ) external payable {
        address newToken = BOND.createToken(name, symbol, maxTokenSupply);

        zapInAVAX(newToken, minAmountOut, _getBeneficiary(beneficiary));
    }

    function zapOut(
        address from,
        address to,
        uint256 amountIn,
        uint256 minAmountOut,
        address beneficiary
    ) external {
        uint256 mintAmount = _receiveAndSwapToWavax(
            from,
            amountIn,
            _getBeneficiary(beneficiary)
        );

        // Swap to WAVAX if necessary
        IERC20 toToken;
        uint256 amountOut;
        if (to == WAVAX_CONTRACT) {
            toToken = IERC20(WAVAX_CONTRACT);
            amountOut = mintAmount;
        } else {
            toToken = IERC20(to);
            amountOut = _swap(WAVAX_CONTRACT, to, mintAmount);
        }

        // Check slippage limit
        require(amountOut >= minAmountOut, "ZAP_SLIPPAGE_LIMIT_EXCEEDED");

        // Send the token to the user
        require(
            toToken.transfer(_msgSender(), amountOut),
            "BALANCE_TRANSFER_FAILED"
        );
    }

    function zapOutAVAX(
        address from,
        uint256 amountIn,
        uint256 minAmountOut,
        address beneficiary
    ) external {
        uint256 amountOut = _receiveAndSwapToWavax(
            from,
            amountIn,
            _getBeneficiary(beneficiary)
        );

        // Unwrap wavax to avax
        IWAVAX(WAVAX_CONTRACT).withdraw(amountOut);

        // Check slippage limit
        require(amountOut >= minAmountOut, "ZAP_SLIPPAGE_LIMIT_EXCEEDED");

        // TODO: FIXME!!!!!

        // Send AVAX to user
        (bool sent, ) = _msgSender().call{value: amountOut}("");
        require(sent, "AVAX_TRANSFER_FAILED");
    }

    function _buyWavaxTokenAndSend(
        address tokenAddress,
        uint256 mintAmount,
        uint256 minAmountOut,
        address beneficiary
    ) internal {
        // Finally, buy target tokens with swapped WAVX (can be reverted due to slippage limit)
        BOND.buy(
            tokenAddress,
            mintAmount,
            minAmountOut,
            _getBeneficiary(beneficiary)
        );

        // BOND.buy doesn't return any value, so we need to calculate the purchased amount
        IERC20 token = IERC20(tokenAddress);
        require(
            token.transfer(_msgSender(), token.balanceOf(address(this))),
            "BALANCE_TRANSFER_FAILED"
        );
    }

    function _receiveAndSwapToWavax(
        address from,
        uint256 amountIn,
        address beneficiary
    ) internal returns (uint256) {
        // First, pull tokens to this contract
        IERC20 token = IERC20(from);
        require(
            token.allowance(_msgSender(), address(this)) >= amountIn,
            "NOT_ENOUGH_ALLOWANCE"
        );
        IERC20(from).safeTransferFrom(_msgSender(), address(this), amountIn);

        // Approve infinitely to this contract
        if (token.allowance(address(this), address(BOND)) < amountIn) {
            require(
                token.approve(
                    address(BOND),
                    0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
                ),
                "APPROVE_FAILED"
            );
        }

        // Sell tokens to WAVAX
        // NOTE: ignore minRefund (set as 0) for now, we should check it later on zapOut
        BOND.sell(from, amountIn, 0, _getBeneficiary(beneficiary));
        IERC20 wavaxToken = IERC20(WAVAX_CONTRACT);

        return wavaxToken.balanceOf(address(this));
    }

    function _getPathToWavax(address from)
        internal
        pure
        returns (address[] memory path)
    {
        path = new address[](2);
        path[0] = from;
        path[1] = WAVAX_CONTRACT;
    }

    function _getPathFromWavax(address to)
        internal
        pure
        returns (address[] memory path)
    {
        path = new address[](2);
        path[0] = WAVAX_CONTRACT;
        path[1] = to;
    }

    function _approveToken(address tokenAddress, address spender) internal {
        IERC20 token = IERC20(tokenAddress);
        if (token.allowance(address(this), spender) > 0) {
            return;
        } else {
            token.safeApprove(spender, type(uint256).max);
        }
    }

    /**
        @notice This function is used to swap ERC20 <> ERC20
        @param from The token address to swap from.
        @param to The token address to swap to.
        @param amount The amount of tokens to swap
        @return boughtAmount The quantity of tokens bought
    */
    function _swap(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256 boughtAmount) {
        if (from == to) {
            return amount;
        }

        _approveToken(from, address(PANCAKE_ROUTER));

        address[] memory path;

        if (to == WAVAX_CONTRACT) {
            path = _getPathToWavax(from);
        } else if (from == WAVAX_CONTRACT) {
            path = _getPathFromWavax(to);
        } else {
            revert("INVALID_PATH");
        }

        // Check if there's a liquidity pool for paths
        // path.length is always 2 or 3
        for (uint8 i = 0; i < path.length - 1; i++) {
            address pair = PANCAKE_FACTORY.getPair(path[i], path[i + 1]);
            require(pair != address(0), "INVALID_SWAP_PATH");
        }

        boughtAmount = PANCAKE_ROUTER.swapExactTokensForTokens(
            amount,
            1, // amountOutMin
            path,
            address(this), // to: Recipient of the output tokens
            DEAD_LINE
        )[path.length - 1];

        require(boughtAmount > 0, "SWAP_ERROR");
    }

    // Prevent self referral
    function _getBeneficiary(address beneficiary)
        internal
        view
        returns (address)
    {
        if (beneficiary == address(0) || beneficiary == _msgSender()) {
            return DEFAULT_BENEFICIARY;
        } else {
            return beneficiary;
        }
    }
}