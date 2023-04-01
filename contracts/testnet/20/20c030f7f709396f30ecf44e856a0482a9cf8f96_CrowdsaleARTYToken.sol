/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

interface IWalletFactory {
    function createManagedVestingWallet(address beneficiary, address vestingManager) external returns (address);
    function walletFor(address beneficiary, address vestingManager, bool strict) external view returns (address);
}


interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ICrowdsale {

    struct Vesting {
        address vestingManager;
        uint256 distributionPercentage;
    }

    /**
     * @dev Emitted when `beneficiary` bought `amount` of token.
     */
    event TokenSold(address indexed beneficiary, uint256 indexed amount);

    /**
     * @dev Emitted when vesting wallet `receiver` received `amount` of token.
     */
    event TokenTransferred(address indexed receiver, uint256 indexed amount);

    /**
     * @dev Emitted when vesting wallet `receiver` received `amount` of token.
     */
    event BonusTransferred(address indexed receiver, uint256 indexed amount);

    /**
     * @dev Emitted when `referrer` get his `level`'s reward from his referee (eg referee bought tokens).
     */
    event RewardEarned(address indexed referrer, uint256 indexed amount, uint256 indexed level);

    function price() external view returns (uint256);
    function raise() external view returns (uint256);
    function start() external view returns (uint256);
    function duration() external view returns (uint256);
    function minAmount() external view returns (uint256);
    function maxAmount() external view returns (uint256);
    function getVestingManagersCount() external view returns (uint256);
    function getVestingManager(uint256 index) external view returns (address, uint256);
    function getVestingManagers() external view returns (address[] memory);
    function getVestingWallets(address beneficiary, address[] memory vestingManagers) external view returns (address[] memory);
    function walletFor(address beneficiary, address vestingManager) external view returns (address);

    function totalSold() external view returns (uint256);
    function totalEarned() external view returns (uint256);
    function totalBonus() external view returns (uint256);

    function BUSD() external view returns (address);
    function USDT() external view returns (address);
    function ARTY() external view returns (address);
    function pancakeRouter() external view returns (address);

    function setPrice(uint256) external;
    function setRaise(uint256) external;
    function setStart(uint64) external;
    function setDuration(uint64) external;
    function setMinAmount(uint256 minAmount_) external;
    function setMaxAmount(uint256 maxAmount_) external;
    function addVestingManager(address vestingManager_, uint256 distributionPercentage_) external;
    function removeVestingManager(uint256 index) external;

    function pause() external;
    function unpause() external;

    function withdraw(address) external;

    function buy(address erc20, uint256 amountIn, uint256 minAmountOut, address referrer) external payable;
}

interface IWhitelistedCrowdsale is ICrowdsale {
    function isInWhitelist(address user, bytes32[] memory proof) external view returns (bool);
    function setWhitelist(bytes32 whitelist_) external;
    function buyWithProof(bytes32[] memory proof, address erc20, uint256 amountIn, uint256 minAmountOut, address referrer) external payable;
}

/**
 * @title Crowdsale
 */
contract CrowdsaleARTYToken is ICrowdsale, Ownable, Pausable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    /**
     * @dev Predefined max referral levels.
     */
    uint256 public constant REFERRAL_PROGRAM_LEVELS = 3;

    uint256 internal constant PERCENTAGE_DENOM = 10000;

    /**
     * @dev Getter for the price.
     */
    uint256 public price;

    /**
     * @dev Getter for the raise.
     */
    uint256 public raise;

    /**
     * @dev Getter for the min possible amountIn at time.
     */
    uint256 public minAmount;

    /**
     * @dev Getter for max possible amount total.
     */
    uint256 public maxAmount;

    /**
     * @dev Getter for sale start.
     */
    uint256 public start;

    /**
     * @dev Getter for duration.
     */
    uint256 public duration;

    /**
     * @dev Getter for the total ARTY sold.
     */
    uint256 public totalSold;

    /**
     * @dev Getter for the total reward earned by all referrers.
     */
    uint256 public totalEarned;

    /**
     * @dev Getter for the total sum bonus.
     */
    uint256 public totalBonus;

    address public immutable BUSD; // 0xe9e7cea3dedca5984780bafc599bd69add087d56
    address public immutable USDT; // 0x55d398326f99059ff775485246999027b3197955
    address public immutable USDC; // 0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d
    address public immutable ARTY;
    address public immutable pancakeRouter; // 0x10ed43c718714eb63d5aa57b78b54704e256024e
    
    /**
     * @dev Getter referres.
     */
    mapping(address => address) public referrers;

    /**
     * @dev Getter for spent amounts by user.
     */
    mapping(address => uint256) public spent;

    /**
     * @dev Getter for bought ARTY amounts by user.
     */
    mapping(address => uint256) public bought;

    /**
     * @dev Getter for all level rewards by user.
     */
    mapping(address => uint256) public rewards;

    /**
     * @dev Getter for bonuses by user.
     */
    mapping(address => uint256) public bonuses;

    /**
     * @dev Factory address to create vesting wallets.
     */
    address internal _walletFactory;

    /**
     * @dev Internal vesting managers storage.
     */
    Vesting[] internal _vestingManagers;

    modifier onlySalePeriod {
        require(block.timestamp >= start && block.timestamp < (start + duration), "Sale: sale not started or already finished");
        _;
    }

    modifier whenNotStarted {
        require(start == 0 || (start > 0 && block.timestamp < start), "Sale: sale already started");
        _;
    }

    /**
     * @param BUSD_ The BUSD address, preferable to buy for;
     * @param USDT_ The USDT address;
     * @param USDC_ The USDC_ address;
     * @param ARTY_ The selling ARTY address;
     * @param pancakeRouter_ The PancakeRouter address. Used to change BNB\USDT\USDC to BUSD;
     * @param walletFactory_ The IWalletFactory implementation.
     *
     * USDT, USDC and PancakeRouter are optional. In that case sale be possible only for BUSD.
     */
    constructor(address BUSD_, address USDT_, address USDC_, address ARTY_, address pancakeRouter_, address walletFactory_) {
        BUSD = BUSD_;
        USDT = USDT_;
        USDC = USDC_;
        ARTY = ARTY_;
        pancakeRouter = pancakeRouter_;
        _walletFactory = walletFactory_;
    }

    /**
     * @dev Getter for vesting managers count.
     */
    function getVestingManagersCount() external view virtual override returns (uint256) {
        return _vestingManagers.length;
    }

    /**
     * @dev Getter for vesting manager.
     *
     * @return The address of vesting manager and its distribution percentage.
     */
    function getVestingManager(uint256 index) external view virtual override returns (address, uint256) {
        return (_vestingManagers[index].vestingManager, _vestingManagers[index].distributionPercentage);
    }

    /**
     * @dev Getter for vesting managers.
     */
    function getVestingManagers() external view virtual override returns (address[] memory) {
        address[] memory vestingManagers = new address[](_vestingManagers.length);
        for (uint256 i = 0; i < _vestingManagers.length; ++i) {
            vestingManagers[i] = _vestingManagers[i].vestingManager;
        }
        return vestingManagers;
    }

    /**
     * @dev Getter for user's vesting wallet.
     *
     * Can return all vesting wallets for given vesting managers (from any sale which used same wallet factory).
     *
     * @param beneficiary The beneficiary;
     * @param vestingManagers The array of vesting managers, used in current or previous sale.
     */
    function getVestingWallets(address beneficiary, address[] memory vestingManagers) external view virtual override returns (address[] memory) {
        address[] memory wallets = new address[](_vestingManagers.length);
        for (uint256 i = 0; i < vestingManagers.length; ++i) {
            address vestingManager = vestingManagers[i];
            wallets[i] = _walletFor(beneficiary, vestingManager);
        }
        return wallets;
    }

    /**
     * @dev Getter for user's vesting wallet.
     */
    function walletFor(address beneficiary, address vestingManager) external view virtual override returns (address) {
        return _walletFor(beneficiary, vestingManager);
    }

    /**
     * @dev Setter for the price.
     *
     * @param price_ The price in BUSD (18 decimals).
     */
    function setPrice(uint256 price_) external virtual override onlyOwner whenNotStarted {
        require(price_ > 0, "Sale: wrong price");
        price = price_;
    }

    /**
     * @dev Setter for the raise. Only for info purpose, not used in this contract.
     *
     * @param raise_ The target raise in BUSD (18 decimals).
     */
    function setRaise(uint256 raise_) external virtual override onlyOwner whenNotStarted {
        raise = raise_;
    }

    /**
     * @dev Setter for the sale start.
     *
     * @param start_ in seconds, timestamp format.
     */
    function setStart(uint64 start_) external virtual override onlyOwner whenNotStarted {
        require(start_ > block.timestamp, "Sale: past timestamp");
        start = start_;
    }

    /**
     * @dev Setter for the sale duration.
     *
     * @param duration_ in seconds.
     */
    function setDuration(uint64 duration_) external virtual override onlyOwner whenNotStarted {
        duration = duration_;
    }

    /**
     * @dev Setter min possible amount for one beneficiary at time.
     */
    function setMinAmount(uint256 minAmount_) external virtual override onlyOwner whenNotStarted {
        minAmount = minAmount_;
    }

    /**
     * @dev Setter for total max possible amount for one beneficiary.
     */
    function setMaxAmount(uint256 maxAmount_) external virtual override onlyOwner whenNotStarted {
        maxAmount = maxAmount_;
    }

    /**
     * @dev Adds vesting manager.
     *
     * @param vestingManager_ The new vesting manager.
     * @param distributionPercentage_ The distribution percentage, with 3 decimals (100% is 10000).
     *
     * To start sale total sum of distributionPercentage of all managers have to be 10000 (100%).
     */
    function addVestingManager(address vestingManager_, uint256 distributionPercentage_) external virtual override onlyOwner whenNotStarted {
        uint256 distributionPercentageTotal = _getDistributionPercentageTotal();
        distributionPercentageTotal += distributionPercentage_;
        require(distributionPercentageTotal <= 10000, "Sale: wrong total distribution percentage");
        _vestingManagers.push(Vesting(vestingManager_, distributionPercentage_));
    }

    /**
     * @dev Removes vesting manager.
     */
    function removeVestingManager(uint256 index) external virtual override onlyOwner whenNotStarted {
        require(index < _vestingManagers.length, "Sale: wrong index");
        uint256 lastIndex = _vestingManagers.length - 1;
        _vestingManagers[index].vestingManager = _vestingManagers[lastIndex].vestingManager;
        _vestingManagers[index].distributionPercentage = _vestingManagers[lastIndex].distributionPercentage;
        _vestingManagers.pop();
    }

    /**
     * @dev Withdraws given `token` tokens from the contracts's account to owner.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     */
    function withdraw(address token) external virtual override onlyOwner {
        require(token != address(0), "Sale: zero address given");
        IERC20 tokenImpl = IERC20(token);
        tokenImpl.safeTransfer(msg.sender, tokenImpl.balanceOf(address(this)));
    }

    /**
     * @dev Triggers stopped state.
     */
    function pause() external virtual override onlyOwner onlySalePeriod {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     */
    function unpause() external virtual override onlyOwner onlySalePeriod {
        _unpause();
    }

    /**
     * @dev Buy tokens for `token`'s `amountIn`. 
     *
     * @param token For what token user want buy ARTY. Can be BUSD\USDT\USDC\0x0. Use 0x0 and send value to buy ARTY for BNB.
     *  USDT\USDC\BNB will be changed to BUSD 'on the fly';
     * @param amountIn Amount for which user want to buy ARTY;
     * @param minAmountOut Min amount out in terms of PancakeRouter. Have to be given if token is USDT\USDC\BNB, 
     *  otherwise have to be 0;
     * @param referrer The referrer, if present. If possible will be set in the ARTY token too, to get rewards from future
     *  transfers.
     *
     * Can be used only in sale period.
     *
     * Can be paused by owner in emergency case.
     *
     * minAmountOut can be get from PancakeRouter:
     *  - to deduct PancakeRouter's fee from amountIn (will not work with if amountIn is equal with minAmountIn set in sale):
     *      const minAmountOut = pancakeRouter.getAmountsOut(amountIn, [USDT, BUSD])
     *  - or add it amountIn before call:
     *      const amountsIn = pancakeRouter.getAmountsIn(amountOut, [USDT, BUSD])
     *      const minAmountOut = amountsIn[0]
     *      
     * Emits {TokenTransferred} event;
     * Emits {TokenSold} event;
     * Emits {RewardEarned} event if referrer provided;
     * Emits few {Transfer} event.
     */
    function buy(address token, uint256 amountIn, uint256 minAmountOut, address referrer) external payable virtual override onlySalePeriod whenNotPaused nonReentrant {
        _buy(token, amountIn, minAmountOut, referrer);
    }

    function _buy(address token, uint256 amountIn, uint256 minAmountOut, address referrer) internal {
        require(_getDistributionPercentageTotal() == 10000, "Sale: vestings are not correct");
        require(token == BUSD || token == USDT || token == USDC || (token == address(0) && msg.value > 0), "Sale: wrong asset or value");
        if (referrer != address(0)) {
            address existingReferrer = referrers[msg.sender];
            if (existingReferrer != address(0)) {
                require(existingReferrer == referrer, "Sale: referrer already set");
            }
            // check is referrer have vesting wallet
            address[] memory wallets = _getVestingWallets(referrer);
            // can check only first element, cause there is no case when first element is not set but second one is
            require(wallets.length > 0 && wallets[0] != address(0), "Sale: invalid referrer");
        }

        uint256 amountBusdIn = amountIn;
        if (token == address(0)) { // native asset (BNB)
            amountBusdIn = _swapToBusd(address(0), 0, minAmountOut);
        } else {
            IERC20 tokenImpl = IERC20(token);

            tokenImpl.safeTransferFrom(msg.sender, address(this), amountIn);

            if (token != BUSD) { // USDT or USDC
                amountBusdIn = _swapToBusd(token, amountIn, minAmountOut);
            }
        }

        require(amountBusdIn >= minAmount, "Sale: minAmount");
        spent[msg.sender] += amountBusdIn;
        require(spent[msg.sender] <= maxAmount, "Sale: maxAmount");

        referrers[msg.sender] = referrer;

        IBEP20 erc20Impl = IBEP20(ARTY);
        uint256 decimals = erc20Impl.decimals();

        uint256[] memory amountArtyOuts = new uint256[](5);
        for (uint256 i = 0; i < _vestingManagers.length; ++i) {
            uint256 amountBusdInByVestingManager = (amountBusdIn * _vestingManagers[i].distributionPercentage) / PERCENTAGE_DENOM;

            uint256 amountOut = (amountBusdInByVestingManager * 10**decimals) / price;

            amountArtyOuts[0] = amountOut;
            amountArtyOuts[1] = (amountOut * 500) / PERCENTAGE_DENOM;
            amountArtyOuts[2] = (amountOut * 300) / PERCENTAGE_DENOM;
            amountArtyOuts[3] = (amountOut * 200) / PERCENTAGE_DENOM;
            amountArtyOuts[4] = _getBonus(token == address(0) ? amountBusdIn : amountIn, amountOut);

            _execute(_vestingManagers[i].vestingManager, msg.sender, amountArtyOuts);
        }
    }

    function _swapToBusd(address erc20, uint256 amountIn, uint256 minAmountOut) private returns (uint256) {
        IPancakeRouter02 pancakeRouterImpl = IPancakeRouter02(pancakeRouter);

        address[] memory path = new address[](2);
        path[1] = BUSD;

        IERC20 BUSDImpl = IERC20(BUSD);
        uint256 balanceBefore = BUSDImpl.balanceOf(address(this));

        if (erc20 == address(0)) {
            path[0] = pancakeRouterImpl.WETH();
            pancakeRouterImpl.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value }(minAmountOut, path, address(this), block.timestamp);
        } else {
            path[0] = erc20;
            IERC20 erc20Impl = IERC20(erc20);
            erc20Impl.safeIncreaseAllowance(pancakeRouter, amountIn);
            pancakeRouterImpl.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, minAmountOut, path, address(this), block.timestamp);
        }

        uint256 balanceAfter = BUSDImpl.balanceOf(address(this));

        return balanceAfter - balanceBefore;
    }

    function _execute(address vestingManager, address beneficiary, uint256[] memory amountArtyOuts) private {
        (address[] memory allLevelsVestingWallets, address[] memory allLevelsReferrers) = _getAllLevelsVestingWallets(vestingManager, beneficiary);

        totalSold += amountArtyOuts[0];
        emit TokenTransferred(allLevelsVestingWallets[0], amountArtyOuts[0]);
        emit TokenSold(beneficiary, amountArtyOuts[0]);

        IERC20 erc20Impl = IERC20(ARTY);

        bought[beneficiary] += amountArtyOuts[0];
        
        erc20Impl.safeTransfer(allLevelsVestingWallets[0], amountArtyOuts[0]);
        for (uint256 i = 1; i < allLevelsVestingWallets.length; ++i) {
            if (allLevelsVestingWallets[i] == address(0)) {
                break;
            }
            totalEarned += amountArtyOuts[i];
            emit RewardEarned(allLevelsVestingWallets[i], amountArtyOuts[i], i);
            rewards[allLevelsReferrers[i]] += amountArtyOuts[i];
            erc20Impl.safeTransfer(allLevelsVestingWallets[i], amountArtyOuts[i]);
        }
        if (amountArtyOuts[4] > 0) {
            emit BonusTransferred(allLevelsVestingWallets[0], amountArtyOuts[0]);
            totalBonus += amountArtyOuts[4];
            bonuses[beneficiary] += amountArtyOuts[4];
            erc20Impl.safeTransfer(allLevelsVestingWallets[0], amountArtyOuts[4]);
        }
    }

    function _getVestingWallets(address beneficiary) internal view returns (address[] memory) {
        address[] memory wallets = new address[](_vestingManagers.length);
        for (uint256 i = 0; i < _vestingManagers.length; ++i) {
            address vestingManager = _vestingManagers[i].vestingManager;
            wallets[i] = _walletFor(beneficiary, vestingManager);
        }
        return wallets;
    }

    function _getDistributionPercentageTotal() internal view returns (uint256) {
        uint256 distributionPercentageTotal = 0;
        for (uint256 i = 0; i < _vestingManagers.length; ++i) {
            distributionPercentageTotal += _vestingManagers[i].distributionPercentage;
        }
        return distributionPercentageTotal;
    }

    function _getAllLevelsVestingWallets(address vestingManager, address beneficiary) internal returns (address[] memory, address[] memory) {
        address[] memory allLevelsVestingWallets = new address[](REFERRAL_PROGRAM_LEVELS + 1);
        address[] memory allLevelsReferrers = new address[](REFERRAL_PROGRAM_LEVELS + 1);

        address vestingWallet = _walletFor(beneficiary, vestingManager);

        if (vestingWallet == address(0)) {
            IWalletFactory factoryImpl = IWalletFactory(_walletFactory);
            vestingWallet = factoryImpl.createManagedVestingWallet(beneficiary, vestingManager);
        }

        allLevelsVestingWallets[0] = vestingWallet;

        address referrer = referrers[beneficiary];
        for (uint256 i = 1; i <= REFERRAL_PROGRAM_LEVELS; ++i) {
            address referrerVestingWallet = _walletFor(referrer, vestingManager);
            if (referrerVestingWallet == address(0)) {
                break;
            }
            allLevelsVestingWallets[i] = referrerVestingWallet;
            allLevelsReferrers[i] = referrer;
            referrer = referrers[referrer];
        }

        return (allLevelsVestingWallets, allLevelsReferrers);
    }

    function _getBonus(uint256 amountIn, uint256 amountOut) internal pure returns (uint256) {
        uint256 bonus = 0;
        if (amountIn >= 5000 ether) {
            bonus = ((amountOut * 500) / PERCENTAGE_DENOM);
        } else if (amountIn >= 2500 ether) {
            bonus = ((amountOut * 300) / PERCENTAGE_DENOM);
        }
        return bonus;
    }

    function _walletFor(address beneficiary, address vestingManager) internal view returns (address) {
        return IWalletFactory(_walletFactory).walletFor(beneficiary, vestingManager, true);
    }
}