/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// File: @openzeppelin/contracts/utils/Counters.sol


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

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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

        assembly {
            result := store
        }

        return result;
    }
}

// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts/access/IAccessControlEnumerable.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;


/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: @openzeppelin/contracts/access/AccessControlEnumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;




/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Pausable.sol)

pragma solidity ^0.8.0;



/**
 * @dev ERC721 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC721Pausable is ERC721, Pausable {
    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;



/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;



/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// File: @openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol)

pragma solidity ^0.8.0;








/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 *
 * _Deprecated in favor of https://wizard.openzeppelin.com/[Contracts Wizard]._
 */
contract ERC721PresetMinterPauserAutoId is
    Context,
    AccessControlEnumerable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

    string private _baseTokenURI;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// File: contracts/Velhalla721.sol

pragma solidity ^0.8.0;

contract Velhalla721 is ERC721PresetMinterPauserAutoId {

    // uint256[] grasslandsIDs = [10012888];
    // uint256[] tundraIDs = [10012101];
    // uint256[] moltenBarrensIDs = [10012466];
    // uint256[] wastelandsIDs = [10012182];
    // uint256[] crystalHighlandsIDs = [10000001];

    uint32[] grasslandsIDs = [10012888, 10012889, 10012890, 10012891, 10012892, 10012893, 10012978, 10012979, 10012980, 10012981, 10012982, 10012983, 10012984, 10012985, 10012986];
    uint32[] tundraIDs = [10012101, 10012102, 10012103, 10012104, 10012105, 10012106, 10012107, 10012108, 10012109, 10012110, 10012111, 10012112, 10012113, 10012114, 10012115];
    uint32[] moltenBarrensIDs = [10012466, 10012467, 10012529, 10012530, 10012531, 10012532, 10012595, 10012596, 10012597, 10012598, 10012599, 10012600, 10012670, 10012671, 10012672];
    uint32[] wastelandsIDs = [10012182, 10012183, 10012207, 10012208, 10012232, 10012233, 10012234, 10012235, 10012236, 10012237, 10012262, 10012263, 10012264, 10012265, 10012266];
    uint32[] crystalHighlandsIDs = [10000001, 10000002];

    // uint32[] grasslandsIDs = [10012888, 10012889, 10012890, 10012891, 10012892, 10012893, 10012978, 10012979, 10012980, 10012981, 10012982, 10012983, 10012984, 10012985, 10012986, 10012987, 10012998, 10012999, 10013070, 10013071, 10013072, 10013073, 10013074, 10013075, 10013076, 10013077, 10013078, 10013079, 10013080, 10013081, 10013082, 10013090, 10013091, 10013092, 10013093, 10013163, 10013164, 10013165, 10013166, 10013167, 10013168, 10013169, 10013170, 10013171, 10013172, 10013173, 10013174, 10013175, 10013176, 10013177, 10013178, 10013179, 10013184, 10013185, 10013186, 10013187, 10013188, 10013259, 10013260, 10013261, 10013262, 10013263, 10013264, 10013265, 10013266, 10013267, 10013268, 10013269, 10013270, 10013271, 10013272, 10013273, 10013274, 10013275, 10013276, 10013277, 10013278, 10013281, 10013282, 10013283, 10013284, 10013285, 10013286, 10013357, 10013358, 10013359, 10013360, 10013361, 10013362, 10013363, 10013364, 10013365, 10013366, 10013367, 10013368, 10013369, 10013370, 10013371, 10013372, 10013373, 10013374, 10013375, 10013376, 10013377, 10013378, 10013379, 10013380, 10013381, 10013382, 10013383, 10013384, 10013385, 10013386, 10013458, 10013459, 10013460, 10013461, 10013462, 10013463, 10013464, 10013465, 10013466, 10013467, 10013468, 10013469, 10013470, 10013471, 10013472, 10013473, 10013474, 10013475, 10013476, 10013477, 10013478, 10013479, 10013480, 10013481, 10013482, 10013483, 10013484, 10013485, 10013486, 10013487, 10013488, 10013559, 10013560, 10013561, 10013562, 10013563, 10013564, 10013565, 10013566, 10013567, 10013568, 10013569, 10013570, 10013571, 10013572, 10013573, 10013574, 10013575, 10013576, 10013577, 10013578, 10013579, 10013580, 10013581, 10013582, 10013583, 10013584, 10013585, 10013586, 10013587, 10013588, 10013589, 10013664, 10013665, 10013666, 10013667, 10013668, 10013669, 10013670, 10013671, 10013672, 10013673, 10013674, 10013675, 10013676, 10013677, 10013678, 10013679, 10013680, 10013681, 10013682, 10013683, 10013684, 10013685, 10013686, 10013687, 10013688, 10013689, 10013690, 10013691, 10013692, 10013768, 10013769, 10013770, 10013771, 10013772, 10013773, 10013774, 10013775, 10013776, 10013777, 10013778, 10013779, 10013780, 10013781, 10013782, 10013783, 10013784, 10013785, 10013786, 10013787, 10013788, 10013789, 10013790, 10013791, 10013792, 10013793, 10013794, 10013795, 10013796, 10013874, 10013875, 10013876, 10013877, 10013878, 10013879, 10013880, 10013881, 10013882, 10013883, 10013884, 10013885, 10013886, 10013887, 10013888, 10013889, 10013890, 10013891, 10013892, 10013893, 10013894, 10013895, 10013896, 10013897, 10013898, 10013899, 10013900, 10013901, 10013902, 10013903, 10013904, 10013980, 10013981, 10013982, 10013983, 10013984, 10013985, 10013986, 10013987, 10013988, 10013989, 10013990, 10013991, 10013992, 10013993, 10013994, 10013995, 10013996, 10013997, 10013998, 10013999, 10014000, 10014001, 10014002, 10014003, 10014004, 10014005, 10014006, 10014007, 10014008, 10014009, 10014010, 10014011, 10014012, 10014088, 10014089, 10014090, 10014091, 10014092, 10014093, 10014094, 10014095, 10014096, 10014097, 10014098, 10014099, 10014100, 10014101, 10014102, 10014103, 10014104, 10014105, 10014106, 10014107, 10014108, 10014109, 10014110, 10014111, 10014112, 10014113, 10014114, 10014115, 10014116, 10014117, 10014118, 10014119, 10014120, 10014200, 10014201, 10014202, 10014203, 10014204, 10014205, 10014206, 10014207, 10014208, 10014209, 10014210, 10014211, 10014212, 10014213, 10014214, 10014215, 10014216, 10014217, 10014218, 10014219, 10014220, 10014221, 10014222, 10014223, 10014224, 10014225, 10014226, 10014227, 10014228, 10014229, 10014230, 10014231, 10014232, 10014313, 10014314, 10014315, 10014316, 10014317, 10014318, 10014319, 10014320, 10014321, 10014322, 10014323, 10014324, 10014325, 10014326, 10014327, 10014328, 10014329, 10014330, 10014331, 10014332, 10014333, 10014334, 10014335, 10014336, 10014337, 10014338, 10014339, 10014340, 10014341, 10014342, 10014343, 10014344, 10014345, 10014346, 10014347, 10014431, 10014432, 10014433, 10014434, 10014435, 10014436, 10014437, 10014438, 10014439, 10014440, 10014441, 10014442, 10014443, 10014444, 10014445, 10014446, 10014447, 10014448, 10014449, 10014450, 10014451, 10014452, 10014453, 10014454, 10014455, 10014456, 10014457, 10014458, 10014459, 10014460, 10014461, 10014462, 10014463, 10014464, 10014465, 10014466, 10014550, 10014551, 10014552, 10014553, 10014554, 10014555, 10014556, 10014557, 10014558, 10014559, 10014560, 10014561, 10014562, 10014563, 10014564, 10014565, 10014566, 10014567, 10014568, 10014569, 10014570, 10014571, 10014572, 10014573, 10014574, 10014575, 10014576, 10014577, 10014578, 10014579, 10014580, 10014581, 10014582, 10014583, 10014584, 10014585, 10014586, 10014587, 10014671, 10014672, 10014673, 10014674, 10014675, 10014676, 10014677, 10014678, 10014679, 10014680, 10014681, 10014682, 10014683, 10014684, 10014685, 10014686, 10014687, 10014688, 10014689, 10014690, 10014691, 10014692, 10014693, 10014694, 10014695, 10014696, 10014697, 10014698, 10014699, 10014700, 10014701, 10014702, 10014703, 10014704, 10014705, 10014706, 10014707, 10014708, 10014709, 10014792, 10014793, 10014794, 10014795, 10014796, 10014797, 10014798, 10014799, 10014800, 10014801, 10014802, 10014803, 10014804, 10014805, 10014806, 10014807, 10014808, 10014809, 10014810, 10014811, 10014812, 10014813, 10014814, 10014815, 10014816, 10014817, 10014818, 10014819, 10014820, 10014821, 10014822, 10014823, 10014824, 10014825, 10014826, 10014827, 10014828, 10014829, 10014830, 10014831, 10014914, 10014915, 10014916, 10014917, 10014918, 10014919, 10014920, 10014921, 10014922, 10014923, 10014924, 10014925, 10014926, 10014927, 10014928, 10014929, 10014930, 10014931, 10014932, 10014933, 10014934, 10014935, 10014936, 10014937, 10014938, 10014939, 10014940, 10014941, 10014942, 10014943, 10014944, 10014945, 10014946, 10014947, 10014948, 10014949, 10014950, 10014951, 10014952, 10014953, 10014954, 10015036, 10015037, 10015038, 10015039, 10015040, 10015041, 10015042, 10015043, 10015044, 10015045, 10015046, 10015047, 10015048, 10015049, 10015050, 10015051, 10015052, 10015053, 10015054, 10015055, 10015056, 10015057, 10015058, 10015059, 10015060, 10015061, 10015062, 10015063, 10015064, 10015065, 10015066, 10015067, 10015068, 10015069, 10015070, 10015071, 10015072, 10015073, 10015074, 10015075, 10015156, 10015157, 10015158, 10015159, 10015160, 10015161, 10015162, 10015163, 10015164, 10015165, 10015166, 10015167, 10015168, 10015169, 10015170, 10015171, 10015172, 10015173, 10015174, 10015175, 10015176, 10015177, 10015178, 10015179, 10015180, 10015181, 10015182, 10015183, 10015184, 10015185, 10015186, 10015187, 10015188, 10015189, 10015190, 10015191, 10015192, 10015193, 10015194, 10015195, 10015275, 10015276, 10015277, 10015278, 10015279, 10015280, 10015281, 10015282, 10015283, 10015284, 10015285, 10015286, 10015287, 10015288, 10015289, 10015290, 10015291, 10015292, 10015293, 10015294, 10015295, 10015296, 10015297, 10015298, 10015299, 10015300, 10015301, 10015302, 10015303, 10015304, 10015305, 10015306, 10015307, 10015308, 10015309, 10015310, 10015311, 10015312, 10015313, 10015314, 10015315, 10015394, 10015395, 10015396, 10015397, 10015398, 10015399, 10015400, 10015401, 10015402, 10015403, 10015404, 10015405, 10015406, 10015407, 10015408, 10015409, 10015410, 10015411, 10015412, 10015413, 10015414, 10015415, 10015416, 10015417, 10015418, 10015419, 10015420, 10015421, 10015422, 10015423, 10015424, 10015425, 10015426, 10015427, 10015428, 10015429, 10015430, 10015431, 10015432, 10015433, 10015434, 10015512, 10015513, 10015514, 10015515, 10015516, 10015517, 10015518, 10015519, 10015520, 10015521, 10015522, 10015523, 10015524, 10015525, 10015526, 10015527, 10015528, 10015529, 10015530, 10015531, 10015532, 10015533, 10015534, 10015535, 10015536, 10015537, 10015538, 10015539, 10015540, 10015541, 10015542, 10015543, 10015544, 10015545, 10015546, 10015547, 10015548, 10015549, 10015627, 10015628, 10015629, 10015630, 10015631, 10015632, 10015633, 10015634, 10015635, 10015636, 10015637, 10015638, 10015639, 10015640, 10015641, 10015642, 10015643, 10015644, 10015645, 10015646, 10015647, 10015648, 10015649, 10015650, 10015651, 10015652, 10015653, 10015654, 10015655, 10015656, 10015657, 10015658, 10015659, 10015660, 10015661, 10015662, 10015663, 10015743, 10015744, 10015745, 10015746, 10015747, 10015748, 10015749, 10015750, 10015751, 10015752, 10015753, 10015754, 10015755, 10015756, 10015757, 10015758, 10015759, 10015760, 10015761, 10015762, 10015763, 10015764, 10015765, 10015766, 10015767, 10015768, 10015769, 10015770, 10015771, 10015772, 10015773, 10015774, 10015775, 10015776, 10015777, 10015778, 10015861, 10015862, 10015863, 10015864, 10015865, 10015866, 10015867, 10015868, 10015869, 10015870, 10015871, 10015872, 10015873, 10015874, 10015875, 10015876, 10015877, 10015878, 10015879, 10015880, 10015881, 10015882, 10015883, 10015884, 10015885, 10015886, 10015887, 10015888, 10015889, 10015890, 10015891, 10015892, 10015893, 10015894, 10015977, 10015978, 10015979, 10015980, 10015981, 10015982, 10015983, 10015984, 10015985, 10015986, 10015987, 10015988, 10015989, 10015990, 10015991, 10015992, 10015993, 10015994, 10015995, 10015996, 10015997, 10015998, 10015999, 10016000, 10016001, 10016002, 10016003, 10016004, 10016005, 10016006, 10016007, 10016008, 10016009, 10016093, 10016094, 10016095, 10016096, 10016097, 10016098, 10016099, 10016100, 10016101, 10016102, 10016103, 10016104, 10016105, 10016106, 10016107, 10016108, 10016109, 10016110, 10016111, 10016112, 10016113, 10016114, 10016115, 10016116, 10016117, 10016118, 10016119, 10016120, 10016121, 10016122, 10016123, 10016124, 10016125, 10016211, 10016212, 10016213, 10016214, 10016215, 10016216, 10016217, 10016218, 10016219, 10016220, 10016221, 10016222, 10016223, 10016224, 10016225, 10016226, 10016227, 10016228, 10016229, 10016230, 10016231, 10016232, 10016233, 10016234, 10016235, 10016236, 10016237, 10016238, 10016239, 10016240, 10016241, 10016242, 10016243, 10016244, 10016245, 10016335, 10016336, 10016337, 10016338, 10016339, 10016340, 10016341, 10016342, 10016343, 10016344, 10016345, 10016346, 10016347, 10016348, 10016349, 10016350, 10016351, 10016352, 10016353, 10016354, 10016355, 10016356, 10016357, 10016358, 10016359, 10016360, 10016361, 10016362, 10016363, 10016364, 10016365, 10016366, 10016367, 10016368, 10016369, 10016462, 10016463, 10016464, 10016465, 10016466, 10016467, 10016468, 10016469, 10016470, 10016471, 10016472, 10016473, 10016474, 10016475, 10016476, 10016477, 10016478, 10016479, 10016480, 10016481, 10016482, 10016483, 10016484, 10016485, 10016486, 10016487, 10016488, 10016489, 10016490, 10016491, 10016492, 10016493, 10016494, 10016495, 10016496, 10016592, 10016593, 10016594, 10016595, 10016596, 10016597, 10016598, 10016599, 10016600, 10016601, 10016602, 10016603, 10016604, 10016605, 10016606, 10016607, 10016608, 10016609, 10016610, 10016611, 10016612, 10016613, 10016614, 10016615, 10016616, 10016617, 10016618, 10016619, 10016620, 10016621, 10016622, 10016623, 10016624, 10016625, 10016626, 10016723, 10016724, 10016725, 10016726, 10016727, 10016728, 10016729, 10016730, 10016731, 10016732, 10016733, 10016734, 10016735, 10016736, 10016737, 10016738, 10016739, 10016740, 10016741, 10016742, 10016743, 10016744, 10016745, 10016746, 10016747, 10016748, 10016749, 10016750, 10016751, 10016752, 10016753, 10016754, 10016755, 10016756, 10016757, 10016858, 10016859, 10016860, 10016861, 10016862, 10016863, 10016864, 10016865, 10016866, 10016867, 10016868, 10016869, 10016870, 10016871, 10016872, 10016873, 10016874, 10016875, 10016876, 10016877, 10016878, 10016879, 10016880, 10016881, 10016882, 10016883, 10016884, 10016885, 10016886, 10016887, 10016888, 10016889, 10016890, 10016891, 10016892, 10016994, 10016995, 10016996, 10016997, 10016998, 10016999, 10017000, 10017001, 10017002, 10017003, 10017004, 10017005, 10017006, 10017007, 10017008, 10017009, 10017010, 10017011, 10017012, 10017013, 10017014, 10017015, 10017016, 10017017, 10017018, 10017019, 10017020, 10017021, 10017022, 10017023, 10017024, 10017025, 10017026, 10017027, 10017028, 10017130, 10017131, 10017132, 10017133, 10017134, 10017135, 10017136, 10017137, 10017138, 10017139, 10017140, 10017141, 10017142, 10017143, 10017144, 10017145, 10017146, 10017147, 10017148, 10017149, 10017150, 10017151, 10017152, 10017153, 10017154, 10017155, 10017156, 10017157, 10017158, 10017159, 10017160, 10017161, 10017162, 10017163, 10017164, 10017267, 10017268, 10017269, 10017270, 10017271, 10017272, 10017273, 10017274, 10017275, 10017276, 10017277, 10017278, 10017279, 10017280, 10017281, 10017282, 10017283, 10017284, 10017285, 10017286, 10017287, 10017288, 10017289, 10017290, 10017291, 10017292, 10017293, 10017294, 10017295, 10017296, 10017297, 10017298, 10017299, 10017300, 10017403, 10017404, 10017405, 10017406, 10017407, 10017408, 10017409, 10017410, 10017411, 10017412, 10017413, 10017414, 10017415, 10017416, 10017417, 10017418, 10017419, 10017420, 10017421, 10017422, 10017423, 10017424, 10017425, 10017426, 10017427, 10017428, 10017429, 10017430, 10017431, 10017432, 10017433, 10017434, 10017435, 10017436, 10017544, 10017545, 10017546, 10017547, 10017548, 10017549, 10017550, 10017551, 10017552, 10017553, 10017554, 10017555, 10017556, 10017557, 10017558, 10017559, 10017560, 10017561, 10017562, 10017563, 10017564, 10017565, 10017566, 10017567, 10017568, 10017569, 10017570, 10017571, 10017572, 10017573, 10017574, 10017575, 10017576, 10017577, 10017578, 10017579, 10017689, 10017690, 10017691, 10017692, 10017693, 10017694, 10017695, 10017696, 10017697, 10017698, 10017699, 10017700, 10017701, 10017702, 10017703, 10017704, 10017705, 10017706, 10017707, 10017708, 10017709, 10017710, 10017711, 10017712, 10017713, 10017714, 10017715, 10017716, 10017717, 10017718, 10017719, 10017720, 10017721, 10017722, 10017723, 10017724, 10017832, 10017833, 10017834, 10017835, 10017836, 10017837, 10017838, 10017839, 10017840, 10017841, 10017842, 10017843, 10017844, 10017845, 10017846, 10017847, 10017848, 10017849, 10017850, 10017851, 10017852, 10017853, 10017854, 10017855, 10017856, 10017857, 10017858, 10017859, 10017860, 10017861, 10017862, 10017863, 10017864, 10017865, 10017866, 10017867, 10017975, 10017976, 10017977, 10017978, 10017979, 10017980, 10017981, 10017982, 10017983, 10017984, 10017985, 10017986, 10017987, 10017988, 10017989, 10017990, 10017991, 10017992, 10017993, 10017994, 10017995, 10017996, 10017997, 10017998, 10017999, 10018000, 10018001, 10018002, 10018003, 10018004, 10018005, 10018006, 10018007, 10018008, 10018009, 10018010, 10018119, 10018120, 10018121, 10018122, 10018123, 10018124, 10018125, 10018126, 10018127, 10018128, 10018129, 10018130, 10018131, 10018132, 10018133, 10018134, 10018135, 10018136, 10018137, 10018138, 10018139, 10018140, 10018141, 10018142, 10018143, 10018144, 10018145, 10018146, 10018147, 10018148, 10018149, 10018150, 10018151, 10018152, 10018153, 10018154, 10018155, 10018156, 10018267, 10018268, 10018269, 10018270, 10018271];
    // uint32[] tundraIDs = [10012101, 10012102, 10012103, 10012104, 10012105, 10012106, 10012107, 10012108, 10012109, 10012110, 10012111, 10012112, 10012113, 10012114, 10012115, 10012116, 10012117, 10012118, 10012119, 10012120, 10012121, 10012122, 10012123, 10012124, 10012125, 10012126, 10012127, 10012128, 10012129, 10012130, 10012131, 10012132, 10012133, 10012134, 10012135, 10012136, 10012137, 10012138, 10012139, 10012140, 10012141, 10012142, 10012143, 10012144, 10012145, 10012146, 10012147, 10012148, 10012149, 10012150, 10012151, 10012152, 10012153, 10012154, 10012155, 10012156, 10012157, 10012158, 10012159, 10012160, 10012161, 10012162, 10012163, 10012164, 10012165, 10012166, 10012167, 10012168, 10012169, 10012170, 10012171, 10012172, 10012173, 10012174, 10012175, 10012176, 10012177, 10012178, 10012179, 10012180, 10012181, 10012184, 10012185, 10012186, 10012187, 10012188, 10012189, 10012190, 10012191, 10012192, 10012193, 10012194, 10012195, 10012196, 10012197, 10012198, 10012199, 10012200, 10012201, 10012202, 10012203, 10012204, 10012205, 10012206, 10012209, 10012210, 10012211, 10012212, 10012213, 10012214, 10012215, 10012216, 10012217, 10012218, 10012219, 10012220, 10012221, 10012222, 10012223, 10012224, 10012225, 10012226, 10012227, 10012228, 10012229, 10012230, 10012231, 10012238, 10012239, 10012240, 10012241, 10012242, 10012243, 10012244, 10012245, 10012246, 10012247, 10012248, 10012249, 10012250, 10012251, 10012252, 10012253, 10012254, 10012255, 10012256, 10012257, 10012258, 10012259, 10012260, 10012261, 10012269, 10012270, 10012271, 10012272, 10012273, 10012274, 10012275, 10012276, 10012277, 10012278, 10012279, 10012280, 10012281, 10012282, 10012283, 10012284, 10012285, 10012286, 10012287, 10012288, 10012289, 10012290, 10012291, 10012292, 10012302, 10012303, 10012304, 10012305, 10012306, 10012307, 10012308, 10012309, 10012310, 10012311, 10012312, 10012313, 10012314, 10012315, 10012316, 10012317, 10012318, 10012319, 10012320, 10012321, 10012322, 10012323, 10012324, 10012325, 10012326, 10012327, 10012340, 10012341, 10012342, 10012343, 10012344, 10012345, 10012346, 10012347, 10012348, 10012349, 10012350, 10012351, 10012352, 10012353, 10012354, 10012355, 10012356, 10012357, 10012358, 10012359, 10012360, 10012361, 10012362, 10012363, 10012364, 10012365, 10012366, 10012367, 10012381, 10012382, 10012383, 10012384, 10012385, 10012386, 10012387, 10012388, 10012389, 10012390, 10012391, 10012392, 10012393, 10012394, 10012395, 10012396, 10012397, 10012398, 10012399, 10012400, 10012401, 10012402, 10012403, 10012404, 10012405, 10012406, 10012407, 10012408, 10012409, 10012426, 10012427, 10012428, 10012429, 10012430, 10012431, 10012432, 10012433, 10012434, 10012435, 10012436, 10012437, 10012438, 10012439, 10012440, 10012441, 10012442, 10012443, 10012444, 10012445, 10012446, 10012447, 10012448, 10012449, 10012450, 10012451, 10012452, 10012453, 10012454, 10012455, 10012456, 10012457, 10012458, 10012459, 10012460, 10012461, 10012462, 10012463, 10012464, 10012465, 10012485, 10012486, 10012487, 10012488, 10012489, 10012490, 10012491, 10012492, 10012493, 10012494, 10012495, 10012496, 10012497, 10012498, 10012499, 10012500, 10012501, 10012502, 10012503, 10012504, 10012505, 10012506, 10012507, 10012508, 10012509, 10012510, 10012511, 10012512, 10012513, 10012514, 10012515, 10012516, 10012517, 10012518, 10012519, 10012520, 10012521, 10012522, 10012523, 10012524, 10012525, 10012526, 10012527, 10012528, 10012550, 10012551, 10012552, 10012553, 10012554, 10012555, 10012556, 10012557, 10012558, 10012559, 10012560, 10012561, 10012562, 10012563, 10012564, 10012565, 10012566, 10012567, 10012568, 10012569, 10012570, 10012571, 10012572, 10012573, 10012574, 10012575, 10012576, 10012577, 10012578, 10012579, 10012580, 10012581, 10012582, 10012583, 10012584, 10012585, 10012586, 10012587, 10012588, 10012589, 10012590, 10012591, 10012592, 10012593, 10012594, 10012623, 10012624, 10012625, 10012626, 10012627, 10012628, 10012629, 10012630, 10012631, 10012632, 10012633, 10012634, 10012635, 10012636, 10012637, 10012638, 10012639, 10012640, 10012641, 10012642, 10012643, 10012644, 10012645, 10012646, 10012647, 10012648, 10012649, 10012650, 10012651, 10012652, 10012653, 10012654, 10012655, 10012656, 10012657, 10012658, 10012659, 10012660, 10012661, 10012662, 10012663, 10012664, 10012665, 10012666, 10012667, 10012668, 10012669, 10012704, 10012705, 10012706, 10012707, 10012708, 10012709, 10012710, 10012711, 10012712, 10012713, 10012714, 10012715, 10012716, 10012717, 10012718, 10012719, 10012720, 10012721, 10012722, 10012723, 10012724, 10012725, 10012726, 10012727, 10012728, 10012729, 10012730, 10012731, 10012732, 10012733, 10012734, 10012735, 10012736, 10012737, 10012738, 10012739, 10012740, 10012741, 10012742, 10012743, 10012744, 10012745, 10012746, 10012747, 10012748, 10012749, 10012750, 10012751, 10012752, 10012793, 10012794, 10012795, 10012796, 10012797, 10012798, 10012799, 10012800, 10012801, 10012802, 10012803, 10012804, 10012805, 10012806, 10012807, 10012808, 10012809, 10012810, 10012811, 10012812, 10012813, 10012814, 10012815, 10012816, 10012817, 10012818, 10012819, 10012820, 10012821, 10012822, 10012823, 10012824, 10012825, 10012826, 10012827, 10012828, 10012829, 10012830, 10012831, 10012832, 10012833, 10012834, 10012835, 10012836, 10012837, 10012838, 10012839, 10012840, 10012841, 10012842, 10012843, 10012844, 10012883, 10012884, 10012885, 10012886, 10012887, 10012894, 10012895, 10012896, 10012897, 10012898, 10012899, 10012900, 10012901, 10012902, 10012903, 10012904, 10012905, 10012906, 10012907, 10012908, 10012909, 10012910, 10012911, 10012912, 10012913, 10012914, 10012915, 10012916, 10012917, 10012918, 10012919, 10012920, 10012921, 10012922, 10012923, 10012924, 10012925, 10012926, 10012927, 10012928, 10012929, 10012930, 10012931, 10012932, 10012933, 10012934, 10012935, 10012974, 10012975, 10012976, 10012977, 10012988, 10012989, 10012990, 10012991, 10012992, 10012993, 10012994, 10012995, 10012996, 10012997, 10013000, 10013001, 10013002, 10013003, 10013004, 10013005, 10013006, 10013007, 10013008, 10013009, 10013010, 10013011, 10013012, 10013013, 10013014, 10013015, 10013016, 10013017, 10013018, 10013019, 10013020, 10013021, 10013022, 10013023, 10013024, 10013025, 10013026, 10013027, 10013028, 10013029, 10013067, 10013068, 10013069, 10013083, 10013084, 10013085, 10013086, 10013087, 10013088, 10013089, 10013094, 10013095, 10013096, 10013097, 10013098, 10013099, 10013100, 10013101, 10013102, 10013103, 10013104, 10013105, 10013106, 10013107, 10013108, 10013109, 10013110, 10013111, 10013112, 10013113, 10013114, 10013115, 10013116, 10013117, 10013118, 10013119, 10013120, 10013121, 10013122, 10013123, 10013124, 10013162, 10013180, 10013181, 10013182, 10013183, 10013189, 10013190, 10013191, 10013192, 10013193, 10013194, 10013195, 10013196, 10013197, 10013198, 10013199, 10013200, 10013201, 10013202, 10013203, 10013204, 10013205, 10013206, 10013207, 10013208, 10013209, 10013210, 10013211, 10013212, 10013213, 10013214, 10013215, 10013216, 10013217, 10013218, 10013219, 10013220, 10013221, 10013222, 10013279, 10013280, 10013287, 10013288, 10013289, 10013290, 10013291, 10013292, 10013293, 10013294, 10013295, 10013296, 10013297, 10013298, 10013299, 10013300, 10013301, 10013302, 10013303, 10013304, 10013305, 10013306, 10013307, 10013308, 10013309, 10013310, 10013311, 10013312, 10013313, 10013314, 10013315, 10013316, 10013317, 10013318, 10013319, 10013320, 10013387, 10013388, 10013389, 10013390, 10013391, 10013392, 10013393, 10013394, 10013395, 10013396, 10013397, 10013398, 10013399, 10013400, 10013401, 10013402, 10013403, 10013404, 10013405, 10013406, 10013407, 10013408, 10013409, 10013410, 10013411, 10013412, 10013413, 10013414, 10013415, 10013416, 10013417, 10013418, 10013489, 10013490, 10013491, 10013492, 10013493, 10013494, 10013495, 10013496, 10013497, 10013498, 10013499, 10013500, 10013501, 10013502, 10013503, 10013504, 10013505, 10013506, 10013507, 10013508, 10013509, 10013510, 10013511, 10013512, 10013513, 10013514, 10013515, 10013516, 10013517, 10013518, 10013519, 10013590, 10013591, 10013592, 10013593, 10013594, 10013595, 10013596, 10013597, 10013598, 10013599, 10013600, 10013601, 10013602, 10013603, 10013604, 10013605, 10013606, 10013607, 10013608, 10013609, 10013610, 10013611, 10013612, 10013613, 10013614, 10013615, 10013616, 10013617, 10013618, 10013619, 10013620, 10013693, 10013694, 10013695, 10013696, 10013697, 10013698, 10013699, 10013700, 10013701, 10013702, 10013703, 10013704, 10013705, 10013706, 10013707, 10013708, 10013709, 10013710, 10013711, 10013712, 10013713, 10013714, 10013715, 10013716, 10013717, 10013718, 10013719, 10013720, 10013721, 10013722, 10013723, 10013797, 10013798, 10013799, 10013800, 10013801, 10013802, 10013803, 10013804, 10013805, 10013806, 10013807, 10013808, 10013809, 10013810, 10013811, 10013812, 10013813, 10013814, 10013815, 10013816, 10013817, 10013818, 10013819, 10013820, 10013821, 10013822, 10013823, 10013824, 10013825, 10013826, 10013905, 10013906, 10013907, 10013908, 10013909, 10013910, 10013911, 10013912, 10013913, 10013914, 10013915, 10013916, 10013917, 10013918, 10013919, 10013920, 10013921, 10013922, 10013923, 10013924, 10013925, 10013926, 10013927, 10013930, 10013931, 10014013, 10014014, 10014015, 10014016, 10014017, 10014018, 10014019, 10014020, 10014021, 10014022, 10014023, 10014024, 10014025, 10014026, 10014027, 10014028, 10014029, 10014030, 10014031, 10014032, 10014033, 10014034, 10014121, 10014122, 10014123, 10014124, 10014125, 10014126, 10014127, 10014128, 10014129, 10014130, 10014131, 10014132, 10014133, 10014134, 10014135, 10014136, 10014137, 10014138, 10014139, 10014140, 10014141, 10014233, 10014234, 10014235, 10014236, 10014237, 10014238, 10014239, 10014240, 10014241, 10014242, 10014243, 10014244, 10014245, 10014246, 10014247, 10014248, 10014249, 10014250, 10014251, 10014252, 10014348, 10014349, 10014350, 10014351, 10014352, 10014353, 10014354, 10014355, 10014356, 10014357, 10014358, 10014359, 10014360, 10014361, 10014362, 10014363, 10014364, 10014365, 10014467, 10014468, 10014469, 10014470, 10014471, 10014472, 10014473, 10014474, 10014475, 10014476, 10014477, 10014478, 10014479, 10014480, 10014481, 10014482, 10014483, 10014588, 10014589, 10014590, 10014591, 10014592, 10014593, 10014594, 10014595, 10014596, 10014597, 10014598, 10014599, 10014600, 10014601, 10014602, 10014603, 10014710, 10014711, 10014712, 10014713, 10014714, 10014715, 10014716, 10014717, 10014718, 10014719, 10014720, 10014721, 10014722, 10014723, 10014724, 10014832, 10014833, 10014834, 10014835, 10014836, 10014837, 10014838, 10014839, 10014840, 10014841, 10014842, 10014843, 10014844, 10014955, 10014956, 10014957, 10014958, 10014959, 10014960, 10014961, 10014962, 10014963, 10014964, 10014965, 10015076, 10015077, 10015078, 10015079, 10015080, 10015081, 10015082, 10015083, 10015084, 10015196, 10015197, 10015198, 10015199, 10015200, 10015201, 10015202, 10015203, 10015316, 10015317, 10015318, 10015319, 10015320, 10015321, 10015322, 10015435, 10015436, 10015437, 10015438, 10015439, 10015440, 10015550, 10015551, 10015552, 10015553, 10015554, 10015664, 10015665, 10015666, 10015667, 10015668, 10015779, 10015780, 10015781, 10015782, 10015783, 10015784, 10015895, 10015896, 10015897, 10015898, 10015899, 10015900, 10015901, 10016010, 10016011, 10016012, 10016013, 10016014, 10016015, 10016016, 10016017, 10016126, 10016127, 10016128, 10016129, 10016130, 10016131, 10016132, 10016133, 10016246, 10016247, 10016248, 10016249, 10016250, 10016251, 10016252, 10016253, 10016254, 10016370, 10016371, 10016372, 10016373, 10016374, 10016375, 10016376, 10016377, 10016378, 10016379, 10016497, 10016498, 10016499, 10016500, 10016501, 10016502, 10016503, 10016504, 10016505, 10016506, 10016507, 10016627, 10016628, 10016629, 10016630, 10016631, 10016632, 10016633, 10016634, 10016635, 10016636, 10016637, 10016638, 10016639, 10016758, 10016759, 10016760, 10016761, 10016762, 10016763, 10016764, 10016765, 10016766, 10016767, 10016768, 10016769, 10016770, 10016893, 10016894, 10016895, 10016896, 10016897, 10016898, 10016899, 10016900, 10016901, 10016902, 10016903, 10016904, 10016905, 10017029, 10017030, 10017031, 10017032, 10017033, 10017034, 10017035, 10017036, 10017037, 10017038, 10017039, 10017040, 10017041, 10017165, 10017166, 10017167, 10017168, 10017169, 10017170, 10017171, 10017172, 10017173, 10017174, 10017175, 10017176, 10017177, 10017178, 10017301, 10017302, 10017303, 10017304, 10017305, 10017306, 10017307, 10017308, 10017309, 10017310, 10017311, 10017312, 10017313, 10017314, 10017315, 10017316, 10017437, 10017438, 10017439, 10017440, 10017441, 10017442, 10017443, 10017444, 10017445, 10017446, 10017447, 10017448, 10017449, 10017450, 10017451, 10017452, 10017580, 10017581, 10017582, 10017583, 10017584, 10017585, 10017586, 10017587, 10017588, 10017589, 10017590, 10017591, 10017592, 10017593, 10017594, 10017595, 10017596, 10017725, 10017726, 10017727, 10017728, 10017729, 10017730, 10017731, 10017732, 10017733, 10017734, 10017735, 10017736, 10017737, 10017738, 10017739, 10017740, 10017741, 10017868, 10017869, 10017870, 10017871, 10017872, 10017873, 10017874, 10017875, 10017876, 10017877, 10017878, 10017879, 10017880, 10017881, 10017882, 10017883, 10017884, 10018011, 10018012, 10018013, 10018014, 10018015, 10018016, 10018017, 10018018, 10018019, 10018020, 10018021, 10018022, 10018023, 10018024, 10018025, 10018026, 10018027, 10018028, 10018157, 10018158, 10018159, 10018160, 10018161, 10018162, 10018163, 10018164, 10018165, 10018166, 10018167, 10018168, 10018169, 10018170, 10018171, 10018172, 10018173, 10018174, 10018175, 10018306, 10018307, 10018308, 10018309, 10018310, 10018311, 10018312, 10018313, 10018314, 10018315, 10018316, 10018317, 10018318, 10018319, 10018320, 10018321, 10018322, 10018323, 10018324, 10018453, 10018454, 10018455, 10018456, 10018457, 10018458, 10018459, 10018460, 10018461, 10018462, 10018463, 10018464, 10018465, 10018466, 10018467, 10018468, 10018469, 10018470, 10018471, 10018472, 10018597, 10018598, 10018599, 10018600, 10018601, 10018602, 10018603, 10018604, 10018605, 10018606, 10018607, 10018608, 10018609, 10018610, 10018611, 10018612, 10018613, 10018614, 10018615, 10018616, 10018736, 10018737, 10018738, 10018739, 10018740, 10018741, 10018742, 10018743, 10018744, 10018745, 10018746, 10018747, 10018748, 10018749, 10018750, 10018751, 10018752, 10018753, 10018754, 10018755, 10018756, 10018757, 10018874, 10018875, 10018876, 10018877, 10018878, 10018879, 10018880, 10018881, 10018882, 10018883, 10018884, 10018885, 10018886, 10018887, 10018888, 10018889, 10018890, 10018891, 10018892, 10018893, 10018894, 10018895, 10018896, 10019012, 10019013, 10019014, 10019015, 10019016, 10019017, 10019018, 10019019, 10019020, 10019021, 10019022, 10019023, 10019024, 10019025, 10019026, 10019027, 10019028, 10019029, 10019030, 10019031, 10019032, 10019033, 10019034, 10019035, 10019147, 10019148, 10019149, 10019150, 10019151, 10019152, 10019153, 10019154, 10019155, 10019156, 10019157, 10019158];
    // uint32[] moltenBarrensIDs = [10012466, 10012467, 10012529, 10012530, 10012531, 10012532, 10012595, 10012596, 10012597, 10012598, 10012599, 10012600, 10012670, 10012671, 10012672, 10012673, 10012674, 10012675, 10012676, 10012677, 10012678, 10012679, 10012680, 10012681, 10012753, 10012754, 10012755, 10012756, 10012757, 10012758, 10012759, 10012760, 10012761, 10012762, 10012763, 10012764, 10012765, 10012766, 10012767, 10012768, 10012769, 10012845, 10012846, 10012847, 10012848, 10012849, 10012850, 10012851, 10012852, 10012853, 10012854, 10012855, 10012856, 10012857, 10012858, 10012859, 10012860, 10012861, 10012936, 10012937, 10012938, 10012939, 10012940, 10012941, 10012942, 10012943, 10012944, 10012945, 10012946, 10012947, 10012948, 10012949, 10012950, 10012951, 10012952, 10013030, 10013031, 10013032, 10013033, 10013034, 10013035, 10013036, 10013037, 10013038, 10013039, 10013040, 10013041, 10013042, 10013043, 10013044, 10013045, 10013046, 10013125, 10013126, 10013127, 10013128, 10013129, 10013130, 10013131, 10013132, 10013133, 10013134, 10013135, 10013136, 10013137, 10013138, 10013139, 10013140, 10013223, 10013224, 10013225, 10013226, 10013227, 10013228, 10013229, 10013230, 10013231, 10013232, 10013233, 10013234, 10013235, 10013236, 10013237, 10013321, 10013322, 10013323, 10013324, 10013325, 10013326, 10013327, 10013328, 10013329, 10013330, 10013331, 10013332, 10013333, 10013334, 10013335, 10013419, 10013420, 10013421, 10013422, 10013423, 10013424, 10013425, 10013426, 10013427, 10013428, 10013429, 10013430, 10013431, 10013432, 10013433, 10013520, 10013521, 10013522, 10013523, 10013524, 10013525, 10013526, 10013527, 10013528, 10013529, 10013530, 10013531, 10013532, 10013533, 10013534, 10013621, 10013622, 10013623, 10013624, 10013625, 10013626, 10013627, 10013628, 10013629, 10013630, 10013631, 10013632, 10013633, 10013634, 10013635, 10013724, 10013725, 10013726, 10013727, 10013728, 10013729, 10013730, 10013731, 10013732, 10013733, 10013734, 10013735, 10013736, 10013737, 10013827, 10013828, 10013829, 10013830, 10013831, 10013832, 10013833, 10013834, 10013835, 10013836, 10013837, 10013838, 10013839, 10013928, 10013929, 10013932, 10013933, 10013934, 10013935, 10013936, 10013937, 10013938, 10013939, 10013940, 10013941, 10013942, 10013943, 10013944, 10014035, 10014036, 10014037, 10014038, 10014039, 10014040, 10014041, 10014042, 10014043, 10014044, 10014045, 10014046, 10014047, 10014048, 10014049, 10014050, 10014051, 10014142, 10014143, 10014144, 10014145, 10014146, 10014147, 10014148, 10014149, 10014150, 10014151, 10014152, 10014153, 10014154, 10014155, 10014156, 10014157, 10014158, 10014159, 10014253, 10014254, 10014255, 10014256, 10014257, 10014258, 10014259, 10014260, 10014261, 10014262, 10014263, 10014264, 10014265, 10014266, 10014267, 10014268, 10014269, 10014270, 10014271, 10014366, 10014367, 10014368, 10014369, 10014370, 10014371, 10014372, 10014373, 10014374, 10014375, 10014376, 10014377, 10014378, 10014379, 10014380, 10014381, 10014382, 10014383, 10014384, 10014385, 10014484, 10014485, 10014486, 10014487, 10014488, 10014489, 10014490, 10014491, 10014492, 10014493, 10014494, 10014495, 10014496, 10014497, 10014498, 10014499, 10014500, 10014501, 10014502, 10014503, 10014604, 10014605, 10014606, 10014607, 10014608, 10014609, 10014610, 10014611, 10014612, 10014613, 10014614, 10014615, 10014616, 10014617, 10014618, 10014619, 10014620, 10014621, 10014622, 10014623, 10014725, 10014726, 10014727, 10014728, 10014729, 10014730, 10014731, 10014732, 10014733, 10014734, 10014735, 10014736, 10014737, 10014738, 10014739, 10014740, 10014741, 10014742, 10014743, 10014744, 10014845, 10014846, 10014847, 10014848, 10014849, 10014850, 10014851, 10014852, 10014853, 10014854, 10014855, 10014856, 10014857, 10014858, 10014859, 10014860, 10014861, 10014862, 10014863, 10014864, 10014865, 10014866, 10014966, 10014967, 10014968, 10014969, 10014970, 10014971, 10014972, 10014973, 10014974, 10014975, 10014976, 10014977, 10014978, 10014979, 10014980, 10014981, 10014982, 10014983, 10014984, 10014985, 10014986, 10014987, 10014988, 10015085, 10015086, 10015087, 10015088, 10015089, 10015090, 10015091, 10015092, 10015093, 10015094, 10015095, 10015096, 10015097, 10015098, 10015099, 10015100, 10015101, 10015102, 10015103, 10015104, 10015105, 10015106, 10015107, 10015108, 10015109, 10015204, 10015205, 10015206, 10015207, 10015208, 10015209, 10015210, 10015211, 10015212, 10015213, 10015214, 10015215, 10015216, 10015217, 10015218, 10015219, 10015220, 10015221, 10015222, 10015223, 10015224, 10015225, 10015226, 10015227, 10015228, 10015323, 10015324, 10015325, 10015326, 10015327, 10015328, 10015329, 10015330, 10015331, 10015332, 10015333, 10015334, 10015335, 10015336, 10015337, 10015338, 10015339, 10015340, 10015341, 10015342, 10015343, 10015344, 10015345, 10015346, 10015347, 10015348, 10015441, 10015442, 10015443, 10015444, 10015445, 10015446, 10015447, 10015448, 10015449, 10015450, 10015451, 10015452, 10015453, 10015454, 10015455, 10015456, 10015457, 10015458, 10015459, 10015460, 10015461, 10015462, 10015463, 10015464, 10015465, 10015466, 10015555, 10015556, 10015557, 10015558, 10015559, 10015560, 10015561, 10015562, 10015563, 10015564, 10015565, 10015566, 10015567, 10015568, 10015569, 10015570, 10015571, 10015572, 10015573, 10015574, 10015575, 10015576, 10015577, 10015578, 10015579, 10015580, 10015669, 10015670, 10015671, 10015672, 10015673, 10015674, 10015675, 10015676, 10015677, 10015678, 10015679, 10015680, 10015681, 10015682, 10015683, 10015684, 10015685, 10015686, 10015687, 10015688, 10015689, 10015690, 10015691, 10015692, 10015693, 10015694, 10015703, 10015704, 10015705, 10015785, 10015786, 10015787, 10015788, 10015789, 10015790, 10015791, 10015792, 10015793, 10015794, 10015795, 10015796, 10015797, 10015798, 10015799, 10015800, 10015801, 10015802, 10015803, 10015804, 10015805, 10015806, 10015807, 10015808, 10015809, 10015810, 10015818, 10015819, 10015820, 10015821, 10015822, 10015902, 10015903, 10015904, 10015905, 10015906, 10015907, 10015908, 10015909, 10015910, 10015911, 10015912, 10015913, 10015914, 10015915, 10015916, 10015917, 10015918, 10015919, 10015920, 10015921, 10015922, 10015923, 10015924, 10015925, 10015934, 10015935, 10015936, 10015937, 10015938, 10015939, 10016018, 10016019, 10016020, 10016021, 10016022, 10016023, 10016024, 10016025, 10016026, 10016027, 10016028, 10016029, 10016030, 10016031, 10016032, 10016033, 10016034, 10016035, 10016036, 10016037, 10016038, 10016039, 10016040, 10016041, 10016050, 10016051, 10016052, 10016053, 10016054, 10016055, 10016056, 10016134, 10016135, 10016136, 10016137, 10016138, 10016139, 10016140, 10016141, 10016142, 10016143, 10016144, 10016145, 10016146, 10016147, 10016148, 10016149, 10016150, 10016151, 10016152, 10016153, 10016154, 10016155, 10016156, 10016157, 10016158, 10016166, 10016167, 10016168, 10016169, 10016170, 10016171, 10016172, 10016173, 10016255, 10016256, 10016257, 10016258, 10016259, 10016260, 10016261, 10016262, 10016263, 10016264, 10016265, 10016266, 10016267, 10016268, 10016269, 10016270, 10016271, 10016272, 10016273, 10016274, 10016275, 10016276, 10016277, 10016278, 10016279, 10016286, 10016287, 10016288, 10016289, 10016290, 10016291, 10016292, 10016293, 10016294, 10016380, 10016381, 10016382, 10016383, 10016384, 10016385, 10016386, 10016387, 10016388, 10016389, 10016390, 10016391, 10016392, 10016393, 10016394, 10016395, 10016396, 10016397, 10016398, 10016399, 10016400, 10016401, 10016402, 10016403, 10016404, 10016410, 10016411, 10016412, 10016413, 10016414, 10016415, 10016416, 10016417, 10016418, 10016419, 10016420, 10016508, 10016509, 10016510, 10016511, 10016512, 10016513, 10016514, 10016515, 10016516, 10016517, 10016518, 10016519, 10016520, 10016521, 10016522, 10016523, 10016524, 10016525, 10016526, 10016527, 10016528, 10016529, 10016530, 10016531, 10016532, 10016533, 10016534, 10016538, 10016539, 10016540, 10016541, 10016542, 10016543, 10016544, 10016545, 10016546, 10016547, 10016548, 10016549, 10016640, 10016641, 10016642, 10016643, 10016644, 10016645, 10016646, 10016647, 10016648, 10016649, 10016650, 10016651, 10016652, 10016653, 10016654, 10016655, 10016656, 10016657, 10016658, 10016659, 10016660, 10016661, 10016662, 10016663, 10016664, 10016665, 10016666, 10016668, 10016669, 10016670, 10016671, 10016672, 10016673, 10016674, 10016675, 10016676, 10016677, 10016678, 10016679, 10016680, 10016681, 10016771, 10016772, 10016773, 10016774, 10016775, 10016776, 10016777, 10016778, 10016779, 10016780, 10016781, 10016782, 10016783, 10016784, 10016785, 10016786, 10016787, 10016788, 10016789, 10016790, 10016791, 10016792, 10016793, 10016794, 10016795, 10016796, 10016797, 10016798, 10016799, 10016800, 10016801, 10016802, 10016803, 10016804, 10016805, 10016806, 10016807, 10016808, 10016809, 10016810, 10016811, 10016812, 10016813, 10016906, 10016907, 10016908, 10016909, 10016910, 10016911, 10016912, 10016913, 10016914, 10016915, 10016916, 10016917, 10016918, 10016919, 10016920, 10016921, 10016922, 10016923, 10016924, 10016925, 10016926, 10016927, 10016928, 10016929, 10016930, 10016931, 10016932, 10016933, 10016934, 10016935, 10016936, 10016937, 10016938, 10016939, 10016940, 10016941, 10016942, 10016943, 10016944, 10016945, 10016946, 10016947, 10016948, 10016949, 10017042, 10017043, 10017044, 10017045, 10017046, 10017047, 10017048, 10017049, 10017050, 10017051, 10017052, 10017053, 10017054, 10017055, 10017056, 10017057, 10017058, 10017059, 10017060, 10017061, 10017062, 10017063, 10017064, 10017065, 10017066, 10017067, 10017068, 10017069, 10017070, 10017071, 10017072, 10017073, 10017074, 10017075, 10017076, 10017077, 10017078, 10017079, 10017080, 10017081, 10017082, 10017083, 10017084, 10017085, 10017086, 10017179, 10017180, 10017181, 10017182, 10017183, 10017184, 10017185, 10017186, 10017187, 10017188, 10017189, 10017190, 10017191, 10017192, 10017193, 10017194, 10017195, 10017196, 10017197, 10017198, 10017199, 10017200, 10017201, 10017202, 10017203, 10017204, 10017205, 10017206, 10017207, 10017208, 10017209, 10017210, 10017211, 10017212, 10017213, 10017214, 10017215, 10017216, 10017217, 10017218, 10017219, 10017220, 10017221, 10017222, 10017223, 10017224, 10017225, 10017317, 10017318, 10017319, 10017320, 10017321, 10017322, 10017323, 10017324, 10017325, 10017326, 10017327, 10017328, 10017329, 10017330, 10017331, 10017332, 10017333, 10017334, 10017335, 10017336, 10017337, 10017338, 10017339, 10017340, 10017341, 10017342, 10017343, 10017344, 10017345, 10017346, 10017347, 10017348, 10017349, 10017350, 10017351, 10017352, 10017353, 10017354, 10017355, 10017356, 10017357, 10017358, 10017359, 10017360, 10017361, 10017362, 10017363, 10017364, 10017365, 10017453, 10017454, 10017455, 10017456, 10017457, 10017458, 10017459, 10017460, 10017461, 10017462, 10017463, 10017464, 10017465, 10017466, 10017467, 10017468, 10017469, 10017470, 10017471, 10017472, 10017473, 10017474, 10017475, 10017476, 10017477, 10017478, 10017479, 10017480, 10017481, 10017482, 10017483, 10017484, 10017485, 10017486, 10017487, 10017488, 10017489, 10017490, 10017491, 10017492, 10017493, 10017494, 10017495, 10017496, 10017497, 10017498, 10017499, 10017500, 10017501, 10017502, 10017597, 10017598, 10017599, 10017600, 10017601, 10017602, 10017603, 10017604, 10017605, 10017606, 10017607, 10017608, 10017609, 10017610, 10017611, 10017612, 10017613, 10017614, 10017615, 10017616, 10017617, 10017618, 10017619, 10017620, 10017621, 10017622, 10017623, 10017624, 10017625, 10017626, 10017627, 10017628, 10017629, 10017630, 10017631, 10017632, 10017633, 10017634, 10017635, 10017636, 10017637, 10017638, 10017639, 10017640, 10017641, 10017642, 10017643, 10017644, 10017645, 10017646, 10017742, 10017743, 10017744, 10017745, 10017746, 10017747, 10017748, 10017749, 10017750, 10017751, 10017752, 10017753, 10017754, 10017755, 10017756, 10017757, 10017758, 10017759, 10017760, 10017761, 10017762, 10017763, 10017764, 10017765, 10017766, 10017767, 10017768, 10017769, 10017770, 10017771, 10017772, 10017773, 10017774, 10017775, 10017776, 10017777, 10017778, 10017779, 10017780, 10017781, 10017782, 10017783, 10017784, 10017785, 10017786, 10017787, 10017788, 10017789, 10017790, 10017791, 10017792, 10017885, 10017886, 10017887, 10017888, 10017889, 10017890, 10017891, 10017892, 10017893, 10017894, 10017895, 10017896, 10017897, 10017898, 10017899, 10017900, 10017901, 10017902, 10017903, 10017904, 10017905, 10017906, 10017907, 10017908, 10017909, 10017910, 10017911, 10017912, 10017913, 10017914, 10017915, 10017916, 10017917, 10017918, 10017919, 10017920, 10017921, 10017922, 10017923, 10017924, 10017925, 10017926, 10017927, 10017928, 10017929, 10017930, 10017931, 10017932, 10017933, 10017934, 10017935, 10017936, 10018029, 10018030, 10018031, 10018032, 10018033, 10018034, 10018035, 10018036, 10018037, 10018038, 10018039, 10018040, 10018041, 10018042, 10018043, 10018044, 10018045, 10018046, 10018047, 10018048, 10018049, 10018050, 10018051, 10018052, 10018053, 10018054, 10018055, 10018056, 10018057, 10018058, 10018059, 10018060, 10018061, 10018062, 10018063, 10018064, 10018065, 10018066, 10018067, 10018068, 10018069, 10018070, 10018071, 10018072, 10018073, 10018074, 10018075, 10018076, 10018077, 10018078, 10018079, 10018080, 10018081, 10018176, 10018177, 10018178, 10018179, 10018180, 10018181, 10018182, 10018183, 10018184, 10018185, 10018186, 10018187, 10018188, 10018189, 10018190, 10018191, 10018192, 10018193, 10018194, 10018195, 10018196, 10018197, 10018198, 10018199, 10018200, 10018201, 10018202, 10018203, 10018204, 10018205, 10018206, 10018207, 10018208, 10018209, 10018210, 10018211, 10018212, 10018213, 10018214, 10018215, 10018216, 10018217, 10018218, 10018219, 10018220, 10018221, 10018222, 10018223, 10018224, 10018225, 10018226, 10018227, 10018325, 10018326, 10018327, 10018328, 10018329, 10018330, 10018331, 10018332, 10018333, 10018334, 10018335, 10018336, 10018337, 10018338, 10018339, 10018340, 10018341, 10018342, 10018343, 10018344, 10018345, 10018346, 10018347, 10018348, 10018349, 10018350, 10018351, 10018352, 10018353, 10018354, 10018355, 10018356, 10018357, 10018358, 10018359, 10018360, 10018361, 10018362, 10018363, 10018364, 10018365, 10018366, 10018367, 10018368, 10018369, 10018370, 10018371, 10018372, 10018373, 10018374, 10018375, 10018376, 10018473, 10018474, 10018475, 10018476, 10018477, 10018478, 10018479, 10018480, 10018481, 10018482, 10018483, 10018484, 10018485, 10018486, 10018487, 10018488, 10018489, 10018490, 10018491, 10018492, 10018493, 10018494, 10018495, 10018496, 10018497, 10018498, 10018499, 10018500, 10018501, 10018502, 10018503, 10018504, 10018505, 10018506, 10018507, 10018508, 10018509, 10018510, 10018511, 10018512, 10018513, 10018514, 10018515, 10018516, 10018517, 10018518, 10018519, 10018520, 10018521, 10018522, 10018617, 10018618, 10018619, 10018620, 10018621, 10018622, 10018623, 10018624, 10018625, 10018626, 10018627, 10018628, 10018629, 10018630, 10018631, 10018632, 10018633, 10018634, 10018635, 10018636, 10018637, 10018638, 10018639, 10018640, 10018641, 10018642];
    // uint32[] wastelandsIDs = [10012182, 10012183, 10012207, 10012208, 10012232, 10012233, 10012234, 10012235, 10012236, 10012237, 10012262, 10012263, 10012264, 10012265, 10012266, 10012267, 10012268, 10012293, 10012294, 10012295, 10012296, 10012297, 10012298, 10012299, 10012300, 10012301, 10012328, 10012329, 10012330, 10012331, 10012332, 10012333, 10012334, 10012335, 10012336, 10012337, 10012338, 10012339, 10012368, 10012369, 10012370, 10012371, 10012372, 10012373, 10012374, 10012375, 10012376, 10012377, 10012378, 10012379, 10012380, 10012410, 10012411, 10012412, 10012413, 10012414, 10012415, 10012416, 10012417, 10012418, 10012419, 10012420, 10012421, 10012422, 10012423, 10012424, 10012425, 10012468, 10012469, 10012470, 10012471, 10012472, 10012473, 10012474, 10012475, 10012476, 10012477, 10012478, 10012479, 10012480, 10012481, 10012482, 10012483, 10012484, 10012533, 10012534, 10012535, 10012536, 10012537, 10012538, 10012539, 10012540, 10012541, 10012542, 10012543, 10012544, 10012545, 10012546, 10012547, 10012548, 10012549, 10012601, 10012602, 10012603, 10012604, 10012605, 10012606, 10012607, 10012608, 10012609, 10012610, 10012611, 10012612, 10012613, 10012614, 10012615, 10012616, 10012617, 10012618, 10012619, 10012620, 10012621, 10012622, 10012682, 10012683, 10012684, 10012685, 10012686, 10012687, 10012688, 10012689, 10012690, 10012691, 10012692, 10012693, 10012694, 10012695, 10012696, 10012697, 10012698, 10012699, 10012700, 10012701, 10012702, 10012703, 10012770, 10012771, 10012772, 10012773, 10012774, 10012775, 10012776, 10012777, 10012778, 10012779, 10012780, 10012781, 10012782, 10012783, 10012784, 10012785, 10012786, 10012787, 10012788, 10012789, 10012790, 10012791, 10012792, 10012862, 10012863, 10012864, 10012865, 10012866, 10012867, 10012868, 10012869, 10012870, 10012871, 10012872, 10012873, 10012874, 10012875, 10012876, 10012877, 10012878, 10012879, 10012880, 10012881, 10012882, 10012953, 10012954, 10012955, 10012956, 10012957, 10012958, 10012959, 10012960, 10012961, 10012962, 10012963, 10012964, 10012965, 10012966, 10012967, 10012968, 10012969, 10012970, 10012971, 10012972, 10012973, 10013047, 10013048, 10013049, 10013050, 10013051, 10013052, 10013053, 10013054, 10013055, 10013056, 10013057, 10013058, 10013059, 10013060, 10013061, 10013062, 10013063, 10013064, 10013065, 10013066, 10013141, 10013142, 10013143, 10013144, 10013145, 10013146, 10013147, 10013148, 10013149, 10013150, 10013151, 10013152, 10013153, 10013154, 10013155, 10013156, 10013157, 10013158, 10013159, 10013160, 10013161, 10013238, 10013239, 10013240, 10013241, 10013242, 10013243, 10013244, 10013245, 10013246, 10013247, 10013248, 10013249, 10013250, 10013251, 10013252, 10013253, 10013254, 10013255, 10013256, 10013257, 10013258, 10013336, 10013337, 10013338, 10013339, 10013340, 10013341, 10013342, 10013343, 10013344, 10013345, 10013346, 10013347, 10013348, 10013349, 10013350, 10013351, 10013352, 10013353, 10013354, 10013355, 10013356, 10013434, 10013435, 10013436, 10013437, 10013438, 10013439, 10013440, 10013441, 10013442, 10013443, 10013444, 10013445, 10013446, 10013447, 10013448, 10013449, 10013450, 10013451, 10013452, 10013453, 10013454, 10013455, 10013456, 10013457, 10013535, 10013536, 10013537, 10013538, 10013539, 10013540, 10013541, 10013542, 10013543, 10013544, 10013545, 10013546, 10013547, 10013548, 10013549, 10013550, 10013551, 10013552, 10013553, 10013554, 10013555, 10013556, 10013557, 10013558, 10013636, 10013637, 10013638, 10013639, 10013640, 10013641, 10013642, 10013643, 10013644, 10013645, 10013646, 10013647, 10013648, 10013649, 10013650, 10013651, 10013652, 10013653, 10013654, 10013655, 10013656, 10013657, 10013658, 10013659, 10013660, 10013661, 10013662, 10013663, 10013738, 10013739, 10013740, 10013741, 10013742, 10013743, 10013744, 10013745, 10013746, 10013747, 10013748, 10013749, 10013750, 10013751, 10013752, 10013753, 10013754, 10013755, 10013756, 10013757, 10013758, 10013759, 10013760, 10013761, 10013762, 10013763, 10013764, 10013765, 10013766, 10013767, 10013840, 10013841, 10013842, 10013843, 10013844, 10013845, 10013846, 10013847, 10013848, 10013849, 10013850, 10013851, 10013852, 10013853, 10013854, 10013855, 10013856, 10013857, 10013858, 10013859, 10013860, 10013861, 10013862, 10013863, 10013864, 10013865, 10013866, 10013867, 10013868, 10013869, 10013870, 10013871, 10013872, 10013873, 10013945, 10013946, 10013947, 10013948, 10013949, 10013950, 10013951, 10013952, 10013953, 10013954, 10013955, 10013956, 10013957, 10013958, 10013959, 10013960, 10013961, 10013962, 10013963, 10013964, 10013965, 10013966, 10013967, 10013968, 10013969, 10013970, 10013971, 10013972, 10013973, 10013974, 10013975, 10013976, 10013977, 10013978, 10013979, 10014052, 10014053, 10014054, 10014055, 10014056, 10014057, 10014058, 10014059, 10014060, 10014061, 10014062, 10014063, 10014064, 10014065, 10014066, 10014067, 10014068, 10014069, 10014070, 10014071, 10014072, 10014073, 10014074, 10014075, 10014076, 10014077, 10014078, 10014079, 10014080, 10014081, 10014082, 10014083, 10014084, 10014085, 10014086, 10014087, 10014160, 10014161, 10014162, 10014163, 10014164, 10014165, 10014166, 10014167, 10014168, 10014169, 10014170, 10014171, 10014172, 10014173, 10014174, 10014175, 10014176, 10014177, 10014178, 10014179, 10014180, 10014181, 10014182, 10014183, 10014184, 10014185, 10014186, 10014187, 10014188, 10014189, 10014190, 10014191, 10014192, 10014193, 10014194, 10014195, 10014196, 10014197, 10014198, 10014199, 10014272, 10014273, 10014274, 10014275, 10014276, 10014277, 10014278, 10014279, 10014280, 10014281, 10014282, 10014283, 10014284, 10014285, 10014286, 10014287, 10014288, 10014289, 10014290, 10014291, 10014292, 10014293, 10014294, 10014295, 10014296, 10014297, 10014298, 10014299, 10014300, 10014301, 10014302, 10014303, 10014304, 10014305, 10014306, 10014307, 10014308, 10014309, 10014310, 10014311, 10014312, 10014386, 10014387, 10014388, 10014389, 10014390, 10014391, 10014392, 10014393, 10014394, 10014395, 10014396, 10014397, 10014398, 10014399, 10014400, 10014401, 10014402, 10014403, 10014404, 10014405, 10014406, 10014407, 10014408, 10014409, 10014410, 10014411, 10014412, 10014413, 10014414, 10014415, 10014416, 10014417, 10014418, 10014419, 10014420, 10014421, 10014422, 10014423, 10014424, 10014425, 10014426, 10014427, 10014428, 10014429, 10014430, 10014504, 10014505, 10014506, 10014507, 10014508, 10014509, 10014510, 10014511, 10014512, 10014513, 10014514, 10014515, 10014516, 10014517, 10014518, 10014519, 10014520, 10014521, 10014522, 10014523, 10014524, 10014525, 10014526, 10014527, 10014528, 10014529, 10014530, 10014531, 10014532, 10014533, 10014534, 10014535, 10014536, 10014537, 10014538, 10014539, 10014540, 10014541, 10014542, 10014543, 10014544, 10014545, 10014546, 10014547, 10014548, 10014549, 10014624, 10014625, 10014626, 10014627, 10014628, 10014629, 10014630, 10014631, 10014632, 10014633, 10014634, 10014635, 10014636, 10014637, 10014638, 10014639, 10014640, 10014641, 10014642, 10014643, 10014644, 10014645, 10014646, 10014647, 10014648, 10014649, 10014650, 10014651, 10014652, 10014653, 10014654, 10014655, 10014656, 10014657, 10014658, 10014659, 10014660, 10014661, 10014662, 10014663, 10014664, 10014665, 10014666, 10014667, 10014668, 10014669, 10014670, 10014745, 10014746, 10014747, 10014748, 10014749, 10014750, 10014751, 10014752, 10014753, 10014754, 10014755, 10014756, 10014757, 10014758, 10014759, 10014760, 10014761, 10014762, 10014763, 10014764, 10014765, 10014766, 10014767, 10014768, 10014769, 10014770, 10014771, 10014772, 10014773, 10014774, 10014775, 10014776, 10014777, 10014778, 10014779, 10014780, 10014781, 10014782, 10014783, 10014784, 10014785, 10014786, 10014787, 10014788, 10014789, 10014790, 10014791, 10014867, 10014868, 10014869, 10014870, 10014871, 10014872, 10014873, 10014874, 10014875, 10014876, 10014877, 10014878, 10014879, 10014880, 10014881, 10014882, 10014883, 10014884, 10014885, 10014886, 10014887, 10014888, 10014889, 10014890, 10014891, 10014892, 10014893, 10014894, 10014895, 10014896, 10014897, 10014898, 10014899, 10014900, 10014901, 10014902, 10014903, 10014904, 10014905, 10014906, 10014907, 10014908, 10014909, 10014910, 10014911, 10014912, 10014913, 10014989, 10014990, 10014991, 10014992, 10014993, 10014994, 10014995, 10014996, 10014997, 10014998, 10014999, 10015000, 10015001, 10015002, 10015003, 10015004, 10015005, 10015006, 10015007, 10015008, 10015009, 10015010, 10015011, 10015012, 10015013, 10015014, 10015015, 10015016, 10015017, 10015018, 10015019, 10015020, 10015021, 10015022, 10015023, 10015024, 10015025, 10015026, 10015027, 10015028, 10015029, 10015030, 10015031, 10015032, 10015033, 10015034, 10015035, 10015110, 10015111, 10015112, 10015113, 10015114, 10015115, 10015116, 10015117, 10015118, 10015119, 10015120, 10015121, 10015122, 10015123, 10015124, 10015125, 10015126, 10015127, 10015128, 10015129, 10015130, 10015131, 10015132, 10015133, 10015134, 10015135, 10015136, 10015137, 10015138, 10015139, 10015140, 10015141, 10015142, 10015143, 10015144, 10015145, 10015146, 10015147, 10015148, 10015149, 10015150, 10015151, 10015152, 10015153, 10015154, 10015155, 10015229, 10015230, 10015231, 10015232, 10015233, 10015234, 10015235, 10015236, 10015237, 10015238, 10015239, 10015240, 10015241, 10015242, 10015243, 10015244, 10015245, 10015246, 10015247, 10015248, 10015249, 10015250, 10015251, 10015252, 10015253, 10015254, 10015255, 10015256, 10015257, 10015258, 10015259, 10015260, 10015261, 10015262, 10015263, 10015264, 10015265, 10015266, 10015267, 10015268, 10015269, 10015270, 10015271, 10015272, 10015273, 10015274, 10015349, 10015350, 10015351, 10015352, 10015353, 10015354, 10015355, 10015356, 10015357, 10015358, 10015359, 10015360, 10015361, 10015362, 10015363, 10015364, 10015365, 10015366, 10015367, 10015368, 10015369, 10015370, 10015371, 10015372, 10015373, 10015374, 10015375, 10015376, 10015377, 10015378, 10015379, 10015380, 10015381, 10015382, 10015383, 10015384, 10015385, 10015386, 10015387, 10015388, 10015389, 10015390, 10015391, 10015392, 10015393, 10015467, 10015468, 10015469, 10015470, 10015471, 10015472, 10015473, 10015474, 10015475, 10015476, 10015477, 10015478, 10015479, 10015480, 10015481, 10015482, 10015483, 10015484, 10015485, 10015486, 10015487, 10015488, 10015489, 10015490, 10015491, 10015492, 10015493, 10015494, 10015495, 10015496, 10015497, 10015498, 10015499, 10015500, 10015501, 10015502, 10015503, 10015504, 10015505, 10015506, 10015507, 10015508, 10015509, 10015510, 10015511, 10015581, 10015582, 10015583, 10015584, 10015585, 10015586, 10015587, 10015588, 10015589, 10015590, 10015591, 10015592, 10015593, 10015594, 10015595, 10015596, 10015597, 10015598, 10015599, 10015600, 10015601, 10015602, 10015603, 10015604, 10015605, 10015606, 10015607, 10015608, 10015609, 10015610, 10015611, 10015612, 10015613, 10015614, 10015615, 10015616, 10015617, 10015618, 10015619, 10015620, 10015621, 10015622, 10015623, 10015624, 10015625, 10015626, 10015695, 10015696, 10015697, 10015698, 10015699, 10015700, 10015701, 10015702, 10015706, 10015707, 10015708, 10015709, 10015710, 10015711, 10015712, 10015713, 10015714, 10015715, 10015716, 10015717, 10015718, 10015719, 10015720, 10015721, 10015722, 10015723, 10015724, 10015725, 10015726, 10015727, 10015728, 10015729, 10015730, 10015731, 10015732, 10015733, 10015734, 10015735, 10015736, 10015737, 10015738, 10015739, 10015740, 10015741, 10015742, 10015811, 10015812, 10015813, 10015814, 10015815, 10015816, 10015817, 10015823, 10015824, 10015825, 10015826, 10015827, 10015828, 10015829, 10015830, 10015831, 10015832, 10015833, 10015834, 10015835, 10015836, 10015837, 10015838, 10015839, 10015840, 10015841, 10015842, 10015843, 10015844, 10015845, 10015846, 10015847, 10015848, 10015849, 10015850, 10015851, 10015852, 10015853, 10015854, 10015855, 10015856, 10015857, 10015858, 10015859, 10015860, 10015926, 10015927, 10015928, 10015929, 10015930, 10015931, 10015932, 10015933, 10015940, 10015941, 10015942, 10015943, 10015944, 10015945, 10015946, 10015947, 10015948, 10015949, 10015950, 10015951, 10015952, 10015953, 10015954, 10015955, 10015956, 10015957, 10015958, 10015959, 10015960, 10015961, 10015962, 10015963, 10015964, 10015965, 10015966, 10015967, 10015968, 10015969, 10015970, 10015971, 10015972, 10015973, 10015974, 10015975, 10015976, 10016042, 10016043, 10016044, 10016045, 10016046, 10016047, 10016048, 10016049, 10016057, 10016058, 10016059, 10016060, 10016061, 10016062, 10016063, 10016064, 10016065, 10016066, 10016067, 10016068, 10016069, 10016070, 10016071, 10016072, 10016073, 10016074, 10016075, 10016076, 10016077, 10016078, 10016079, 10016080, 10016081, 10016082, 10016083, 10016084, 10016085, 10016086, 10016087, 10016088, 10016089, 10016090, 10016091, 10016092, 10016159, 10016160, 10016161, 10016162, 10016163, 10016164, 10016165, 10016174, 10016175, 10016176, 10016177, 10016178, 10016179, 10016180, 10016181, 10016182, 10016183, 10016184, 10016185, 10016186, 10016187, 10016188, 10016189, 10016190, 10016191, 10016192, 10016193, 10016194, 10016195, 10016196, 10016197, 10016198, 10016199, 10016200, 10016201, 10016202, 10016203, 10016204, 10016205, 10016206, 10016207, 10016208, 10016209, 10016210, 10016280, 10016281, 10016282, 10016283, 10016284, 10016285, 10016295, 10016296, 10016297, 10016298, 10016299, 10016300, 10016301, 10016302, 10016303, 10016304, 10016305, 10016306, 10016307, 10016308, 10016309, 10016310, 10016311, 10016312, 10016313, 10016314, 10016315, 10016316, 10016317, 10016318, 10016319, 10016320, 10016321, 10016322, 10016323, 10016324, 10016325, 10016326, 10016327, 10016328, 10016329, 10016330, 10016331, 10016332, 10016405, 10016406, 10016407, 10016408, 10016409, 10016421, 10016422, 10016423, 10016424, 10016425, 10016426, 10016427, 10016428, 10016429, 10016430, 10016431, 10016432, 10016433, 10016434, 10016435, 10016436, 10016437, 10016438, 10016439, 10016440, 10016441, 10016442, 10016443, 10016444, 10016445, 10016446, 10016447, 10016448, 10016449, 10016450, 10016451, 10016452, 10016453, 10016454, 10016455, 10016456, 10016457, 10016535, 10016536, 10016537, 10016550, 10016551, 10016552, 10016553, 10016554, 10016555, 10016556, 10016557, 10016558, 10016559, 10016560, 10016561, 10016562, 10016563, 10016564, 10016565, 10016566, 10016567, 10016568, 10016569, 10016570, 10016571, 10016572, 10016573, 10016574, 10016575, 10016576, 10016577, 10016578, 10016579, 10016580, 10016581, 10016582, 10016583, 10016584, 10016585, 10016586, 10016667, 10016682, 10016683, 10016684, 10016685, 10016686, 10016687, 10016688, 10016689, 10016690, 10016691, 10016692, 10016693, 10016694, 10016695, 10016696, 10016697, 10016698, 10016699, 10016700, 10016701, 10016702, 10016703, 10016704, 10016705, 10016706, 10016707, 10016708, 10016709, 10016710, 10016711, 10016712, 10016713, 10016714, 10016715, 10016716, 10016717, 10016814, 10016815, 10016816, 10016817, 10016818, 10016819, 10016820, 10016821, 10016822, 10016823, 10016824, 10016825, 10016826, 10016827, 10016828, 10016829, 10016830, 10016831, 10016832, 10016833, 10016834, 10016835];
    // uint32[] crystalHighlandsIDs = [10000001, 10000002, 10000003, 10000004, 10000005, 10000006, 10000007, 10000008, 10000009, 10000010, 10000011, 10000012, 10000013, 10000014, 10000015, 10000016, 10000017, 10000018, 10000019, 10000020, 10000021, 10000022, 10000023, 10000024, 10000025, 10000026, 10000027, 10000028, 10000029, 10000030, 10000031, 10000032, 10000033, 10000034, 10000035, 10000036, 10000037, 10000038, 10000039, 10000040, 10000041, 10000042, 10000043, 10000044, 10000045, 10000046, 10000047, 10000048, 10000049, 10000050, 10000051, 10000052, 10000053, 10000054, 10000055, 10000056, 10000057, 10000058, 10000059, 10000060, 10000061, 10000062, 10000063, 10000064, 10000065, 10000066, 10000067, 10000070, 10000071, 10000072, 10000073, 10000074, 10000075, 10000076, 10000077, 10000078, 10000079, 10000080, 10000081, 10000082, 10000083, 10000084, 10000085, 10000086, 10000099, 10000100, 10000101];
    
    using Counters for Counters.Counter;
    Counters.Counter private _grasslandsIDsTracker;
    Counters.Counter private _tundraIDsTracker;
    Counters.Counter private _moltenBarrensIDsTracker;
    Counters.Counter private _wastelandsIDsTracker;
    Counters.Counter private _crystalHighlandsIDsTracker;
    

    // 0: grasslandChest price, 1: tundraChest Price, 2: moltenBarrensChest Price, 3: wastelandChest Price
    uint256 public grasslandsNumber;
    uint256 public tundraNumber;
    uint256 public moltenBarrensNumber;
    uint256 public wastelandsNumber;
    uint256 public crystalHighlandsNumber;
    uint256 public totalLandNumber;

    uint256 public constant grasslands = 0;
    uint256 public constant tundra = 1;
    uint256 public constant moltenBarrens = 2;
    uint256 public constant wastelands = 3;
    uint256 public constant crystalHighlands = 4;

    uint256 public constant grasslandChestOfCHL = 30;       // 30/1000   grasslandChest has 3% CrystalHighlands(CHL) 
    uint256 public constant tundraChestOfCHL = 20;          // 20/1000   tundraChest has 2% CrystalHighlands(CHL) 
    uint256 public constant moltenBarrensChestOfCHL = 15;   // 15/1000   moltenBarrensChest has 1.5% CrystalHighlands(CHL) 
    uint256 public constant wastelandChestOfCHL = 10;       // 10/1000   wastelandChest has 1% CrystalHighlands(CHL) 

    event landChestmint(address indexed user, uint256 indexed land, uint256 landID);

    constructor() public ERC721PresetMinterPauserAutoId("Velhalla Land", "VL", "URI")  
    {

        grasslandsNumber = 15;
        tundraNumber = 15;
        moltenBarrensNumber = 15;
        wastelandsNumber = 15;
        crystalHighlandsNumber = 2;
        totalLandNumber = grasslandsNumber + tundraNumber + moltenBarrensNumber + wastelandsNumber; // total alloc number will not include crystalHighlands
   
    }

    function mint(address to) public override {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");
        revert();   // deprecate original mint

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        
        // _mint(to, _tokenIdTracker.current());
        // _tokenIdTracker.increment();
    }

    // This allows the minter to update the tokenURI after it's been minted.
    // To disable this, delete this function.
    function setTokenURI(uint256 tokenId, string memory tokenURI) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "web3 CLI: must have minter role to update tokenURI");
        setTokenURI(tokenId, tokenURI);
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encode(block.timestamp, blockhash(block.number))))%1000;  // To be modify
    }

    // GrasslandChest Mint
    function grasslandChestMint(address to) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "web3 CLI: must have minter role to update tokenURI");
        require(grasslandsNumber != 0, "No grasslands available");

        if(((random() < grasslandChestOfCHL) && (crystalHighlandsNumber != 0)) ||
                (totalLandNumber == crystalHighlandsNumber)){    // will design other random function for get crystalHighlands
            _mint(to, crystalHighlandsIDs[_crystalHighlandsIDsTracker.current()]);  // will design other random function for get random ID without repeat
            emit landChestmint(to, crystalHighlands, _crystalHighlandsIDsTracker.current());
            _crystalHighlandsIDsTracker.increment();
            crystalHighlandsNumber = crystalHighlandsNumber - 1;
            totalLandNumber = totalLandNumber - 1;
        }else{
            _mint(to, grasslandsIDs[_grasslandsIDsTracker.current()]);
            emit landChestmint(to, grasslands, _grasslandsIDsTracker.current());
            _grasslandsIDsTracker.increment();
            grasslandsNumber = grasslandsNumber - 1;
            totalLandNumber = totalLandNumber - 1;
        }
    }
    // TundraChest Mint
    function tundraChestMint(address to) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "web3 CLI: must have minter role to update tokenURI");
        require(tundraNumber != 0, "No tundra available");

        if(((random() < tundraChestOfCHL) && (crystalHighlandsNumber != 0)) ||
                (totalLandNumber == crystalHighlandsNumber)){    // will design other random function
            _mint(to, crystalHighlandsIDs[_crystalHighlandsIDsTracker.current()]);
            emit landChestmint(to, crystalHighlands, _crystalHighlandsIDsTracker.current());
            _crystalHighlandsIDsTracker.increment();
            crystalHighlandsNumber = crystalHighlandsNumber - 1;
            totalLandNumber = totalLandNumber - 1;
        }else{
            _mint(to, tundraIDs[_tundraIDsTracker.current()]);
            emit landChestmint(to, tundra, _tundraIDsTracker.current());
            _tundraIDsTracker.increment();
            tundraNumber = tundraNumber - 1;
            totalLandNumber = totalLandNumber - 1;
        }
    }
    // MoltenBarrensChest Mint
    function moltenBarrensChestMint(address to) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "web3 CLI: must have minter role to update tokenURI");
        require(moltenBarrensNumber != 0, "No moltenBarrens available");

        if(((random() < moltenBarrensChestOfCHL) && (crystalHighlandsNumber != 0)) ||
                (totalLandNumber == crystalHighlandsNumber)){    // will design other random function
            _mint(to, crystalHighlandsIDs[_crystalHighlandsIDsTracker.current()]);
            emit landChestmint(to, crystalHighlands, _crystalHighlandsIDsTracker.current());
            _crystalHighlandsIDsTracker.increment();
            crystalHighlandsNumber = crystalHighlandsNumber - 1;
            totalLandNumber = totalLandNumber - 1;
        }else{
            _mint(to, moltenBarrensIDs[_moltenBarrensIDsTracker.current()]);
            emit landChestmint(to, moltenBarrens, _moltenBarrensIDsTracker.current());
            _moltenBarrensIDsTracker.increment();
            moltenBarrensNumber = moltenBarrensNumber - 1;
            totalLandNumber = totalLandNumber - 1;
        }
    }
    // WastelandChest Mint
    function wastelandChestMint(address to) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "web3 CLI: must have minter role to update tokenURI");
        require(wastelandsNumber != 0, "No wastelands available");

        if(((random() < wastelandChestOfCHL) && (crystalHighlandsNumber != 0)) ||
                (totalLandNumber == crystalHighlandsNumber)){    // will design other random function
            _mint(to, crystalHighlandsIDs[_crystalHighlandsIDsTracker.current()]);
            emit landChestmint(to, crystalHighlands, _crystalHighlandsIDsTracker.current());
            _crystalHighlandsIDsTracker.increment();
            crystalHighlandsNumber = crystalHighlandsNumber - 1;
            totalLandNumber = totalLandNumber - 1;

        }else{
            _mint(to, wastelandsIDs[_wastelandsIDsTracker.current()]);
            emit landChestmint(to, wastelands, _wastelandsIDsTracker.current());
            _wastelandsIDsTracker.increment();
            wastelandsNumber = wastelandsNumber - 1;
            totalLandNumber = totalLandNumber - 1;
        }
    }
}