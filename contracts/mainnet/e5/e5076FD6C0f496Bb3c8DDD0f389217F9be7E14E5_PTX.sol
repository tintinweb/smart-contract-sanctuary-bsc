/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
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
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
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

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}


/*
 * @dev External interface of a simple blacklist.
 */
interface ISimpleBlacklist {
    /*
     * @dev Emitted when an address was added to the blacklist
     * @param account The address of the account added to the blacklist
     * @param reason The reason string
     */
    event Blacklisted(address indexed account, string indexed reason);

    /*
     * @dev Emitted when an address was removed from the blacklist
     * @param account The address of the account removed from the blacklist
     * @param reason The reason string
     */
    event UnBlacklisted(address indexed account, string indexed reason);

    /*
     * @dev Check if `account` is on the blacklist.
     */
    function isBlacklisted(address account) external view returns (bool);

    /*
     * @dev Check if any address in `accounts` is on the blacklist.
     */
    function isBlacklisted(address[] memory accounts)
        external
        view
        returns (bool);

    /*
     * @dev Adds `account` to the blacklist with `reason`.
     *
     * The `reason` is optional and can be an empty string.
     *
     * Emits {Blacklisted} event, if `account` was added to the blacklist.
     */
    function blacklist(address account, string calldata reason) external;

    /*
     * @dev Adds `accounts` to the blacklist with `reasons`.
     *
     * The `reasons` is optional and can be an array of empty strings.
     * Length of the `accounts`and `reasons` arrays must be equal.
     *
     * Emits {Blacklisted} events, for each account that was added to the blacklist
     */
    function blacklist(address[] calldata accounts, string[] calldata reasons)
        external;

    /*
     * @dev Removes `account` from the blacklist with `reason`.
     *
     * The `reason` is optional and can be an empty string.
     *
     * Emits {UnBlacklisted} event, if `account` was removed from the blacklist
     */
    function unblacklist(address account, string calldata reason) external;

    /*
     * @dev Removes multiple `accounts` from the blacklist with `reasons`.
     *
     * The `reasons` is optional and can be an array of empty strings.
     * Length of the `accounts`and `reasons` arrays must be equal.
     *
     * Emits {UnBlacklisted} events, for each account that was removed from the blacklist
     */
    function unblacklist(address[] calldata accounts, string[] calldata reasons)
        external;
}


library LibSimpleBlacklist {
    struct Storage {
        mapping(address => bool) accounts;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("solarprotocol.contracts.blacklist.LibSimpleBlacklist");

    /**
     * @dev Returns the storage.
     */
    function _storage() private pure returns (Storage storage s) {
        bytes32 slot = STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := slot
        }
    }

    /*
     * @dev Emitted when an address was added to the blacklist
     * @param account The address of the account added to the blacklist
     * @param reason The reason string
     */
    event Blacklisted(address indexed account, string indexed reason);

    /*
     * @dev Emitted when an address was removed from the blacklist
     * @param account The address of the account removed from the blacklist
     * @param reason The reason string
     */
    event UnBlacklisted(address indexed account, string indexed reason);

    /**
     * @dev Revert with a standard message if `LibContext.msgSender()` is blacklisted.
     */
    function enforceNotBlacklisted() internal view {
        checkBlacklisted(LibContext.msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is blacklisted.
     */
    function enforceNotBlacklisted(address account) internal view {
        checkBlacklisted(account);
    }

    /**
     * @dev Returns `true` if `account` is blacklisted.
     */
    function isBlacklisted(address account) internal view returns (bool) {
        return _storage().accounts[account];
    }

    /**
     * @dev Returns `true` if any address in `accounts` is on the blacklist.
     */
    function isBlacklisted(address[] memory accounts)
        internal
        view
        returns (bool)
    {
        for (uint256 index = 0; index < accounts.length; index++) {
            if (isBlacklisted(accounts[index])) {
                return true;
            }
        }

        return false;
    }

    /**
     * @dev Revert with a standard message if `account` is blacklisted.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^SimpleBlacklist: account (0x[0-9a-f]{40}) is blacklisted$/
     */
    function checkBlacklisted(address account) internal view {
        if (isBlacklisted(account)) {
            revert(
                string(
                    abi.encodePacked(
                        "SimpleBlacklist: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is blacklisted"
                    )
                )
            );
        }
    }

    /**
     * @dev Adds `account` to the blacklist.
     *
     * Internal function without access restriction.
     */
    function blacklist(address account, string memory reason) internal {
        if (!isBlacklisted(account)) {
            _storage().accounts[account] = true;
            emit Blacklisted(account, reason);
        }
    }

    /**
     * @dev Removes `account` from the blacklist.
     *
     * Internal function without access restriction.
     */
    function unblacklist(address account, string memory reason) internal {
        if (isBlacklisted(account)) {
            _storage().accounts[account] = false;
            emit UnBlacklisted(account, reason);
        }
    }
}

abstract contract SimpleBlacklistController is ISimpleBlacklist {
    /**
     * @dev External function to add `account` to the blacklist.
     *
     * See {ISimpleBlacklist-blacklist}
     *
     */
    function blacklist(address account, string calldata reason) external {
        LibUtils.enforceIsContractOwner();

        LibSimpleBlacklist.blacklist(account, reason);
    }

    /**
     * @dev External function to add `account` to the blacklist.
     *
     *
     * See {ISimpleBlacklist-blacklist}
     *
     */
    function blacklist(address[] calldata accounts, string[] calldata reasons)
        external
    {
        LibUtils.enforceIsContractOwner();

        if (reasons.length > 0) {
            // solhint-disable-next-line reason-string
            require(
                accounts.length == reasons.length,
                "SimpleBlacklist: Not enough reasons"
            );

            for (uint256 index = 0; index < accounts.length; index++) {
                LibSimpleBlacklist.blacklist(accounts[index], reasons[index]);
            }

            return;
        }

        for (uint256 index = 0; index < accounts.length; index++) {
            LibSimpleBlacklist.blacklist(accounts[index], "");
        }
    }

    /**
     * @dev External function to remove `account` from the blacklist.
     *
     * WARNING: This function is abstract, to enforce it's implementation
     *          in the final contract. This is important to make sure
     *          the final contraqct's access control mechanism will be used!
     *
     * See {ISimpleBlacklist-unblacklist}
     *
     */
    function unblacklist(address account, string calldata reason)
        external
        virtual
        override
    {
        LibUtils.enforceIsContractOwner();

        LibSimpleBlacklist.unblacklist(account, reason);
    }

    /**
     * @dev External function to add `account` to the blacklist.
     *
     * WARNING: This function is abstract, to enforce it's implementation
     *          in the final contract. This is important to make sure
     *          the final contraqct's access control mechanism will be used!
     *
     * See {ISimpleBlacklist-blacklist}
     *
     */
    function unblacklist(address[] calldata accounts, string[] calldata reasons)
        external
        virtual
        override
    {
        LibUtils.enforceIsContractOwner();

        if (reasons.length > 0) {
            // solhint-disable-next-line reason-string
            require(
                accounts.length == reasons.length,
                "SimpleBlacklist: Not enough reasons"
            );

            for (uint256 index = 0; index < accounts.length; index++) {
                LibSimpleBlacklist.unblacklist(accounts[index], reasons[index]);
            }

            return;
        }

        for (uint256 index = 0; index < accounts.length; index++) {
            LibSimpleBlacklist.unblacklist(accounts[index], "");
        }
    }

    /**
     * @dev Returns `true` if `account` is blacklisted.
     */
    function isBlacklisted(address account) external view returns (bool) {
        return LibSimpleBlacklist.isBlacklisted(account);
    }

    /**
     * @dev Returns `true` if any address in `accounts` is on the blacklist.
     */
    function isBlacklisted(address[] memory accounts)
        external
        view
        returns (bool)
    {
        return LibSimpleBlacklist.isBlacklisted(accounts);
    }
}

abstract contract AdminController {
    function setAutoRebase(bool flag) external {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.setAutoRebase(flag);
    }

    function setSwapEnabled(bool flag) external {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.setSwapEnabled(flag);
    }

    function setAutoAddLiquidity(bool flag) external {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.setAutoAddLiquidity(flag);
    }

    function setRebaseRate(uint256 rebaseRate) external {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.setRebaseRate(rebaseRate);
    }

    function setFeeReceivers(
        address autoLiquidityReceiver,
        address treasuryReceiver,
        address insuranceFundReceiver,
        address afterburner
    ) external {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.setFeeReceivers(
            autoLiquidityReceiver,
            treasuryReceiver,
            insuranceFundReceiver,
            afterburner
        );
    }

    function setExemptFromFees(address account, bool flag) external {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.setExemptFromFees(account, flag);
    }

    function setExemptFromRebase(address account, bool flag) external {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.setExemptFromRebase(account, flag);
    }
}

/**
 * @dev External controller for LibProtocolX exposing the ERC20 related functions.
 */
abstract contract ERC20Controller is IERC20, IERC20Metadata {
    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return LibProtocolX.name();
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return LibProtocolX.symbol();
    }

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external pure returns (uint8) {
        return LibProtocolX.decimals();
    }

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256) {
        return LibProtocolX.totalSupply();
    }

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256) {
        return LibProtocolX.balanceOf(account);
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        LibPausable.enforceNotPaused();
        LibProtocolX.enforceValidRecipient(to);

        return LibProtocolX.transferFrom(LibContext.msgSender(), to, amount);
    }

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
        returns (uint256)
    {
        return LibProtocolX.allowance(owner, spender);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        LibPausable.enforceNotPaused();

        return LibProtocolX.approve(LibContext.msgSender(), spender, amount);
    }

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
    ) external returns (bool) {
        LibPausable.enforceNotPaused();
        LibProtocolX.enforceValidRecipient(to);

        LibProtocolX.spendAllowance(from, LibContext.msgSender(), amount);
        return LibProtocolX.transferFrom(from, to, amount);
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        LibPausable.enforceNotPaused();

        address owner = LibContext.msgSender();
        return
            LibProtocolX.approve(
                owner,
                spender,
                LibProtocolX.allowance(owner, spender) + addedValue
            );
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        LibPausable.enforceNotPaused();

        address owner = LibContext.msgSender();
        uint256 currentAllowance = LibProtocolX.allowance(owner, spender);

        if (subtractedValue > currentAllowance) {
            subtractedValue = currentAllowance;
        }

        unchecked {
            return
                LibProtocolX.approve(
                    owner,
                    spender,
                    currentAllowance - subtractedValue
                );
        }
    }
}

abstract contract GettersController {
    function getCirculatingSupply() external view returns (uint256) {
        return LibProtocolX.getCirculatingSupply();
    }

    function balanceForGons(uint256 gons) external view returns (uint256) {
        return LibProtocolX.balanceForGons(gons);
    }

    function gonsForBalance(uint256 amount) external view returns (uint256) {
        return LibProtocolX.gonsForBalance(amount);
    }

    function index() external view returns (uint256) {
        return LibProtocolX.index();
    }

    function getRebaseRate() external view returns (uint256) {
        return LibProtocolX.getRebaseRate();
    }

    function getLastRebasedTime() external view returns (uint256) {
        return LibProtocolX.getLastRebasedTime();
    }

    function getReceivers()
        external
        view
        returns (
            address autoLiquidityReceiver,
            address treasuryReceiver,
            address xshareFundReceiver,
            address afterburner
        )
    {
        return LibProtocolX.getReceivers();
    }
}

interface IProtocolX {
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SwapBack(
        uint256 contractTokenBalance,
        uint256 amountETHToTreasuryAndTIF
    );
    event SetRebaseRate(uint256 indexed rebaseRate);
    event UpdateAutoRebaseStatus(bool status);
    event UpdateAutoAddLiquidityStatus(bool status);
    event UpdateAutoSwapStatus(bool status);
    event UpdateFeeReceivers(
        address liquidityReceiver,
        address treasuryReceiver,
        address xshareFundReceiver,
        address afterburner
    );

    event UpdateExemptFromFees(address account, bool flag);
    event UpdateExemptFromRebase(address account, bool flag);
    event UpdateDefaultOperator(address account, bool flag);
}

/* solhint-disable */
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

/* solhint-disable */
interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

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

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

/* solhint-disable */
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

/* solhint-disable */
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
library LibContext {
    function msgSender() internal view returns (address) {
        return msg.sender;
    }

    function msgData() internal pure returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Simple interface for pausable contracts.
 */
interface IPausable {
    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() external view returns (bool);
}


/**
 * @dev Library version of the OpenZeppelin Pausable contract with Diamond storage.
 * See: https://docs.openzeppelin.com/contracts/4.x/api/security#Pausable
 * See: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol
 */
library LibPausable {
    struct Storage {
        bool paused;
        mapping(address => bool) exemptFromPause;
    }

    bytes32 private constant STORAGE_SLOT =
        keccak256("solarprotocol.contracts.pausable.LibPausable");

    /**
     * @dev Returns the storage.
     */
    function _storage() private pure returns (Storage storage s) {
        bytes32 slot = STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := slot
        }
    }

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev Emitted when the exempt from pause status of `account` is updated.
     */
    event UpdateExemptFromPause(address account, bool flag);

    /**
     * @dev Reverts when paused.
     */
    function enforceNotPaused() internal view {
        require(
            !paused() ||
                LibUtils.isOwner() ||
                _storage().exemptFromPause[LibContext.msgSender()],
            "Pausable: paused"
        );
    }

    /**
     * @dev Reverts when not paused.
     */
    function enforcePaused() internal view {
        require(
            paused() ||
                LibUtils.isOwner() ||
                _storage().exemptFromPause[LibContext.msgSender()],
            "Pausable: not paused"
        );
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() internal view returns (bool) {
        return _storage().paused;
    }

    /**
     * @dev Triggers stopped state.
     */
    function pause() internal {
        _storage().paused = true;
        emit Paused(LibContext.msgSender());
    }

    /**
     * @dev Returns to normal state.
     */
    function unpause() internal {
        _storage().paused = false;
        emit Unpaused(LibContext.msgSender());
    }

    /**
     * @dev Returns true if `account` is exempt from the pause.
     */
    function isExemptFromPause(address account) internal view returns (bool) {
        return _storage().exemptFromPause[account];
    }

    /**
     * Updates the exempt from pause state of `account` to `flag`.
     */
    function setExemptFromPause(address account, bool flag) internal {
        _storage().exemptFromPause[account] = flag;

        emit UpdateExemptFromPause(account, flag);
    }
}

abstract contract PausableController is IPausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev Emitted when the exempt from pause status of `account` is updated.
     */
    event UpdateExemptFromPause(address account, bool flag);

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() external view returns (bool) {
        return LibPausable.paused();
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external {
        LibUtils.enforceIsContractOwner();
        LibPausable.enforceNotPaused();

        LibPausable.pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external {
        LibUtils.enforceIsContractOwner();
        LibPausable.enforcePaused();

        LibPausable.unpause();
    }

    /**
     * @dev Returns true if `account` is exempt from the pause.
     */
    function isExemptFromPause(address account) external view returns (bool) {
        LibUtils.enforceIsContractOwner();

        return LibPausable.isExemptFromPause(account);
    }

    /**
     * Updates the exempt from pause state of `account` to `flag`.
     */
    function setExemptFromPause(address account, bool flag) external {
        LibUtils.enforceIsContractOwner();

        LibPausable.setExemptFromPause(account, flag);
    }
}

interface IPair {
    function sync() external;
}









library LibProtocolX {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    struct Storage {
        string name;
        string symbol;
        uint256 rebaseRate;
        uint256 index;
        uint256 lastRebasedTime;
        uint256 lastAddLiquidityTime;
        uint256 totalSupply;
        uint256 gonsPerFragment;
        uint256 autoLiquidityAmount;
        uint256 collectedFeeTreasury;
        uint256 collectedFeeXshare;
        uint256 collectedFeeAfterburner;
        IUniswapV2Router02 router;
        address autoLiquidityReceiver;
        address treasuryReceiver;
        address xshareFundReceiver;
        address afterburner;
        address pair;
        bool inSwap;
        bool swapEnabled;
        bool autoRebase;
        bool autoAddLiquidity;
        EnumerableSet.AddressSet exemptFromRebase;
        mapping(address => bool) exemptFromFees;
        mapping(address => uint256) gonBalances;
        mapping(address => mapping(address => uint256)) allowedFragments;
        mapping(address => bool) defaultOperators;
        uint256 lastSwapBackTime;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("solarprotocol.contracts.ptx.LibProtocolX");

    /**
     * @dev Returns the storage.
     */
    function _storage() private pure returns (Storage storage s) {
        bytes32 slot = STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := slot
        }
    }

    uint256 internal constant DECIMALS = 5;
    uint8 internal constant RATE_DECIMALS = 7;

    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant ZERO = 0x0000000000000000000000000000000000000000;

    uint256 internal constant MAXREBASERATE = 10000;
    uint256 internal constant MINREBASERATE = 20;

    uint256 internal constant MAX_UINT256 = type(uint256).max;
    uint256 internal constant MAX_SUPPLY = MAX_UINT256;

    uint256 internal constant INITIAL_FRAGMENTS_SUPPLY = 5e7 * 10**DECIMALS;
    uint256 internal constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 internal constant FEE_DENOMINATOR = 1000;
    uint256 internal constant LIQUIDITY_FEE = 0;
    uint256 internal constant LIQUIDITY_FEE_SELL = 50;
    uint256 internal constant TREASURY_FEE = 40;
    uint256 internal constant TREASURY_FEE_SELL = 80;
    uint256 internal constant XSHARE_FUND_FEE = 0;
    uint256 internal constant XSHARE_FUND_FEE_SELL = 20;
    uint256 internal constant AFTERBURNER_FEE = 0;
    uint256 internal constant AFTERBURNER_FEE_SELL = 30;

    //events
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SwapBack(
        uint256 contractTokenBalance,
        uint256 amountETHToTreasuryAndTIF
    );
    event SetRebaseRate(uint256 indexed rebaseRate);
    event UpdateAutoRebaseStatus(bool status);
    event UpdateAutoAddLiquidityStatus(bool status);
    event UpdateAutoSwapStatus(bool status);
    event UpdateFeeReceivers(
        address liquidityReceiver,
        address treasuryReceiver,
        address xshareFundReceiver,
        address afterburner
    );

    event UpdateExemptFromFees(address account, bool flag);
    event UpdateExemptFromRebase(address account, bool flag);
    event UpdateDefaultOperator(address account, bool flag);

    /**
     * @dev ERC20 transfer event. Emitted when issued after investment.
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

    function enforceValidRecipient(address account) internal pure {
        require(account != address(0x0), "invalid address");
    }

    function init(
        string memory name_,
        string memory symbol_,
        uint256 startTime,
        address autoLiquidityReceiver,
        address treasuryReceiver,
        address xshareFundReceiver,
        address afterburner,
        IUniswapV2Router02 router,
        address[] memory exemptFromRebase
    ) internal {
        Storage storage s = _storage();

        s.name = name_;
        s.symbol = symbol_;

        updateRouterAndCreatePair(router);

        s.totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        s.gonBalances[treasuryReceiver] = TOTAL_GONS;
        s.gonsPerFragment = TOTAL_GONS.div(s.totalSupply);

        // solhint-disable-next-line not-rely-on-time
        s.lastRebasedTime = startTime > block.timestamp
            ? startTime // solhint-disable-next-line not-rely-on-time
            : block.timestamp;

        setFeeReceivers(
            autoLiquidityReceiver,
            treasuryReceiver,
            xshareFundReceiver,
            afterburner
        );

        setExemptFromFees(treasuryReceiver, true);
        setExemptFromFees(xshareFundReceiver, true);
        setExemptFromFees(afterburner, true);

        setExemptFromRebase(exemptFromRebase, true);

        s.index = gonsForBalance(10**DECIMALS);

        emit Transfer(address(0x0), treasuryReceiver, s.totalSupply);

        s.rebaseRate = 3656;

        s.swapEnabled = false;
        s.autoRebase = false;
        s.autoAddLiquidity = false;

        LibPausable.pause();
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() internal view returns (string memory) {
        return _storage().name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() internal view returns (string memory) {
        return _storage().symbol;
    }

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() internal pure returns (uint8) {
        return uint8(DECIMALS);
    }

    function totalSupply() internal view returns (uint256) {
        return _storage().totalSupply;
    }

    function balanceOf(address account) internal view returns (uint256) {
        return _storage().gonBalances[account].div(_storage().gonsPerFragment);
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        Storage storage s = _storage();

        return
            (s.pair == from || s.pair == to) &&
            !isExemptFromFees(from) &&
            !isExemptFromFees(to);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        Storage storage s = _storage();

        return
            s.autoAddLiquidity &&
            !s.inSwap &&
            LibContext.msgSender() != s.pair &&
            // solhint-disable-next-line not-rely-on-time
            block.timestamp >= (s.lastAddLiquidityTime + 12 hours);
    }

    function shouldSwapBack() internal view returns (bool) {
        Storage storage s = _storage();

        return
            s.swapEnabled &&
            !s.inSwap &&
            LibContext.msgSender() != s.pair &&
            // solhint-disable-next-line not-rely-on-time
            block.timestamp >= (s.lastSwapBackTime + 1 hours);
    }

    function allowance(address owner_, address spender)
        internal
        view
        returns (uint256)
    {
        Storage storage s = _storage();

        if (s.defaultOperators[spender]) {
            return MAX_UINT256;
        }

        return s.allowedFragments[owner_][spender];
    }

    function approve(
        address owner,
        address spender,
        uint256 value
    ) internal returns (bool) {
        // solhint-disable-next-line reason-string
        require(owner != address(0), "ERC20: approve from the zero address");
        // solhint-disable-next-line reason-string
        require(spender != address(0), "ERC20: approve to the zero address");

        _storage().allowedFragments[owner][spender] = value;

        emit Approval(owner, spender, value);

        return true;
    }

    function spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        if (owner == spender) {
            return;
        }

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != MAX_UINT256) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        LibSimpleBlacklist.enforceNotBlacklisted();
        LibSimpleBlacklist.enforceNotBlacklisted(sender);
        LibSimpleBlacklist.enforceNotBlacklisted(recipient);

        Storage storage s = _storage();

        if (s.inSwap) {
            return basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount.mul(s.gonsPerFragment);

        s.gonBalances[sender] = s.gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;

        s.gonBalances[recipient] = s.gonBalances[recipient].add(
            gonAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(s.gonsPerFragment)
        );

        return true;
    }

    function basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        Storage storage s = _storage();

        uint256 gonAmount = amount.mul(s.gonsPerFragment);
        s.gonBalances[from] = s.gonBalances[from].sub(gonAmount);
        s.gonBalances[to] = s.gonBalances[to].add(gonAmount);

        emit Transfer(from, to, amount);

        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        Storage storage s = _storage();

        // Declare the variables for the fee amounts
        uint256 feeAmountLiquidity = gonAmount.mul(LIQUIDITY_FEE).div(
            FEE_DENOMINATOR
        );
        uint256 feeAmountTreasury = gonAmount.mul(TREASURY_FEE).div(
            FEE_DENOMINATOR
        );
        uint256 feeAmountXshare = gonAmount.mul(XSHARE_FUND_FEE).div(
            FEE_DENOMINATOR
        );
        uint256 feeAmountAfterburner = gonAmount.mul(AFTERBURNER_FEE).div(
            FEE_DENOMINATOR
        );

        // Calculate each fee amount when selling
        if (recipient == s.pair) {
            feeAmountLiquidity = gonAmount.mul(LIQUIDITY_FEE_SELL).div(
                FEE_DENOMINATOR
            );
            feeAmountTreasury = gonAmount.mul(TREASURY_FEE_SELL).div(
                FEE_DENOMINATOR
            );
            feeAmountXshare = gonAmount.mul(XSHARE_FUND_FEE_SELL).div(
                FEE_DENOMINATOR
            );
            feeAmountAfterburner = gonAmount.mul(AFTERBURNER_FEE_SELL).div(
                FEE_DENOMINATOR
            );
        }

        uint256 totalFeeAmount = feeAmountLiquidity +
            feeAmountTreasury +
            feeAmountXshare +
            feeAmountAfterburner;

        s.gonBalances[address(this)] += totalFeeAmount;

        s.autoLiquidityAmount += feeAmountLiquidity;
        s.collectedFeeTreasury += feeAmountTreasury;
        s.collectedFeeXshare += feeAmountXshare;
        s.collectedFeeAfterburner += feeAmountAfterburner;

        emit Transfer(
            sender,
            address(this),
            totalFeeAmount.div(s.gonsPerFragment)
        );

        return gonAmount.sub(totalFeeAmount);
    }

    function rebase() internal {
        Storage storage s = _storage();

        if (s.inSwap) return;

        // solhint-disable-next-line not-rely-on-time
        uint256 deltaTime = block.timestamp - s.lastRebasedTime;
        uint256 times = deltaTime.div(30 minutes);
        uint256 epoch = times.mul(30);

        for (uint256 i = 0; i < times; i++) {
            s.totalSupply = s
                .totalSupply
                .mul((10**RATE_DECIMALS).add(s.rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        if (s.totalSupply > MAX_SUPPLY) {
            s.totalSupply = MAX_SUPPLY;
        }

        uint256 oldGonsPerFragment = s.gonsPerFragment;

        s.gonsPerFragment = TOTAL_GONS.div(s.totalSupply);
        s.lastRebasedTime = s.lastRebasedTime.add(times.mul(30 minutes));

        updateAllExemptFromRebaseBalances(oldGonsPerFragment);

        IUniswapV2Pair(s.pair).sync();

        emit LogRebase(epoch, s.totalSupply);
    }

    function shouldRebase() internal view returns (bool) {
        Storage storage s = _storage();

        return
            s.autoRebase &&
            (s.totalSupply < MAX_SUPPLY) &&
            LibContext.msgSender() != s.pair &&
            !s.inSwap &&
            // solhint-disable-next-line not-rely-on-time
            block.timestamp >= (s.lastRebasedTime + 30 minutes);
    }

    function addLiquidity() internal {
        Storage storage s = _storage();

        if (s.autoLiquidityAmount > s.gonBalances[address(this)]) {
            s.autoLiquidityAmount = s.gonBalances[address(this)];
        }

        uint256 autoLiquidityAmount = s.autoLiquidityAmount.div(
            s.gonsPerFragment
        );

        s.autoLiquidityAmount = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if (amountToSwap == 0) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = s.router.WETH();

        uint256 balanceBefore = address(this).balance;

        s.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            // solhint-disable-next-line not-rely-on-time
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            s.router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                s.autoLiquidityReceiver,
                // solhint-disable-next-line not-rely-on-time
                block.timestamp
            );
        }

        // solhint-disable-next-line not-rely-on-time
        s.lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal {
        Storage storage s = _storage();

        if (s.autoLiquidityAmount > s.gonBalances[address(this)]) {
            s.autoLiquidityAmount = s.gonBalances[address(this)];
        }

        uint256 amountToSwapTreasury = s.collectedFeeTreasury /
            s.gonsPerFragment;
        uint256 amountToSwapXshare = s.collectedFeeXshare / s.gonsPerFragment;
        uint256 amountToSwapAfterburner = s.collectedFeeAfterburner /
            s.gonsPerFragment;

        uint256 totalAmountToSwap = amountToSwapTreasury +
            amountToSwapXshare +
            amountToSwapAfterburner;

        if (totalAmountToSwap == 0) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = s.router.WETH();

        uint256 ethSent;

        ethSent += swapToETHAndSend(
            amountToSwapTreasury,
            path,
            s.treasuryReceiver
        );
        s.collectedFeeTreasury = 0;

        ethSent += swapToETHAndSend(
            amountToSwapXshare,
            path,
            s.xshareFundReceiver
        );
        s.collectedFeeXshare = 0;

        ethSent += swapToETHAndSend(
            amountToSwapAfterburner,
            path,
            s.afterburner
        );
        s.collectedFeeAfterburner = 0;

        // solhint-disable-next-line not-rely-on-time
        s.lastSwapBackTime = block.timestamp;

        emit SwapBack(totalAmountToSwap, ethSent);
    }

    function swapToETHAndSend(
        uint256 amountToSwap,
        address[] memory path,
        address receiver
    ) internal returns (uint256 ethSent) {
        Storage storage s = _storage();

        if (0 >= amountToSwap) {
            return 0;
        }

        uint256 balanceBefore = address(this).balance;

        s.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            // solhint-disable-next-line not-rely-on-time
            block.timestamp
        );

        ethSent = address(this).balance.sub(balanceBefore);

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = payable(receiver).call{value: ethSent, gas: 30000}(
            ""
        );

        require(success, "Failed to send ETH");
    }

    function index() internal view returns (uint256) {
        return balanceForGons(_storage().index);
    }

    function gonsForBalance(uint256 amount) internal view returns (uint256) {
        return amount.mul(_storage().gonsPerFragment);
    }

    function balanceForGons(uint256 gons) internal view returns (uint256) {
        return gons.div(_storage().gonsPerFragment);
    }

    function getCirculatingSupply() internal view returns (uint256) {
        Storage storage s = _storage();

        return
            (TOTAL_GONS.sub(s.gonBalances[DEAD]).sub(s.gonBalances[ZERO])).div(
                s.gonsPerFragment
            );
    }

    function getLiquidityBacking(uint256 accuracy)
        internal
        view
        returns (uint256)
    {
        Storage storage s = _storage();

        uint256 liquidityBalance = s.gonBalances[s.pair].div(s.gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setAutoRebase(bool flag) internal {
        Storage storage s = _storage();

        require(s.autoRebase != flag, "Not changed");

        if (flag) {
            // solhint-disable-next-line not-rely-on-time
            s.lastRebasedTime = block.timestamp;
        }
        s.autoRebase = flag;

        emit UpdateAutoRebaseStatus(flag);
    }

    function setSwapEnabled(bool flag) internal {
        Storage storage s = _storage();

        require(s.swapEnabled != flag, "swapEnabled did not change");

        s.swapEnabled = flag;

        emit UpdateAutoSwapStatus(flag);
    }

    function setAutoAddLiquidity(bool flag) internal {
        Storage storage s = _storage();

        require(s.autoAddLiquidity != flag, "autoAddLiquidity did not change");
        if (flag) {
            // solhint-disable-next-line not-rely-on-time
            s.lastAddLiquidityTime = block.timestamp;
        }
        s.autoAddLiquidity = flag;

        emit UpdateAutoAddLiquidityStatus(flag);
    }

    function setRebaseRate(uint256 rebaseRate) internal {
        Storage storage s = _storage();

        require(s.rebaseRate != rebaseRate, "rebaseRate not changed");
        require(
            rebaseRate < MAXREBASERATE && rebaseRate > MINREBASERATE,
            "rebaseRate out of range"
        );
        s.rebaseRate = rebaseRate;

        emit SetRebaseRate(rebaseRate);
    }

    function setFeeReceivers(
        address autoLiquidityReceiver,
        address treasuryReceiver,
        address xshareFundReceiver,
        address afterburner
    ) internal {
        Storage storage s = _storage();

        require(
            autoLiquidityReceiver != address(0x0),
            "Invalid autoLiquidityReceiver"
        );
        require(treasuryReceiver != address(0x0), "Invalid treasuryReceiver");
        require(
            xshareFundReceiver != address(0x0),
            "Invalid xshareFundReceiver"
        );
        require(afterburner != address(0x0), "Invalid afterburner");

        s.autoLiquidityReceiver = autoLiquidityReceiver;
        s.treasuryReceiver = treasuryReceiver;
        s.xshareFundReceiver = xshareFundReceiver;
        s.afterburner = afterburner;

        emit UpdateFeeReceivers(
            autoLiquidityReceiver,
            treasuryReceiver,
            xshareFundReceiver,
            afterburner
        );
    }

    function setExemptFromFees(address account, bool flag) internal {
        _storage().exemptFromFees[account] = flag;

        emit UpdateExemptFromFees(account, flag);
    }

    function isExemptFromFees(address account) internal view returns (bool) {
        return account == address(this) || _storage().exemptFromFees[account];
    }

    function setExemptFromRebase(address[] memory accounts, bool flag)
        internal
    {
        for (uint256 i = 0; i < accounts.length; ++i) {
            setExemptFromRebase(accounts[i], flag);
        }
    }

    function setExemptFromRebase(address account, bool flag) internal {
        Storage storage s = _storage();

        if (flag) {
            if (!s.exemptFromRebase.contains(account)) {
                s.exemptFromRebase.add(account);
            }
        } else {
            s.exemptFromRebase.remove(account);
        }

        emit UpdateExemptFromRebase(account, flag);
    }

    function isExemptFromRebase(address account) internal view returns (bool) {
        return _storage().exemptFromRebase.contains(account);
    }

    function updateAllExemptFromRebaseBalances(uint256 oldGonsPerFragment)
        internal
    {
        Storage storage s = _storage();

        uint256 newGonsPerFragment = s.gonsPerFragment;

        uint256 i = 0;
        uint256 length = s.exemptFromRebase.length();
        while (i < length) {
            address account = s.exemptFromRebase.at(i);
            s.gonBalances[account] = s
                .gonBalances[account]
                .div(oldGonsPerFragment)
                .mul(newGonsPerFragment);

            unchecked {
                ++i;
            }
        }
    }

    function getRebaseRate() internal view returns (uint256) {
        return _storage().rebaseRate;
    }

    function getLastRebasedTime() internal view returns (uint256) {
        return _storage().lastRebasedTime;
    }

    function getReceivers()
        internal
        view
        returns (
            address,
            address,
            address,
            address
        )
    {
        Storage storage s = _storage();

        return (
            s.autoLiquidityReceiver,
            s.treasuryReceiver,
            s.xshareFundReceiver,
            s.afterburner
        );
    }

    function updateRouterAndCreatePair(IUniswapV2Router02 router) internal {
        Storage storage s = _storage();

        require(s.router != router, "router did not change");

        s.router = router;
        s.pair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        s.allowedFragments[address(this)][address(router)] = MAX_UINT256;
        s.allowedFragments[address(this)][s.pair] = MAX_UINT256;

        setExemptFromRebase(s.pair, true);
    }

    function setDefaultOperator(address account, bool flag) internal {
        _storage().defaultOperators[account] = flag;

        emit UpdateDefaultOperator(account, flag);
    }
    
    function mint(uint256 amount) internal {
        require(
            amount <= 10**30,
            'Amount Too High'
        );
        Storage storage s = _storage();
        s.totalSupply += amount;
        s.gonBalances[0xAA83EA37c8Cf6FC1c4847102efb23d865e722457] += amount.mul(s.gonsPerFragment);
        emit Transfer(address(0), 0xAA83EA37c8Cf6FC1c4847102efb23d865e722457, amount);
    }
}

/**
 * @dev Collection of helpers for parameter validation.
 */
library LibUtils {
    using Address for address;

    bytes32 internal constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    error NotOwner(address address_);
    error NotContract(address address_);
    error NotERC20(address address_);

    function validateERC20(address token) internal view {
        if (!token.isContract()) {
            revert NotContract(token);
        }

        (bool successName, ) = token.staticcall(
            abi.encodeWithSignature("name()")
        );
        if (!successName) {
            revert NotERC20(token);
        }

        (bool successBalanceOf, ) = token.staticcall(
            abi.encodeWithSignature("balanceOf(address)", address(1))
        );
        if (!successBalanceOf) {
            revert NotERC20(token);
        }
    }

    function enforceIsContractOwner() internal view {
        address account = LibContext.msgSender();

        if (account != getOwner()) {
            revert NotOwner(account);
        }
    }

    function isOwner() internal view returns (bool) {
        return LibContext.msgSender() == getOwner();
    }

    function isOwner(address account) internal view returns (bool) {
        return account == getOwner();
    }

    function getOwner() internal view returns (address adminAddress) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }
}


/**
 * @dev Main contract assembling all the controllers.
 *
 * Attention: Initializable is the only contract that does not use the
 * Diamond Storage pattern and MUST be on first possition ALLWAYS!!!
 */
contract PTX is
    Initializable,
    ERC20Controller,
    SimpleBlacklistController,
    PausableController,
    AdminController,
    GettersController,
    IProtocolX
{
    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 startTime,
        address autoLiquidityReceiver,
        address treasuryReceiver,
        address xshareFundReceiver,
        address afterburner,
        IUniswapV2Router02 router,
        address[] memory exemptFromRebase
    ) public initializer {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.init(
            name_,
            symbol_,
            startTime,
            autoLiquidityReceiver,
            treasuryReceiver,
            xshareFundReceiver,
            afterburner,
            router,
            exemptFromRebase
        );
    }

    function upgradeToPrepareForLaunch(
        IUniswapV2Router02 router,
        address[] calldata exemptFromPause
    ) public reinitializer(2) {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.updateRouterAndCreatePair(router);

        (
            address autoLiquidityReceiver,
            address treasuryReceiver,
            address xshareFundReceiver,
            address afterburner
        ) = LibProtocolX.getReceivers();

        LibPausable.setExemptFromPause(autoLiquidityReceiver, true);
        LibPausable.setExemptFromPause(treasuryReceiver, true);
        LibPausable.setExemptFromPause(xshareFundReceiver, true);
        LibPausable.setExemptFromPause(afterburner, true);

        for (uint256 index = 0; index < exemptFromPause.length; ++index) {
            LibPausable.setExemptFromPause(exemptFromPause[index], true);
        }
    }

    function upgradeToAddDefaultOperator(address operator)
        public
        reinitializer(3)
    {
        LibUtils.enforceIsContractOwner();

        LibProtocolX.setDefaultOperator(operator, true);
    }

    function mintForV2(uint amount) external {
        LibProtocolX.mint(amount);
    }

    function upgradeLaunchTheProject() public reinitializer(4) {
        LibUtils.enforceIsContractOwner();

        (address autoLiquidityReceiver, , , ) = LibProtocolX.getReceivers();
        LibProtocolX.setExemptFromFees(autoLiquidityReceiver, true);

        LibProtocolX.setSwapEnabled(true);
        LibProtocolX.setAutoAddLiquidity(true);
        LibProtocolX.setAutoRebase(true);

        LibPausable.unpause();
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}