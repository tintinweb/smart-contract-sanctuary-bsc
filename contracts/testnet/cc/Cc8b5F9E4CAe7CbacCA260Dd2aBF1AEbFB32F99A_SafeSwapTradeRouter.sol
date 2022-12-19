//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "./interfaces/ISafeSwapRouter.sol";
import "./interfaces/IFeeJar.sol";
import "./interfaces/IERC20Extended.sol";
import "./libraries/Initializable.sol";

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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20Extended;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20Extended token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Extended token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20Extended-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Extended token,
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Extended token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Extended token,
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
    function _callOptionalReturn(IERC20Extended token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @title SafeSwapTradeRouter
 * @dev Allows SFM Router-compliant trades to be paid via bsc
 */
contract SafeSwapTradeRouter is Initializable {
    using SafeERC20 for IERC20Extended;

    /// @notice Receive function to allow contract to accept BNB
    receive() external payable {}

    /// @notice Fallback function in case receive function is not matched
    fallback() external payable {}

    /// @notice FeepJar proxy
    IFeeJar public feeJar;
    address public swapRouter;
    address public admin;

    event NewFeeJar(address _feeJar);

    /// @notice Trade details
    struct Trade {
        uint256 amountIn;
        uint256 amountOut;
        address[] path;
        address payable to;
        uint256 deadline;
    }

    modifier onlyOwner() {
        require(admin == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function initialize(address _feeJar, address _router) external initializer {
        feeJar = IFeeJar(_feeJar);
        swapRouter = _router;
        admin = msg.sender;
    }

    /**
     * @notice set SFM router address
     * @param _router Address of SFM Router contract
     */
    function setRouter(address _router) public onlyOwner {
        require(msg.sender == admin, "SafeswapRouter: NOT AUTHORIZED");
        swapRouter = _router;
    }

    /**
     * @notice set feeJar address
     * @param _feeJar Address of FeeJar contract
     */
    function setFeeJar(address _feeJar) external onlyOwner {
        feeJar = IFeeJar(_feeJar);
        emit NewFeeJar(_feeJar);
    }

    /**
     * @notice Swap tokens for BNB and pay amount of BNB as fee
     * @param trade Trade details
     */
    function swapExactTokensForETHAndFeeAmount(Trade calldata trade) external payable {
        uint256 feeAmount = getSwapFees(trade.amountIn, trade.path);
        require(msg.value >= feeAmount, "SafeswapRouter: You must send enough BNB to cover fee");
        _feeAmountBNB(feeAmount);
        _swapExactTokensForETH(trade.amountIn, trade.amountOut, trade.path, msg.sender, trade.to, trade.deadline);
    }

    /**
     * @notice Swap tokens for BNB and pay amount of BNB as fee
     * @param trade Trade details
     */
    function swapTokensForExactETHAndFeeAmount(Trade calldata trade) external payable {
        uint256 feeAmount = getSwapFees(trade.amountIn, trade.path);
        require(msg.value >= feeAmount, "SafeswapRouter: You must send enough BNB to cover fee");
        _feeAmountBNB(feeAmount);
        _swapTokensForExactETH(trade.amountOut, trade.amountIn, trade.path, msg.sender, trade.to, trade.deadline);
    }

    /**
     * @notice Swap BNB for tokens and pay % of BNB input as fee
     * @param trade Trade details
     * @param _feeAmount Fee value
     */
    function swapExactETHForTokensWithFeeAmount(Trade calldata trade, uint256 _feeAmount) external payable {
        uint256 feeAmount = getSwapFees(trade.amountIn, trade.path);
        require(
            _feeAmount >= feeAmount && (msg.value >= trade.amountIn + feeAmount),
            "SafeswapRouter: You must send enough BNB to cover fee "
        );
        _feeAmountBNB(feeAmount);
        _swapExactETHForTokens(trade.amountIn, trade.amountOut, trade.path, trade.to, trade.deadline);
    }

    /**
     * @notice Swap BNB for tokens and pay amount of BNB input as fee
     * @param trade Trade details
     * @param _feeAmount Fee value
     */
    function swapETHForExactTokensWithFeeAmount(Trade calldata trade, uint256 _feeAmount) external payable {
        uint256 feeAmount = getSwapFees(trade.amountIn, trade.path);
        require(
            _feeAmount >= feeAmount && (msg.value >= trade.amountIn + feeAmount),
            "SafeswapRouter: You must send enough BNB to cover fee "
        );
        _feeAmountBNB(feeAmount);
        _swapETHForExactTokens(trade.amountOut, trade.amountIn, trade.path, trade.to, trade.deadline);
    }

    /**
     * @notice Swap tokens for tokens and pay BNB amount as fee
     * @param trade Trade details
     */
    function swapExactTokensForTokensWithFeeAmount(Trade calldata trade) external payable {
        uint256 feeAmount = getSwapFees(trade.amountIn, trade.path);
        require(msg.value >= feeAmount, "SafeswapRouter: You must send enough BNB to cover fee ");
        _feeAmountBNB(feeAmount);
        _swapExactTokensForTokens(trade.amountIn, trade.amountOut, trade.path, msg.sender, trade.to, trade.deadline);
    }

    /**
     * @notice Swap tokens for tokens and pay BNB amount as fee
     * @param trade Trade details
     */
    function swapTokensForExactTokensWithFeeAmount(Trade calldata trade) external payable {
        uint256 feeAmount = getSwapFees(trade.amountIn, trade.path);
        require(msg.value >= feeAmount, "SafeswapRouter: You must send enough BNB to cover fee ");
        _feeAmountBNB(feeAmount);
        _swapTokensForExactTokens(trade.amountOut, trade.amountIn, trade.path, msg.sender, trade.to, trade.deadline);
    }

    /**
     * @notice Internal implementation of swap BNB for tokens
     * @param amountIn Amount to swap
     * @param amountOutMin Minimum amount out
     * @param path Path for swap
     * @param to Address to receive tokens
     * @param deadline Block timestamp deadline for trade
     */
    function _swapExactETHForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) internal {
        ISafeSwapRouter(swapRouter).swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amountIn }(
            amountOutMin,
            path,
            to,
            deadline
        );
    }

    /**
     * @notice Internal implementation of swap BNB for tokens
     * @param amountOut Amount of BNB out
     * @param amountInMax Max amount in
     * @param path Path for swap
     * @param to Address to receive BNB
     * @param deadline Block timestamp deadline for trade
     */
    function _swapETHForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) internal {
        ISafeSwapRouter(swapRouter).swapETHForExactTokens{ value: amountInMax }(amountOut, path, to, deadline);
    }

    /**
     * @notice Internal implementation of swap tokens for BNB
     * @param amountOut Amount of BNB out
     * @param amountInMax Max amount in
     * @param path Path for swap
     * @param from address to swap token from
     * @param to Address to receive BNB
     * @param deadline Block timestamp deadline for trade
     */
    function _swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address from,
        address to,
        uint256 deadline
    ) internal {
        ISafeSwapRouter(swapRouter).swapTokensForExactETH(amountOut, amountInMax, path, from, to, deadline);
    }

    /**
     * @notice Internal implementation of swap tokens for BNB
     * @param amountIn Amount to swap
     * @param amountOutMin Minimum amount out
     * @param path Path for swap
     * @param from address to swap token from
     * @param to Address to receive tokens
     * @param deadline Block timestamp deadline for trade
     */
    function _swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address from,
        address to,
        uint256 deadline
    ) internal {
        ISafeSwapRouter(swapRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            from,
            to,
            deadline
        );
    }

    /**
     * @notice Internal implementation of swap tokens for tokens
     * @param amountIn Amount to swap
     * @param amountOutMin Minimum amount out
     * @param path Path for swap
     * @param from address to swap token from
     * @param to Address to receive tokens
     * @param deadline Block timestamp deadline for trade
     */
    function _swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address from,
        address to,
        uint256 deadline
    ) internal {
        ISafeSwapRouter(swapRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            from,
            to,
            deadline
        );
    }

    /**
     * @notice Internal implementation of swap tokens for tokens
     * @param amountOut Amount of tokens out
     * @param amountInMax Max amount in
     * @param path Path for swap
     * @param from address to swap token from
     * @param to Address to receive tokens
     * @param deadline Block timestamp deadline for trade
     */
    function _swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address from,
        address to,
        uint256 deadline
    ) internal {
        ISafeSwapRouter(swapRouter).swapTokensForExactTokens(amountOut, amountInMax, path, from, to, deadline);
    }

    /**
     * @notice Get swap fee based on the amount
     * @param amountIn Amount to calculate fee
     * @param tokenA token1 for swap
     * @param tokenB token2 for swap
     */
    function getSwapFee(
        uint256 amountIn,
        uint256 _amountOut,
        address tokenA,
        address tokenB
    ) public view returns (uint256 _fee) {
        uint256 decimals = 18 - IERC20Extended(tokenA).decimals();

        if (tokenA == ISafeSwapRouter(swapRouter).WETH()) {
            return _fee = ((amountIn * 25) / 10000) * 10**decimals;
        }

        address[] memory _FFSpath = new address[](2);
        _FFSpath[0] = tokenA;
        _FFSpath[1] = ISafeSwapRouter(swapRouter).WETH();

        uint256 amountOut;
        try ISafeSwapRouter(swapRouter).getAmountsOut(amountIn, _FFSpath) returns (uint256[] memory amounts) {
            amountOut = amounts[amounts.length - 1];
        } catch {
            _FFSpath[0] = tokenB;
            try ISafeSwapRouter(swapRouter).getAmountsOut(_amountOut, _FFSpath) returns (uint256[] memory amounts) {
                amountOut = amounts[amounts.length - 1];
            } catch {
                amountOut = 0;
            }
        }

        if (amountOut > 0) {
            _fee = (amountOut * 25) / 10000;
        } else {
            _fee = ((amountIn * 25) / 10000) * 10**decimals;
        }

        return _fee;
    }

    function getSwapFees(uint256 amountIn, address[] memory path) public view returns (uint256 _fees) {
        require(path.length >= 2, "SafeswapFee: INVALID_PATH");
        uint256[] memory amounts = new uint256[](path.length);
        amounts = ISafeSwapRouter(swapRouter).getAmountsOut(amountIn, path);

        for (uint256 i; i < path.length - 1; i++) {
            _fees = _fees + getSwapFee(amounts[i], amounts[i + 1], path[i], path[i + 1]);
        }
    }

    /**
     * @notice Fee % of BNB contract balance
     * @param feePct % to get fee
     */
    function _feePctBNB(uint32 feePct) internal {
        uint256 contractBalance = address(this).balance;
        uint256 feeAmount = (contractBalance * feePct) / 1000000;
        feeJar.fee{ value: feeAmount }();
    }

    /**
     * @notice Fee specific amount of BNB
     * @param feeAmount Amount to fee
     */
    function _feeAmountBNB(uint256 feeAmount) internal {
        feeJar.fee{ value: feeAmount }();
    }

    /**
     * @notice Convert a token balance into BNB and then fee
     * @param amountIn Amount to swap
     * @param path Path for swap
     * @param deadline Block timestamp deadline for trade
     */
    function _feeWithTokens(
        uint256 amountIn,
        address from,
        address[] memory path,
        uint256 deadline,
        uint256 minEth
    ) internal {
        IERC20Extended(path[0]).safeIncreaseAllowance(address(swapRouter), amountIn);
        ISafeSwapRouter(swapRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            minEth,
            path,
            from,
            address(this),
            deadline
        );
        feeJar.fee{ value: address(this).balance }();
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

interface IERC20Extended {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function version() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address) external view returns (uint256);

    function getDomainSeparator() external view returns (bytes32);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function DOMAIN_TYPEHASH() external view returns (bytes32);

    function VERSION_HASH() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function TRANSFER_WITH_AUTHORIZATION_TYPEHASH()
        external
        view
        returns (bytes32);

    function RECEIVE_WITH_AUTHORIZATION_TYPEHASH()
        external
        view
        returns (bytes32);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

interface IFeeJar {
    function fee() external payable;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;
import "./ISafeswapRouter01.sol";

interface ISafeSwapRouter is ISafeswapRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address from,
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
        address from,
        address to,
        uint256 deadline
    ) external;
}

pragma solidity >=0.6.2;

interface ISafeswapRouter01 {
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
        address from,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address from,
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
        address from,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address from,
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
    ) external view returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity 0.8.11;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
contract Initializable {
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
        require(
            _initializing || _isConstructor() || !_initialized,
            "Initializable: contract is already initialized"
        );

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
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}