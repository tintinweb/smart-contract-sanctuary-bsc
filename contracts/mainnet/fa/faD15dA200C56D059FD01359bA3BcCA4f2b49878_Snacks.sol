// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
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

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Arrays.sol)

pragma solidity ^0.8.0;

import "./StorageSlot.sol";
import "./math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    using StorageSlot for bytes32;

    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (unsafeAccess(array, mid).value > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && unsafeAccess(array, low - 1).value == element) {
            return low - 1;
        } else {
            return low;
        }
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(address[] storage arr, uint256 pos) internal pure returns (StorageSlot.AddressSlot storage) {
        bytes32 slot;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getAddressSlot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(bytes32[] storage arr, uint256 pos) internal pure returns (StorageSlot.Bytes32Slot storage) {
        bytes32 slot;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getBytes32Slot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(uint256[] storage arr, uint256 pos) internal pure returns (StorageSlot.Uint256Slot storage) {
        bytes32 slot;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getUint256Slot();
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivFixedPointOverflow(uint256 prod1);

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);

/// @notice Emitted when one of the inputs is type(int256).min.
error PRBMath__MulDivSignedInputTooSmall();

/// @notice Emitted when the intermediary absolute result overflows int256.
error PRBMath__MulDivSignedOverflow(uint256 rAbs);

/// @notice Emitted when the input is MIN_SD59x18.
error PRBMathSD59x18__AbsInputTooSmall();

/// @notice Emitted when ceiling a number overflows SD59x18.
error PRBMathSD59x18__CeilOverflow(int256 x);

/// @notice Emitted when one of the inputs is MIN_SD59x18.
error PRBMathSD59x18__DivInputTooSmall();

/// @notice Emitted when one of the intermediary unsigned results overflows SD59x18.
error PRBMathSD59x18__DivOverflow(uint256 rAbs);

/// @notice Emitted when the input is greater than 133.084258667509499441.
error PRBMathSD59x18__ExpInputTooBig(int256 x);

/// @notice Emitted when the input is greater than 192.
error PRBMathSD59x18__Exp2InputTooBig(int256 x);

/// @notice Emitted when flooring a number underflows SD59x18.
error PRBMathSD59x18__FloorUnderflow(int256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format overflows SD59x18.
error PRBMathSD59x18__FromIntOverflow(int256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format underflows SD59x18.
error PRBMathSD59x18__FromIntUnderflow(int256 x);

/// @notice Emitted when the product of the inputs is negative.
error PRBMathSD59x18__GmNegativeProduct(int256 x, int256 y);

/// @notice Emitted when multiplying the inputs overflows SD59x18.
error PRBMathSD59x18__GmOverflow(int256 x, int256 y);

/// @notice Emitted when the input is less than or equal to zero.
error PRBMathSD59x18__LogInputTooSmall(int256 x);

/// @notice Emitted when one of the inputs is MIN_SD59x18.
error PRBMathSD59x18__MulInputTooSmall();

/// @notice Emitted when the intermediary absolute result overflows SD59x18.
error PRBMathSD59x18__MulOverflow(uint256 rAbs);

/// @notice Emitted when the intermediary absolute result overflows SD59x18.
error PRBMathSD59x18__PowuOverflow(uint256 rAbs);

/// @notice Emitted when the input is negative.
error PRBMathSD59x18__SqrtNegativeInput(int256 x);

/// @notice Emitted when the calculating the square root overflows SD59x18.
error PRBMathSD59x18__SqrtOverflow(int256 x);

/// @notice Emitted when addition overflows UD60x18.
error PRBMathUD60x18__AddOverflow(uint256 x, uint256 y);

/// @notice Emitted when ceiling a number overflows UD60x18.
error PRBMathUD60x18__CeilOverflow(uint256 x);

/// @notice Emitted when the input is greater than 133.084258667509499441.
error PRBMathUD60x18__ExpInputTooBig(uint256 x);

/// @notice Emitted when the input is greater than 192.
error PRBMathUD60x18__Exp2InputTooBig(uint256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format format overflows UD60x18.
error PRBMathUD60x18__FromUintOverflow(uint256 x);

/// @notice Emitted when multiplying the inputs overflows UD60x18.
error PRBMathUD60x18__GmOverflow(uint256 x, uint256 y);

/// @notice Emitted when the input is less than 1.
error PRBMathUD60x18__LogInputTooSmall(uint256 x);

/// @notice Emitted when the calculating the square root overflows UD60x18.
error PRBMathUD60x18__SqrtOverflow(uint256 x);

/// @notice Emitted when subtraction underflows UD60x18.
error PRBMathUD60x18__SubUnderflow(uint256 x, uint256 y);

/// @dev Common mathematical functions used in both PRBMathSD59x18 and PRBMathUD60x18. Note that this shared library
/// does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal fixed-point
/// representation. When it does not, it is explicitly mentioned in the NatSpec documentation.
library PRBMath {
    /// STRUCTS ///

    struct SD59x18 {
        int256 value;
    }

    struct UD60x18 {
        uint256 value;
    }

    /// STORAGE ///

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @dev Largest power of two divisor of SCALE.
    uint256 internal constant SCALE_LPOTD = 262144;

    /// @dev SCALE inverted mod 2^256.
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661_508869554232690281;

    /// FUNCTIONS ///

    /// @notice Calculates the binary exponent of x using the binary fraction method.
    /// @dev Has to use 192.64-bit fixed-point numbers.
    /// See https://ethereum.stackexchange.com/a/96594/24693.
    /// @param x The exponent as an unsigned 192.64-bit fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp2(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            // Start from 0.5 in the 192.64-bit fixed-point format.
            result = 0x800000000000000000000000000000000000000000000000;

            // Multiply the result by root(2, 2^-i) when the bit at position i is 1. None of the intermediary results overflows
            // because the initial result is 2^191 and all magic factors are less than 2^65.
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }

            // We're doing two things at the same time:
            //
            //   1. Multiply the result by 2^n + 1, where "2^n" is the integer part and the one is added to account for
            //      the fact that we initially set the result to 0.5. This is accomplished by subtracting from 191
            //      rather than 192.
            //   2. Convert the result to the unsigned 60.18-decimal fixed-point format.
            //
            // This works because 2^(191-ip) = 2^ip / 2^191, where "ip" is the integer part "2^n".
            result *= SCALE;
            result >>= (191 - (x >> 64));
        }
    }

    /// @notice Finds the zero-based index of the first one in the binary representation of x.
    /// @dev See the note on msb in the "Find First Set" Wikipedia article https://en.wikipedia.org/wiki/Find_first_set
    /// @param x The uint256 number for which to find the index of the most significant bit.
    /// @return msb The index of the most significant bit as an uint256.
    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            // No need to shift x any more.
            msb += 1;
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The multiplicand as an uint256.
    /// @param y The multiplier as an uint256.
    /// @param denominator The divisor as an uint256.
    /// @return result The result as an uint256.
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2^256 + prod0.
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division.
        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
            return result;
        }

        // Make sure the result is less than 2^256. Also prevents denominator == 0.
        if (prod1 >= denominator) {
            revert PRBMath__MulDivOverflow(prod1, denominator);
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0].
        uint256 remainder;
        assembly {
            // Compute remainder using mulmod.
            remainder := mulmod(x, y, denominator)

            // Subtract 256 bit number from 512 bit number.
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
        // See https://cs.stackexchange.com/q/138556/92363.
        unchecked {
            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by lpotdod.
                denominator := div(denominator, lpotdod)

                // Divide [prod1 prod0] by lpotdod.
                prod0 := div(prod0, lpotdod)

                // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one.
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * lpotdod;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /// @notice Calculates floor(x*y÷1e18) with full precision.
    ///
    /// @dev Variant of "mulDiv" with constant folding, i.e. in which the denominator is always 1e18. Before returning the
    /// final result, we add 1 if (x * y) % SCALE >= HALF_SCALE. Without this, 6.6e-19 would be truncated to 0 instead of
    /// being rounded to 1e-18.  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717.
    ///
    /// Requirements:
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works.
    /// - It is assumed that the result can never be type(uint256).max when x and y solve the following two equations:
    ///     1. x * y = type(uint256).max * SCALE
    ///     2. (x * y) % SCALE >= SCALE / 2
    ///
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert PRBMath__MulDivFixedPointOverflow(prod1);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev An extension of "mulDiv" for signed numbers. Works by computing the signs and the absolute values separately.
    ///
    /// Requirements:
    /// - None of the inputs can be type(int256).min.
    /// - The result must fit within int256.
    ///
    /// @param x The multiplicand as an int256.
    /// @param y The multiplier as an int256.
    /// @param denominator The divisor as an int256.
    /// @return result The result as an int256.
    function mulDivSigned(
        int256 x,
        int256 y,
        int256 denominator
    ) internal pure returns (int256 result) {
        if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
            revert PRBMath__MulDivSignedInputTooSmall();
        }

        // Get hold of the absolute values of x, y and the denominator.
        uint256 ax;
        uint256 ay;
        uint256 ad;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
            ad = denominator < 0 ? uint256(-denominator) : uint256(denominator);
        }

        // Compute the absolute value of (x*y)÷denominator. The result must fit within int256.
        uint256 rAbs = mulDiv(ax, ay, ad);
        if (rAbs > uint256(type(int256).max)) {
            revert PRBMath__MulDivSignedOverflow(rAbs);
        }

        // Get the signs of x, y and the denominator.
        uint256 sx;
        uint256 sy;
        uint256 sd;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
            sd := sgt(denominator, sub(0, 1))
        }

        // XOR over sx, sy and sd. This is checking whether there are one or three negative signs in the inputs.
        // If yes, the result should be negative.
        result = sx ^ sy ^ sd == 0 ? -int256(rAbs) : int256(rAbs);
    }

    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Set the initial guess to the least power of two that is greater than or equal to sqrt(x).
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

import "./PRBMath.sol";

/// @title PRBMathUD60x18
/// @author Paul Razvan Berg
/// @notice Smart contract library for advanced fixed-point math that works with uint256 numbers considered to have 18
/// trailing decimals. We call this number representation unsigned 60.18-decimal fixed-point, since there can be up to 60
/// digits in the integer part and up to 18 decimals in the fractional part. The numbers are bound by the minimum and the
/// maximum values permitted by the Solidity type uint256.
library PRBMathUD60x18 {
    /// @dev Half the SCALE number.
    uint256 internal constant HALF_SCALE = 5e17;

    /// @dev log2(e) as an unsigned 60.18-decimal fixed-point number.
    uint256 internal constant LOG2_E = 1_442695040888963407;

    /// @dev The maximum value an unsigned 60.18-decimal fixed-point number can have.
    uint256 internal constant MAX_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_584007913129639935;

    /// @dev The maximum whole value an unsigned 60.18-decimal fixed-point number can have.
    uint256 internal constant MAX_WHOLE_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_000000000000000000;

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @notice Calculates the arithmetic average of x and y, rounding down.
    /// @param x The first operand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The second operand as an unsigned 60.18-decimal fixed-point number.
    /// @return result The arithmetic average as an unsigned 60.18-decimal fixed-point number.
    function avg(uint256 x, uint256 y) internal pure returns (uint256 result) {
        // The operations can never overflow.
        unchecked {
            // The last operand checks if both x and y are odd and if that is the case, we add 1 to the result. We need
            // to do this because if both numbers are odd, the 0.5 remainder gets truncated twice.
            result = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    /// @notice Yields the least unsigned 60.18 decimal fixed-point number greater than or equal to x.
    ///
    /// @dev Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional counterparts.
    /// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
    ///
    /// Requirements:
    /// - x must be less than or equal to MAX_WHOLE_UD60x18.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number to ceil.
    /// @param result The least integer greater than or equal to x, as an unsigned 60.18-decimal fixed-point number.
    function ceil(uint256 x) internal pure returns (uint256 result) {
        if (x > MAX_WHOLE_UD60x18) {
            revert PRBMathUD60x18__CeilOverflow(x);
        }
        assembly {
            // Equivalent to "x % SCALE" but faster.
            let remainder := mod(x, SCALE)

            // Equivalent to "SCALE - remainder" but faster.
            let delta := sub(SCALE, remainder)

            // Equivalent to "x + delta * (remainder > 0 ? 1 : 0)" but faster.
            result := add(x, mul(delta, gt(remainder, 0)))
        }
    }

    /// @notice Divides two unsigned 60.18-decimal fixed-point numbers, returning a new unsigned 60.18-decimal fixed-point number.
    ///
    /// @dev Uses mulDiv to enable overflow-safe multiplication and division.
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    ///
    /// @param x The numerator as an unsigned 60.18-decimal fixed-point number.
    /// @param y The denominator as an unsigned 60.18-decimal fixed-point number.
    /// @param result The quotient as an unsigned 60.18-decimal fixed-point number.
    function div(uint256 x, uint256 y) internal pure returns (uint256 result) {
        result = PRBMath.mulDiv(x, SCALE, y);
    }

    /// @notice Returns Euler's number as an unsigned 60.18-decimal fixed-point number.
    /// @dev See https://en.wikipedia.org/wiki/E_(mathematical_constant).
    function e() internal pure returns (uint256 result) {
        result = 2_718281828459045235;
    }

    /// @notice Calculates the natural exponent of x.
    ///
    /// @dev Based on the insight that e^x = 2^(x * log2(e)).
    ///
    /// Requirements:
    /// - All from "log2".
    /// - x must be less than 133.084258667509499441.
    ///
    /// @param x The exponent as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp(uint256 x) internal pure returns (uint256 result) {
        // Without this check, the value passed to "exp2" would be greater than 192.
        if (x >= 133_084258667509499441) {
            revert PRBMathUD60x18__ExpInputTooBig(x);
        }

        // Do the fixed-point multiplication inline to save gas.
        unchecked {
            uint256 doubleScaleProduct = x * LOG2_E;
            result = exp2((doubleScaleProduct + HALF_SCALE) / SCALE);
        }
    }

    /// @notice Calculates the binary exponent of x using the binary fraction method.
    ///
    /// @dev See https://ethereum.stackexchange.com/q/79903/24693.
    ///
    /// Requirements:
    /// - x must be 192 or less.
    /// - The result must fit within MAX_UD60x18.
    ///
    /// @param x The exponent as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp2(uint256 x) internal pure returns (uint256 result) {
        // 2^192 doesn't fit within the 192.64-bit format used internally in this function.
        if (x >= 192e18) {
            revert PRBMathUD60x18__Exp2InputTooBig(x);
        }

        unchecked {
            // Convert x to the 192.64-bit fixed-point format.
            uint256 x192x64 = (x << 64) / SCALE;

            // Pass x to the PRBMath.exp2 function, which uses the 192.64-bit fixed-point number representation.
            result = PRBMath.exp2(x192x64);
        }
    }

    /// @notice Yields the greatest unsigned 60.18 decimal fixed-point number less than or equal to x.
    /// @dev Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional counterparts.
    /// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
    /// @param x The unsigned 60.18-decimal fixed-point number to floor.
    /// @param result The greatest integer less than or equal to x, as an unsigned 60.18-decimal fixed-point number.
    function floor(uint256 x) internal pure returns (uint256 result) {
        assembly {
            // Equivalent to "x % SCALE" but faster.
            let remainder := mod(x, SCALE)

            // Equivalent to "x - remainder * (remainder > 0 ? 1 : 0)" but faster.
            result := sub(x, mul(remainder, gt(remainder, 0)))
        }
    }

    /// @notice Yields the excess beyond the floor of x.
    /// @dev Based on the odd function definition https://en.wikipedia.org/wiki/Fractional_part.
    /// @param x The unsigned 60.18-decimal fixed-point number to get the fractional part of.
    /// @param result The fractional part of x as an unsigned 60.18-decimal fixed-point number.
    function frac(uint256 x) internal pure returns (uint256 result) {
        assembly {
            result := mod(x, SCALE)
        }
    }

    /// @notice Converts a number from basic integer form to unsigned 60.18-decimal fixed-point representation.
    ///
    /// @dev Requirements:
    /// - x must be less than or equal to MAX_UD60x18 divided by SCALE.
    ///
    /// @param x The basic integer to convert.
    /// @param result The same number in unsigned 60.18-decimal fixed-point representation.
    function fromUint(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            if (x > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__FromUintOverflow(x);
            }
            result = x * SCALE;
        }
    }

    /// @notice Calculates geometric mean of x and y, i.e. sqrt(x * y), rounding down.
    ///
    /// @dev Requirements:
    /// - x * y must fit within MAX_UD60x18, lest it overflows.
    ///
    /// @param x The first operand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The second operand as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function gm(uint256 x, uint256 y) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        unchecked {
            // Checking for overflow this way is faster than letting Solidity do it.
            uint256 xy = x * y;
            if (xy / x != y) {
                revert PRBMathUD60x18__GmOverflow(x, y);
            }

            // We don't need to multiply by the SCALE here because the x*y product had already picked up a factor of SCALE
            // during multiplication. See the comments within the "sqrt" function.
            result = PRBMath.sqrt(xy);
        }
    }

    /// @notice Calculates 1 / x, rounding toward zero.
    ///
    /// @dev Requirements:
    /// - x cannot be zero.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the inverse.
    /// @return result The inverse as an unsigned 60.18-decimal fixed-point number.
    function inv(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            // 1e36 is SCALE * SCALE.
            result = 1e36 / x;
        }
    }

    /// @notice Calculates the natural logarithm of x.
    ///
    /// @dev Based on the insight that ln(x) = log2(x) / log2(e).
    ///
    /// Requirements:
    /// - All from "log2".
    ///
    /// Caveats:
    /// - All from "log2".
    /// - This doesn't return exactly 1 for 2.718281828459045235, for that we would need more fine-grained precision.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the natural logarithm.
    /// @return result The natural logarithm as an unsigned 60.18-decimal fixed-point number.
    function ln(uint256 x) internal pure returns (uint256 result) {
        // Do the fixed-point multiplication inline to save gas. This is overflow-safe because the maximum value that log2(x)
        // can return is 196205294292027477728.
        unchecked {
            result = (log2(x) * SCALE) / LOG2_E;
        }
    }

    /// @notice Calculates the common logarithm of x.
    ///
    /// @dev First checks if x is an exact power of ten and it stops if yes. If it's not, calculates the common
    /// logarithm based on the insight that log10(x) = log2(x) / log2(10).
    ///
    /// Requirements:
    /// - All from "log2".
    ///
    /// Caveats:
    /// - All from "log2".
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the common logarithm.
    /// @return result The common logarithm as an unsigned 60.18-decimal fixed-point number.
    function log10(uint256 x) internal pure returns (uint256 result) {
        if (x < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(x);
        }

        // Note that the "mul" in this block is the assembly multiplication operation, not the "mul" function defined
        // in this contract.
        // prettier-ignore
        assembly {
            switch x
            case 1 { result := mul(SCALE, sub(0, 18)) }
            case 10 { result := mul(SCALE, sub(1, 18)) }
            case 100 { result := mul(SCALE, sub(2, 18)) }
            case 1000 { result := mul(SCALE, sub(3, 18)) }
            case 10000 { result := mul(SCALE, sub(4, 18)) }
            case 100000 { result := mul(SCALE, sub(5, 18)) }
            case 1000000 { result := mul(SCALE, sub(6, 18)) }
            case 10000000 { result := mul(SCALE, sub(7, 18)) }
            case 100000000 { result := mul(SCALE, sub(8, 18)) }
            case 1000000000 { result := mul(SCALE, sub(9, 18)) }
            case 10000000000 { result := mul(SCALE, sub(10, 18)) }
            case 100000000000 { result := mul(SCALE, sub(11, 18)) }
            case 1000000000000 { result := mul(SCALE, sub(12, 18)) }
            case 10000000000000 { result := mul(SCALE, sub(13, 18)) }
            case 100000000000000 { result := mul(SCALE, sub(14, 18)) }
            case 1000000000000000 { result := mul(SCALE, sub(15, 18)) }
            case 10000000000000000 { result := mul(SCALE, sub(16, 18)) }
            case 100000000000000000 { result := mul(SCALE, sub(17, 18)) }
            case 1000000000000000000 { result := 0 }
            case 10000000000000000000 { result := SCALE }
            case 100000000000000000000 { result := mul(SCALE, 2) }
            case 1000000000000000000000 { result := mul(SCALE, 3) }
            case 10000000000000000000000 { result := mul(SCALE, 4) }
            case 100000000000000000000000 { result := mul(SCALE, 5) }
            case 1000000000000000000000000 { result := mul(SCALE, 6) }
            case 10000000000000000000000000 { result := mul(SCALE, 7) }
            case 100000000000000000000000000 { result := mul(SCALE, 8) }
            case 1000000000000000000000000000 { result := mul(SCALE, 9) }
            case 10000000000000000000000000000 { result := mul(SCALE, 10) }
            case 100000000000000000000000000000 { result := mul(SCALE, 11) }
            case 1000000000000000000000000000000 { result := mul(SCALE, 12) }
            case 10000000000000000000000000000000 { result := mul(SCALE, 13) }
            case 100000000000000000000000000000000 { result := mul(SCALE, 14) }
            case 1000000000000000000000000000000000 { result := mul(SCALE, 15) }
            case 10000000000000000000000000000000000 { result := mul(SCALE, 16) }
            case 100000000000000000000000000000000000 { result := mul(SCALE, 17) }
            case 1000000000000000000000000000000000000 { result := mul(SCALE, 18) }
            case 10000000000000000000000000000000000000 { result := mul(SCALE, 19) }
            case 100000000000000000000000000000000000000 { result := mul(SCALE, 20) }
            case 1000000000000000000000000000000000000000 { result := mul(SCALE, 21) }
            case 10000000000000000000000000000000000000000 { result := mul(SCALE, 22) }
            case 100000000000000000000000000000000000000000 { result := mul(SCALE, 23) }
            case 1000000000000000000000000000000000000000000 { result := mul(SCALE, 24) }
            case 10000000000000000000000000000000000000000000 { result := mul(SCALE, 25) }
            case 100000000000000000000000000000000000000000000 { result := mul(SCALE, 26) }
            case 1000000000000000000000000000000000000000000000 { result := mul(SCALE, 27) }
            case 10000000000000000000000000000000000000000000000 { result := mul(SCALE, 28) }
            case 100000000000000000000000000000000000000000000000 { result := mul(SCALE, 29) }
            case 1000000000000000000000000000000000000000000000000 { result := mul(SCALE, 30) }
            case 10000000000000000000000000000000000000000000000000 { result := mul(SCALE, 31) }
            case 100000000000000000000000000000000000000000000000000 { result := mul(SCALE, 32) }
            case 1000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 33) }
            case 10000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 34) }
            case 100000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 35) }
            case 1000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 36) }
            case 10000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 37) }
            case 100000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 38) }
            case 1000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 39) }
            case 10000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 40) }
            case 100000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 41) }
            case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 42) }
            case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 43) }
            case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 44) }
            case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 45) }
            case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 46) }
            case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 47) }
            case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 48) }
            case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 49) }
            case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 50) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 51) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 52) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 53) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 54) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 55) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 56) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 57) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 58) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 59) }
            default {
                result := MAX_UD60x18
            }
        }

        if (result == MAX_UD60x18) {
            // Do the fixed-point division inline to save gas. The denominator is log2(10).
            unchecked {
                result = (log2(x) * SCALE) / 3_321928094887362347;
            }
        }
    }

    /// @notice Calculates the binary logarithm of x.
    ///
    /// @dev Based on the iterative approximation algorithm.
    /// https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation
    ///
    /// Requirements:
    /// - x must be greater than or equal to SCALE, otherwise the result would be negative.
    ///
    /// Caveats:
    /// - The results are nor perfectly accurate to the last decimal, due to the lossy precision of the iterative approximation.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the binary logarithm.
    /// @return result The binary logarithm as an unsigned 60.18-decimal fixed-point number.
    function log2(uint256 x) internal pure returns (uint256 result) {
        if (x < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(x);
        }
        unchecked {
            // Calculate the integer part of the logarithm and add it to the result and finally calculate y = x * 2^(-n).
            uint256 n = PRBMath.mostSignificantBit(x / SCALE);

            // The integer part of the logarithm as an unsigned 60.18-decimal fixed-point number. The operation can't overflow
            // because n is maximum 255 and SCALE is 1e18.
            result = n * SCALE;

            // This is y = x * 2^(-n).
            uint256 y = x >> n;

            // If y = 1, the fractional part is zero.
            if (y == SCALE) {
                return result;
            }

            // Calculate the fractional part via the iterative approximation.
            // The "delta >>= 1" part is equivalent to "delta /= 2", but shifting bits is faster.
            for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                // Is y^2 > 2 and so in the range [2,4)?
                if (y >= 2 * SCALE) {
                    // Add the 2^(-m) factor to the logarithm.
                    result += delta;

                    // Corresponds to z/2 on Wikipedia.
                    y >>= 1;
                }
            }
        }
    }

    /// @notice Multiplies two unsigned 60.18-decimal fixed-point numbers together, returning a new unsigned 60.18-decimal
    /// fixed-point number.
    /// @dev See the documentation for the "PRBMath.mulDivFixedPoint" function.
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The product as an unsigned 60.18-decimal fixed-point number.
    function mul(uint256 x, uint256 y) internal pure returns (uint256 result) {
        result = PRBMath.mulDivFixedPoint(x, y);
    }

    /// @notice Returns PI as an unsigned 60.18-decimal fixed-point number.
    function pi() internal pure returns (uint256 result) {
        result = 3_141592653589793238;
    }

    /// @notice Raises x to the power of y.
    ///
    /// @dev Based on the insight that x^y = 2^(log2(x) * y).
    ///
    /// Requirements:
    /// - All from "exp2", "log2" and "mul".
    ///
    /// Caveats:
    /// - All from "exp2", "log2" and "mul".
    /// - Assumes 0^0 is 1.
    ///
    /// @param x Number to raise to given power y, as an unsigned 60.18-decimal fixed-point number.
    /// @param y Exponent to raise x to, as an unsigned 60.18-decimal fixed-point number.
    /// @return result x raised to power y, as an unsigned 60.18-decimal fixed-point number.
    function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {
        if (x == 0) {
            result = y == 0 ? SCALE : uint256(0);
        } else {
            result = exp2(mul(log2(x), y));
        }
    }

    /// @notice Raises x (unsigned 60.18-decimal fixed-point number) to the power of y (basic unsigned integer) using the
    /// famous algorithm "exponentiation by squaring".
    ///
    /// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    ///
    /// Requirements:
    /// - The result must fit within MAX_UD60x18.
    ///
    /// Caveats:
    /// - All from "mul".
    /// - Assumes 0^0 is 1.
    ///
    /// @param x The base as an unsigned 60.18-decimal fixed-point number.
    /// @param y The exponent as an uint256.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function powu(uint256 x, uint256 y) internal pure returns (uint256 result) {
        // Calculate the first iteration of the loop in advance.
        result = y & 1 > 0 ? x : SCALE;

        // Equivalent to "for(y /= 2; y > 0; y /= 2)" but faster.
        for (y >>= 1; y > 0; y >>= 1) {
            x = PRBMath.mulDivFixedPoint(x, x);

            // Equivalent to "y % 2 == 1" but faster.
            if (y & 1 > 0) {
                result = PRBMath.mulDivFixedPoint(result, x);
            }
        }
    }

    /// @notice Returns 1 as an unsigned 60.18-decimal fixed-point number.
    function scale() internal pure returns (uint256 result) {
        result = SCALE;
    }

    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    ///
    /// Requirements:
    /// - x must be less than MAX_UD60x18 / SCALE.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the square root.
    /// @return result The result as an unsigned 60.18-decimal fixed-point .
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            if (x > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__SqrtOverflow(x);
            }
            // Multiply x by the SCALE to account for the factor of SCALE that is picked up when multiplying two unsigned
            // 60.18-decimal fixed-point numbers together (in this case, those two numbers are both the square root).
            result = PRBMath.sqrt(x * SCALE);
        }
    }

    /// @notice Converts a unsigned 60.18-decimal fixed-point number to basic integer form, rounding down in the process.
    /// @param x The unsigned 60.18-decimal fixed-point number to convert.
    /// @return result The same number in basic integer form.
    function toUint(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            result = x / SCALE;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Arrays.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@prb/math/contracts/PRBMathUD60x18.sol";

import "./base/SnacksBase.sol";
import "./interfaces/ISnacks.sol";
import "./interfaces/IMultipleRewardPool.sol";
import "./interfaces/ISnacksPool.sol";
import "./interfaces/ILunchBox.sol";

contract Snacks is ISnacks, SnacksBase {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using Arrays for uint256[];
    using Counters for Counters.Counter;
    using PRBMathUD60x18 for uint256;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    uint256 private constant STEP = 0.000001 * 1e18;
    uint256 private constant CORRELATION_FACTOR = 1e24;
    uint256 private constant TOTAL_SUPPLY_FACTOR = 1e6;
    uint256 private constant PULSE_FEE_PERCENT = 3500;
    uint256 private constant POOL_REWARD_DISTRIBUTOR_FEE_PERCENT = 4500;
    uint256 private constant SENIORAGE_FEE_PERCENT = 500;
    
    address public btcSnacks;
    address public ethSnacks;
    address public snacksPool;
    address public lunchBox;
    uint256 private _btcSnacksFeeAmountStored;
    uint256 private _ethSnacksFeeAmountStored;
    Counters.Counter private _currentSnapshotId;
    
    mapping(uint256 => uint256) public snapshotIdToBtcSnacksFeeAmount;
    mapping(uint256 => uint256) public snapshotIdToEthSnacksFeeAmount;
    mapping(address => uint256) private _btcSnacksStartIndexPerAccount;
    mapping(address => uint256) private _ethSnacksStartIndexPerAccount;
    mapping(address => Snapshots) private _accountBalanceAndDepositSnapshots;
    uint256[] private _btcSnacksFeeSnapshots;
    uint256[] private _ethSnacksFeeSnapshots;
    Snapshots private _holderSupplySnapshots;
    
    event Snapshot(uint256 id);
    event BtcSnacksFeeAdded(uint256 feeAmount);
    event EthSnacksFeeAdded(uint256 feeAmount);
    
    modifier onlyBtcSnacks {
        require(
            msg.sender == btcSnacks,
            "Snacks: caller is not the BtcSnacks contract"
        );
        _;
    }
    
    modifier onlyEthSnacks {
        require(
            msg.sender == ethSnacks,
            "Snacks: caller is not the EthSnacks contract"
        );
        _;
    }
    
    constructor()
        SnacksBase(
            STEP,
            CORRELATION_FACTOR,
            TOTAL_SUPPLY_FACTOR,
            PULSE_FEE_PERCENT,
            POOL_REWARD_DISTRIBUTOR_FEE_PERCENT,
            SENIORAGE_FEE_PERCENT,
            "Snacks",
            "SNACK"
        )
    {}
    
    /**
    * @notice Configures the contract.
    * @dev Could be called by the owner in case of resetting addresses.
    * @param zoinks_ Zoinks token address.
    * @param pulse_ Pulse contract address.
    * @param poolRewardDistributor_ PoolRewardDistributor contract address.
    * @param seniorage_ Seniorage contract address.
    * @param snacksPool_ SnacksPool contract address.
    * @param pancakeSwapPool_ PancakeSwapPool contract address.
    * @param lunchBox_ LunchBox contract address.
    * @param authority_ Authorised address.
    * @param btcSnacks_ BtcSnacks token address.
    * @param ethSnacks_ EthSnacks token address.
    */
    function configure(
        address zoinks_,
        address pulse_,
        address poolRewardDistributor_,
        address seniorage_,
        address snacksPool_,
        address pancakeSwapPool_,
        address lunchBox_,
        address authority_,
        address btcSnacks_,
        address ethSnacks_
    )
        external
        onlyOwner
    {
        _configure(
            zoinks_,
            pulse_,
            poolRewardDistributor_,
            seniorage_,
            snacksPool_,
            pancakeSwapPool_,
            lunchBox_,
            authority_
        );
        snacksPool = snacksPool_;
        lunchBox = lunchBox_;
        btcSnacks = btcSnacks_;
        ethSnacks = ethSnacks_;
        _excludedHolders.add(btcSnacks_);
        _excludedHolders.add(ethSnacks_);
    }
    
    /**
    * @notice Notifies the contract about the incoming fee in BtcSnacks token.
    * @dev The `distributeFee()` function in the BtcSnacks contract must be called before
    * the `distributeFee()` function in the Snacks contract.
    * @param feeAmount_ Fee amount.
    */
    function notifyBtcSnacksFeeAmount(uint256 feeAmount_) external onlyBtcSnacks {
        _btcSnacksFeeAmountStored += feeAmount_;
        emit BtcSnacksFeeAdded(feeAmount_);
    }
    
    /**
    * @notice Notifies the contract about the incoming fee in EthSnacks token.
    * @dev The `distributeFee()` function in the EthSnacks contract must be called before
    * the `distributeFee()` function in the Snacks contract.
    * @param feeAmount_ Fee amount.
    */
    function notifyEthSnacksFeeAmount(uint256 feeAmount_) external onlyEthSnacks {
        _ethSnacksFeeAmountStored += feeAmount_;
        emit EthSnacksFeeAdded(feeAmount_);
    }
    
    /**
    * @notice Withdraws all the fee earned by the holder in BtcSnacks token.
    * @dev Theoretically, there may not be enough gas to execute this function 
    * if the holder has not withdrawn his fee for a long time. 
    * In this case, he needs to use the `withdrawBtcSnacks(offset)` function.
    */
    function withdrawBtcSnacks() external whenNotPaused nonReentrant {
        (uint256 newStartIndex, uint256 feeAmount) = getPendingBtcSnacks();
        _withdrawBtcSnacks(newStartIndex, feeAmount);
    }
    
    /**
    * @notice Withdraws the fee earned by the holder in BtcSnacks token in parts.
    * @dev Used when there is not enough gas to execute the `withdrawBtcSnacks()` function.
    * @param offset_ Number of unused withdrawals of the earned fee.
    */
    function withdrawBtcSnacks(uint256 offset_) external whenNotPaused nonReentrant {
        (uint256 newStartIndex, uint256 feeAmount) = getPendingBtcSnacks(offset_);
        _withdrawBtcSnacks(newStartIndex, feeAmount);
    }
    
    /**
    * @notice Withdraws all the fee earned by the holder in EthSnacks token.
    * @dev Theoretically, there may not be enough gas to perform this function 
    * if the holder has not withdrawn his fee for a long time. 
    * In this case, he needs to use the `withdrawEthSnacks(offset)` function.
    */
    function withdrawEthSnacks() external whenNotPaused nonReentrant {
        (uint256 newStartIndex, uint256 feeAmount) = getPendingEthSnacks();
        _withdrawEthSnacks(newStartIndex, feeAmount);
    }
    
    /**
    * @notice Withdraws the fee earned by the holder in EthSnacks token in parts.
    * @dev Used when there is not enough gas to execute the `withdrawEthSnacks()` function.
    * @param offset_ Number of unused withdrawals of the earned fee.
    */
    function withdrawEthSnacks(uint256 offset_) external whenNotPaused nonReentrant {
        (uint256 newStartIndex, uint256 feeAmount) = getPendingEthSnacks(offset_);
        _withdrawEthSnacks(newStartIndex, feeAmount);
    }
    
    /**
    * @notice Retrieves all the fee earned by the holder in BtcSnacks token.
    * @dev Executed inside the `withdrawBtcSnacks()` function, since the upper limit 
    * of the count is equal to the total number of fee distributions.
    * @return New start index (if it makes sense) and all the fee earned by the holder
    * in BtcSnacks token.
    */
    function getPendingBtcSnacks() public view returns (uint256, uint256) {
        uint256 startIndex = _btcSnacksStartIndexPerAccount[msg.sender];
        return _calculatePending(startIndex, _btcSnacksFeeSnapshots.length, true);
    }
    
    /**
    * @notice Retrieves the fee earned by the holder in BtcSnacks token for some number
    * of unused withdrawals.
    * @dev Executed inside the `withdrawBtcSnacks(offset)` function, since the upper limit 
    * of the count is equal to `starting index + offset`.
    * @param offset_ Number of unused withdrawals of the earned fee.
    * @return New start index (if it makes sense) and the fee earned by the holder 
    * in BtcSnacks token for some number of unused withdrawals.
    */
    function getPendingBtcSnacks(
        uint256 offset_
    )
        public
        view
        returns (uint256, uint256)
    {
        require(
            offset_ <= getAvailableBtcSnacksOffsetByAccount(msg.sender),
            "Snacks: invalid offset"
        );
        uint256 startIndex = _btcSnacksStartIndexPerAccount[msg.sender];
        return _calculatePending(startIndex, startIndex + offset_, true);
    }
    
    /**
    * @notice Retrieves all the fee earned by the holder in EthSnacks token.
    * @dev Executed inside the `withdrawEthSnacks()` function, since the upper limit 
    * of the count is equal to the total number of fee distributions.
    * @return New start index (if it makes sense) and all the fee earned by the holder
    * in EthSnacks token.
    */
    function getPendingEthSnacks() public view returns (uint256, uint256) {
        uint256 startIndex = _ethSnacksStartIndexPerAccount[msg.sender];
        return _calculatePending(startIndex, _ethSnacksFeeSnapshots.length, false);
    }
    
    /**
    * @notice Retrieves the fee earned by the holder in EthSnacks token for some number
    * of unused withdrawals.
    * @dev Executed inside the `withdrawEthSnacks(offset)` function, since the upper limit 
    * of the count is equal to `starting index + offset`.
    * @param offset_ Number of unused withdrawals of the earned fee.
    * @return New start index (if it makes sense) and the fee earned by the holder 
    * in EthSnacks token for some number of unused withdrawals.
    */
    function getPendingEthSnacks(
        uint256 offset_
    )
        public
        view
        returns (uint256, uint256)
    {
        require(
            offset_ <= getAvailableEthSnacksOffsetByAccount(msg.sender),
            "Snacks: invalid offset"
        );
        uint256 startIndex = _ethSnacksStartIndexPerAccount[msg.sender];
        return _calculatePending(startIndex, startIndex + offset_, false);
    }
    
    /**
    * @notice Retrieves a number of unused withdrawals of the earned fee in BtcSnacks token.
    * @dev Used as a check inside the `getPendingBtcSnacks(offset)` function.
    * @param account_ Account address.
    * @return Number of unused withdrawals of the earned fee.
    */
    function getAvailableBtcSnacksOffsetByAccount(
        address account_
    )
        public
        view
        returns (uint256)
    {
        uint256 startIndex = _btcSnacksStartIndexPerAccount[account_];
        uint256 endIndex = _btcSnacksFeeSnapshots.length;
        return endIndex - startIndex;
    }
    
    /**
    * @notice Retrieves a number of unused withdrawals of the earned fee in EthSnacks token.
    * @dev Used as a check inside the `getPendingEthSnacks(offset)` function.
    * @param account_ Account address.
    * @return Number of unused withdrawals of the earned fee.
    */
    function getAvailableEthSnacksOffsetByAccount(
        address account_
    )
        public
        view
        returns (uint256)
    {
        uint256 startIndex = _ethSnacksStartIndexPerAccount[account_];
        uint256 endIndex = _ethSnacksFeeSnapshots.length;
        return endIndex - startIndex;
    }
    
    /** 
    * @notice Retrieves summed up the balance and deposit of an account.
    * @dev The function is utilized in order to take into account the deposit 
    * of users in SnacksPool contract in the calculation of earned fees.
    * @param account_ Account address.
    * @return Account balance and deposit amount.
    */
    function balanceAndDepositOf(address account_) public view returns (uint256) {
        return IMultipleRewardPool(snacksPool).getBalance(account_) + balanceOf(account_);
    }

    /**
    * @notice Retrieves summed up the balance and deposit of an account at the time `snapshotId_` was created.
    * @dev The function is utilized for the correct calculation of fees each holder belongs to.
    * @param account_ Account address.
    * @param snapshotId_ Snapshot ID.
    * @return Accounts sum of balance and deposit amount at the time `snapshotId_` was created.
    */
    function balanceAndDepositOfAt(
        address account_, 
        uint256 snapshotId_
    ) 
        public 
        view  
        returns (uint256) 
    {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId_, _accountBalanceAndDepositSnapshots[account_]);
        return snapshotted ? value : balanceAndDepositOf(account_);
    }

    /**
    * @notice Retrieves the holder supply at the time `snapshotId_` was created.
    * @dev The function is utilized for the correct calculation of fees each holder belongs to.
    * @param snapshotId_ Snapshot ID.
    * @return Holder supply at the time `snapshotId_` was created.
    */
    function holderSupplyAt(
        uint256 snapshotId_
    ) 
        public 
        view 
        returns (uint256) 
    {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId_, _holderSupplySnapshots);
        return snapshotted ? value : _totalSupply - getExcludedBalance();
    }

    /**
    * @notice Gets total balance and deposit amount of all excluded holders.
    * @dev Overriden for taking into account not excluded holders deposits.
    * @return Total balance and deposit amount of all excluded holders.
    */
    function getExcludedBalance() public override view returns (uint256) {
        uint256 excludedBalance;
        for (uint256 i = 0; i < _excludedHolders.length(); i++) {
            excludedBalance += balanceOf(_excludedHolders.at(i));
        }
        excludedBalance -= ISnacksPool(snacksPool).getNotExcludedHoldersSupply();
        return excludedBalance;
    }

    /**
    * @notice Retrieves the current snapshot ID.
    * @dev Utilized to properly update and retrieve data.
    * @return Current snapshot ID.
    */
    function getCurrentSnapshotId() public view returns (uint256) {
        return _currentSnapshotId.current();
    }
    
    /**
    * @notice Hook that is called inside `distributeFee()` function.
    * @dev In addition to the standard behavior, the function updates the information about the 
    * received fee in the BtcSnacks tokens and EthSnacks tokens and takes a snapshot.
    * @param undistributedFee_ Amount of undistributed fee left.
    */
    function _afterDistributeFee(uint256 undistributedFee_) internal override {
        uint256 excludedBalance = getExcludedBalance();
        uint256 holdersBalance = _totalSupply - excludedBalance;
        if (undistributedFee_ != 0) {
            uint256 seniorageFeeAmount = undistributedFee_ / 10;
            _transfer(address(this), seniorage, seniorageFeeAmount);
            if (holdersBalance != 0) {
                address snacksPoolAddress = snacksPool;
                undistributedFee_ -= seniorageFeeAmount;
                uint256 notExcludedHoldersSupplyBefore = ISnacksPool(snacksPoolAddress).getNotExcludedHoldersSupply();
                uint256 totalSupplyBefore = ISnacksPool(snacksPoolAddress).getTotalSupply();
                uint256 lunchBoxParticipantsTotalSupplyBefore = ISnacksPool(snacksPoolAddress).getLunchBoxParticipantsTotalSupply();
                adjustmentFactor = adjustmentFactor.mul((holdersBalance + undistributedFee_).div(holdersBalance));
                uint256 difference = ISnacksPool(snacksPoolAddress).getNotExcludedHoldersSupply() - notExcludedHoldersSupplyBefore;
                _adjustedBalances[snacksPoolAddress] += difference;
                ISnacksPool(snacksPoolAddress).updateTotalSupplyFactor(totalSupplyBefore);
                ILunchBox(lunchBox).updateTotalSupplyFactor(lunchBoxParticipantsTotalSupplyBefore);
                _adjustedBalances[address(this)] = 0;
                emit RewardForHolders(undistributedFee_);
            }
        }
        uint256 currentId = _snapshot();
        if (_btcSnacksFeeAmountStored != 0) {
            _btcSnacksFeeSnapshots.push(currentId);
            snapshotIdToBtcSnacksFeeAmount[currentId] = _btcSnacksFeeAmountStored;
            _btcSnacksFeeAmountStored = 0;
        }
        if (_ethSnacksFeeAmountStored != 0) {
            _ethSnacksFeeSnapshots.push(currentId);
            snapshotIdToEthSnacksFeeAmount[currentId] = _ethSnacksFeeAmountStored;
            _ethSnacksFeeAmountStored = 0;
        }
    }
    
    /**
    * @notice Updates snapshots after the values are modified. 
    * @dev Executed for `_mint()`, `_burn()`, and `_transfer()` functions.
    * @param from_ Address from which tokens are sent.
    * @param to_ Address to which tokens are sent.
    */
    function _afterTokenTransfer(
        address from_,
        address to_
    )
        internal
        override
    {
        if (from_ == address(0)) {
            _updateAccountBalanceAndDeposit(to_);
            _updateHolderSupply();
        } else if (to_ == address(0)) {
            _updateAccountBalanceAndDeposit(from_);
            _updateHolderSupply();
        } else {
            _updateAccountBalanceAndDeposit(from_);
            _updateAccountBalanceAndDeposit(to_);
        }
    }
    
    /**
    * @notice Sends the calculated amount of fee earned in BtcSnacks token to the holder 
    * and updates the starting index.
    * @dev Implemented to allow modularity in the contract.
    * @param newStartIndex_ New start index.
    * @param feeAmount_ Fee earned by the holder in BtcSnacks token.
    */
    function _withdrawBtcSnacks(
        uint256 newStartIndex_,
        uint256 feeAmount_
    )
        private
    {
        if (newStartIndex_ != _btcSnacksStartIndexPerAccount[msg.sender]) {
            _btcSnacksStartIndexPerAccount[msg.sender] = newStartIndex_;
        }
        if (feeAmount_ != 0) {
            IERC20(btcSnacks).safeTransfer(msg.sender, feeAmount_);
        }
    }
    
    /**
    * @notice Sends the calculated amount of fee earned in EthSnacks token to the holder 
    * and updates the starting index.
    * @dev Implemented to allow modularity in the contract.
    * @param newStartIndex_ New start index.
    * @param feeAmount_ Fee earned by the holder in EthSnacks token.
    */
    function _withdrawEthSnacks(
        uint256 newStartIndex_,
        uint256 feeAmount_
    )
        private
    {
        if (newStartIndex_ != _ethSnacksStartIndexPerAccount[msg.sender]) {
            _ethSnacksStartIndexPerAccount[msg.sender] = newStartIndex_;
        }
        if (feeAmount_ != 0) {
            IERC20(ethSnacks).safeTransfer(msg.sender, feeAmount_);
        }
    }
    
    /**
    * @notice Creates a new snapshot and returns its ID.
    * @dev A snapshot is taken once every 12 hours when the `distributeFee()` function is called.
    * @return New snapshot ID.
    */
    function _snapshot() private returns (uint256) {
        _currentSnapshotId.increment();
        uint256 currentId = getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }
    
    /**
    * @notice Updates the balance and deposit, and then it's taking a snapshot for the `account_`.
    * @dev Called inside `_afterTokenTransfer()` callback.
    * @param account_ Account address.
    */
    function _updateAccountBalanceAndDeposit(address account_) private {
        _updateSnapshot(_accountBalanceAndDepositSnapshots[account_], balanceAndDepositOf(account_));
    }
    
    /**
    * @notice Updates holder supply snapshot.
    * @dev Called inside `_afterTokenTransfer()` callback.
    */
    function _updateHolderSupply() private {
        _updateSnapshot(_holderSupplySnapshots, _totalSupply - getExcludedBalance());
    }

    /**
    * @notice Updates snapshot.
    * @dev If information about the amount of the balance and deposit or holder supply 
    * has already been updated in the current snapshot, then it is re-updated.
    * @param snapshots_ Snapshot history.
    * @param currentValue_ Current value.
    */
    function _updateSnapshot(Snapshots storage snapshots_, uint256 currentValue_) private {
        uint256 currentId = getCurrentSnapshotId();
        uint256 lastSnapshotId = _lastSnapshotId(snapshots_.ids);
        if (lastSnapshotId < currentId) {
            snapshots_.ids.push(currentId);
            snapshots_.values.push(currentValue_);
        } else if (lastSnapshotId == currentId && currentId != 0) {
            snapshots_.values.pop();
            snapshots_.values.push(currentValue_);
        }
    }

    /**
    * @notice Retrieves the last snapshot ID. 
    * @dev Called inside `_updateSnapshot()` function.
    * @param ids_ Snapshot ids array.
    * @return Last snapshot ID.
    */
    function _lastSnapshotId(uint256[] storage ids_) private view returns (uint256) {
        if (ids_.length == 0) {
            return 0;
        } else {
            return ids_[ids_.length - 1];
        }
    }

    /**
    * @notice Retrieves the value at the time `snapshotId_` was created.
    * @dev Called inside `balanceAndDepositOfAt()` and `holderSupplyAt()` functions.
    * @param snapshotId_ Snapshot ID.
    * @param snapshots_ Snapshot history.
    * @return Boolean value indicating whether snapshot was taken or not
    * and the value at the time `snapshotId_` was created (0 if snapshot wasn't taken).
    */
    function _valueAt(
        uint256 snapshotId_, 
        Snapshots storage snapshots_
    ) 
        private 
        view 
        returns (bool, uint256) 
    {
        require(snapshotId_ > 0, "Snacks: id is 0");
        require(snapshotId_ <= getCurrentSnapshotId(), "Snacks: nonexistent id");
        // When a valid snapshot is queried, there are three possibilities:
        // 1. The queried value was not modified after the snapshot was taken. 
        // Therefore, a snapshot entry was never created for this ID, and all stored snapshot ids 
        // are smaller than the requested one. The value that corresponds to this ID is the current one.
        // 2. The queried value was modified after the snapshot was taken. 
        // Therefore, there will be an entry with the requested ID, and its value is the one to return.
        // 3. More snapshots were created after the requested one, and the queried value was later modified. 
        // There will be no entry for the requested ID: the value that corresponds to it is that 
        // of the smallest snapshot ID that is larger than the requested one.
        // In summary, we need to find an element in an array, returning the index of the smallest value that 
        // is larger if it is not found, unless said value doesn't exist (e.g. when all values are smaller). 
        // Arrays.findUpperBound does exactly this.
        uint256 index = snapshots_.ids.findUpperBound(snapshotId_);
        if (index == snapshots_.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots_.values[index]);
        }
    }

    /**
    * @notice Calculates pending amount of the earned fee.
    * @dev The calculation uses cumulative values, as the holder 
    * may not withdraw his fee for a long time.
    * @param startIndex_ Starting index.
    * @param endIndex_ Ending index.
    * @param flag_ Flag that determines for which token to calculate.
    * @return New start index (if it makes sense) and the fee earned by the holder.
    */
    function _calculatePending(
        uint256 startIndex_,
        uint256 endIndex_,
        bool flag_
    )
        private
        view
        returns (uint256, uint256)
    {
        uint256 cumulativeBalanceAndDeposit;
        uint256 cumulativeHolderSupply;
        uint256 cumulativeFeeAmount;
        uint256 feeSnapshotId;
        uint256 i;
        if (flag_) {
            for (i = startIndex_; i < endIndex_; i++) {
                feeSnapshotId = _btcSnacksFeeSnapshots[i];
                cumulativeBalanceAndDeposit += balanceAndDepositOfAt(msg.sender, feeSnapshotId);
                cumulativeHolderSupply += holderSupplyAt(feeSnapshotId);
                cumulativeFeeAmount += snapshotIdToBtcSnacksFeeAmount[feeSnapshotId];
            }
        } else {
            for (i = startIndex_; i < endIndex_; i++) {
                feeSnapshotId = _ethSnacksFeeSnapshots[i];
                cumulativeBalanceAndDeposit += balanceAndDepositOfAt(msg.sender, feeSnapshotId);
                cumulativeHolderSupply += holderSupplyAt(feeSnapshotId);
                cumulativeFeeAmount += snapshotIdToEthSnacksFeeAmount[feeSnapshotId];
            }
        }
        if (i == startIndex_) {
            return (startIndex_, 0);
        } else {
            return (i, cumulativeFeeAmount.mul(cumulativeBalanceAndDeposit).div(cumulativeHolderSupply));
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@prb/math/contracts/PRBMathUD60x18.sol";

import "../interfaces/ISnacksBase.sol";

abstract contract SnacksBase is ISnacksBase, IERC20Metadata, Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using PRBMathUD60x18 for uint256;
    
    address private constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 private constant ONE_SNACK = 1e18;
    uint256 private constant MINT_FEE_PERCENT = 500;
    uint256 private constant REDEEM_FEE_PERCENT = 1000;
    uint256 internal constant BASE_PERCENT = 10000;
    
    address public payToken;
    address public pulse;
    address public poolRewardDistributor;
    address public seniorage;
    address public authority;
    uint256 public adjustmentFactor = PRBMathUD60x18.fromUint(1);
    uint256 internal _totalSupply;
    uint256 private immutable _step;
    uint256 private immutable _correlationFactor;
    uint256 private immutable _totalSupplyFactor;
    uint256 private immutable _pulseFeePercent;
    uint256 private immutable _poolRewardDistributorFeePercent;
    uint256 private immutable _seniorageFeePercent;
    string private _name;
    string private _symbol;
    
    mapping(address => uint256) internal _adjustedBalances;
    mapping(address => mapping(address => uint256)) private _allowedAmount;
    EnumerableSet.AddressSet internal _excludedHolders;
    
    event Buy(
        address indexed buyer,
        uint256 totalSupplyBefore,
        uint256 buyTokenAmount,
        uint256 buyTokenAmountToBuyer,
        uint256 fee,
        uint256 payTokenAmount
    );
    event Redeem(
        address indexed seller,
        uint256 totalSupplyAfter,
        uint256 buyTokenAmount,
        uint256 buyTokenAmountToRedeem,
        uint256 fee,
        uint256 payTokenAmountToSeller
    );
    event RewardForHolders(uint256 indexed reward);
    
    modifier onlyAuthority {
        require(
            msg.sender == authority,
            "SnacksBase: caller is not authorised"
        );
        _;
    }

    modifier validOwnerAndSpender(address owner_, address spender_) {
        require(
            owner_ != address(0), 
            "SnacksBase: approve from the zero address");
        require(
            spender_ != address(0), 
            "SnacksBase: approve to the zero address"
        );
        _;
    }
    
    
    /**
    * @param step_ An arithmetic progression step.
    * @param correlationFactor_ The transition from Snacks/BtcSnacks/EthSnacks token 
    * to Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token is made by
    * the counted number divided by the `correlationFactor` 
    * @param totalSupplyFactor_ `_totalSupply` is divided by the `totalSupplyFactor_` to get 
    * the cost of the last Snacks/BtcSnacks/EthSnacks token purchased.
    * @param pulseFeePercent_ Percent of the Pulse contract from the commission for 12 hours.
    * @param poolRewardDistributorFeePercent_ Percent of the PoolRewardDistributor contract 
    * from the commission for 12 hours.
    * @param seniorageFeePercent_ Percent of the Seniorage contract from the commission for 12 hours.
    * @param name_ Token name.
    * @param symbol_ Token symbol.
    */
    constructor(
        uint256 step_,
        uint256 correlationFactor_,
        uint256 totalSupplyFactor_,
        uint256 pulseFeePercent_,
        uint256 poolRewardDistributorFeePercent_,
        uint256 seniorageFeePercent_,
        string memory name_,
        string memory symbol_
    ) {
        _step = step_;
        _correlationFactor = correlationFactor_;
        _totalSupplyFactor = totalSupplyFactor_;
        _pulseFeePercent = pulseFeePercent_;
        _poolRewardDistributorFeePercent = poolRewardDistributorFeePercent_;
        _seniorageFeePercent = seniorageFeePercent_;
        _name = name_;
        _symbol = symbol_;
    }
    
    /**
    * @notice Configures the contract.
    * @dev Could be called by the owner in case of resetting addresses.
    * @param payToken_ Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token address.
    * @param pulse_ Pulse contract address.
    * @param poolRewardDistributor_ PoolRewardDistributor contract address.
    * @param seniorage_ Seniorage contract address.
    * @param snacksPool_ SnacksPool contract address.
    * @param pancakeSwapPool_ PancakeSwapPool contract address.
    * @param lunchBox_ LunchBox contract address.
    * @param authority_ Authorised address.
    */
    function _configure(
        address payToken_,
        address pulse_,
        address poolRewardDistributor_,
        address seniorage_,
        address snacksPool_,
        address pancakeSwapPool_,
        address lunchBox_,
        address authority_
    )
        internal
        onlyOwner
    {
        payToken = payToken_;
        pulse = pulse_;
        poolRewardDistributor = poolRewardDistributor_;
        seniorage = seniorage_;
        authority = authority_;
        for (uint256 i = 0; i < _excludedHolders.length(); i++) {
            address excludedHolder = _excludedHolders.at(i);
            _excludedHolders.remove(excludedHolder);
        }
        _excludedHolders.add(payToken_);
        _excludedHolders.add(pulse_);
        _excludedHolders.add(poolRewardDistributor_);
        _excludedHolders.add(seniorage_);
        _excludedHolders.add(snacksPool_);
        _excludedHolders.add(pancakeSwapPool_);
        _excludedHolders.add(lunchBox_);
        _excludedHolders.add(address(this));
        _excludedHolders.add(address(0));
        _excludedHolders.add(DEAD_ADDRESS);
    }

    /**
    * @notice Triggers stopped state.
    * @dev Could be called by the owner in case of resetting addresses.
    */
    function pause() external onlyOwner {
        _pause();
    }

    /**
    * @notice Returns to normal state.
    * @dev Could be called by the owner in case of resetting addresses.
    */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
    * @notice Distributes fees between the contracts and holders.
    * @dev Called by the authorised address once every 12 hours.
    */
    function distributeFee() external whenNotPaused onlyAuthority {
        uint256 undistributedFee = balanceOf(address(this));
        _beforeDistributeFee(undistributedFee);
        if (undistributedFee != 0) {
            _transfer(
                address(this),
                pulse,
                undistributedFee * _pulseFeePercent / BASE_PERCENT
            );
            _transfer(
                address(this),
                poolRewardDistributor,
                undistributedFee * _poolRewardDistributorFeePercent / BASE_PERCENT
            );
            _transfer(
                address(this),
                seniorage,
                undistributedFee * _seniorageFeePercent / BASE_PERCENT
            );
        }
        _afterDistributeFee(balanceOf(address(this)));
    }
    
    /**
    * @notice Mints Snacks/BtcSnacks/EthSnacks token.
    * @dev The fee charged from the user is 5%. Thus, he will receive 95% of `buyTokenAmount_`.
    * @param buyTokenAmount_ Amount of Snacks/BtcSnacks/EthSnacks token to mint.
    * @return Amount of Snacks/BtcSnacks/EthSnacks token received.
    */
    function mintWithBuyTokenAmount(
        uint256 buyTokenAmount_
    ) 
        external 
        whenNotPaused
        nonReentrant 
        returns (uint256)
    {
        uint256 payTokenAmount = calculatePayTokenAmountOnMint(buyTokenAmount_);
        IERC20(payToken).safeTransferFrom(msg.sender, address(this), payTokenAmount);
        uint256 fee = buyTokenAmount_ * MINT_FEE_PERCENT / BASE_PERCENT;
        _mint(address(this), fee);
        _mint(msg.sender, buyTokenAmount_ - fee);
        emit Buy(
            msg.sender,
            _totalSupply - buyTokenAmount_,
            buyTokenAmount_,
            buyTokenAmount_ - fee,
            fee,
            payTokenAmount
        );
        return buyTokenAmount_ - fee;
    }
    
    /**
    * @notice Mints Snacks/BtcSnacks/EthSnacks token.
    * @dev The fee charged from the user is 5%. Thus, he will receive 95% of calculated `buyTokenAmount`.
    * @param payTokenAmount_ Amount of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token to spend.
    * @return Amount of Snacks/BtcSnacks/EthSnacks token received.
    */
    function mintWithPayTokenAmount(
        uint256 payTokenAmount_
    ) 
        external 
        whenNotPaused
        nonReentrant 
        returns (uint256)
    {
        uint256 buyTokenAmount = calculateBuyTokenAmountOnMint(payTokenAmount_);
        IERC20(payToken).safeTransferFrom(msg.sender, address(this), payTokenAmount_);
        uint256 fee = buyTokenAmount * MINT_FEE_PERCENT / BASE_PERCENT;
        _mint(address(this), fee);
        _mint(msg.sender, buyTokenAmount - fee);
        emit Buy(
            msg.sender,
            _totalSupply - buyTokenAmount,
            buyTokenAmount,
            buyTokenAmount - fee,
            fee,
            payTokenAmount_
        );
        return buyTokenAmount - fee;
    }
    
    /**
    * @notice Redeems Snacks/BtcSnacks/EthSnacks token.
    * @dev The fee charged from the user is 10%. Thus, he will receive 
    * Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token for 90% of `buyTokenAmount_`.
    * @param buyTokenAmount_ Amount of Snacks/BtcSnacks/EthSnacks token to redeem.
    * @return Amount of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token received.
    */
    function redeem(
        uint256 buyTokenAmount_
    ) 
        external 
        whenNotPaused
        nonReentrant 
        returns (uint256)
    {
        uint256 fee = buyTokenAmount_ * REDEEM_FEE_PERCENT / BASE_PERCENT;
        _transfer(msg.sender, address(this), fee);
        uint256 payTokenAmount = calculatePayTokenAmountOnRedeem(buyTokenAmount_ - fee);
        IERC20(payToken).safeTransfer(msg.sender, payTokenAmount);
        _burn(msg.sender, buyTokenAmount_ - fee);
        emit Redeem(
            msg.sender,
            _totalSupply,
            buyTokenAmount_,
            buyTokenAmount_ - fee,
            fee,
            payTokenAmount
        );
        return payTokenAmount;
    }
    
    /**
    * @notice Sets `amount_` as the allowance of `spender_` over the caller's tokens.
    * @dev Caller and `spender_` cannot be zero addresses.
    * @param spender_ Spender address.
    * @param amount_ Amount to approve.
    * @return Boolean value indicating whether the operation succeeded.
    */
    function approve(
        address spender_, 
        uint256 amount_
    ) 
        external 
        override
        whenNotPaused
        validOwnerAndSpender(msg.sender, spender_)
        returns (bool) 
    {
        _allowedAmount[msg.sender][spender_] = amount_;
        emit Approval(msg.sender, spender_, amount_);
        return true;
    }
    
    /**
    * @notice Atomically increases the allowance granted to `spender_` by the caller.
    * @dev Caller and `spender_` cannot be zero addresses.
    * @param spender_ Spender address.
    * @param amount_ Amount to increase.
    * @return Boolean value indicating whether the operation succeeded.
    */
    function increaseAllowance(
        address spender_,
        uint256 amount_
    )
        external
        whenNotPaused
        validOwnerAndSpender(msg.sender, spender_)
        returns (bool)
    {
        _allowedAmount[msg.sender][spender_] += amount_;
        emit Approval(msg.sender, spender_, _allowedAmount[msg.sender][spender_]);
        return true;
    }
    
    /**
    * @notice Atomically decreases the allowance granted to `spender_` by the caller.
    * @dev Caller and `spender_` cannot be zero addresses.
    * @param spender_ Spender address.
    * @param amount_ Amount to decrease.
    * @return Boolean value indicating whether the operation succeeded.
    */
    function decreaseAllowance(
        address spender_,
        uint256 amount_
    )
        external
        whenNotPaused
        validOwnerAndSpender(msg.sender, spender_)
        returns (bool)
    {
        uint256 oldAmount = _allowedAmount[msg.sender][spender_];
        if (amount_ >= oldAmount) {
            _allowedAmount[msg.sender][spender_] = 0;
        } else {
            _allowedAmount[msg.sender][spender_] = oldAmount - amount_;
        }
        emit Approval(msg.sender, spender_, _allowedAmount[msg.sender][spender_]);
        return true;
    }
    
    /**
    * @notice Moves `amount_` tokens from the caller's account to `to_`.
    * @dev `to_` cannot be the zero address. The caller must have a balance of at least `amount_`.
    * @param to_ Address to which tokens are sent.
    * @param amount_ Amount to transfer.
    * @return Boolean value indicating whether the operation succeeded.
    */
    function transfer(
        address to_,
        uint256 amount_
    )
        external
        override
        whenNotPaused
        returns (bool)
    {
        _transfer(msg.sender, to_, amount_);
        return true;
    }
    
    /**
    * @notice Moves `amount_` tokens from `from_` to `to_` using the
    * allowance mechanism. `amount_` is then deducted from the caller's allowance.
    * @dev `from_` and `to_` cannot be the zero address. `from_` must have a balance of at least `amount_`.
    * The caller must have allowance for `from_`'s tokens of at least `amount_`.
    * @param from_ Address from which tokens are sent.
    * @param to_ Address to which tokens are sent.
    * @param amount_ Amount to transfer.
    */
    function transferFrom(
        address from_,
        address to_,
        uint256 amount_
    )
        external
        override
        whenNotPaused
        returns (bool)
    {
        _allowedAmount[from_][msg.sender] -= amount_;
        _transfer(from_, to_, amount_);
        return true;
    }

    /**
    * @notice Adds an account to the excluded holders list.
    * @dev The excluded holders don't receive fee for holding. 
    * @param account_ Account address.
    */
    function addToExcludedHolders(address account_) external onlyOwner {
        require(
            _excludedHolders.add(account_),
            "SnacksBase: already excluded"
        );
        _adjustedBalances[account_] = _adjustedBalances[account_].mul(adjustmentFactor);
    }

    /**
    * @notice Removes an account from excluded holders list.
    * @dev Not excluded holders do receive fee for holding. 
    * @param account_ Account address.
    */
    function removeFromExcludedHolders(address account_) external onlyOwner {
        require(
            _excludedHolders.remove(account_),
            "SnacksBase: not excluded"
        );
        _adjustedBalances[account_] = _adjustedBalances[account_].div(adjustmentFactor);
    }

    /**
    * @notice Checks whether the account is an excluded holder.
    * @dev If the account is an excluded holder then it doesn't receive fee for holding.
    * @param account_ Account address.
    * @return Boolean value indicating whether the account is excluded holder or not.
    */
    function isExcludedHolder(address account_) external view returns (bool) {
        return _excludedHolders.contains(account_);
    }

    /**
    * @notice Checks whether `buyTokenAmount_` is enough 
    * to buy Snacks/BtcSnacks/EthSnacks token at least on 1 wei 
    * of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token.
    * @dev See description to `calculatePayTokenAmountOnMint()` function for math explanation.
    * @param buyTokenAmount_ Amount of Snacks/BtcSnacks/EthSnacks token to mint.
    * @return Boolean value indicating whether `buyTokenAmount_` is enough to buy
    * Snacks/BtcSnacks/EthSnacks token at least on 1 wei 
    * of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token.
    */
    function sufficientBuyTokenAmountOnMint(
        uint256 buyTokenAmount_
    )
        external
        view
        returns (bool)
    {
        uint256 next = _totalSupply + ONE_SNACK;
        uint256 last = _totalSupply + buyTokenAmount_;
        return (next + last) * buyTokenAmount_ >= 2 * _correlationFactor;
    }
    
    /**
    * @notice Checks whether `payTokenAmount_` is above or 
    * equal to next Snacks/BtcSnacks/EthSnacks token price.
    * @dev See description to `calculateBuyTokenAmountOnMint()` function for math explanation.
    * @param payTokenAmount_ Amount of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token to spend.
    * @return Boolean value indicating whether `payTokenAmount_` is above or equal to 
    * next Snacks/BtcSnacks/EthSnacks token price.
    */
    function sufficientPayTokenAmountOnMint(
        uint256 payTokenAmount_
    )
        external
        view
        returns (bool)
    {
        uint256 nextSnackPrice = _step + _totalSupply / _totalSupplyFactor;
        return payTokenAmount_ >= nextSnackPrice;
    }

    /**
    * @notice Checks whether `buyTokenAmount_` is enough 
    * to redeem Snacks/BtcSnacks/EthSnacks token at least on 1 wei 
    * of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token.
    * @dev See description to `calculatePayTokenAmountOnRedeem()` function for math explanation.
    * @param buyTokenAmount_ Amount of Snacks/BtcSnacks/EthSnacks token to redeem.
    * @return Boolean value indicating whether `buyTokenAmount_` is enough to redeem
    * Snacks/BtcSnacks/EthSnacks token at least on 1 wei 
    * of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token.
    */
    function sufficientBuyTokenAmountOnRedeem(
        uint256 buyTokenAmount_
    )
        external
        view
        returns (bool)
    {
        uint256 fee = buyTokenAmount_ * REDEEM_FEE_PERCENT / BASE_PERCENT;
        buyTokenAmount_ -= fee;
        uint256 start = _totalSupply - buyTokenAmount_ + ONE_SNACK;
        return (start + _totalSupply) * buyTokenAmount_ >= 2 * _correlationFactor;
    }
    
    /**
    * @notice Retrieves the amount of tokens in existence.
    * @dev The returned value is imperceptibly different from the real amount of tokens 
    * in existence because of the reflection mechanism.
    * @return Amount of tokens in existence.
    */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    /**
    * @notice Retrieves the remaining number of tokens that `spender_` will be
    * allowed to spend on behalf of `owner_` through `transferFrom()` function. This is
    * zero by default.
    * @dev This value changes when `approve()` or `transferFrom()` functions are called.
    * @param owner_ Owner address.
    * @param spender_ Spender address.
    * @return Remaining number of tokens that `spender_` will be
    * allowed to spend on behalf of `owner_` through `transferFrom()` function.
    */
    function allowance(
        address owner_, 
        address spender_
    ) 
        external 
        view 
        override 
        returns (uint256) 
    {
        return _allowedAmount[owner_][spender_];
    }
    
    /**
    * @notice Retrieves the name of the token.
    * @dev Standard ERC20.
    * @return Name of the token.
    */
    function name() external view override returns (string memory) {
        return _name;
    }
    
    /**
    * @notice Returns the symbol of the token, usually a shorter version of the name.
    * @dev Standard ERC20.
    * @return Symbol of the token.
    */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }
    
    /**
    * @notice Returns the number of decimals utilized to get its human-readable representation.
    * @dev Standard ERC20.
    * @return Number of decimals.
    */
    function decimals() external pure override returns (uint8) {
        return 18;
    }
    
    /**
    * @notice Returns the amount of tokens owned by account.
    * @dev If account is not excluded holder then his balance 
    * automatically increases after each distribution of fee.
    * @param account_ Account address.
    * @return Amount of tokens owned by account.
    */
    function balanceOf(address account_) public view override returns (uint256) {
        if (_excludedHolders.contains(account_)) {
            return _adjustedBalances[account_];
        } else {
            return _adjustedBalances[account_].mul(adjustmentFactor);
        }
    }
    
    /**
    * @notice Returns the amount of tokens owned by all excluded holders.
    * @dev Utilized to correctly calculate the balance of holders when recalculating the adjustment factor.
    * @return Amount of tokens owned by all excluded holders.
    */
    function getExcludedBalance() public view virtual returns (uint256) {
        uint256 excludedBalance;
        for (uint256 i = 0; i < _excludedHolders.length(); i++) {
            excludedBalance += balanceOf(_excludedHolders.at(i));
        }
        return excludedBalance;
    }
    
    /**
    * @notice Calculates an amount of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token 
    * which caller will spend in exchange for `buyTokenAmount_` Snacks/BtcSnacks/EthSnacks token.
    * @dev When calculating, the following formula is used: `S(n, m) = (n + m) * (m - n + 1) / 2 * d`, where 
    * `n = next`, `m = last`. After substituting the values, we get 
    * `S(next, last) = (next + last) * (last - next + ONE_SNACK) / 2 * d =
    * (next + last) * buyTokenAmount_ / (2 * _correlationFactor)`.
    * @param buyTokenAmount_ Amount of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token which caller will spend
    * in exchange for `buyTokenAmount_` Snacks/BtcSnacks/EthSnacks token. 
    * WARNING: the fees for mint are not accounted.
    */
    function calculatePayTokenAmountOnMint(
        uint256 buyTokenAmount_
    )
        public
        view
        returns (uint256)
    {
        uint256 next = _totalSupply + ONE_SNACK;
        uint256 last = _totalSupply + buyTokenAmount_;
        uint256 numerator = (next + last) * buyTokenAmount_;
        require(
            numerator >= 2 * _correlationFactor,
            "SnacksBase: invalid buy token amount"
        );
        return numerator / (2 * _correlationFactor);
    }
    
    /**
    * @notice Calculates an amount of Snacks/BtcSnacks/EthSnacks token which caller will spend
    * in exchange for `payTokenAmount_` Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token.
    * @dev When calculating, the following formula is used: `S = (2 * a + d * (n - 1)) / 2 * n`, where
    * `a = nextSnackPrice`. From this formula we need to find the value of n, so after transformations 
    * we obtain that we need to solve the quadratic equation `d * n ^ 2 + (2 * a - d) * n - 2 * S = 0`.
    * @param payTokenAmount_ Amount of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token to spend. 
    * WARNING: the fees for the mint are not accounted.
    * @return Amount of Snacks/BtcSnacks/EthSnacks token which caller will spend
    * in exchange for `payTokenAmount_` Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token.
    */
    function calculateBuyTokenAmountOnMint(
        uint256 payTokenAmount_
    )
        public
        view
        returns (uint256)
    {
        uint256 nextSnackPrice = _step + _totalSupply / _totalSupplyFactor;
        require(
            payTokenAmount_ >= nextSnackPrice,
            "SnacksBase: invalid pay token amount"
        );
        uint256 a = _step;
        uint256 b = 2 * nextSnackPrice - a;
        uint256 c = 2 * payTokenAmount_;
        uint256 discriminant = (b ** 2) + 4 * a * c;
        uint256 squareRoot = Math.sqrt(discriminant);
        return (squareRoot - b).div(2 * a);
    }
    
    /**
    * @notice Calculates an amount of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token which caller will receive
    * on redeem `buyTokenAmount_` Snacks/BtcSnacks/EthSnacks token (10% fee not included).
    * @dev When calculating, the following formula is used: `S(n, m) = (n + m) * (m - n + 1) / 2 * d`, where
    * `n = start`, `m = _totalSupply`. After substituting the values, we get 
    * `S(start, _totalSuply) = (start + _totalSupply) * (_totalSupply - start + ONE_SNACK) / 2 * d =
    * (start + _totalSupply) * buyTokenAmount_ / (2 * _correlationFactor)`.
    * @param buyTokenAmount_ Amount of Snacks/BtcSnacks/EthSnacks token to redeem. 
    * WARNING: the fees for redeem are not accounted.
    * @return Amount of Zoinks/Binance-Peg BTCB/Binance-Peg Ethereum token which caller will receive
    * on redeem `buyTokenAmount_` Snacks/BtcSnacks/EthSnacks token (10% fee not included).
    */
    function calculatePayTokenAmountOnRedeem(
        uint256 buyTokenAmount_
    )
        public
        view
        returns (uint256)
    {
        uint256 start = _totalSupply + ONE_SNACK - buyTokenAmount_;
        uint256 numerator = (start + _totalSupply) * buyTokenAmount_;
        require(
            numerator >= 2 * _correlationFactor,
            "SnacksBase: invalid buy token amount"
        );
        return numerator / (2 * _correlationFactor);
    }
    
    /**
    * @notice Hook that is called inside `distributeFee()` function.
    * @dev Used only by BtcSnacks and EthSnacks contracts.
    */
    function _beforeDistributeFee(uint256) internal virtual {}
    
    /** 
    * @notice Hook that is called inside `distributeFee()` function.
    * @dev Recalculates adjustmentFactor according to formula: 
    * `adjustmentFactor = a * (b + c) / b`, where `a = current adjustment factor`,
    * `b = not excluded holders balance` and `c = left undistributed fee`.
    * @param undistributedFee_ Amount of left undistributed fee.
    */
    function _afterDistributeFee(uint256 undistributedFee_) internal virtual {
        uint256 excludedBalance = getExcludedBalance();
        uint256 holdersBalance = _totalSupply - excludedBalance;
        if (undistributedFee_ != 0) {
            uint256 seniorageFeeAmount = undistributedFee_ / 10;
            _transfer(address(this), seniorage, seniorageFeeAmount);
            if (holdersBalance != 0) {
                undistributedFee_ -= seniorageFeeAmount;
                adjustmentFactor = adjustmentFactor.mul((holdersBalance + undistributedFee_).div(holdersBalance));
                _adjustedBalances[address(this)] = 0;
                emit RewardForHolders(undistributedFee_);
            }
        }
    }
    
    /**
    * @notice Hook that is called right after any 
    * transfer of tokens. This includes minting and burning.
    * @dev Used only by the Snacks contract.
    */
    function _afterTokenTransfer(address, address) internal virtual {}
    
    /**
    * @notice Moves `amount_` of tokens from `from_` to `to_`.
    * @dev `from_` and `to_` cannot be the zero address. `from_` must have a balance of at least `amount_`. 
    * Takes into account the current `adjustmentFactor`.
    * @param from_ Address from which tokens are sent.
    * @param to_ Address to which tokens are sent.
    * @param amount_ Amount to transfer.
    */
    function _transfer(
        address from_,
        address to_,
        uint256 amount_
    )
        internal
    {
        require(
            from_ != address(0),
            "SnacksBase: transfer from the zero address"
        );
        require(
            to_ != address(0),
            "SnacksBase: transfer to the zero address"
        );
        uint256 adjustedAmount = amount_.div(adjustmentFactor);
        if (!_excludedHolders.contains(from_) && _excludedHolders.contains(to_)) {
            _adjustedBalances[from_] -= adjustedAmount;
            _adjustedBalances[to_] += amount_;
        } else if (_excludedHolders.contains(from_) && !_excludedHolders.contains(to_)) {
            _adjustedBalances[from_] -= amount_;
            _adjustedBalances[to_] += adjustedAmount;
        } else if (!_excludedHolders.contains(from_) && !_excludedHolders.contains(to_)) {
            _adjustedBalances[from_] -= adjustedAmount;
            _adjustedBalances[to_] += adjustedAmount;
        } else {
            _adjustedBalances[from_] -= amount_;
            _adjustedBalances[to_] += amount_;
        }
        emit Transfer(from_, to_, amount_);
        _afterTokenTransfer(from_, to_);
    }
    
    /**
    * @notice Creates the `amount_` tokens and assigns them to an `account_`, increasing the total supply.
    * @dev Takes into account the current `adjustmentFactor`.
    * @param account_ Account address.
    * @param amount_ Amount of tokens to mint.
    */
    function _mint(address account_, uint256 amount_) private {
        _totalSupply += amount_;
        uint256 adjustedAmount = amount_.div(adjustmentFactor);
        if (_excludedHolders.contains(account_)) {
            _adjustedBalances[account_] += amount_;
        } else {
            _adjustedBalances[account_] += adjustedAmount;
        }
        emit Transfer(address(0), account_, amount_);
        _afterTokenTransfer(address(0), account_);
    }
    
    /**
    * @notice Burns the `amount_` tokens from an `account_`, reducing the total supply.
    * @dev Takes into account the current `adjustmentFactor`.
    * @param account_ Account address.
    * @param amount_ Amount of tokens to burn.
    */
    function _burn(address account_, uint256 amount_) private {
        _totalSupply -= amount_;
        uint256 adjustedAmount = amount_.div(adjustmentFactor);
        if (_excludedHolders.contains(account_)) {
            _adjustedBalances[account_] -= amount_;
        } else {
            _adjustedBalances[account_] -= adjustedAmount;
        }
        emit Transfer(account_, address(0), amount_);
        _afterTokenTransfer(account_, address(0));
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

/**
* @title Interface that can be used to interact with the LunchBox contract.
*/
interface ILunchBox {
    function stakeForSeniorage(uint256 busdAmount) external;
    function stakeForSeniorage(
        uint256 zoinksAmount,
        uint256 btcAmount,
        uint256 ethAmount,
        uint256 snacksAmount,
        uint256 btcSnacksAmount,
        uint256 ethSnacksAmount,
        uint256 zoinksBusdAmountOutMin,
        uint256 btcBusdAmountOutMin,
        uint256 ethBusdAmountOutMin
    )
        external;
    function stakeForSnacksPool(
        uint256 snacksAmount,
        uint256 btcSnacksAmount,
        uint256 ethSnacksAmount,
        uint256 zoinksBusdAmountOutMin,
        uint256 btcBusdAmountOutMin,
        uint256 ethBusdAmountOutMin
    )
        external;
    function updateRewardForUser(address user) external;
    function updateTotalSupplyFactor(uint256 totalSupplyBefore) external;
    function getReward(address user) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

/**
* @title Interface that can be used to interact with multiple reward pool contracts.
*/
interface IMultipleRewardPool {
    function notifyRewardAmount(
        address rewardToken,
        uint256 reward
    )
        external;
    function stake(uint256 amount) external;
    function getReward() external;
    function getBalance(address user) external view returns (uint256);
    function getTotalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

/**
* @title Interface that can be used to interact with the Snacks contract.
*/
interface ISnacks {
    function notifyBtcSnacksFeeAmount(uint256 feeAmount) external;
    function notifyEthSnacksFeeAmount(uint256 feeAmount) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

/**
* @title Interface that can be used to interact with Snacks/BtcSnacks/EthSnacks contracts.
*/
interface ISnacksBase {
    function mintWithBuyTokenAmount(uint256 buyTokenAmount) external returns (uint256);
    function mintWithPayTokenAmount(uint256 payTokenAmount) external returns (uint256);
    function isExcludedHolder(address account) external view returns (bool);
    function redeem(uint256 buyTokenAmount) external returns (uint256);
    function adjustmentFactor() external view returns (uint256);
    function sufficientBuyTokenAmountOnMint(
        uint256 buyTokenAmount
    ) 
        external 
        view
        returns (bool);
    function sufficientPayTokenAmountOnMint(
        uint256 payTokenAmount
    )
        external
        view
        returns (bool);
    function sufficientBuyTokenAmountOnRedeem(
        uint256 buyTokenAmount
    )
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

/**
* @title Interface that can be used to interact with the SnacksPool contract.
*/
interface ISnacksPool {
    function getLunchBoxParticipantsTotalSupply() external view returns (uint256);
    function isLunchBoxParticipant(address user) external view returns (bool);
    function getNotExcludedHoldersSupply() external view returns (uint256);
    function getTotalSupply() external view returns (uint256);
    function updateTotalSupplyFactor(uint256 totalSupplyBefore) external;
}