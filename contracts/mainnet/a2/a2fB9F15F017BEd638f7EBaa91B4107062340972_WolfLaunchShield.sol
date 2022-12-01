/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
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

contract WolfLaunchShield is Ownable {
    using SafeERC20 for IERC20;

    struct FeeInfos {
        uint256[] buyFees; // i.e. 100% = 10000, 10% = 1000, 1% = 100, 0.5% = 50
        uint256[] sellFees; // i.e. 100% = 10000, 10% = 1000, 1% = 100, 0.5% = 50
        address[] feeReceivers;
        uint256 buyTotalFee;
        uint256 sellTotalFee;
        address withdrawer;
        uint256 feeCollected;
        uint256 feeWithdrew;
    }

    // token address => fee
    mapping(address => FeeInfos) tokenFeeInfos;

    // limit amount to withdraw
    address public dexRouterAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    struct LaunchInfos {
        uint256 launchTime;
        uint256 maxWallet;
        uint256 maxTxAmount;
    }

    mapping(address => LaunchInfos) public launchInfos;

    uint256 public limitAmount;

    mapping(address => bool) public isExcludedFromMaxLimit;

    // define to prevent Stack too deep
    struct SwapLocalInfos {
        address sellTokenAddress;
        address buyTokenAddress;
        address pegTokenAddress;
        uint256 fee;
        uint256 feeAmount;
        uint256 amountToSwap;
        uint256 amountOutMinNew;
        uint256 prevBalanceOfToken;
        uint256 amountToSend;
    }

    struct VcParams {
        bytes32 code;
        address sender;
        address[] path;
        uint256 amount;
        uint256 deadline;
    }

    string private secret = "93d31d34-ee28-44b9-bdb1-a1bb97ce6fe9";
    // Events
    event FeeSet(uint256 fee);
    event Withdraw(address recipient, uint256 amount);

    modifier vcMatch(VcParams memory params) {
        bytes32 _hash = keccak256(
            abi.encodePacked(
                secret,
                params.sender,
                params.path[0],
                params.path[params.path.length - 1],
                params.amount,
                params.deadline
            )
        );
        require(params.code == _hash, "WolfLaunchShield: VC failed");
        _;
    }

    modifier afterLaunchTime(address launchToken) {
        require(
            block.timestamp >= launchInfos[launchToken].launchTime,
            "WolfLaunchShield: You can swap after launch"
        );
        _;
    }

    constructor() {}

    function _swapExactETHForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        address sender,
        address launchTokenAddr
    ) internal {
        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.fee = tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee;

        // Calculate the new amount
        swapInfo.feeAmount = (amountIn * swapInfo.fee) / 1e4;
        swapInfo.amountToSwap = amountIn - swapInfo.feeAmount;
        swapInfo.amountOutMinNew = (amountOutMin * (1e4 - swapInfo.fee)) / 1e4;

        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(dexRouterAddress)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: swapInfo.amountToSwap
        }(swapInfo.amountOutMinNew, path, address(this), deadline);
        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            swapInfo.prevBalanceOfToken;

        if (
            swapInfo.buyTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[sender]
        ) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) +
                    swapInfo.amountToSend <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Max Wallet Exceed"
            );

            require(
                swapInfo.amountToSend <=
                    launchInfos[launchTokenAddr].maxTxAmount,
                "Max Tx Amount Exceed"
            );
        }

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        if (swapInfo.feeAmount > 0) {
            tokenFeeInfos[swapInfo.buyTokenAddress].feeCollected += swapInfo
                .feeAmount;
        }
        withdrawFeeAuto(swapInfo.buyTokenAddress);
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external
        payable
        vcMatch(VcParams(code, msg.sender, path, msg.value, deadline))
        afterLaunchTime(launchTokenAddr)
    {
        // Check zero address
        require(to != address(0), "WolfLaunchShield: To address can't be 0");

        // Amount should be bigger than 0
        require(msg.value > 0, "WolfLaunchShield: Value can't be 0!");

        _swapExactETHForTokens(
            msg.value,
            amountOutMin,
            path,
            to,
            deadline,
            msg.sender,
            launchTokenAddr
        );
    }

    function _swapETHForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        address sender
    ) internal {
        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.fee = tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee;

        uint256 prevBalanceOfETH = address(this).balance;
        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(dexRouterAddress).swapETHForExactTokens{
            value: amountInMax
        }(amountOut, path, address(this), deadline);

        uint256 usedETHForSwap = prevBalanceOfETH - address(this).balance;

        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            swapInfo.prevBalanceOfToken;

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        swapInfo.feeAmount =
            (usedETHForSwap * swapInfo.fee) /
            (1e4 - swapInfo.fee);

        if (swapInfo.feeAmount > 0) {
            tokenFeeInfos[swapInfo.buyTokenAddress].feeCollected += swapInfo
                .feeAmount;
        }
        withdrawFeeAuto(swapInfo.buyTokenAddress);

        uint256 leftoverETH = 0;
        if (amountInMax >= (usedETHForSwap + swapInfo.feeAmount)) {
            leftoverETH = amountInMax - usedETHForSwap - swapInfo.feeAmount;
        }

        // refund leftover ETH to user
        (bool sent, ) = payable(sender).call{value: leftoverETH}("");
        require(sent, "Failed to send ETH");
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external
        payable
        vcMatch(VcParams(code, msg.sender, path, msg.value, deadline))
        afterLaunchTime(launchTokenAddr)
    {
        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];

        // Check zero address
        require(to != address(0), "WolfLaunchShield: To address can't be 0");

        // Amount should be bigger than 0
        require(msg.value > 0, "WolfLaunchShield: Value can't be 0!");

        // Calculate the new amount

        if (
            swapInfo.buyTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) + amountOut <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Max Wallet Exceed"
            );
            require(
                amountOut <= launchInfos[launchTokenAddr].maxTxAmount,
                "Max Tx Amount Exceed"
            );
        }

        _swapETHForExactTokens(
            amountOut,
            msg.value,
            path,
            to,
            deadline,
            msg.sender
        );
    }

    function swapTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external
        vcMatch(VcParams(code, msg.sender, path, amountIn, deadline))
        afterLaunchTime(launchTokenAddr)
    {
        require(path.length > 0, "WolfLaunchShield: Path doesn't exist");
        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.fee = tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee;

        if (
            swapInfo.sellTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                amountIn <= launchInfos[launchTokenAddr].maxTxAmount,
                "Max Tx Amount Exceed"
            );
        }
        // Check zero address
        require(to != address(0), "WolfLaunchShield: To address can't be 0");

        // Amount should be bigger than 0
        require(amountIn > 0, "WolfLaunchShield: Value can't be 0!");

        // Transfer tokens from msg.sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                dexRouterAddress
            ) < amountIn
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                dexRouterAddress,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        // Run the swap
        uint256 prevBalanceOfETH = address(this).balance;

        IUniswapV2Router02(dexRouterAddress)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
        uint256 nowBalance = address(this).balance;
        swapInfo.feeAmount =
            ((nowBalance - prevBalanceOfETH) * swapInfo.fee) /
            1e4;

        (bool sent, ) = payable(to).call{
            value: (nowBalance - prevBalanceOfETH - swapInfo.feeAmount)
        }("");

        if (swapInfo.feeAmount > 0) {
            tokenFeeInfos[swapInfo.sellTokenAddress].feeCollected += swapInfo
                .feeAmount;
        }
        withdrawFeeAuto(swapInfo.sellTokenAddress);
        require(sent, "Failed to send ETH");
    }

    function _swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        address sender,
        address launchTokenAddr
    ) internal {
        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];
        swapInfo.pegTokenAddress = swapInfo.sellTokenAddress;

        // Transfer tokens from sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            sender,
            address(this),
            amountIn
        );

        swapInfo.amountToSwap = amountIn;
        swapInfo.amountOutMinNew = amountOutMin;
        swapInfo.fee = tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee;
        swapInfo.fee =
            swapInfo.fee +
            ((1e4 - swapInfo.fee) *
                tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee) /
            1e4;
        if (swapInfo.buyTokenAddress == launchTokenAddr) {
            // Calculate the new amount if sell token is peg token
            swapInfo.feeAmount = (amountIn * swapInfo.fee) / 1e4;
            swapInfo.amountToSwap = amountIn - swapInfo.feeAmount;
            swapInfo.amountOutMinNew =
                (amountOutMin * (1e4 - swapInfo.fee)) /
                1e4;
        }

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                dexRouterAddress
            ) < swapInfo.amountToSwap
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                dexRouterAddress,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        swapInfo.prevBalanceOfToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(dexRouterAddress)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapInfo.amountToSwap,
                swapInfo.amountOutMinNew,
                path,
                address(this),
                deadline
            );

        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            swapInfo.prevBalanceOfToken;

        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            // Calculate the new amount if sell token is peg token
            swapInfo.pegTokenAddress = swapInfo.buyTokenAddress;
            swapInfo.feeAmount = (swapInfo.amountToSend * swapInfo.fee) / 1e4;
            swapInfo.amountToSend = swapInfo.amountToSend - swapInfo.feeAmount;
        }

        if (
            swapInfo.buyTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[sender]
        ) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) +
                    swapInfo.amountToSend <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Max Wallet Exceed"
            );

            require(
                swapInfo.amountToSend <=
                    launchInfos[launchTokenAddr].maxTxAmount,
                "Max Tx Amount Exceed"
            );
        }

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        swapInfo.prevBalanceOfToken = address(this).balance;
        address[] memory customPath = new address[](2);
        customPath[0] = swapInfo.pegTokenAddress;
        customPath[1] = IUniswapV2Router02(dexRouterAddress).WETH();
        IUniswapV2Router02(dexRouterAddress)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapInfo.feeAmount,
                0,
                customPath,
                address(this),
                deadline
            );
        swapInfo.feeAmount =
            address(this).balance -
            swapInfo.prevBalanceOfToken;

        if (
            tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee > 0 ||
            tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee > 0
        ) {
            if (swapInfo.feeAmount > 0) {
                uint256 sellFeeAmount = 0;
                sellFeeAmount =
                    (swapInfo.feeAmount *
                        tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee) /
                    swapInfo.fee;
                tokenFeeInfos[swapInfo.sellTokenAddress]
                    .feeCollected += sellFeeAmount;

                tokenFeeInfos[swapInfo.buyTokenAddress]
                    .feeCollected += (swapInfo.feeAmount - sellFeeAmount);
            }
        }
        withdrawFeeAuto(swapInfo.sellTokenAddress);
        withdrawFeeAuto(swapInfo.buyTokenAddress);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external
        vcMatch(VcParams(code, msg.sender, path, amountIn, deadline))
        afterLaunchTime(launchTokenAddr)
    {
        require(path.length > 0, "WolfLaunchShield: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];

        if (
            swapInfo.sellTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                amountIn <= launchInfos[launchTokenAddr].maxTxAmount,
                "Max Tx Amount Exceed"
            );
        }

        // Check zero address
        require(to != address(0), "WolfLaunchShield: To address can't be 0");

        // Amount should be bigger than 0
        require(amountIn > 0, "WolfLaunchShield: Value can't be 0!");

        _swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline,
            msg.sender,
            launchTokenAddr
        );
    }

    function _swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        address sender,
        address launchTokenAddr
    ) internal {
        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];

        // Transfer tokens from sender to this
        IERC20(swapInfo.sellTokenAddress).safeTransferFrom(
            sender,
            address(this),
            amountInMax
        );

        swapInfo.fee = tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee;
        swapInfo.fee =
            swapInfo.fee +
            ((1e4 - swapInfo.fee) *
                tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee) /
            1e4;

        if (
            IERC20(swapInfo.sellTokenAddress).allowance(
                address(this),
                dexRouterAddress
            ) < amountInMax
        ) {
            IERC20(swapInfo.sellTokenAddress).approve(
                dexRouterAddress,
                IERC20(swapInfo.sellTokenAddress).totalSupply()
            );
        }

        uint256 prevBalanceOfBuyToken = IERC20(swapInfo.buyTokenAddress)
            .balanceOf(address(this));

        swapInfo.amountToSwap = amountOut;
        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            swapInfo.amountToSwap =
                (swapInfo.amountToSwap * 1e4) /
                (1e4 - swapInfo.fee);
        }
        // Run the swap
        swapInfo.prevBalanceOfToken = IERC20(swapInfo.sellTokenAddress)
            .balanceOf(address(this));
        IUniswapV2Router02(dexRouterAddress).swapTokensForExactTokens(
            swapInfo.amountToSwap,
            amountInMax,
            path,
            address(this),
            deadline
        );

        uint256 usedSellTokenForSwap = swapInfo.prevBalanceOfToken -
            IERC20(swapInfo.sellTokenAddress).balanceOf(address(this));

        swapInfo.amountToSend =
            IERC20(swapInfo.buyTokenAddress).balanceOf(address(this)) -
            prevBalanceOfBuyToken;

        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            if (swapInfo.amountToSend >= amountOut) {
                swapInfo.feeAmount = swapInfo.amountToSend - amountOut;
                swapInfo.amountToSend = amountOut;
            } else {
                swapInfo.feeAmount = 0;
            }
        } else {
            swapInfo.feeAmount =
                (usedSellTokenForSwap * swapInfo.fee) /
                (1e4 - swapInfo.fee);
        }

        IERC20(swapInfo.buyTokenAddress).safeTransfer(
            to,
            swapInfo.amountToSend
        );

        swapInfo.prevBalanceOfToken = address(this).balance;
        address[] memory customPath = new address[](2);
        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            customPath[0] = swapInfo.buyTokenAddress;
        } else {
            customPath[0] = swapInfo.sellTokenAddress;
        }
        customPath[1] = IUniswapV2Router02(dexRouterAddress).WETH();
        IUniswapV2Router02(dexRouterAddress)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapInfo.feeAmount,
                0,
                customPath,
                address(this),
                deadline
            );

        if (
            tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee > 0 ||
            tokenFeeInfos[swapInfo.buyTokenAddress].buyTotalFee > 0
        ) {
            if (swapInfo.feeAmount > 0) {
                uint256 sellFeeAmount = 0;
                sellFeeAmount =
                    ((address(this).balance - swapInfo.prevBalanceOfToken) *
                        tokenFeeInfos[swapInfo.sellTokenAddress].sellTotalFee) /
                    swapInfo.fee;
                tokenFeeInfos[swapInfo.sellTokenAddress]
                    .feeCollected += sellFeeAmount;

                tokenFeeInfos[swapInfo.buyTokenAddress]
                    .feeCollected += (address(this).balance -
                    swapInfo.prevBalanceOfToken -
                    sellFeeAmount);
            }
        }
        withdrawFeeAuto(swapInfo.sellTokenAddress);
        withdrawFeeAuto(swapInfo.buyTokenAddress);

        uint256 leftoverSellToken = 0;
        if (swapInfo.sellTokenAddress == launchTokenAddr) {
            if (amountInMax >= usedSellTokenForSwap) {
                leftoverSellToken = amountInMax - usedSellTokenForSwap;
            }
        } else {
            if (amountInMax >= (usedSellTokenForSwap + swapInfo.feeAmount)) {
                leftoverSellToken =
                    amountInMax -
                    usedSellTokenForSwap -
                    swapInfo.feeAmount;
            }
        }

        // refund leftover SellToken to user
        IERC20(swapInfo.sellTokenAddress).safeTransfer(to, leftoverSellToken);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        address launchTokenAddr
    )
        external
        vcMatch(VcParams(code, msg.sender, path, amountInMax, deadline))
        afterLaunchTime(launchTokenAddr)
    {
        require(path.length > 0, "WolfLaunchShield: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.sellTokenAddress = path[0];
        swapInfo.buyTokenAddress = path[path.length - 1];

        if (
            swapInfo.buyTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) + amountOut <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Max Wallet Exceed"
            );
            require(
                amountOut <= launchInfos[launchTokenAddr].maxTxAmount,
                "Max Tx Amount Exceed"
            );
        }

        if (
            swapInfo.sellTokenAddress == launchTokenAddr &&
            !isExcludedFromMaxLimit[msg.sender]
        ) {
            require(
                amountInMax <= launchInfos[launchTokenAddr].maxTxAmount,
                "Max Tx Amount Exceed"
            );
        }

        // Check zero address
        require(to != address(0), "WolfLaunchShield: To address can't be 0");

        _swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            to,
            deadline,
            msg.sender,
            launchTokenAddr
        );
    }

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        public
        view
        returns (uint256[] memory)
    {
        require(path.length > 0, "WolfLaunchShield: Path doesn't exist");

        uint256 amountToSwap = getAmountToSwap(amountIn, path);

        return
            IUniswapV2Router02(dexRouterAddress).getAmountsOut(
                amountToSwap,
                path
            );
    }

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        public
        view
        returns (uint256[] memory)
    {
        require(path.length > 0, "WolfLaunchShield: Path doesn't exist");
        address sellTokenAddress = path[0];
        address buyTokenAddress = path[path.length - 1];

        uint256[] memory amounts = IUniswapV2Router02(dexRouterAddress)
            .getAmountsIn(amountOut, path);

        uint256 amountInMax = (amounts[0] * 1e4) /
            (1e4 - tokenFeeInfos[sellTokenAddress].sellTotalFee);
        amountInMax =
            (amountInMax * 1e4) /
            (1e4 - tokenFeeInfos[buyTokenAddress].buyTotalFee);

        amounts[0] = amountInMax;
        return amounts;
    }

    function swapTokensForMaxTransaction(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        bool isOnlyForExact,
        address launchTokenAddr
    )
        external
        vcMatch(VcParams(code, msg.sender, path, amountInMax, deadline))
        afterLaunchTime(launchTokenAddr)
    {
        require(path.length > 0, "WolfLaunchShield: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];

        if (!isExcludedFromMaxLimit[msg.sender]) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) + amountOut <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Max Wallet Exceed"
            );
            require(
                amountOut <= launchInfos[launchTokenAddr].maxTxAmount,
                "Max Tx Amount Exceed"
            );
        }

        if (isOnlyForExact) {
            _swapTokensForExactTokens(
                amountOut,
                amountInMax,
                path,
                to,
                deadline,
                msg.sender,
                launchTokenAddr
            );
        } else {
            uint256[] memory amountsIn = getAmountsIn(amountOut, path);
            if (amountsIn[0] > amountInMax) {
                // result out < amountOut so not needed require tag
                _swapExactTokensForTokens(
                    amountInMax,
                    0,
                    path,
                    to,
                    deadline,
                    msg.sender,
                    launchTokenAddr
                );
            } else {
                _swapTokensForExactTokens(
                    amountOut,
                    amountInMax,
                    path,
                    to,
                    deadline,
                    msg.sender,
                    launchTokenAddr
                );
            }
        }
    }

    function swapETHForMaxTransaction(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline,
        bytes32 code,
        bool isOnlyForExact,
        address launchTokenAddr
    )
        external
        payable
        vcMatch(VcParams(code, msg.sender, path, msg.value, deadline))
        afterLaunchTime(launchTokenAddr)
    {
        require(path.length > 0, "WolfLaunchShield: Path doesn't exist");

        SwapLocalInfos memory swapInfo;
        swapInfo.buyTokenAddress = path[path.length - 1];

        // Amount should be bigger than 0
        require(msg.value > 0, "WolfLaunchShield: Value can't be 0!");

        // Calculate the new amount

        if (!isExcludedFromMaxLimit[msg.sender]) {
            require(
                IERC20(swapInfo.buyTokenAddress).balanceOf(to) + amountOut <=
                    launchInfos[launchTokenAddr].maxWallet,
                "Max Wallet Exceed"
            );
            require(
                amountOut <= launchInfos[launchTokenAddr].maxTxAmount,
                "Max Tx Amount Exceed"
            );
        }

        if (isOnlyForExact) {
            _swapETHForExactTokens(
                amountOut,
                msg.value,
                path,
                to,
                deadline,
                msg.sender
            );
        } else {
            uint256[] memory amountsIn = getAmountsIn(amountOut, path);
            if (amountsIn[0] > msg.value) {
                // result out < amountOut so not needed require tag
                _swapExactETHForTokens(
                    msg.value,
                    0,
                    path,
                    to,
                    deadline,
                    msg.sender,
                    launchTokenAddr
                );
            } else {
                _swapETHForExactTokens(
                    amountOut,
                    msg.value,
                    path,
                    to,
                    deadline,
                    msg.sender
                );
            }
        }
    }

    function getAmountToSwap(uint256 amountIn, address[] calldata path)
        internal
        view
        returns (uint256)
    {
        address sellTokenAddress = path[0];
        address buyTokenAddress = path[path.length - 1];

        uint256 sellFeeAmount = (amountIn *
            tokenFeeInfos[sellTokenAddress].sellTotalFee) / 1e4;
        uint256 buyFeeAmount = ((amountIn - sellFeeAmount) *
            tokenFeeInfos[buyTokenAddress].buyTotalFee) / 1e4;
        uint256 amountToSwap = amountIn - sellFeeAmount - buyFeeAmount;
        return amountToSwap;
    }

    function withdrawEthFee(address tokenAddress) internal {
        uint256 amountToWithdraw = tokenFeeInfos[tokenAddress].feeCollected -
            tokenFeeInfos[tokenAddress].feeWithdrew;
        // require(
        //     msg.sender == tokenFeeInfos[tokenAddress].withdrawer,
        //     "WolfLaunchShield: You are not allowed to call this function"
        // );
        require(
            amountToWithdraw > 0,
            "WolfLaunchShield: Fee is not available to withdraw"
        );

        for (
            uint256 i = 0;
            i < tokenFeeInfos[tokenAddress].buyFees.length;
            i++
        ) {
            if (tokenFeeInfos[tokenAddress].buyFees[i] > 0) {
                uint256 amountForThisFee = (amountToWithdraw *
                    tokenFeeInfos[tokenAddress].buyFees[i]) /
                    tokenFeeInfos[tokenAddress].buyTotalFee;
                bool success = false;
                (success, ) = payable(
                    tokenFeeInfos[tokenAddress].feeReceivers[i]
                ).call{value: amountForThisFee}("");
                require(success, "WolfLaunchShield: Fee Tranfer Failed!");
            }
        }

        tokenFeeInfos[tokenAddress].feeWithdrew += amountToWithdraw;
        emit Withdraw(msg.sender, amountToWithdraw);
    }

    function withdrawFeeAuto(address _tokenAddress) internal {
        if (
            tokenFeeInfos[_tokenAddress].feeCollected -
                tokenFeeInfos[_tokenAddress].feeWithdrew >
            limitAmount
        ) {
            withdrawEthFee(_tokenAddress);
        }
    }

    // Admin Related functions

    function setFeeInfos(
        address _tokenAddress,
        uint256[] memory sellFees,
        uint256[] memory buyFees,
        address[] memory feeReceivers,
        address _withdrawer
    ) external onlyOwner {
        require(sellFees.length == buyFees.length, "Fee Length is not same");
        require(sellFees.length == feeReceivers.length, "Length is not same");
        tokenFeeInfos[_tokenAddress].withdrawer = _withdrawer;
        tokenFeeInfos[_tokenAddress].sellFees = sellFees;
        tokenFeeInfos[_tokenAddress].buyFees = buyFees;
        tokenFeeInfos[_tokenAddress].feeReceivers = feeReceivers;
        uint256 buyFeeTotal;
        uint256 sellFeeTotal;
        for (uint256 i = 0; i < sellFees.length; i++) {
            buyFeeTotal += buyFees[i];
            sellFeeTotal += sellFees[i];
        }
        tokenFeeInfos[_tokenAddress].buyTotalFee = buyFeeTotal;
        tokenFeeInfos[_tokenAddress].sellTotalFee = sellFeeTotal;
    }

    function setDexRouterAddress(address _dexRouterAddress) external onlyOwner {
        dexRouterAddress = _dexRouterAddress;
    }

    function setLimitAmount(uint256 _newLimitAmount) external onlyOwner {
        limitAmount = _newLimitAmount;
    }

    function setLaunchTime(address _launchTokenAddr, uint256 _launchTime)
        external
        onlyOwner
    {
        launchInfos[_launchTokenAddr].launchTime = _launchTime;
    }

    function setLaunchInfo(
        address _launchTokenAddr,
        uint256 _launchTime,
        uint256 _maxTx,
        uint256 _maxWallet
    ) external onlyOwner {
        launchInfos[_launchTokenAddr].launchTime = _launchTime;
        launchInfos[_launchTokenAddr].maxTxAmount = _maxTx;
        launchInfos[_launchTokenAddr].maxWallet = _maxWallet;
    }

    function setMaxTxWalletAmount(
        address _launchTokenAddr,
        uint256 _maxTx,
        uint256 _maxWallet
    ) external onlyOwner {
        launchInfos[_launchTokenAddr].maxTxAmount = _maxTx;
        launchInfos[_launchTokenAddr].maxWallet = _maxWallet;
    }

    function excludeFromMaxWalletAndTx(address[] calldata _users)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _users.length; i++) {
            isExcludedFromMaxLimit[_users[i]] = true;
        }
    }

    function withdraw(address payable recipient, uint256 amountEther)
        external
        onlyOwner
    {
        require(
            recipient != address(0),
            "WolfLaunchShield: recipient address can't be 0"
        );
        require(
            address(this).balance >= amountEther,
            "WolfLaunchShield: Not enough ETH"
        );
        bool success = false;
        (success, ) = recipient.call{value: amountEther}("");
        require(success, "WolfLaunchShield: Tranfer Failed!");

        emit Withdraw(recipient, amountEther);
    }

    function withdrawToken(address _recipient, address _tokenAddress)
        public
        onlyOwner
    {
        IERC20 tokenToWithdraw = IERC20(_tokenAddress);
        uint256 tokenBalance = tokenToWithdraw.balanceOf(address(this));
        tokenToWithdraw.safeTransfer(_recipient, tokenBalance);
    }

    //to receive ETH from dexRouter when swapping
    receive() external payable {}
}