// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "./ISoulBound.sol";

interface IERC721Metadata is ISoulBound {
    /**
     * @dev Returns the SoulBound Token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the SoulBound Token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface IManagement {
    /**
       	@notice Verify `role` of `account`
       	@dev  Caller can be ANY
        @param	_role				    Bytes32 hash role
        @param	_account				Address of `account` that needs to check `role`
    */
    function hasRole(
        bytes32 _role,
        address _account
    ) external view returns (bool);

    /**
       	@notice Get status of `paused`
       	@dev  Caller can be ANY
    */
    function paused() external view returns (bool);

    /**
       	@notice Checking whether `_account` is blacklisted
       	@dev  Caller can be ANY
        @param	_account				Address of `account` that needs to check
    */
    function blacklist(address _account) external view returns (bool);
}

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ISoulBound is IERC165 {
    /**
     * @dev Emitted when `soulboundId` of a soulbound token is minted and linked to `owner`
     */
    event Issued(uint256 indexed soulboundId, address indexed owner);

    /**
     * @dev Emitted when `soulboundId` of a soulbound token is unlinked from `owner`
     */
    event Revoked(uint256 indexed soulboundId, address indexed owner);

    /**
     * @dev Emitted when `soulboundId` of a soulbound token is:
     * unlinked with `from` and linked to `to`
     */
    event Changed(
        uint256 indexed soulboundId,
        address indexed from,
        address indexed to
    );

    /**
     * @dev Emitted when `soulboundId` of a soulbound token is transferred from:
     * address(0) to `to` OR `to` to address(0)
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed soulboundId
    );

    /**
     * @dev Returns the total number of SoulBound tokens has been released
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `soulboundId` token.
     * Requirements:
     * - `soulboundId` must exist.
     */
    function ownerOf(uint256 soulboundId) external view returns (address owner);

    /**
     * @dev Returns the soulboundId of the `owner`.
     * Requirements:
     * - `owner` must own a soulbound token.
     */
    function tokenOf(address owner) external view returns (uint256);

    /**
       	@notice Get total number of accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function numOfLinkedAccounts(
        uint256 soulboundId
    ) external view returns (uint256);

    /**
       	@notice Get accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	fromIndex				Starting index of query range
        @param	toIndex				    Ending index of query range
    */
    function linkedAccounts(
        uint256 soulboundId,
        uint256 fromIndex,
        uint256 toIndex
    ) external view returns (address[] memory accounts);
}

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "./interfaces/IManagement.sol";
import "./SoulBound.sol";

contract ReputationV2 is SoulBound {
    struct Response {
        uint128 scores;
        uint32 timestamp;
    }

    bytes32 private constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 private constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    //  Address of Management contract
    IManagement public management;

    //  public counter
    uint256 public counter;

    //  mapping of latest reputation score per soulboundId
    mapping(uint256 => Response) private _latestAnswers;

    //  TokenURI = baseURI + tokenId
    string public baseURI;

    event Request(address indexed requestor, uint256[] tokenIds);
    event Respond(
        address indexed operator,
        uint256[] tokenIds,
        uint256[] scores
    );

    modifier onlyManager() {
        require(management.hasRole(MANAGER_ROLE, _msgSender()), "Only Manager");
        _;
    }

    modifier onlyOperator() {
        require(
            management.hasRole(OPERATOR_ROLE, _msgSender()),
            "Only Operator"
        );
        _;
    }

    modifier whenNotInBlacklist() {
        require(!management.blacklist(_msgSender()), "Blacklist");
        _;
    }

    modifier whenNotPause() {
        require(!management.paused(), "Paused");
        _;
    }

    constructor(
        IManagement _management,
        string memory _name,
        string memory _symbol,
        string memory baseURI_
    ) SoulBound(_name, _symbol) {
        management = _management;
        baseURI = baseURI_;
    }

    /**
       	@notice Update Address of Management contract
       	@dev  Caller must have Manager role
		@param	_management				Address of new Management contract
    */
    function setManagement(address _management) external onlyManager {
        require(_management != address(0), "Unable to set 0x00 to Management");
        management = IManagement(_management);
    }

    /**
       	@notice Update new string of `baseURI`
       	@dev  Caller must have Manager role
		@param	_newURI				New string of `baseURI`
    */
    function setBaseURI(string calldata _newURI) external onlyManager {
        baseURI = _newURI;
    }

    /**
       	@notice Assign `_soulboundId` to `msg.sender`
       	@dev  Caller can be ANY
		
        Note: One `msg.sender` is assigned ONLY one `_soulboundId`
    */
    function issue() external {
        address _caller = _msgSender();
        _issue(_caller, 0);
    }

    /**
       	@notice Unlink `_soulboundId` to its `_owner`
       	@dev  Caller can be ANY
        @param	_soulboundId				Soulbound id

        Note: After revoke, the update is:
        - `_soulboundId` -> `_owner` is unlinked, but
        - `_owner` -> `_soulboundId` is still linked
    */
    function revoke(uint256 _soulboundId) external {
        _revoke(_soulboundId);
    }

    /**
       	@notice Change `_soulboundId` to new `_owner`
       	@dev  Caller can be ANY
        @param	_soulboundId				Soulbound id
        @param	_from				        Address of a current `_owner`
        @param	_to				            Address of a new `_owner`

        Note: Change address from `_from` to `_to` does not mean ownership transfer
        Instead, it indicates which `_account` is currently set as Primary
        Using `linkedAccounts()` can query all `_account` has been set as Primary
    */
    function change(uint256 _soulboundId, address _from, address _to) external {
        _change(_soulboundId, _from, _to);
    }

    /**
       	@notice Request to update latest reputation scores of `_soulboundIds`
       	@dev  Caller can be ANY
        @param	_soulboundIds				A list of `_soulboundId`
    */
    function request(
        uint256[] calldata _soulboundIds
    ) external whenNotInBlacklist {
        uint256 _len = _soulboundIds.length;
        for (uint256 i; i < _len; i++) _requireMinted(_soulboundIds[i]);

        emit Request(_msgSender(), _soulboundIds);
    }

    /**
       	@notice Update latest reputation scores of `_soulboundIds`
       	@dev  Caller can have Operator role
        @param	_soulboundIds				A list of `_soulboundId`
        @param	_scores				        A list of latest scores that corresponding to each `_soulboundId` respectively
    */
    function fullfil(
        uint256[] calldata _soulboundIds,
        uint256[] calldata _scores
    ) external onlyOperator {
        uint256 _len = _soulboundIds.length;
        require(_scores.length == _len, "Length mismatch");

        uint32 _timestamp = uint32(block.timestamp);
        uint256 _soulboundId;
        for (uint256 i; i < _len; i++) {
            _soulboundId = _soulboundIds[i];
            _requireMinted(_soulboundId);

            _latestAnswers[_soulboundId].scores = uint128(_scores[i]);
            _latestAnswers[_soulboundId].timestamp = _timestamp;
        }

        emit Respond(_msgSender(), _soulboundIds, _scores);
    }

    /**
       	@notice Get latest reputation scores of `_soulboundId`
       	@dev  Caller can be ANY
        @param	_soulboundId				Soulbound Id
    */
    function latestAnswer(
        uint256 _soulboundId
    ) external view returns (Response memory) {
        return _latestAnswers[_soulboundId];
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _issue(
        address _owner,
        uint256 /* _soulboundId */
    ) internal override {
        //  try to get soulbound id that has been assigned to `_caller`
        //  if `_caller` not yet assigned any -> catch occurs -> `prevId = counter`
        //  Otherwise, using previous `soulboundId`
        //  if `soulboundId` is minted, revert likely occurs
        uint256 _prevId;
        try this.tokenOf(_owner) returns (uint256 _found) {
            _prevId = _found;
        } catch {
            _prevId = counter;
        }
        counter++;
        _safeMint(_owner, _prevId);

        emit Issued(_prevId, _owner);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _soulboundId
    ) internal override whenNotPause {
        super._beforeTokenTransfer(_from, _to, _soulboundId);
    }
}

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IERC721Metadata.sol";
import "./interfaces/ISoulBound.sol";

contract SoulBound is Context, ERC165, ISoulBound, IERC721Metadata {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;
    using Strings for uint256;

    //  Total SoulBound tokens have been released
    uint256 private _totalSupply;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to current owner address
    mapping(uint256 => address) private _owners;

    // Archive list of token ID to owner addresses
    mapping(uint256 => EnumerableSet.AddressSet) private _archives;

    // Mapping from owner address to token ID
    mapping(address => uint256) private _tokens;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(ISoulBound).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
       	@notice Get name of SoulBound Token
       	@dev  Caller can be ANY
    */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
       	@notice Get symbol of SoulBound Token
       	@dev  Caller can be ANY
    */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
       	@notice Get total minted SoulBound tokens
       	@dev  Caller can be ANY
    */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
       	@notice Get total minted SoulBound of `owner` 
       	@dev  Caller can be ANY
        @param	owner				Address of querying account
    */
    function balanceOf(
        address owner
    ) public view virtual override returns (uint256) {
        require(
            owner != address(0),
            "SoulBound: address zero is not a valid owner"
        );
        return _balances[owner];
    }

    /**
       	@notice Get owner of `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function ownerOf(
        uint256 soulboundId
    ) public view virtual override returns (address) {
        address owner = _owners[soulboundId];
        require(owner != address(0), "SoulBound: invalid soulbound ID");
        return owner;
    }

    /**
       	@notice Get current `soulboundId` that is assigned to `owner`
       	@dev  Caller can be ANY
        @param	owner				Address of querying account
    */
    function tokenOf(
        address owner
    ) external view virtual override returns (uint256) {
        uint256 token = _tokens[owner];
        require(token != 0, "SoulBound: account not yet assigned a soulbound");
        return token;
    }

    /**
       	@notice Get tokenURI of `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function tokenURI(
        uint256 soulboundId
    ) public view virtual override returns (string memory) {
        _requireMinted(soulboundId);

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, soulboundId.toString()))
                : "";
    }

    /**
       	@notice Get total number of accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function numOfLinkedAccounts(
        uint256 soulboundId
    ) external view virtual override returns (uint256) {
        return _numOfLinkedAccounts(soulboundId);
    }

    /**
       	@notice Get accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	fromIndex				Starting index of query range
        @param	toIndex				    Ending index of query range
    */
    function linkedAccounts(
        uint256 soulboundId,
        uint256 fromIndex,
        uint256 toIndex
    ) external view virtual override returns (address[] memory accounts) {
        uint256 len = toIndex - fromIndex + 1;
        accounts = new address[](len);

        for (uint256 i; i < len; i++)
            accounts[i] = _linkedAccountAt(soulboundId, fromIndex + i);
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function _exists(uint256 soulboundId) internal view virtual returns (bool) {
        return _owners[soulboundId] != address(0);
    }

    function _numOfLinkedAccounts(
        uint256 soulboundId
    ) internal view virtual returns (uint256) {
        return _archives[soulboundId].length();
    }

    function _linkedAccountAt(
        uint256 soulboundId,
        uint256 index
    ) internal view virtual returns (address) {
        uint256 _totalLinkedAccounts = _numOfLinkedAccounts(soulboundId);
        require(
            _totalLinkedAccounts != 0,
            "SoulBound: id not linked to any accounts"
        );
        require(
            index <= _totalLinkedAccounts - 1,
            "SoulBound: index out of bounds"
        );

        return _archives[soulboundId].at(index);
    }

    function _issue(address _owner, uint256 _soulboundId) internal virtual {
        //  try to get soulbound id that has been assigned to `_owner`
        //  if `_owner` not yet assigned any -> catch occurs -> do nothing (`_prevId` = default = 0)
        uint256 _prevId;
        try this.tokenOf(_owner) returns (uint256 _found) {
            _prevId = _found;
        } catch {}
        if (_prevId != 0)
            require(
                _soulboundId == _prevId,
                "SoulBound: unable to assign a new id to existed profile"
            );

        _safeMint(_owner, _soulboundId);

        emit Issued(_soulboundId, _owner);
    }

    function _revoke(uint256 _soulboundId) internal virtual {
        _requireMinted(_soulboundId);
        address _owner = ownerOf(_soulboundId);
        _burn(_soulboundId);

        emit Revoked(_soulboundId, _owner);
    }

    function _change(
        uint256 _soulboundId,
        address _from,
        address _to
    ) internal virtual {
        _requireMinted(_soulboundId);
        require(
            ownerOf(_soulboundId) == _from,
            "SoulBound: source account not owns the soulbound id"
        );

        _burn(_soulboundId);
        _safeMint(_to, _soulboundId);

        emit Changed(_soulboundId, _from, _to);
    }

    /**
     * @dev Safely mints `soulboundId` and transfers it to `to`.
     * Requirements:
     * - `soulboundId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 soulboundId) internal virtual {
        _safeMint(to, soulboundId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 soulboundId,
        bytes memory data
    ) internal virtual {
        _mint(to, soulboundId);
        require(
            _checkOnERC721Received(address(0), to, soulboundId, data),
            "SoulBound: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `soulboundId` and transfers it to `to`.
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     * Requirements:
     * - `soulboundId` must not exist.
     * - `to` cannot be the zero address.
     * - `to` must not own any soulbound tokens or `soulboundId` must be the same as previous one
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 soulboundId) internal virtual {
        require(to != address(0), "SoulBound: mint to the zero address");
        require(!_exists(soulboundId), "SoulBound: token already minted");

        try this.tokenOf(to) returns (uint256 found) {
            require(
                found == soulboundId,
                "SoulBound: address already assigned a soulbound"
            );
        } catch {
            require(
                balanceOf(to) == 0,
                "SoulBound: address already assigned a soulbound"
            );
        }

        _beforeTokenTransfer(address(0), to, soulboundId);

        // update current ownership of `soulboundId`
        // link `soulboundId` to `to`. Unable to unlink even soulbound token is revoked/burned
        // update `archives` list
        _balances[to] += 1;
        _owners[soulboundId] = to;
        _tokens[to] = soulboundId;
        _archives[soulboundId].add(to);
        _totalSupply++;

        emit Transfer(address(0), to, soulboundId);

        _afterTokenTransfer(address(0), to, soulboundId);
    }

    /**
     * @dev Destroys `soulboundId`.
     * Requirements:
     * - `soulboundId` must exist.
     * Emits a {Transfer} event.
     */
    function _burn(uint256 soulboundId) internal virtual {
        address owner = ownerOf(soulboundId);

        _beforeTokenTransfer(owner, address(0), soulboundId);

        // when soulbound is revoked/burned, only decrease balance of `owner`
        // and delete a connection of `soulboundId` and `owner` in the `_owners` mapping
        // `_archives` and `_tokens` mappings remain unchanged
        _balances[owner] -= 1;
        delete _owners[soulboundId];
        _totalSupply--;

        emit Transfer(owner, address(0), soulboundId);

        _afterTokenTransfer(owner, address(0), soulboundId);
    }

    /**
     * @dev Reverts if the `soulboundId` has not been minted yet.
     */
    function _requireMinted(uint256 soulboundId) internal view virtual {
        require(_exists(soulboundId), "SoulBound: invalid soulbound ID");
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 soulboundId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    soulboundId,
                    data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "SoulBound: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    /// @solidity memory-safe-assembly
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
     * Calling conditions:
     * - When `from` and `to` are both non-zero, ``from``'s `soulboundId` will be
     * transferred to `to`.
     * - When `from` is zero, `soulboundId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `soulboundId` will be burned.
     * - `from` and `to` are never both zero.
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 soulboundId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     * Calling conditions:
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 soulboundId
    ) internal virtual {}
}