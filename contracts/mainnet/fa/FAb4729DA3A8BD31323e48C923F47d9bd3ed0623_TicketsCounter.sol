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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
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
        return _values(set._inner);
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
     * @dev Returns the number of values on the set. O(1).
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILockableStaking {
    function createLock(
        address user,
        uint256 index,
        uint32 until,
        uint256 amount
    ) external;

    function deleteExpiredLock(address user, uint256 index) external;
}

interface IRefTreeStorage {
    function refererOf(address user) external view returns (address);

    function referralsOf(address referer) external view returns (address[] memory);

    function setReferer(address user, address referer) external;
}

interface ITicketsCounter {
    struct StakingLockDetails {
        uint256 amount;
        ILockableStaking target;
    }

    function smartLockTickets(
        address user,
        uint256 drawDate,
        uint256 ticketsRequested
    ) external returns (StakingLockDetails[] memory shouldLock);

    function countTickets(address user, uint256 drawDate)
        external
        view
        returns (uint256 totalTickets, uint256 usableTickets);

    function unlockTickets(address user, uint256 amount) external;
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRefTreeStorage, ILockableStaking} from './Interfaces.sol';
import {RefProgramBase} from './RefProgramBase.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

contract LpStaking is ReentrancyGuard, RefProgramBase, ILockableStaking {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 constant _ACCURACY_ = 1e18;
    uint256 constant _OVERFLOW_LIMITER_ = type(uint256).max / _ACCURACY_;

    /* ========== STATE VARIABLES ========== */
    EnumerableSet.AddressSet _lockAgents;

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public rewardsDuration = 7 days;
    uint256 public lastUpdateTime;
    /// @notice multiplied by _ACCURACY_
    uint256 public rewardPerTokenStored;

    /// @notice multiplied by _ACCURACY_
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    struct LockInfo {
        uint32 until;
        uint256 amount;
    }
    // user -> lock agent -> lock index -> lock info
    mapping(address => mapping(address => mapping(uint256 => LockInfo))) public userLocks;
    // user -> lock agent -> list of lock ids of this user
    mapping(address => mapping(address => uint256[])) public currentUserLockIds;
    // user -> lock agent -> program index -> index of lock id for this user at this program in currentUserLockIds
    mapping(address => mapping(address => mapping(uint256 => uint256))) public InoIdoToLockIdIndex;

    modifier onlyLockAgent() {
        require(_lockAgents.contains(msg.sender), 'only ino/ido');
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(
        IERC20 rewardsToken_,
        IERC20 stakingToken_,
        IRefTreeStorage refTreeStorage_
    ) RefProgramBase(refTreeStorage_) {
        rewardsToken = rewardsToken_;
        stakingToken = stakingToken_;
    }

    /* ========== VIEWS ========== */

    function lockAgents() external view returns (address[] memory) {
        return _lockAgents.values();
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    /// @notice multiplied by _ACCURACY_
    function rewardPerToken() public view returns (uint256 value) {
        value = rewardPerTokenStored;
        if (_totalSupply > 0) {
            uint256 timePassed = lastTimeRewardApplicable() - lastUpdateTime;
            value += (timePassed * rewardRate * _ACCURACY_) / _totalSupply;
        }
    }

    function earned(address account) public view returns (uint256 value) {
        uint256 rewardPerTokenEarned = rewardPerToken() - userRewardPerTokenPaid[account];
        value = (_balances[account] * rewardPerTokenEarned) / _ACCURACY_ + rewards[account];
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate * rewardsDuration;
    }

    function infoBundle(address user)
        external
        view
        returns (
            uint256 bal,
            uint256 all,
            uint256 earned_,
            uint256 staked
        )
    {
        bal = stakingToken.balanceOf(user);
        all = stakingToken.allowance(user, address(this));
        earned_ = earned(user);
        staked = _balances[user];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount, address referer) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, 'Cannot stake 0');
        _totalSupply += amount;
        _balances[msg.sender] += amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        _trySetReferer(msg.sender, referer);
        emit Staked(msg.sender, amount);
    }

    function _canWithdraw(address user, uint256 amount) internal view returns (bool) {
        return _balances[user] - amount >= getCurrentLock(user);
    }

    function getCurrentLock(address user) public view returns (uint256 lockSum) {
        uint256 _lockAgentsLength = _lockAgents.length();
        for (uint256 i = 0; i < _lockAgentsLength; i++) {
            address _lockAgent = _lockAgents.at(i);
            uint256[] memory currentLockIds = currentUserLockIds[user][_lockAgent];
            for (uint256 j = 0; j < currentLockIds.length; ++j) {
                LockInfo memory _lock = userLocks[user][_lockAgent][currentLockIds[j]];
                if (_lock.until > block.timestamp) lockSum += _lock.amount;
            }
        }
    }

    function getCurrentUserLockIds(address user, address lockAgent) external view returns (uint256[] memory) {
        return currentUserLockIds[user][lockAgent];
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, 'Cannot withdraw 0');
        require(_canWithdraw(msg.sender, amount), 'Withdraw locked');
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function createLock(
        address user,
        uint256 index,
        uint32 until,
        uint256 amount
    ) external override onlyLockAgent {
        userLocks[user][msg.sender][index].until = until;
        userLocks[user][msg.sender][index].amount = amount;
        uint256 length = currentUserLockIds[user][msg.sender].length;
        currentUserLockIds[user][msg.sender].push(index);
        InoIdoToLockIdIndex[user][msg.sender][index] = length;
        emit LockCreated(user, index, until, amount);
    }

    function deleteExpiredLock(address user, uint256 index) external override onlyLockAgent {
        uint256 indexInCurrentLocks = InoIdoToLockIdIndex[user][msg.sender][index];
        uint256 lastCurrentUserLockId = currentUserLockIds[user][msg.sender].length - 1;
        uint256 lastValue = currentUserLockIds[user][msg.sender][lastCurrentUserLockId];
        currentUserLockIds[user][msg.sender][indexInCurrentLocks] = lastValue;
        InoIdoToLockIdIndex[user][msg.sender][lastValue] = indexInCurrentLocks;
        currentUserLockIds[user][msg.sender].pop();
        emit LockDeleted(user, index);
    }

    function notifyRewardAmount(uint256 reward) public onlyOwner updateReward(address(0)) {
        uint256 leftover = periodFinish > block.timestamp ? (periodFinish - block.timestamp) * rewardRate : 0;
        uint256 rewardAmount = reward + leftover;
        // Ensure the provided reward amount is not more than the balance in the contract.
        require(rewardsToken.balanceOf(address(this)) >= rewardAmount, 'Provided reward too high');
        // Prevent overflows in the future. Practically unnecessary, but depends on rewardToken parameters
        require(rewardAmount < _OVERFLOW_LIMITER_);

        rewardRate = rewardAmount / rewardsDuration;

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(reward);
    }

    function supplyAndNotify(uint256 reward) external {
        rewardsToken.safeTransferFrom(msg.sender, address(this), reward);
        notifyRewardAmount(reward);
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(IERC20 token, uint256 tokenAmount) external onlyOwner {
        require(token != stakingToken, 'Cannot withdraw the staking token');
        token.safeTransfer(owner(), tokenAmount);
        emit Recovered(token, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(
            block.timestamp > periodFinish,
            'Previous rewards period must be complete before changing the duration for the new period'
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    function addLockAgent(address lockAgent) external onlyOwner {
        _lockAgents.add(lockAgent);
    }

    function removeLockAgent(address lockAgent) external onlyOwner {
        _lockAgents.remove(lockAgent);
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(IERC20 token, uint256 amount);
    event LockCreated(address indexed user, uint256 indexed index, uint32 until, uint256 amount);
    event LockDeleted(address indexed user, uint256 indexed index);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRefTreeStorage} from './Interfaces.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

abstract contract RefProgramBase is Ownable {
    IRefTreeStorage public refTreeStorage;

    constructor(IRefTreeStorage refTreeStorage_) {
        setRefTreeStorage(refTreeStorage_);
    }

    // SETTERS

    function setRefTreeStorage(IRefTreeStorage refTreeStorage_) public onlyOwner {
        refTreeStorage = refTreeStorage_;
    }

    // INTERNAL OPERATIONS

    function _trySetReferer(address user, address referer) internal {
        refTreeStorage.setReferer(user, referer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRefTreeStorage} from './Interfaces.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {RefProgramBase} from './RefProgramBase.sol';
import {SafeERC20, IERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

abstract contract RefProgramStaking is RefProgramBase {
    using SafeERC20 for IERC20;

    struct RefUserInfo {
        uint256[3] refCumulativeParticipants;
        uint256[3] refCumulativeStaked;
        uint256[3] refCumulativeRewards;
    }
    uint256[3] _refererShares = [10, 5, 3];
    mapping(address => RefUserInfo) _refUserInfo;
    event RefRewardDistributed(
        address indexed referer,
        address indexed staker,
        uint8 indexed level,
        uint256 amount,
        uint256 timestamp
    );

    constructor(IRefTreeStorage refTreeStorage_) RefProgramBase(refTreeStorage_) {}

    // SETTERS

    function setRefShares(uint256[3] calldata shares) external onlyOwner {
        _refererShares = shares;
    }

    // INTERNAL OPERATIONS

    mapping(address => bool) private _alreadyStakedBefore;

    function _refDistributeParticipantsStakedAndRewards(
        IERC20 rewardToken,
        uint256 amountStaked,
        uint256 rewardPlanned,
        address staker
    ) internal returns (uint256 totalDividendsSent) {
        address referer = staker;
        for (uint8 i = 0; i < 3; i++) {
            referer = refTreeStorage.refererOf(referer);
            if (referer == address(0)) {
                break;
            }
            if (!_alreadyStakedBefore[staker])
                _refUserInfo[referer].refCumulativeParticipants[i]++;
            _refUserInfo[referer].refCumulativeStaked[i] += amountStaked;
            uint256 refReward = (rewardPlanned * _refererShares[i]) / 100;
            rewardToken.safeTransfer(referer, refReward);
            emit RefRewardDistributed(referer, staker, i, refReward, block.timestamp);
            _refUserInfo[referer].refCumulativeRewards[i] += refReward;
            totalDividendsSent += refReward;
        }
        _alreadyStakedBefore[staker] = true;
    }

    // EXTERNAL GETTERS

    function refUserInfo(address user) external view returns (RefUserInfo memory) {
        return _refUserInfo[user];
    }

    function refererShares() external view returns (uint256[3] memory) {
        return _refererShares;
    }

    function refInfoBundle(address user)
        external
        view
        returns (
            RefUserInfo memory info,
            address referer,
            address[] memory referrals
        )
    {
        info = _refUserInfo[user];
        referer = refTreeStorage.refererOf(user);
        referrals = refTreeStorage.referralsOf(user);
    }
}

contract StakingNext is ReentrancyGuard, RefProgramStaking {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    IERC20 public TKN;

    uint256[3] _periods = [90 days, 180 days, 360 days];
    uint8[3] _rates = [103, 105, 108];
    uint256[3] _minimumAmounts = [100 ether, 300 ether, 500 ether];
    uint256 public limit = 1500000 ether;
    uint256 public MAX_STAKES = 3;
    uint256 public finish_timestamp = 1682899200; // 2023 May 01 00:00 UTC
    bool public DEPRECATED = false;

    struct Stake {
        uint8 tier;
        uint256 amount;
        uint256 finalAmount;
        uint32 started;
        uint32 finish;
    }
    uint256 public totalStakes;
    EnumerableSet.UintSet _stakeIds;
    mapping(uint256 => Stake) _stakeData;
    mapping(address => EnumerableSet.UintSet) _stakeIdsOf;
    mapping(uint256 => address) public ownerOf;
    event Staked(
        address indexed sender,
        uint8 indexed tier,
        uint256 amount,
        uint256 finalAmount
    );
    event Prolonged(
        address indexed sender,
        uint8 indexed tier,
        uint256 newAmount,
        uint256 newFinalAmount
    );
    event Unstaked(address indexed sender, uint8 indexed tier, uint256 amount);

    /* ========== MODIFIER ========== */

    modifier deprecationProtect() {
        require(
            !DEPRECATED,
            'Contract is deprecated, your stakes were moved to new contract'
        );
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(IERC20 stakingToken_, IRefTreeStorage refTreeStorage_)
        RefProgramStaking(refTreeStorage_)
    {
        TKN = stakingToken_;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(
        uint8 _tier,
        uint256 _amount,
        address _referer
    ) external nonReentrant deprecationProtect {
        require((_tier < 3) && (_amount >= _minimumAmounts[_tier]), 'Wrong amount'); // data valid
        require(_stakeIdsOf[msg.sender].length() < MAX_STAKES, 'MAX_STAKES overflow'); // has space for new active stake
        require(
            finish_timestamp > block.timestamp + _periods[_tier],
            'Program will finish before this stake does'
        ); // not staking in the end of program
        uint256 _finalAmount = (_amount * _rates[_tier]) / 100;
        uint256 _reward = _finalAmount - _amount;
        limit -= _reward;
        _trySetReferer(msg.sender, _referer);
        uint256 _rewardsDistributed = _refDistributeParticipantsStakedAndRewards(
            TKN,
            _amount,
            _reward,
            msg.sender
        );
        limit -= _rewardsDistributed;
        TKN.safeTransferFrom(msg.sender, address(this), _amount);

        _stakeData[totalStakes] = Stake({
            tier: _tier,
            amount: _amount,
            finalAmount: _finalAmount,
            started: uint32(block.timestamp),
            finish: uint32(block.timestamp + _periods[_tier])
        });
        _stakeIds.add(totalStakes);
        _stakeIdsOf[msg.sender].add(totalStakes);
        ownerOf[totalStakes] = msg.sender;
        totalStakes++;

        emit Staked(msg.sender, _tier, _amount, _finalAmount);
    }

    function prolong(uint256 _index) external nonReentrant deprecationProtect {
        require(_stakeIdsOf[msg.sender].contains(_index), 'NOT_OWNED');
        Stake storage _s = _stakeData[_index];
        require(block.timestamp >= _s.finish); // staking period finished
        uint256 newFinish = block.timestamp + _periods[_s.tier];
        require(finish_timestamp > newFinish); // not prolonging in the end of program
        uint256 _newAmount = _s.finalAmount;
        uint256 _newFinalAmount = (_newAmount * _rates[_s.tier]) / 100;
        uint256 _reward = _newFinalAmount - _newAmount;
        limit -= _reward;
        uint256 _rewardsDistributed = _refDistributeParticipantsStakedAndRewards(
            TKN,
            _newAmount - _s.amount,
            _reward,
            msg.sender
        );
        limit -= _rewardsDistributed;
        _s.amount = _newAmount;
        _s.finalAmount = _newFinalAmount;
        _s.started = uint32(block.timestamp);
        _s.finish = uint32(newFinish);
        emit Prolonged(msg.sender, _s.tier, _newAmount, _newFinalAmount);
    }

    function unstake(uint256 _index) external nonReentrant deprecationProtect {
        require(_stakeIdsOf[msg.sender].contains(_index), 'NOT_OWNED');
        Stake storage _s = _stakeData[_index];
        require(block.timestamp >= _s.finish); // staking period finished

        TKN.safeTransfer(msg.sender, _s.finalAmount);
        _stakeIds.remove(_index);
        _stakeIdsOf[msg.sender].remove(_index);
        emit Unstaked(msg.sender, _s.tier, _s.finalAmount);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function drain(address _recipient) external onlyOwner {
        require(DEPRECATED || block.timestamp > finish_timestamp);
        TKN.safeTransfer(_recipient, limit);
        limit = 0;
    }

    function drainFull(address _recipient) public onlyOwner {
        require(DEPRECATED || block.timestamp > finish_timestamp + 30 days);
        uint256 _amount = TKN.balanceOf(address(this));
        TKN.safeTransfer(_recipient, _amount);
        limit = 0;
    }

    function returnAccidentallySent(IERC20 _TKN) external onlyOwner {
        require(address(_TKN) != address(TKN));
        uint256 _amount = _TKN.balanceOf(address(this));
        TKN.safeTransfer(msg.sender, _amount);
    }

    function updateMax(uint256 _max) external onlyOwner {
        MAX_STAKES = _max;
    }

    function DEPRECATE(bool also_drain) external onlyOwner {
        MAX_STAKES = 0;
        DEPRECATED = true;
        if (also_drain) drainFull(msg.sender);
    }

    function setFinishTimestamp(uint256 timestamp) external onlyOwner {
        finish_timestamp = timestamp;
    }

    function setLimit(uint256 value) external onlyOwner {
        limit = value;
    }

    /* ========== VIEWS ========== */

    function periods() external view returns (uint256[3] memory) {
        return _periods;
    }

    function rates() external view returns (uint8[3] memory) {
        return _rates;
    }

    function minimumAmounts() external view returns (uint256[3] memory) {
        return _minimumAmounts;
    }

    function stakeIds() external view returns (uint256[] memory) {
        return _stakeIds.values();
    }

    function stakeIdsLength() external view returns (uint256) {
        return _stakeIds.length();
    }

    function stakeIdsOf(address staker) public view returns (uint256[] memory) {
        return _stakeIdsOf[staker].values();
    }

    function stakeIdsOfLength(address staker) public view returns (uint256) {
        return _stakeIdsOf[staker].length();
    }

    function stakesOf(address staker)
        public
        view
        returns (Stake[] memory data, uint256[] memory ids)
    {
        ids = stakeIdsOf(staker);
        data = new Stake[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            data[i] = _stakeData[ids[i]];
        }
    }

    function stakeData(uint256 from, uint256 to)
        public
        view
        returns (Stake[] memory data)
    {
        data = new Stake[](to - from + 1);
        for (uint256 i = from; i <= to; i++) {
            data[i - from] = _stakeData[i];
        }
    }

    function stakeData(uint256 last)
        external
        view
        returns (Stake[] memory data, uint256 from)
    {
        if (last > totalStakes) last = totalStakes;
        from = totalStakes - last;
        data = stakeData(from, totalStakes - 1);
    }

    function myPendingStakesCount(address staker) public view returns (uint256 count) {
        (Stake[] memory data, ) = stakesOf(staker);
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i].finish > block.timestamp) count++;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ITicketsCounter, IUniswapV2Pair, ITicketsCounter} from './Interfaces.sol';
import {LpStaking} from './LpStaking.sol';
import {StakingNext} from './StakingNext.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

contract TicketsCounter is Ownable, ITicketsCounter {
    using EnumerableSet for EnumerableSet.AddressSet;
    LpStaking public lpStaking;
    StakingNext public fixedStaking;
    uint256 public STAKED_PER_TICKET = 100 ether;

    EnumerableSet.AddressSet _lockAgents;

    bool zlwIsToken0;
    IUniswapV2Pair public lp;

    mapping(address => uint256) public lockedTickets;

    event TicketsLocked(address indexed user, uint256 amount);
    event TicketsUnlocked(address indexed user, uint256 amount);

    modifier onlyLockAgent() {
        require(_lockAgents.contains(msg.sender), 'only ino/ido');
        _;
    }

    constructor(
        LpStaking lpStaking_,
        StakingNext fixedStaking_,
        address ZLWToken
    ) {
        lpStaking = lpStaking_;
        fixedStaking = fixedStaking_;

        lp = IUniswapV2Pair(address(lpStaking.stakingToken()));
        if (lp.token0() == ZLWToken) zlwIsToken0 = true;
        else require(lp.token1() == ZLWToken, 'WRONG ZLW/LP');
    }

    function lockAgents() external view returns (address[] memory) {
        return _lockAgents.values();
    }

    function lpToZlw(uint256 lpAmount) public view returns (uint256) {
        (uint112 lpReserve0, uint112 lpReserve1, ) = lp.getReserves();
        uint256 zlwReserve = zlwIsToken0 ? lpReserve0 : lpReserve1;
        return (lpAmount * zlwReserve * 2) / lp.totalSupply();
    }

    function zlwToLp(uint256 zlwAmount) public view returns (uint256) {
        (uint112 lpReserve0, uint112 lpReserve1, ) = lp.getReserves();
        uint256 zlwReserve = zlwIsToken0 ? lpReserve0 : lpReserve1;
        return (zlwAmount * lp.totalSupply()) / zlwReserve / 2;
    }

    function countTickets(address user, uint256 drawDate)
        external
        view
        override
        returns (uint256 totalTickets, uint256 usableTickets)
    {
        totalTickets = (seeStaked(user, drawDate) + seeStaked_LP(user)) / STAKED_PER_TICKET;
        if (totalTickets > lockedTickets[user]) usableTickets = totalTickets - lockedTickets[user];
    }

    function seeStaked(address who, uint256 drawDate) public view returns (uint256 total) {
        (StakingNext.Stake[] memory stakes, ) = fixedStaking.stakesOf(who);
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].finish >= drawDate) {
                total += stakes[i].amount;
            }
        }
    }

    function seeStaked_LP(address user) public view returns (uint256 zlwEquivalent) {
        uint256 lpStaked = lpStaking.balanceOf(user);
        uint256 locked = lpStaking.getCurrentLock(user);
        zlwEquivalent = lpStaked > locked ? lpToZlw(lpStaked - locked) : 0;
    }

    function smartLockTickets(
        address user,
        uint256 drawDate,
        uint256 ticketsRequested
    ) external override onlyLockAgent returns (StakingLockDetails[] memory shouldLock) {
        uint256 fixedStakingValue = seeStaked(user, drawDate);
        uint256 lpStakingValue = seeStaked_LP(user);

        // Now let's substract value that corresponds to locked tickets
        uint256 lockedValue = lockedTickets[user] * STAKED_PER_TICKET;
        if (lockedValue <= fixedStakingValue) {
            fixedStakingValue -= lockedValue;
        } else {
            uint256 lockedLpStakingValue = lockedValue - fixedStakingValue;
            fixedStakingValue = 0;
            // This one is special. This may happen if ZLW price rises a lot, thus decreasing ZLW equivalent of LP staked
            require(lpStakingValue >= lockedLpStakingValue, 'not enough tickets');
            lpStakingValue -= lockedLpStakingValue;
        }

        uint256 valueOfTicketsRequested = ticketsRequested * STAKED_PER_TICKET;
        require(valueOfTicketsRequested <= fixedStakingValue + lpStakingValue, 'not enough tickets');
        if (valueOfTicketsRequested > fixedStakingValue) {
            shouldLock = new StakingLockDetails[](1);
            shouldLock[0] = StakingLockDetails({
                amount: zlwToLp(valueOfTicketsRequested - fixedStakingValue),
                target: lpStaking
            });
        } else {
            shouldLock = new StakingLockDetails[](0);
        }

        lockedTickets[user] += ticketsRequested;
    }

    function unlockTickets(address user, uint256 amount) external override onlyLockAgent {
        lockedTickets[user] -= amount;
        emit TicketsUnlocked(user, amount);
    }

    function setStakedPerTicket(uint256 amount) external onlyOwner {
        STAKED_PER_TICKET = amount;
    }

    function addLockAgent(address lockAgent) external onlyOwner {
        _lockAgents.add(lockAgent);
    }

    function removeLockAgent(address lockAgent) external onlyOwner {
        _lockAgents.remove(lockAgent);
    }
}