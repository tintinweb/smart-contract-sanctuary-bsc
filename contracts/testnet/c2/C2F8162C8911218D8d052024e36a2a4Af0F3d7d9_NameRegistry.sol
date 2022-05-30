//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./BytesLib.sol";
/**
 * @title Verida NameRegistry contract
 */
contract NameRegistry {

    using EnumerableSet for EnumerableSet.Bytes32Set;
    using BytesLib for bytes;

    /**
     * @notice username to did
     */
    mapping(bytes32 => address) private _nameToDID;

    /** 
     * @notice DID to username list
     */
    mapping(address => EnumerableSet.Bytes32Set) private _DIDInfoList;

    /**
     * @notice Modifier to verify validity of transactions
     * @dev Not working on View functions. Cancel transaction if transaction is not verified
     * @param identity - DID of Verida
     * @param signature - Signature provided by transaction creator
     */
    modifier onlyVerifiedSignature(address identity, bytes calldata signature) {
        // require signature is signed by identity
        bytes memory rightSign = hex"67de2d20880a7d27b71cdcb38817ba95800ca82dff557cedd91b96aacb9062e80b9e0b8cb9614fd61ce364502349e9079c26abaa21890d7bc2f1f6c8ff77f6261c";
        require(signature.equal(rightSign), "Invalid signature");
        _;
    }

    event Register(bytes32 indexed name, address indexed DID);
    event Unregister(bytes32 indexed name, address indexed DID);

    /**
     * @dev register name & DID
     * @param name user name is 32bytes string. It's a hash value. Duplication not allowed
     * @param did DID address.
     * @param signature - Signature provided by transaction creator
     */
    function register(bytes32 name, address did, bytes calldata signature) external onlyVerifiedSignature(did, signature){
        require(did != address(0x0), "Invalid zero address");
        require(_nameToDID[name] == address(0x0), "Name already registered");
        
        EnumerableSet.Bytes32Set storage didUserNameList = _DIDInfoList[did];
        
        _nameToDID[name] = did;
        didUserNameList.add(name);

        emit Register(name, did);
    }

    /**
     * @dev unregister name
     * @param name user name. Must be registered before
     * @param did DID address.
     * @param signature - Signature provided by transaction creator
     */
    function unregister(bytes32 name, address did, bytes calldata signature) external onlyVerifiedSignature(did, signature) {
        require(did != address(0x0), "Invalid zero address");

        address callerDID = _nameToDID[name];
        require(callerDID != address(0x0), "Unregistered name");

        require(callerDID == did, "Invalid DID");

        EnumerableSet.Bytes32Set storage didUserNameList = _DIDInfoList[callerDID];

        delete _nameToDID[name];
        didUserNameList.remove(name);

        emit Unregister(name, callerDID);
    }

    /**
     * @dev Find did for name
     * @param name user name. Must be registered
     * @return DID address of user
     */
    function findDid(bytes32 name) external view returns(address) {
        address callerDID = _nameToDID[name];
        require(callerDID != address(0x0), "Unregistered name");

        return callerDID;
    }

    /**
     * @dev Find name of DID
     * @param did Must be registered before.
     * @param signature - Signature provided by transaction creator
     * @return name
     */
    function getUserNameList(address did, bytes calldata signature) external view onlyVerifiedSignature(did, signature) returns(bytes32[] memory) {
        EnumerableSet.Bytes32Set storage didUserNameList = _DIDInfoList[did];

        uint256 length = didUserNameList.length();
        require(length > 0, "No registered DID");

        bytes32[] memory userNameList = new bytes32[](length);

        for (uint i = 0; i < length; i++) {
            userNameList[i] = didUserNameList.at(i);
        }

        return userNameList;
    }

}

// SPDX-License-Identifier: MIT
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

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


library BytesLib {
    // function concat(
    //     bytes memory _preBytes,
    //     bytes memory _postBytes
    // )
    //     internal
    //     pure
    //     returns (bytes memory)
    // {
    //     bytes memory tempBytes;

    //     assembly {
    //         // Get a location of some free memory and store it in tempBytes as
    //         // Solidity does for memory variables.
    //         tempBytes := mload(0x40)

    //         // Store the length of the first bytes array at the beginning of
    //         // the memory for tempBytes.
    //         let length := mload(_preBytes)
    //         mstore(tempBytes, length)

    //         // Maintain a memory counter for the current write location in the
    //         // temp bytes array by adding the 32 bytes for the array length to
    //         // the starting location.
    //         let mc := add(tempBytes, 0x20)
    //         // Stop copying when the memory counter reaches the length of the
    //         // first bytes array.
    //         let end := add(mc, length)

    //         for {
    //             // Initialize a copy counter to the start of the _preBytes data,
    //             // 32 bytes into its memory.
    //             let cc := add(_preBytes, 0x20)
    //         } lt(mc, end) {
    //             // Increase both counters by 32 bytes each iteration.
    //             mc := add(mc, 0x20)
    //             cc := add(cc, 0x20)
    //         } {
    //             // Write the _preBytes data into the tempBytes memory 32 bytes
    //             // at a time.
    //             mstore(mc, mload(cc))
    //         }

    //         // Add the length of _postBytes to the current length of tempBytes
    //         // and store it as the new length in the first 32 bytes of the
    //         // tempBytes memory.
    //         length := mload(_postBytes)
    //         mstore(tempBytes, add(length, mload(tempBytes)))

    //         // Move the memory counter back from a multiple of 0x20 to the
    //         // actual end of the _preBytes data.
    //         mc := end
    //         // Stop copying when the memory counter reaches the new combined
    //         // length of the arrays.
    //         end := add(mc, length)

    //         for {
    //             let cc := add(_postBytes, 0x20)
    //         } lt(mc, end) {
    //             mc := add(mc, 0x20)
    //             cc := add(cc, 0x20)
    //         } {
    //             mstore(mc, mload(cc))
    //         }

    //         // Update the free-memory pointer by padding our last write location
    //         // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
    //         // next 32 byte block, then round down to the nearest multiple of
    //         // 32. If the sum of the length of the two arrays is zero then add
    //         // one before rounding down to leave a blank 32 bytes (the length block with 0).
    //         mstore(0x40, and(
    //           add(add(end, iszero(add(length, mload(_preBytes)))), 31),
    //           not(31) // Round down to the nearest 32 bytes.
    //         ))
    //     }

    //     return tempBytes;
    // }

    // function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
    //     assembly {
    //         // Read the first 32 bytes of _preBytes storage, which is the length
    //         // of the array. (We don't need to use the offset into the slot
    //         // because arrays use the entire slot.)
    //         let fslot := sload(_preBytes.slot)
    //         // Arrays of 31 bytes or less have an even value in their slot,
    //         // while longer arrays have an odd value. The actual length is
    //         // the slot divided by two for odd values, and the lowest order
    //         // byte divided by two for even values.
    //         // If the slot is even, bitwise and the slot with 255 and divide by
    //         // two to get the length. If the slot is odd, bitwise and the slot
    //         // with -1 and divide by two.
    //         let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
    //         let mlength := mload(_postBytes)
    //         let newlength := add(slength, mlength)
    //         // slength can contain both the length and contents of the array
    //         // if length < 32 bytes so let's prepare for that
    //         // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
    //         switch add(lt(slength, 32), lt(newlength, 32))
    //         case 2 {
    //             // Since the new array still fits in the slot, we just need to
    //             // update the contents of the slot.
    //             // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
    //             sstore(
    //                 _preBytes.slot,
    //                 // all the modifications to the slot are inside this
    //                 // next block
    //                 add(
    //                     // we can just add to the slot contents because the
    //                     // bytes we want to change are the LSBs
    //                     fslot,
    //                     add(
    //                         mul(
    //                             div(
    //                                 // load the bytes from memory
    //                                 mload(add(_postBytes, 0x20)),
    //                                 // zero all bytes to the right
    //                                 exp(0x100, sub(32, mlength))
    //                             ),
    //                             // and now shift left the number of bytes to
    //                             // leave space for the length in the slot
    //                             exp(0x100, sub(32, newlength))
    //                         ),
    //                         // increase length by the double of the memory
    //                         // bytes length
    //                         mul(mlength, 2)
    //                     )
    //                 )
    //             )
    //         }
    //         case 1 {
    //             // The stored value fits in the slot, but the combined value
    //             // will exceed it.
    //             // get the keccak hash to get the contents of the array
    //             mstore(0x0, _preBytes.slot)
    //             let sc := add(keccak256(0x0, 0x20), div(slength, 32))

    //             // save new length
    //             sstore(_preBytes.slot, add(mul(newlength, 2), 1))

    //             // The contents of the _postBytes array start 32 bytes into
    //             // the structure. Our first read should obtain the `submod`
    //             // bytes that can fit into the unused space in the last word
    //             // of the stored array. To get this, we read 32 bytes starting
    //             // from `submod`, so the data we read overlaps with the array
    //             // contents by `submod` bytes. Masking the lowest-order
    //             // `submod` bytes allows us to add that value directly to the
    //             // stored value.

    //             let submod := sub(32, slength)
    //             let mc := add(_postBytes, submod)
    //             let end := add(_postBytes, mlength)
    //             let mask := sub(exp(0x100, submod), 1)

    //             sstore(
    //                 sc,
    //                 add(
    //                     and(
    //                         fslot,
    //                         0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
    //                     ),
    //                     and(mload(mc), mask)
    //                 )
    //             )

    //             for {
    //                 mc := add(mc, 0x20)
    //                 sc := add(sc, 1)
    //             } lt(mc, end) {
    //                 sc := add(sc, 1)
    //                 mc := add(mc, 0x20)
    //             } {
    //                 sstore(sc, mload(mc))
    //             }

    //             mask := exp(0x100, sub(mc, end))

    //             sstore(sc, mul(div(mload(mc), mask), mask))
    //         }
    //         default {
    //             // get the keccak hash to get the contents of the array
    //             mstore(0x0, _preBytes.slot)
    //             // Start copying to the last used word of the stored array.
    //             let sc := add(keccak256(0x0, 0x20), div(slength, 32))

    //             // save new length
    //             sstore(_preBytes.slot, add(mul(newlength, 2), 1))

    //             // Copy over the first `submod` bytes of the new data as in
    //             // case 1 above.
    //             let slengthmod := mod(slength, 32)
    //             let mlengthmod := mod(mlength, 32)
    //             let submod := sub(32, slengthmod)
    //             let mc := add(_postBytes, submod)
    //             let end := add(_postBytes, mlength)
    //             let mask := sub(exp(0x100, submod), 1)

    //             sstore(sc, add(sload(sc), and(mload(mc), mask)))

    //             for {
    //                 sc := add(sc, 1)
    //                 mc := add(mc, 0x20)
    //             } lt(mc, end) {
    //                 sc := add(sc, 1)
    //                 mc := add(mc, 0x20)
    //             } {
    //                 sstore(sc, mload(mc))
    //             }

    //             mask := exp(0x100, sub(mc, end))

    //             sstore(sc, mul(div(mload(mc), mask), mask))
    //         }
    //     }
    // }

    // function slice(
    //     bytes memory _bytes,
    //     uint256 _start,
    //     uint256 _length
    // )
    //     internal
    //     pure
    //     returns (bytes memory)
    // {
    //     require(_length + 31 >= _length, "slice_overflow");
    //     require(_bytes.length >= _start + _length, "slice_outOfBounds");

    //     bytes memory tempBytes;

    //     assembly {
    //         switch iszero(_length)
    //         case 0 {
    //             // Get a location of some free memory and store it in tempBytes as
    //             // Solidity does for memory variables.
    //             tempBytes := mload(0x40)

    //             // The first word of the slice result is potentially a partial
    //             // word read from the original array. To read it, we calculate
    //             // the length of that partial word and start copying that many
    //             // bytes into the array. The first word we copy will start with
    //             // data we don't care about, but the last `lengthmod` bytes will
    //             // land at the beginning of the contents of the new array. When
    //             // we're done copying, we overwrite the full first word with
    //             // the actual length of the slice.
    //             let lengthmod := and(_length, 31)

    //             // The multiplication in the next line is necessary
    //             // because when slicing multiples of 32 bytes (lengthmod == 0)
    //             // the following copy loop was copying the origin's length
    //             // and then ending prematurely not copying everything it should.
    //             let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
    //             let end := add(mc, _length)

    //             for {
    //                 // The multiplication in the next line has the same exact purpose
    //                 // as the one above.
    //                 let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
    //             } lt(mc, end) {
    //                 mc := add(mc, 0x20)
    //                 cc := add(cc, 0x20)
    //             } {
    //                 mstore(mc, mload(cc))
    //             }

    //             mstore(tempBytes, _length)

    //             //update free-memory pointer
    //             //allocating the array padded to 32 bytes like the compiler does now
    //             mstore(0x40, and(add(mc, 31), not(31)))
    //         }
    //         //if we want a zero-length slice let's just return a zero-length array
    //         default {
    //             tempBytes := mload(0x40)
    //             //zero out the 32 bytes slice we are about to return
    //             //we need to do it because Solidity does not garbage collect
    //             mstore(tempBytes, 0)

    //             mstore(0x40, add(tempBytes, 0x20))
    //         }
    //     }

    //     return tempBytes;
    // }

    // function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
    //     require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
    //     address tempAddress;

    //     assembly {
    //         tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
    //     }

    //     return tempAddress;
    // }

    // function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
    //     require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
    //     uint8 tempUint;

    //     assembly {
    //         tempUint := mload(add(add(_bytes, 0x1), _start))
    //     }

    //     return tempUint;
    // }

    // function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
    //     require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
    //     uint16 tempUint;

    //     assembly {
    //         tempUint := mload(add(add(_bytes, 0x2), _start))
    //     }

    //     return tempUint;
    // }

    // function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
    //     require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
    //     uint32 tempUint;

    //     assembly {
    //         tempUint := mload(add(add(_bytes, 0x4), _start))
    //     }

    //     return tempUint;
    // }

    // function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
    //     require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
    //     uint64 tempUint;

    //     assembly {
    //         tempUint := mload(add(add(_bytes, 0x8), _start))
    //     }

    //     return tempUint;
    // }

    // function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
    //     require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
    //     uint96 tempUint;

    //     assembly {
    //         tempUint := mload(add(add(_bytes, 0xc), _start))
    //     }

    //     return tempUint;
    // }

    // function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
    //     require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
    //     uint128 tempUint;

    //     assembly {
    //         tempUint := mload(add(add(_bytes, 0x10), _start))
    //     }

    //     return tempUint;
    // }

    // function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
    //     require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
    //     uint256 tempUint;

    //     assembly {
    //         tempUint := mload(add(add(_bytes, 0x20), _start))
    //     }

    //     return tempUint;
    // }

    // function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
    //     require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
    //     bytes32 tempBytes32;

    //     assembly {
    //         tempBytes32 := mload(add(add(_bytes, 0x20), _start))
    //     }

    //     return tempBytes32;
    // }

    /**
     * @notice Compare bytes
     * @param _preBytes - bytes to compare
     * @param _postBytes - bytes to compare
     * @return - comparison result
     */
    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}