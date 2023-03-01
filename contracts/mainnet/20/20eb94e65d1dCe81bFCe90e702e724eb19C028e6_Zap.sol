/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// Sources flattened with hardhat v2.12.7 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]
// SPDX-License-Identifier: UNLICENSED
 
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


// File @openzeppelin/contracts/access/[email protected]

 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

 
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


// File @openzeppelin/contracts/token/ERC20/[email protected]

 
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


// File @openzeppelin/contracts/utils/[email protected]

 
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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

 
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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


// File @openzeppelin/contracts/security/[email protected]

 
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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


// File contracts/Interfaces/IGrizzly.sol

 
pragma solidity ^0.8.17;

interface IGrizzly {
    function depositLp(
        address to,
        uint256 amount,
        address referralGiver,
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    ) external returns (uint256);

    function withdrawToLp(
        address to,
        uint256 amount,
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    ) external returns (uint256);

    function getUpdatedState()
        external
        returns (
            Strategy currentStrategy,
            uint256 deposited,
            uint256 balance,
            uint256 totalReinvested,
            uint256 earnedHoney,
            uint256 earnedBnb,
            uint256 stakedHoney
        );

    function changeStrategy(
        Strategy toStrategy,
        address[] memory fromToken,
        address[] memory toToken,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        uint256 slippage,
        uint256 deadline
    ) external;

    function revokeRole(bytes32 role, address account) external;

    function grantRole(bytes32 role, address account) external;

    function ZAP_ROLE() external view returns (bytes32);

    enum Strategy {
        STANDARD,
        GRIZZLY,
        STABLECOIN
    }
}


// File contracts/Interfaces/ILiquidityImplementation.sol

 
pragma solidity ^0.8.17;

interface ILiquidityImplementation {
    function getSwapRouter(address lpToken) external view returns (address);

    struct AddLiquidityInput {
        address lpToken;
        uint256 amountToken0;
        uint256 amountToken1;
        uint256 minAmountToken0;
        uint256 minAmountToken1;
        address to;
        uint256 deadline;
    }

    struct RemoveLiquidityInput {
        address lpToken;
        uint256 lpAmount;
        uint256 minAmountToken0;
        uint256 minAmountToken1;
        address to;
        uint256 deadline;
    }

    struct AddLiquidityOutput {
        uint256 unusedToken0;
        uint256 unusedToken1;
        uint256 lpToken;
    }

    struct RemoveLiquidityOutput {
        uint256 received0;
        uint256 received1;
    }

    // Interface function to add liquidity to the implementation DEX
    function addLiquidity(AddLiquidityInput calldata addLiquidityInput)
        external
        payable
        returns (AddLiquidityOutput memory);

    // Interface function to remove liquidity to the implementation DEX
    function removeLiquidity(RemoveLiquidityInput calldata removeLiquidityInput)
        external
        returns (RemoveLiquidityOutput memory);

    // Gets token0 for an lp token for the implementation DEX
    function token0(address lpToken) external view returns (address);

    // Gets token1 for an lp token for the implementation DEX
    function token1(address lpToken) external view returns (address);

    // Estimate the swap share
    function estimateSwapShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1);

    // Estimate the out share
    function estimateOutShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1);
}


// File contracts/Interfaces/IVault.sol

 
pragma solidity ^0.8.17;

interface IVault {
    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    function withdraw(uint256 maxShares, address recipient)
        external
        returns (uint256);
}


// File contracts/Interfaces/IWETH.sol

 
pragma solidity ^0.8.17;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}


// File contracts/Interfaces/IZap.sol

 
pragma solidity ^0.8.17;

interface IZap {
    struct ZapInInput {
        address fromTokenAddress; // The input token
        address vault; // the valut or the hive where LP Tokens will be deposited
        address referral; // referral for old hives
        uint256 deadline;
        SwapTokenInfo token0Info;
        SwapTokenInfo token1Info;
    }

    struct ZapOutInput {
        address vault; // the valut or the hive where LP Tokens will be deposited
        uint256 withdrawAmount;
        uint256 deadline;
        uint256 minTokenShare0;
        uint256 minTokenShare1;
    }

    struct SwapTokenInfo {
        address swapTarget; // The 0x swap target
        bytes swapData; // The 0x swap data
        uint256 tokenShare; // The token share can be retrieved by helper function estimateSwapShare
        uint256 minTokenShare;
    }

    struct VaultInfo {
        address lpToken;
        address liquidityRouterImplementation;
        VaultType vaultType;
    }

    struct DepositArrays {
        address[] tokens;
        uint256[] amounts;
    }

    struct ProvideLiquidityInput {
        address token0;
        address token1;
        address swapRouter;
        address lpToken;
        address liquidityImplementation;
        uint256[2] amounts;
        uint256[2] amountsMin;
        uint256 deadline;
    }

    struct RemoveLiquidityInput {
        address swapRouter;
        address lpToken;
        address liquidityImplementation;
        uint256 lpValue;
        uint256[2] minAmounts;
        uint256 deadline;
    }

    enum VaultType {
        YEARN,
        GRIZZLY
    }

    event ZapIn(
        address indexed user,
        address indexed inToken,
        address indexed toVault,
        uint256 amountIn,
        uint256 receivedLpTokens
    );
    event ZapOut(
        address indexed user,
        address indexed fromVault,
        uint256 lpWithdrawAmount,
        uint256 withdrawnAmountToken0,
        uint256 withdrawnAmountToken1
    );
}


// File contracts/ZapBase.sol


pragma solidity ^0.8.0;
abstract contract ZapBase is Ownable {
    using SafeERC20 for IERC20;
    bool public stopped = false;

    // SwapTarget => approval status
    mapping(address => bool) public approvedTargets;

    address internal constant ETHAddress =
        0x0000000000000000000000000000000000000000;

    address internal constant wethTokenAddress =
        0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // Circuit breaker modifiers
    modifier stopInEmergency() {
        if (stopped) {
            revert("Paused");
        } else {
            _;
        }
    }

    function _pullTokens(address token, uint256 amount)
        internal
        returns (uint256)
    {
        if (token == address(0)) {
            require(msg.value > 0, "No eth sent");
            return msg.value;
        }
        require(amount > 0, "Invalid token amount");
        require(msg.value == 0, "Eth sent with token");

        // Transfer token
        require(
            IERC20(token).allowance(msg.sender, address(this)) >= amount,
            "Token is not approved"
        );
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        return amount;
    }

    function _transferToken(
        address token,
        address to,
        uint256 amount
    ) internal {
        if (token == address(0)) {
            (bool sent, bytes memory data) = to.call{value: amount}("");
            require(sent, "Failed to send Ether");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function _getBalance(address token)
        internal
        view
        returns (uint256 balance)
    {
        if (token == address(0)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(token).balanceOf(address(this));
        }
    }

    function _approveToken(address token, address spender) internal {
        IERC20 _token = IERC20(token);
        if (_token.allowance(address(this), spender) > 0) return;
        else {
            _token.safeApprove(spender, type(uint256).max);
        }
    }

    function _approveToken(
        address token,
        address spender,
        uint256 amount
    ) internal {
        IERC20(token).safeApprove(spender, 0);
        IERC20(token).safeApprove(spender, amount);
    }

    // - to Pause the contract
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    ///@notice Withdraw tokens like a sweep function
    function withdrawTokens(address[] calldata tokens) external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 qty;
            // Check weather if is native or just ERC20
            if (tokens[i] == ETHAddress) {
                qty = address(this).balance;
                Address.sendValue(payable(owner()), qty);
            } else {
                qty = IERC20(tokens[i]).balanceOf(address(this));
                IERC20(tokens[i]).safeTransfer(owner(), qty);
            }
        }
    }

    function setApprovedTargets(
        address[] calldata targets,
        bool[] calldata isApproved
    ) external onlyOwner {
        require(targets.length == isApproved.length, "Invalid Input length");

        for (uint256 i = 0; i < targets.length; i++) {
            approvedTargets[targets[i]] = isApproved[i];
        }
    }

    receive() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}


// File contracts/Zap.sol

 
pragma solidity ^0.8.17;
/**
 * @title Zap contract
 * @notice This contract allows users to add or remove liquidity from supported vaults.
 * It also uses 0x api to swap input tokens to the destination tokens in order to provide liquidity
 */
contract Zap is IZap, ZapBase, ReentrancyGuard {
    // Mapping from a vault address to its corresponding VaultInfo.
    mapping(address => VaultInfo) public vaultInfos;

    /**
     * @notice Zap in with a inToken. This function swaps the inToken using 0x to token0 and token1. Then it provides the tokens as liquidity in a supported LiquidityImplementation.
     * Finally, the lp tokens are deposited in a vault.
     * @param zapInInput The input struct for the function
     */
    function zapIn(ZapInInput memory zapInInput)
        external
        payable
        nonReentrant
        stopInEmergency
    {
        require(zapInInput.vault != address(0), "Vault not defined");
        VaultInfo memory vaultInfo = vaultInfos[zapInInput.vault];
        require(vaultInfo.lpToken != address(0), "Vault not supported");

        // Get the appropriate liquidity implementation
        ILiquidityImplementation liquidityImplementation = ILiquidityImplementation(
                vaultInfo.liquidityRouterImplementation
            );

        // pull the input token from the user to the contract
        uint256 receivedTokens = _pullTokens(
            zapInInput.fromTokenAddress,
            zapInInput.token0Info.tokenShare + zapInInput.token1Info.tokenShare
        );

        // swap the input token to token0 and token1
        (uint256 amountToken0, uint256 amountToken1) = _swapZapIn(
            zapInInput,
            receivedTokens,
            liquidityImplementation.token0(vaultInfo.lpToken),
            liquidityImplementation.token1(vaultInfo.lpToken)
        );

        uint256[2] memory depositAmounts = [amountToken0, amountToken1];
        uint256[2] memory minAmounts = [
            zapInInput.token0Info.minTokenShare,
            zapInInput.token1Info.minTokenShare
        ];

        // provide liquidity in the appropriate liquidity implementation (DEX)
        uint256 lpValue = _provideLiquidityZapIn(
            ProvideLiquidityInput(
                liquidityImplementation.token0(vaultInfo.lpToken),
                liquidityImplementation.token1(vaultInfo.lpToken),
                liquidityImplementation.getSwapRouter(vaultInfo.lpToken),
                vaultInfo.lpToken,
                address(liquidityImplementation),
                depositAmounts,
                minAmounts,
                zapInInput.deadline
            )
        );

        // add the received lp tokens to the vault
        _addToVaultZapIn(
            vaultInfo.lpToken,
            zapInInput.vault,
            zapInInput.referral,
            zapInInput.deadline,
            vaultInfo.vaultType,
            lpValue
        );
        emit ZapIn(
            msg.sender,
            zapInInput.fromTokenAddress,
            zapInInput.vault,
            zapInInput.token0Info.tokenShare + zapInInput.token1Info.tokenShare,
            lpValue
        );
    }

    /**
     * @notice Zaps out the lp tokens in a vault to a destination token. It first withdraws lp tokens from the vault, removes liquidity using the proper liquidity implementation
     * and then (optionally) swaps the tokens to a withdraw token.
     * @param zapOutInput The input struct for the zap out
     */
    function zapOut(ZapOutInput memory zapOutInput)
        external
        nonReentrant
        stopInEmergency
    {
        require(zapOutInput.vault != address(0), "Vault not defined");
        VaultInfo memory vaultInfo = vaultInfos[zapOutInput.vault];
        require(vaultInfo.lpToken != address(0), "Vault not supported");

        // Get the appropriate liquidity implementation
        ILiquidityImplementation liquidityImplementation = ILiquidityImplementation(
                vaultInfo.liquidityRouterImplementation
            );

        // remove lp tokens from the vault
        uint256 withdrawnLp = _removeFromVaultZapOut(
            vaultInfo.lpToken,
            zapOutInput.vault,
            vaultInfo.vaultType,
            zapOutInput.withdrawAmount,
            zapOutInput.deadline
        );

        uint256[2] memory minAmounts = [
            zapOutInput.minTokenShare0,
            zapOutInput.minTokenShare1
        ];

        // remove liquidity from the liquidity implementation (DEX)
        (
            uint256 receivedAmount0,
            uint256 receivedAmount1
        ) = _removeLiquidityZapOut(
                RemoveLiquidityInput(
                    liquidityImplementation.getSwapRouter(vaultInfo.lpToken),
                    vaultInfo.lpToken,
                    address(liquidityImplementation),
                    withdrawnLp,
                    minAmounts,
                    zapOutInput.deadline
                )
            );

        // swap to the appropriate out token and send to the user
        _swapZapOut(
            liquidityImplementation.token0(vaultInfo.lpToken),
            liquidityImplementation.token1(vaultInfo.lpToken),
            receivedAmount0,
            receivedAmount1
        );
        emit ZapOut(
            msg.sender,
            zapOutInput.vault,
            zapOutInput.withdrawAmount,
            receivedAmount0,
            receivedAmount1
        );
    }

    /**
     * @notice Sets the vault info. This defines how a vault is implemented, which lp token it uses and which liqidity implementation (DEX) should be used
     * @param vaultAddress The address of the vault
     * @param lpToken The Lp token for the given vault
     * @param liquidityImplementationAddress The liquidity implementation address for this vault
     * @param vaultType The vault type (either YEARN - new vaults, or GRIZZLY - old vaults)
     */
    function setVaultInfo(
        address vaultAddress,
        address lpToken,
        address liquidityImplementationAddress,
        VaultType vaultType
    ) public onlyOwner {
        vaultInfos[vaultAddress] = VaultInfo(
            lpToken,
            liquidityImplementationAddress,
            vaultType
        );
    }

    /**
     * @notice Sets the vault info in batches
     * @param vaultAddresses The addresses of the vault
     * @param lpTokens The Lp tokens for the given vault
     * @param liquidityImplementationAddresses The liquidity implementations address for this vault
     * @param vaultTypes The vault types (either YEARN - new vaults, or GRIZZLY - old vaults)
     */
    function setVaultInfoBatch(
        address[] memory vaultAddresses,
        address[] memory lpTokens,
        address[] memory liquidityImplementationAddresses,
        VaultType[] memory vaultTypes
    ) external onlyOwner {
        require(
            vaultAddresses.length == lpTokens.length &&
                vaultAddresses.length ==
                liquidityImplementationAddresses.length &&
                vaultAddresses.length == vaultTypes.length,
            "Arraylength missmatch"
        );
        for (uint256 i = 0; i < vaultAddresses.length; i++) {
            setVaultInfo(
                vaultAddresses[i],
                lpTokens[i],
                liquidityImplementationAddresses[i],
                vaultTypes[i]
            );
        }
    }

    /**
     * @notice Helper function to estimate the swap share for the client
     * @param amount The input token amount
     * @param vault The vault which should be used
     * Returns The Shares or token0 and token1 that should be swapped to optimally provide liquidity
     */
    function estimateSwapShare(uint256 amount, address vault)
        external
        view
        returns (uint256 share0, uint256 share1)
    {
        VaultInfo memory vaultInfo = vaultInfos[vault];
        ILiquidityImplementation liquidityImplementation = ILiquidityImplementation(
                vaultInfo.liquidityRouterImplementation
            );
        return
            liquidityImplementation.estimateSwapShare(
                amount,
                vaultInfo.lpToken
            );
    }

    /**
     * @notice Helper function to estimate the out share swaps when zapping out
     * @param lpAmount The lp amount which should be withdrawn
     * @param vault The vault which should be used
     * Returns The Shares or token0 and token1 that should be swapped to optimally get the final out token
     */
    function estimateOutShare(uint256 lpAmount, address vault)
        external
        view
        returns (uint256 share0, uint256 share1)
    {
        VaultInfo memory vaultInfo = vaultInfos[vault];
        ILiquidityImplementation liquidityImplementation = ILiquidityImplementation(
                vaultInfo.liquidityRouterImplementation
            );
        return
            liquidityImplementation.estimateOutShare(
                lpAmount,
                vaultInfo.lpToken
            );
    }

    /**
     * @notice swap in token to token0 and token1
     */
    function _swapZapIn(
        ZapInInput memory input,
        uint256 receivedAmount,
        address token0,
        address token1
    ) internal returns (uint256 amountToken0, uint256 amountToken1) {
        uint256 token0Used;
        uint256 token1Used;
        (amountToken0, token0Used) = _fillQuote(
            input.fromTokenAddress,
            token0,
            input.token0Info.tokenShare,
            input.token0Info.swapTarget,
            input.token0Info.swapData
        );

        (amountToken1, token1Used) = _fillQuote(
            input.fromTokenAddress,
            token1,
            input.token1Info.tokenShare,
            input.token1Info.swapTarget,
            input.token1Info.swapData
        );
        require(
            token0Used + token1Used == receivedAmount,
            "Input shares set wrong"
        );
    }

    /**
     * @notice Provides liquidity in the right DEX
     */
    function _provideLiquidityZapIn(ProvideLiquidityInput memory input)
        internal
        returns (uint256)
    {
        _approveToken(input.token0, input.swapRouter, input.amounts[0]);
        _approveToken(input.token1, input.swapRouter, input.amounts[1]);

        (bool success, bytes memory data) = input
            .liquidityImplementation
            .delegatecall(
                abi.encodeWithSignature(
                    "addLiquidity((address,uint256,uint256,uint256,uint256,address,uint256))",
                    input.lpToken,
                    input.amounts[0],
                    input.amounts[1],
                    input.amountsMin[0],
                    input.amountsMin[1],
                    address(this),
                    input.deadline
                )
            );
        require(success, "Liquidity could not be provided");
        (uint256 unusedToken0, uint256 unusedToken1, uint256 lpValue) = abi
            .decode(data, (uint256, uint256, uint256));

        if (unusedToken0 > 0) {
            _transferToken(input.token0, msg.sender, unusedToken0);
        }
        if (unusedToken1 > 0) {
            _transferToken(input.token1, msg.sender, unusedToken1);
        }
        return lpValue;
    }

    /**
     * @notice Adds the lp tokens to a vault (can be GRIZZLY or YEARN)
     */
    function _addToVaultZapIn(
        address lpToken,
        address vault,
        address referral,
        uint256 deadline,
        VaultType vaultType,
        uint256 lpValue
    ) internal {
        // approve vault
        _approveToken(lpToken, vault, lpValue);

        if (vaultType == VaultType.GRIZZLY) {
            DepositArrays memory empty = DepositArrays(
                new address[](0),
                new uint256[](0)
            );

            uint256 result = IGrizzly(vault).depositLp(
                msg.sender,
                lpValue,
                referral,
                empty.tokens,
                empty.tokens,
                empty.amounts,
                empty.amounts,
                0,
                deadline
            );
        } else if (vaultType == VaultType.YEARN) {
            uint256 iniVaultBal = _getBalance(vault);
            IVault(vault).deposit(lpValue, address(this));
            uint256 tokensReceived = _getBalance(vault) - iniVaultBal;

            _transferToken(vault, msg.sender, tokensReceived);
        } else {
            revert("Vault type not supported");
        }
    }

    /**
     * @notice swap token0 and token1 to output token or ignore if wanted. Then sends the requested tokens to the user
     */
    function _swapZapOut(
        address token0,
        address token1,
        uint256 amountReceived0,
        uint256 amountReceived1
    ) internal {
        if (token0 == wethTokenAddress) {
            IWETH(wethTokenAddress).withdraw(amountReceived0);
            token0 = ETHAddress;
        }
        if (token1 == wethTokenAddress) {
            IWETH(wethTokenAddress).withdraw(amountReceived1);
            token1 = ETHAddress;
        }
        _transferToken(token0, msg.sender, amountReceived0);
        _transferToken(token1, msg.sender, amountReceived1);
    }

    /**
     * @notice remove liquidity in the right DEX
     */
    function _removeLiquidityZapOut(RemoveLiquidityInput memory input)
        internal
        returns (uint256 receivedAmount0, uint256 receivedAmount1)
    {
        // approve swap router
        _approveToken(input.lpToken, input.swapRouter, input.lpValue);

        (bool success, bytes memory data) = input
            .liquidityImplementation
            .delegatecall(
                abi.encodeWithSignature(
                    "removeLiquidity((address,uint256,uint256,uint256,address,uint256))",
                    input.lpToken,
                    input.lpValue,
                    input.minAmounts[0],
                    input.minAmounts[1],
                    address(this),
                    input.deadline
                )
            );
        require(success, "Liquidity could not be withdrawn");
        (receivedAmount0, receivedAmount1) = abi.decode(
            data,
            (uint256, uint256)
        );
    }

    /**
     * @notice revmove lp tokens from the right vault (supports GRIZZLY and YEARN)
     */
    function _removeFromVaultZapOut(
        address lpToken,
        address vault,
        VaultType vaultType,
        uint256 lpValue,
        uint256 deadline
    ) internal returns (uint256) {
        uint256 withdrawnLp;
        if (vaultType == VaultType.GRIZZLY) {
            DepositArrays memory empty = DepositArrays(
                new address[](0),
                new uint256[](0)
            );

            withdrawnLp = IGrizzly(vault).withdrawToLp(
                msg.sender,
                lpValue,
                empty.tokens,
                empty.tokens,
                empty.amounts,
                empty.amounts,
                0,
                deadline
            );
        } else if (vaultType == VaultType.YEARN) {
            _pullTokens(vault, lpValue);
            uint256 iniVaultBal = _getBalance(lpToken);
            IVault(vault).withdraw(lpValue, address(this));
            withdrawnLp = _getBalance(lpToken) - iniVaultBal;
        } else {
            revert("Vault type not supported");
        }
        return withdrawnLp;
    }

    /**
     * @notice use 0x library to swap tokens
     */
    function _fillQuote(
        address fromTokenAddress,
        address toTokenAddress,
        uint256 amount,
        address swapTarget,
        bytes memory swapData
    ) internal returns (uint256 amountBought, uint256 fromTokensUsed) {
        if (fromTokenAddress == toTokenAddress) {
            return (amount, amount);
        }

        if (swapTarget == wethTokenAddress && fromTokenAddress == ETHAddress) {
            IWETH(wethTokenAddress).deposit{value: amount}();
            return (amount, amount);
        }

        if (swapTarget == wethTokenAddress && toTokenAddress == ETHAddress) {
            IWETH(wethTokenAddress).withdraw(amount);
            return (amount, amount);
        }

        uint256 valueToSend;
        if (fromTokenAddress == ETHAddress) {
            valueToSend = amount;
        } else {
            _approveToken(fromTokenAddress, swapTarget, amount);
        }

        uint256 initialBalance = _getBalance(toTokenAddress);
        uint256 initialBalanceInToken = _getBalance(fromTokenAddress);

        require(approvedTargets[swapTarget], "Target not Authorized");
        (bool success, ) = swapTarget.call{value: valueToSend}(swapData);
        require(success, "Error Swapping Tokens");

        amountBought = _getBalance(toTokenAddress) - initialBalance;
        fromTokensUsed = initialBalanceInToken - _getBalance(fromTokenAddress);

        require(amountBought > 0, "Swapped To Invalid Intermediate");
    }
}