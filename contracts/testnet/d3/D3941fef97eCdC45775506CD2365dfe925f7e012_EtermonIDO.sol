/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: ETMIDO.sol


pragma solidity 0.8.12;



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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)
            // To delete a key-value pair from the _entries array in O(1), we swap the entry to delete with the last one
            // in the array, and then remove the last entry (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            MapEntry storage lastEntry = map._entries[lastIndex];

            // Move the last entry to the index where the entry to delete is
            map._entries[toDeleteIndex] = lastEntry;
            // Update the index for the moved entry
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved entry was stored
            map._entries.pop();

            // Delete the index for the deleted slot
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

   /**
    * @dev Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Note that there are no guarantees on the ordering of entries inside the
    * array, and it may change when more entries are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     */
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     */
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}
 
/**
* @title Roles
* @dev Library for managing addresses assigned to a Role.
*/
library Roles {
   struct Role {
       mapping (address => bool) bearer;
   }
 
   /**
    * @dev give an account access to this role
    */
   function add(Role storage role, address account) internal {
       require(account != address(0));
       require(!has(role, account));
 
       role.bearer[account] = true;
   }
 
   /**
    * @dev remove an account's access to this role
    */
   function remove(Role storage role, address account) internal {
       require(account != address(0));
       require(has(role, account));
 
       role.bearer[account] = false;
   }
 
   /**
    * @dev check if an account has this role
    * @return bool
    */
   function has(Role storage role, address account) internal view returns (bool) {
       require(account != address(0));
       return role.bearer[account];
   }
}
 
/**
* @title WhitelistAdminRole
* @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
*/
contract WhitelistAdminRole {
   using Roles for Roles.Role;
 
   event WhitelistAdminAdded(address indexed account);
   event WhitelistAdminRemoved(address indexed account);
 
   Roles.Role private _whitelistAdmins;
 
   constructor () {
       _addWhitelistAdmin(msg.sender);
   }
 
   modifier onlyWhitelistAdmin() {
       require(isWhitelistAdmin(msg.sender));
       _;
   }
 
   function isWhitelistAdmin(address account) public view returns (bool) {
       return _whitelistAdmins.has(account);
   }
 
   function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
       _addWhitelistAdmin(account);
   }
 
   function renounceWhitelistAdmin() public {
       _removeWhitelistAdmin(msg.sender);
   }
 
   function _addWhitelistAdmin(address account) internal {
       _whitelistAdmins.add(account);
       emit WhitelistAdminAdded(account);
   }
 
   function _removeWhitelistAdmin(address account) internal {
       _whitelistAdmins.remove(account);
       emit WhitelistAdminRemoved(account);
   }
}
 
/**
* @title WhitelistedRole
* @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
* crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
* it), and not Whitelisteds themselves.
*/
contract WhitelistedRole is WhitelistAdminRole {
   using Roles for Roles.Role;
 
   event WhitelistedAdded(address indexed account);
   event WhitelistedRemoved(address indexed account);
 
   Roles.Role private _whitelisteds;
 
   modifier onlyWhitelisted() {
       require(isWhitelisted(msg.sender));
       _;
   }
 
   function isWhitelisted(address account) public view returns (bool) {
       return _whitelisteds.has(account);
   }
 
   function addWhitelisted(address account) internal onlyWhitelistAdmin {
       _addWhitelisted(account);
   }
 
   function removeWhitelisted(address account) internal onlyWhitelistAdmin {
       _removeWhitelisted(account);
   }
 
   function renounceWhitelisted() internal virtual {
       _removeWhitelisted(msg.sender);
   }
 
   function _addWhitelisted(address account) internal {
       _whitelisteds.add(account);
       emit WhitelistedAdded(account);
   }
 
   function _removeWhitelisted(address account) internal {
       _whitelisteds.remove(account);
       emit WhitelistedRemoved(account);
   }
}
 
abstract contract LockRegistry is Context {
 
   event Locked(address account);
 
   event Unlocked(address account);
 
   bool private _locked;
 
   constructor() {
       _locked = false;
   }
 
   function locked() public view virtual returns (bool) {
       return _locked;
   }
 
   modifier whenNotLocked() {
       require(!locked(), "LockRegistry: locked");
       _;
   }
 
   modifier whenLocked() {
       require(locked(), "LockRegistry: not locked");
       _;
   }
 
   function _lock() internal virtual whenNotLocked {
       _locked = true;
       emit Locked(_msgSender());
   }
 
   function _unlock() internal virtual whenLocked {
       _locked = false;
       emit Unlocked(_msgSender());
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
 
contract EtermonIDO is LockRegistry, WhitelistedRole, ReentrancyGuard {

   using EnumerableSet for EnumerableSet.UintSet;
   using EnumerableMap for EnumerableMap.UintToAddressMap;
   using Counters for Counters.Counter;


   event ETMPublicIDORegistered(address account, uint256 quantity, uint256 paid);
   event ERC20Released(address indexed token, address indexed beneficiary, uint256 amount, uint8 indexed month);
   event ERC20Allocated(address indexed token, address indexed beneficiary, uint256 amount);
   event ChangeBeneficiaryAddress(address indexed from, address indexed to);
   event SlotIssued(address indexed from, address indexed to, uint256 slotId);

   Counters.Counter private _slotIdTracker;
 
   address public busdToken;
   address public etmToken;
   address private immutable _idoRecipientAddress;
   //address[] beneficiaries;
 
   mapping(address=>uint256) private totalETMTokenRegistered;
 
   uint256 public constant TOTAL_ETM_IDO_ALLOCATION = uint256(2000000)*(uint256(10)**18);
   uint256 public constant MAX_ETM_BUYING_RULE = uint256(2500)*(uint256(10)**18);
   uint256 public constant MIN_ETM_BUYING_RULE = uint256(500)*(uint256(10)**18);
   uint256 public constant PRICE_BUSD = uint256(2)*(uint256(10)**18)/uint256(100);
   uint256 public constant MAX_SLOT = 1700;
  
   uint256 private _totalSold;
   uint64 private _slotCounter;
   uint64 private immutable _start;
 
   //uint64 constant MONTH_IN_SECONDS = 2592000;
   uint64 constant MONTH_IN_SECONDS = 60;
   uint256 private _erc20Released;
   mapping(address => uint256) private _beneficiaryReceived;
   mapping(address => mapping(uint8 => bool)) private _monthReleased;
   mapping(address => uint256) private _erc20Allocated;
   mapping(uint256 => address) private _owners;
   // Mapping from beneficiary address to their (enumerable) set of owned slot index
   mapping (address => EnumerableSet.UintSet) private _beneficiarySlotIds;
   // Enumerable mapping from slot index to their owners
   EnumerableMap.UintToAddressMap private _slotBeneficiaries;
   uint64 private immutable _startReleased;
   uint8 public constant Ratio_FixedAllocation_PerMonth = 15;
   uint8 public constant Ratio_TokenGenerationEvent = 25;
 
   constructor(
       address etmTokenAddress,
       address busdTokenAddress,
       address idoRecipientAddress,
       uint64 startTime,
       uint64 startTimeRelease  
   ){
       require(etmTokenAddress != address(0), "EtermonIDO: etmToken is zero address");
       require(busdTokenAddress != address(0), "EtermonIDO: busdToken is zero address");
       require(idoRecipientAddress != address(0), "EtermonIDO: idoRecipientAddress is zero address");
       etmToken = etmTokenAddress;
       busdToken = busdTokenAddress;
       _idoRecipientAddress = idoRecipientAddress;
       _start = startTime;
       _startReleased = startTimeRelease;
   }
 
   function addWhitelisted(address[] memory accounts) public onlyWhitelistAdmin {
       for (uint8 i=0; i<accounts.length; i++) {
           require(totalSlotSupply() <= MAX_SLOT, "EtermonIDO: Exceeded the limitation of the number of participants");
           addWhitelisted(accounts[i]);
           _issue(accounts[i], _slotIdTracker.current());
           _slotIdTracker.increment();
       }
   }
 
   function removeWhitelisted(address[] memory accounts) public onlyWhitelistAdmin {
       for (uint8 i=0; i<accounts.length; i++) {
           removeWhitelisted(accounts[i]);
           _revoke(accounts[i], slotOfOwnerByIndex(accounts[i],0));
       }
   }
 
   function register(uint8 pay) public whenNotLocked onlyWhitelisted nonReentrant {
       require(uint64(block.timestamp) >= start(), "EtermonIDO: IDO has not been started yet");
       uint256 quantity = pay*(uint256(10)**18)/PRICE_BUSD;
       require(quantity*(uint256(10)**18) + totalETMTokenRegistered[_msgSender()] >= MIN_ETM_BUYING_RULE && quantity*(uint256(10)**18) + totalETMTokenRegistered[_msgSender()] <= MAX_ETM_BUYING_RULE, "EtermonIDO: pay is invalid value");
       totalETMTokenRegistered[_msgSender()] += quantity*(uint256(10)**18);
       require(_totalSold + quantity*(uint256(10)**18) <= TOTAL_ETM_IDO_ALLOCATION, "EtermonIDO: Not enough to sell");
       _totalSold += quantity*(uint256(10)**18);
       SafeERC20.safeTransferFrom(IERC20(busdToken), _msgSender(), _idoRecipientAddress, pay*(uint256(10)**18));
       emit ETMPublicIDORegistered(_msgSender(), quantity*(uint256(10)**18), pay*(uint256(10)**18));
       _allocate(_msgSender(), quantity*(uint256(10)**18));
   }
 
   function changeBeneficiaryAddress(address curAddress, address newAddress) public whenLocked onlyWhitelistAdmin virtual {
       _erc20Allocated[newAddress] = _erc20Allocated[curAddress];
       _erc20Allocated[curAddress] = 0;
       _beneficiaryReceived[newAddress] = _beneficiaryReceived[curAddress];
       emit ChangeBeneficiaryAddress(curAddress, newAddress);
       removeWhitelisted(curAddress);
       addWhitelisted(newAddress);
   }
 
   function releases(address[] memory beneficiaries) public whenLocked onlyWhitelistAdmin virtual {
       for (uint8 i=0; i<beneficiaries.length; i++) {
            _release(beneficiaries[i]);
       }
   }

   function release() public whenLocked onlyWhitelistAdmin virtual {
       for (uint8 i=0; i<totalSlotSupply(); i++) {
           address beneficiary = ownerOfSlot(slotByIndex(i));
           if (_monthReleased[beneficiary][uint8((uint64(block.timestamp) - startReleasedTime()) / MONTH_IN_SECONDS)] != true)
            _release(beneficiary);
       }
   }

   function slotOfOwnerByIndex(address beneficiary, uint256 index) public view returns (uint256) {
        return _beneficiarySlotIds[beneficiary].at(index);
    }

    function slotByIndex(uint256 index) public view returns (uint256) {
        (uint256 slotId, ) = _slotBeneficiaries.at(index);
        return slotId;
    }

    function ownerOfSlot(uint256 slotId) public view returns (address) {
        address owner = _owners[slotId];
        require(owner != address(0), "EtermonIDO: owner query for nonexistent slot");
        return owner;
    }
 
   function claim() public whenLocked onlyWhitelisted nonReentrant virtual {
       _release(_msgSender());
   }
 
   function lock() public whenNotLocked onlyWhitelistAdmin {
       _lock();
   }
 
   function unlock() public whenLocked onlyWhitelistAdmin {
       _unlock();
   }
 
   function idoRecipient() public view virtual returns (address) {
       return _idoRecipientAddress;
   }
 
   function totalETMTokenRegister() public view virtual returns (uint256) {
       return totalETMTokenRegistered[_msgSender()];
   }
 
   function totalETMTokenSold() public view virtual returns (uint256) {
       return _totalSold;
   }
 
   function totalSlotSupply() public view virtual returns (uint256) {
       return _slotBeneficiaries.length();
   }
 
   function start() public view virtual returns (uint64) {
       return _start;
   }
 
   function isBeneficiary(address account) public view virtual returns (bool) {
       return _erc20Allocated[account] > 0;
   }
 
   function getTokenAllocations(address beneficiary) public view virtual returns (uint256) {
       return _erc20Allocated[beneficiary];
   }
 
   function startReleasedTime() public view virtual returns (uint64) {
       return _startReleased;
   }
 
   function fixedAllocationPerMonth() public view virtual returns (uint256) {
       return (IERC20(etmToken).balanceOf(address(this)) + released()) * Ratio_FixedAllocation_PerMonth / 100;
   }
 
   function fixedAllocationForBeneficiaryPerMonth(address beneficiary) public view virtual returns (uint256) {
       return (getTokenAllocations(beneficiary)) * Ratio_FixedAllocation_PerMonth / 100;
   }
 
   function tokenGenerationEventOnFirstMonth() public view virtual returns (uint256) {
       return (IERC20(etmToken).balanceOf(address(this)) + released()) * Ratio_TokenGenerationEvent / 100;
   }
 
   function tokenGenerationEventForBeneficiaryOnFirstMonth(address beneficiary) public view virtual returns (uint256) {
       return getTokenAllocations(beneficiary) * Ratio_TokenGenerationEvent / 100;
   }
 
   function released() public view virtual returns (uint256) {
       return _erc20Released;
   }
 
   function releasedForBeneficiary(address beneficiary) public view virtual returns (uint256) {
       return _beneficiaryReceived[beneficiary];
   }
 
   function monthReleased(address beneficiary, uint8 monthIndex) public view virtual returns (bool) {
       return _monthReleased[beneficiary][monthIndex];
   }
 
   function vestedBeneficiaryAmount(address beneficiary, uint64 timestamp) public view virtual returns (uint256) {
       return _vestingSchedule(_erc20Allocated[beneficiary], timestamp, beneficiary);
   }
 
   function _vestingSchedule(uint256 totalAllocation, uint64 timestamp, address beneficiary) internal view virtual returns (uint256) {
       if (timestamp < startReleasedTime()) {
           return 0;
       }
       uint256 amount = _specialSchedule(timestamp, beneficiary);
      
       if (timestamp >= startReleasedTime() && amount <= totalAllocation) {
           return amount;
       } else {
           return totalAllocation;
       }
   }
 
   function _specialSchedule(uint64 timestamp, address beneficiary) internal view virtual returns (uint256) {
       if ((timestamp - startReleasedTime()) / MONTH_IN_SECONDS < 1) {
           return tokenGenerationEventForBeneficiaryOnFirstMonth(beneficiary);
       } else {
           return tokenGenerationEventForBeneficiaryOnFirstMonth(beneficiary) + ((timestamp - startReleasedTime()) / MONTH_IN_SECONDS) * fixedAllocationForBeneficiaryPerMonth(beneficiary);
       }
   }
 
   function _allocate(address beneficiaryAddress, uint256 beneficiaryTokenAllocation) private {
       _erc20Allocated[beneficiaryAddress] += beneficiaryTokenAllocation;
       emit ERC20Allocated(etmToken, beneficiaryAddress, beneficiaryTokenAllocation);
   }
 
   function _release(address beneficiary) private {
       require(uint64(block.timestamp) >= startReleasedTime() && _monthReleased[beneficiary][uint8((uint64(block.timestamp) - startReleasedTime()) / MONTH_IN_SECONDS)] != true, "EtermonIDO: this time has already released");
       uint256 releasable = vestedBeneficiaryAmount(beneficiary, uint64(block.timestamp)) - _beneficiaryReceived[beneficiary];
       require(releasable > 0, "EtermonIDO: don't have token to release for this beneficiary");
       _erc20Released += releasable;
       _beneficiaryReceived[beneficiary] += releasable;
       emit ERC20Released(etmToken, beneficiary, releasable, uint8((uint64(block.timestamp) - startReleasedTime()) / MONTH_IN_SECONDS));
       _monthReleased[beneficiary][uint8((uint64(block.timestamp) - startReleasedTime()) / MONTH_IN_SECONDS)] = true;
       SafeERC20.safeTransfer(IERC20(etmToken), beneficiary, releasable);
   }

   function _exists(uint256 slotId) private view returns (bool) {
        return _slotBeneficiaries.contains(slotId);
    }

    function _issue(address to, uint256 slotId) internal virtual {
        require(to != address(0), "EtermonIDO: issue to the zero address");
        require(!_exists(slotId), "EtermonIDO: slot already issued");
        _owners[slotId] = to;
        _beneficiarySlotIds[to].add(slotId);
        _slotBeneficiaries.set(slotId, to);
        emit SlotIssued(address(0), to, slotId);
    }

    function _revoke(address to, uint256 slotId) internal virtual {
        require(_exists(slotId),  "EtermonIDO: revoke for nonexistent slot");
        delete _owners[slotId];
        _beneficiarySlotIds[to].remove(slotId);
        _slotBeneficiaries.remove(slotId);
        emit SlotIssued(to, address(0), slotId);
    }
 
}