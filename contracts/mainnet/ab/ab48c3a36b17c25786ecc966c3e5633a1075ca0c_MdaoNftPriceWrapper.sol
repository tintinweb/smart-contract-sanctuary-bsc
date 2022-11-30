/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
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
        (bool success, bytes memory returndata) = target.call{value : value}(data);
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


pragma solidity ^0.8.0;


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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}


pragma solidity >=0.5.0;

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

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
interface Metadata {
    function decimals() external view returns (uint8);
}

interface IMarsNFT {
    function ownerOf(uint256 tokenId) external view returns (address);

    function mint(address to, uint256 tokenId) external;

    function burnFrom(uint256 tokenId) external;

    function exists(uint256 tokenId) external view returns (bool);

    function setBaseURI(string memory baseURIstring) external;

    function setURI(uint256 tokenId, string memory tokenURIstring) external;
}

contract MdaoNftPriceWrapper is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    enum VestingType {
        OneTime,
        Linear,
        Staged
    }

    struct TargetTokenPair {
        uint8 decimals;
        address baseToken;
        address pairAddress;
    }

    IMarsNFT public nftContract;
    address public feeAddress;
    IERC20 public constant MDAO_FEE_TOKEN = IERC20(0x60322971a672B81BccE5947706D22c19dAeCf6Fb); // set token address before deploy
    uint256 public constant PERCENT_DENOMINATOR = 10000;
    uint256 public constant PENALTY = 2000;
    uint256 public constant MAX_WITHDRAWAL_FEE = 100 ether;
    uint256 public withdrawFee = 10 ether; // in tokens
    IPancakeFactory public constant pancakeFactory =
        IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    address public constant routerAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E; // uniswap, pancakeswap etc

    // onetime & linear vesting
    struct NftInfo {
        bool withdrawWithPenalty;
        VestingType vestingType; // OneTime, Linear, Staged
        TargetTokenPair tokenPair;
        uint256 unlockStartPrice;
        uint256 unlockEndPrice;
        uint256 fundsLeft; // 10000 (100%)
        uint256[] stagesShares;
        uint256[] stagesTriggerPrices;
        uint256[] amountsList;
        address[] tokenList;
        bool ended;
    }

    NftInfo[] public nftPoolInfo;

    modifier isEOA() {
        require(
            address(msg.sender).code.length == 0 && msg.sender == tx.origin,
            "Only for human"
        );
        _;
    }

    modifier correctPID(uint256 _pid) {
        require(_pid < nftPoolInfo.length, "bad pid");
        require(nftContract.exists(_pid), "burn: pool not live");
        require(
            nftContract.ownerOf(_pid) == msg.sender,
            "burn: Zero NFT balance"
        );
        _;
    }

    /// This pair not found. Needed pair
    /// created by `supportedPancakeFactory` supportedPancakeFactory.
    /// @param supportedPancakeFactory address of supported Pancake Factory.
    error PairNotFound(address supportedPancakeFactory);

    constructor(IMarsNFT _nftContract) {
        nftContract = _nftContract;
        feeAddress = msg.sender;
    }

    function setWithdrawFee(uint256 _withdrawFee) external onlyOwner {
        require(_withdrawFee <= MAX_WITHDRAWAL_FEE, "wrong fee");
        withdrawFee = _withdrawFee;
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        feeAddress = _feeAddress;
    }

    function setNFTBaseURI(string memory _baseURIstring) external onlyOwner {
        nftContract.setBaseURI(_baseURIstring);
    }

    function mintWrappedNft(
        address[] memory _tokenList,
        uint256[] memory _amountsList,
        uint256[] memory _stagesShares, // Staged, total 100% (10000)
        uint256[] memory _stagesTriggerPrices, // first = start, last = end
        VestingType _vestingType, // OneTime, Linear, Staged
        address baseToken,
        address quoteToken,
        string memory tokenURIstring,
        bool _withdrawWithPenalty
    ) external nonReentrant isEOA {
        require(_tokenList.length > 0, "wrong tokenList length");
        require(_tokenList.length == _amountsList.length, "wrong array length");
        require(_stagesTriggerPrices.length > 1, "wrong stages length");
        uint256 startPrice = _stagesTriggerPrices[0];
        uint256 endPrice = _stagesTriggerPrices[
            _stagesTriggerPrices.length - 1
        ];
        require(startPrice <= endPrice, "wrong stages Trigger Prices");

        if (_vestingType == VestingType.Staged) {
            require(
                _stagesShares.length == _stagesTriggerPrices.length,
                "wrong _stages array length"
            );
            require(calculateShares(_stagesShares), "wrong total shares");
        }

        address pairAddress = pancakeFactory.getPair(baseToken, quoteToken);
        if (pairAddress == address(0)) {
            revert PairNotFound(address(pancakeFactory));
        }

        depositERC20List(_tokenList, _amountsList);
        nftContract.mint(msg.sender, nftPoolInfo.length);
        if (bytes(tokenURIstring).length > 0) {
            nftContract.setURI(nftPoolInfo.length, tokenURIstring);
        }

        nftPoolInfo.push(
            NftInfo({
                withdrawWithPenalty: _withdrawWithPenalty,
                vestingType: _vestingType,
                tokenPair: TargetTokenPair(
                    Metadata(baseToken).decimals(),
                    baseToken,
                    pairAddress
                ),
                unlockStartPrice: startPrice,
                unlockEndPrice: endPrice,
                fundsLeft: PERCENT_DENOMINATOR,
                tokenList: _tokenList,
                amountsList: _amountsList,
                stagesShares: _stagesShares,
                stagesTriggerPrices: _stagesTriggerPrices,
                ended: false
            })
        );
    }

    function getOneTokenPrice(uint256 _poolId) public view returns (uint256) {
        NftInfo memory nftPool = nftPoolInfo[_poolId];
        IPancakePair pair = IPancakePair(nftPool.tokenPair.pairAddress);
        (uint112 reserves0, uint112 reserves1, ) = pair.getReserves();
        (uint112 reserveBase, uint112 reserveQuote) = pair.token0() ==
            address(nftPool.tokenPair.baseToken)
            ? (reserves0, reserves1)
            : (reserves1, reserves0);

        if (reserveBase > 0) {
            uint256 oneToken = 10**(nftPool.tokenPair.decimals);
            return (oneToken * reserveQuote) / reserveBase + 1;
        } else {
            return 1;
        }
    }

    function withdrawWithPenalty(uint256 _poolId)
        external
        nonReentrant
        correctPID(_poolId)
    {
        NftInfo memory nftPool = nftPoolInfo[_poolId];
        require(nftPool.ended == false, "pool not live");
        require(nftPool.withdrawWithPenalty, "not alowed");
        nftContract.burnFrom(_poolId);

        if (nftPool.vestingType == VestingType.OneTime) {
            withdrawERC20ListWithPenalty(
                nftPool.tokenList,
                nftPool.amountsList
            );
            payWithdrawalFee(PERCENT_DENOMINATOR);
        } else {
            withdrawPartialERC20ListWithPenalty(
                nftPool.tokenList,
                nftPool.amountsList,
                nftPool.fundsLeft
            );
            if(nftPool.fundsLeft > 0) {
            payWithdrawalFee(nftPool.fundsLeft);
            }
        }

        nftPool.ended = true;
    }

    function burnWrappedNft(uint256 _poolId)
        external
        nonReentrant
        correctPID(_poolId)
    {
        NftInfo memory nftPool = nftPoolInfo[_poolId];
        uint256 currentPrice = getOneTokenPrice(_poolId);
        require(nftPool.ended == false, "pool not live");


        require(currentPrice >= nftPool.unlockEndPrice, "burn: too early");
        nftContract.burnFrom(_poolId);

        if (nftPool.vestingType == VestingType.OneTime) {
            withdrawERC20List(nftPool.tokenList, nftPool.amountsList);
            payWithdrawalFee(PERCENT_DENOMINATOR);
        } else {
            withdrawPartialERC20List(
                nftPool.tokenList,
                nftPool.amountsList,
                nftPool.fundsLeft
            );
            if(nftPool.fundsLeft > 0) {
            payWithdrawalFee(nftPool.fundsLeft);
            }
        }

        nftPoolInfo[_poolId].ended = true;
    }

    function claimLinearVesting(uint256 _poolId)
        external
        nonReentrant
        correctPID(_poolId)
    {
        NftInfo storage nftPool = nftPoolInfo[_poolId];
        require(nftPool.vestingType == VestingType.Linear, "only Linear");
        require(nftPool.ended == false, "pool not live");
        uint256 currentPrice = getOneTokenPrice(_poolId);

        require(currentPrice > nftPool.unlockStartPrice, "claim: too early");
        require(
            currentPrice < nftPool.unlockEndPrice,
            "claim: too late,use burnWrappedNft"
        );

        uint256 shareToPay = calculateLinearPayments(
            nftPool.unlockStartPrice,
            nftPool.unlockEndPrice,
            currentPrice,
            nftPool.fundsLeft
        );
        if(shareToPay > 0) {
            payWithdrawalFee(shareToPay);
        }
        nftPool.fundsLeft -= shareToPay;
        nftPool.unlockStartPrice = currentPrice;
        withdrawPartialERC20List(
            nftPool.tokenList,
            nftPool.amountsList,
            shareToPay
        );
    }

    function claimStagedVesting(uint256 _poolId, uint256 _stageId)
        external
        nonReentrant
        correctPID(_poolId)
    {
        NftInfo storage nftPool = nftPoolInfo[_poolId];
        require(nftPool.vestingType == VestingType.Staged, "only Staged");
        require(nftPool.ended == false, "pool not live");
        require(
            _stageId < nftPool.stagesTriggerPrices.length - 1,
            "bad _stageId,use burnWrappedNft for last stage"
        );
        require(
            nftPool.stagesTriggerPrices[_stageId] != 0,
            "claimStaged: already claimed"
        );
        uint256 currentPrice = getOneTokenPrice(_poolId);
        require(
            currentPrice >= nftPool.stagesTriggerPrices[_stageId],
            "claimStaged: too early"
        );
        uint256 shareToPay = nftPool.stagesShares[_stageId];
        if(shareToPay > 0) {
            payWithdrawalFee(shareToPay);
        }
        nftPool.fundsLeft -= shareToPay;
        withdrawPartialERC20List(
            nftPool.tokenList,
            nftPool.amountsList,
            shareToPay
        );
        nftPool.stagesTriggerPrices[_stageId] = 0;
    }

    function claimAllStages(uint256 _poolId)
        external
        nonReentrant
        correctPID(_poolId)
    {
        NftInfo storage nftPool = nftPoolInfo[_poolId];
        require(nftPool.ended == false, "pool not live");
        uint256 currentPrice = getOneTokenPrice(_poolId);
        uint256 shareToPaySumm;
        for (
            uint256 index = 0;
            index < nftPool.stagesTriggerPrices.length - 1;
            index++
        ) {
            if (
                nftPool.stagesTriggerPrices[index] != 0 &&
                currentPrice >= nftPool.stagesTriggerPrices[index]
            ) {
                uint256 shareToPay = nftPool.stagesShares[index];
                shareToPaySumm += shareToPay;
                withdrawPartialERC20List(
                    nftPool.tokenList,
                    nftPool.amountsList,
                    shareToPay
                );
                nftPool.stagesTriggerPrices[index] = 0;
            }
        }
        if(shareToPaySumm > 0) {
            payWithdrawalFee(shareToPaySumm);
        }
        nftPool.fundsLeft -= shareToPaySumm;
    }

    function depositToNft(uint256 _poolId, uint256[] memory _amountsList)
        public
        nonReentrant
        correctPID(_poolId)
    {
        NftInfo storage nftPool = nftPoolInfo[_poolId];
        require(
            nftPool.tokenList.length == _amountsList.length,
            "depositToNft: wrong amounts"
        );
        require(
            nftPool.fundsLeft == PERCENT_DENOMINATOR,
            "depositToNft: pool live"
        );

        for (uint256 index = 0; index < _amountsList.length; index++) {
            if (_amountsList[index] > 0) {
                IERC20 token = IERC20(nftPool.tokenList[index]);
                uint256 balansBefore = token.balanceOf(address(this));
                token.safeTransferFrom(
                    msg.sender,
                    address(this),
                    _amountsList[index]
                );
                nftPool.amountsList[index] += (token.balanceOf(address(this)) -
                    balansBefore);
            }
        }
    }

    function payWithdrawalFee(uint256 _share) internal {
        uint256 amountToPay = withdrawFee * _share / PERCENT_DENOMINATOR;
        MDAO_FEE_TOKEN.safeTransferFrom(msg.sender, feeAddress, amountToPay);
    }

    function depositERC20List(
        address[] memory _tokenList,
        uint256[] memory _amountsList
    ) internal {
        for (uint256 index = 0; index < _tokenList.length; index++) {
            if (_amountsList[index] > 0) {
                IERC20 token = IERC20(_tokenList[index]);
                uint256 balansBefore = token.balanceOf(address(this));
                token.safeTransferFrom(
                    msg.sender,
                    address(this),
                    _amountsList[index]
                );
                // support txfee tokens or partial withdraw for prevent failed withdrawals
                _amountsList[index] =
                    token.balanceOf(address(this)) -
                    balansBefore;
            }
        }
    }

    function withdrawERC20List(
        address[] memory _tokenList,
        uint256[] memory _amountsList
    ) internal {
        for (uint256 index = 0; index < _tokenList.length; index++) {
            if (_amountsList[index] > 0) {
                IERC20(_tokenList[index]).safeTransfer(
                    msg.sender,
                    _amountsList[index]
                );
            }
        }
    }

    function withdrawERC20ListWithPenalty(
        address[] memory _tokenList,
        uint256[] memory _amountsList
    ) internal {
        for (uint256 index = 0; index < _tokenList.length; index++) {
            if (_amountsList[index] > 0) {
                uint256 penalty = (_amountsList[index] * PENALTY) /
                    PERCENT_DENOMINATOR;

                IERC20(_tokenList[index]).safeTransfer(
                    msg.sender,
                    _amountsList[index] - penalty
                );
                if (penalty > 0) {
                    IERC20(_tokenList[index]).safeTransfer(feeAddress, penalty);
                }
            }
        }
    }

    function withdrawPartialERC20ListWithPenalty(
        address[] memory _tokenList,
        uint256[] memory _amountsList,
        uint256 _share
    ) internal {
        for (uint256 index = 0; index < _tokenList.length; index++) {
            if (_amountsList[index] > 0) {
                uint256 amount = (_amountsList[index] * _share) /
                    PERCENT_DENOMINATOR;
                uint256 penalty = (amount * PENALTY) / PERCENT_DENOMINATOR;
                IERC20(_tokenList[index]).safeTransfer(
                    msg.sender,
                    amount - penalty
                );
                if (penalty > 0) {
                    IERC20(_tokenList[index]).safeTransfer(feeAddress, penalty);
                }
            }
        }
    }

    function withdrawPartialERC20List(
        address[] memory _tokenList,
        uint256[] memory _amountsList,
        uint256 _share
    ) internal {
        for (uint256 index = 0; index < _tokenList.length; index++) {
            if (_amountsList[index] > 0) {
                uint256 amount = (_amountsList[index] * _share) /
                    PERCENT_DENOMINATOR;
                IERC20(_tokenList[index]).safeTransfer(msg.sender, amount);
            }
        }
    }

    // VIEW FUNCTIONS
    function totalNftMinted() public view returns (uint256) {
        return nftPoolInfo.length;
    }

    function viewTokenListById(uint256 _poolId)
        public
        view
        returns (address[] memory)
    {
        return nftPoolInfo[_poolId].tokenList;
    }

    function viewAmountListById(uint256 _poolId)
        public
        view
        returns (uint256[] memory)
    {
        return nftPoolInfo[_poolId].amountsList;
    }

    function viewStagesTriggerPricesById(uint256 _poolId)
        public
        view
        returns (uint256[] memory)
    {
        return nftPoolInfo[_poolId].stagesTriggerPrices;
    }

    function viewStageSharesById(uint256 _poolId)
        public
        view
        returns (uint256[] memory)
    {
        return nftPoolInfo[_poolId].stagesShares;
    }

    function calculateShares(uint256[] memory _stagesShares)
        public
        pure
        returns (bool)
    {
        uint256 totalSum = 0;
        for (uint256 index = 0; index < _stagesShares.length; index++) {
            totalSum += _stagesShares[index];
        }
        return totalSum == PERCENT_DENOMINATOR;
    }

    function calculateLinearPayments(
        uint256 _start,
        uint256 _end,
        uint256 _currentPrice,
        uint256 _fundsLeft
    ) public pure returns (uint256) {
        uint256 paymentPercent = (_fundsLeft * (_currentPrice - _start)) /
            (_end - _start);
        return paymentPercent;
    }
}