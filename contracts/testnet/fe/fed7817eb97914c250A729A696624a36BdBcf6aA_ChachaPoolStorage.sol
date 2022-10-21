/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.17;

contract SlotData {

    constructor() {}

    // for map,  key could be 0x00, but value can't be 0x00;
    // if value == 0x00, it mean the key doesn't has any value
    function sysMapSet(bytes32 mappingSlot, bytes32 key, bytes32 value) internal returns (uint256 length){
        length = sysMapLen(mappingSlot);
        bytes32 elementOffset = sysCalcMapOffset(mappingSlot, key);
        bytes32 storedValue = sysLoadSlotData(elementOffset);
        if (value == storedValue) {
            //if value == 0 & storedValue == 0
            //if value == storedValue != 0
            //needn't set same value;
        } else if (value == bytes32(0x00)) {
            //storedValue != 0
            //deleting value
            sysSaveSlotData(elementOffset, value);
            length--;
            sysSaveSlotData(mappingSlot, bytes32(length));
        } else if (storedValue == bytes32(0x00)) {
            //value != 0
            //adding new value
            sysSaveSlotData(elementOffset, value);
            length++;
            sysSaveSlotData(mappingSlot, bytes32(length));
        } else {
            //value != storedValue & value != 0 & storedValue !=0
            //updating
            sysSaveSlotData(elementOffset, value);
        }
        return length;
    }

    function sysMapGet(bytes32 mappingSlot, bytes32 key) internal view returns (bytes32){
        bytes32 elementOffset = sysCalcMapOffset(mappingSlot, key);
        return sysLoadSlotData(elementOffset);
    }

    function sysMapLen(bytes32 mappingSlot) internal view returns (uint256){
        return uint256(sysLoadSlotData(mappingSlot));
    }

    function sysLoadSlotData(bytes32 slot) internal view returns (bytes32){
        //ask a stack position
        bytes32 ret;
        assembly{
            ret := sload(slot)
        }
        return ret;
    }

    function sysSaveSlotData(bytes32 slot, bytes32 data) internal {
        assembly{
            sstore(slot, data)
        }
    }

    function sysCalcMapOffset(bytes32 mappingSlot, bytes32 key) internal pure returns (bytes32){
        return bytes32(keccak256(abi.encodePacked(key, mappingSlot)));
    }

    function sysCalcSlot(bytes memory name) public pure returns (bytes32){
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked(name))))));
    }

    function calcNewSlot(bytes32 slot, string memory name) internal pure returns (bytes32){
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked(slot, name))))));
    }
}




/** 
 *  SourceUnit: g:\project\HeLianGongShi\XSwap\contracts\rewardPool\ChachaPoolStorage.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.17;

////import "./SlotData.sol";

//once you input a value, it will auto generate an index for that
//index starts from 1, 0 means this value doesn't exist
//the value must be unique, and can't be 0x00
//the index must be unique, and can't be 0x00
/*

slot
value --- index
    a --- 1
    b --- 2
    c --- 3
    c --- 4   X   not allowed
    d --- 3   X   not allowed
    e --- 0   X   not allowed

indexSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked(slot))))));
index --- value
    1 --- a
    2 --- b
    3 --- c
    3 --- d   X   not allowed

*/

contract EnhancedUniqueIndexMap is SlotData {

    constructor() {}

    // slot : value => index
    function sysUniqueIndexMapAdd(bytes32 slot, bytes32 value) internal {

        require(value != bytes32(0x00));

        bytes32 indexSlot = calcIndexSlot(slot);

        uint256 index = uint256(sysMapGet(slot, value));
        require(index == 0, "sysUniqueIndexMapAdd, value already exist");

        uint256 last = sysUniqueIndexMapSize(slot);
        last ++;
        sysMapSet(slot, value, bytes32(last));
        sysMapSet(indexSlot, bytes32(last), value);
    }

    function sysUniqueIndexMapDel(bytes32 slot, bytes32 value) internal {

        //require(value != bytes32(0x00), "sysUniqueIndexMapDel, value must not be 0x00");

        bytes32 indexSlot = calcIndexSlot(slot);

        uint256 index = uint256(sysMapGet(slot, value));
        require(index != 0, "sysUniqueIndexMapDel, value doesn't exist");

        uint256 lastIndex = sysUniqueIndexMapSize(slot);
        require(lastIndex > 0, "sysUniqueIndexMapDel, lastIndex must be large than 0, this must not happen");
        if (index != lastIndex) {

            bytes32 lastValue = sysMapGet(indexSlot, bytes32(lastIndex));
            //move the last to the current place
            //this would be faster than move all elements forward after the deleting one, but not stable(the sequence will change)
            sysMapSet(slot, lastValue, bytes32(index));
            sysMapSet(indexSlot, bytes32(index), lastValue);
        }
        sysMapSet(slot, value, bytes32(0x00));
        sysMapSet(indexSlot, bytes32(lastIndex), bytes32(0x00));
    }

    function sysUniqueIndexMapDelArrange(bytes32 slot, bytes32 value) internal {

        require(value != bytes32(0x00), "sysUniqueIndexMapDelArrange, value must not be 0x00");

        bytes32 indexSlot = calcIndexSlot(slot);

        uint256 index = uint256(sysMapGet(slot, value));
        require(index != 0, "sysUniqueIndexMapDelArrange, value doesn't exist");

        uint256 lastIndex = (sysUniqueIndexMapSize(slot));
        require(lastIndex > 0, "sysUniqueIndexMapDelArrange, lastIndex must be large than 0, this must not happen");

        sysMapSet(slot, value, bytes32(0x00));

        while (index < lastIndex) {

            bytes32 nextValue = sysMapGet(indexSlot, bytes32(index + 1));
            sysMapSet(indexSlot, bytes32(index), nextValue);
            sysMapSet(slot, nextValue, bytes32(index));

            index ++;
        }

        sysMapSet(indexSlot, bytes32(lastIndex), bytes32(0x00));
    }

    function sysUniqueIndexMapReplace(bytes32 slot, bytes32 oldValue, bytes32 newValue) internal {
        require(oldValue != bytes32(0x00), "sysUniqueIndexMapReplace, oldValue must not be 0x00");
        require(newValue != bytes32(0x00), "sysUniqueIndexMapReplace, newValue must not be 0x00");

        bytes32 indexSlot = calcIndexSlot(slot);

        uint256 index = uint256(sysMapGet(slot, oldValue));
        require(index != 0, "sysUniqueIndexMapDel, oldValue doesn't exists");
        require(uint256(sysMapGet(slot, newValue)) == 0, "sysUniqueIndexMapDel, newValue already exists");

        sysMapSet(slot, oldValue, bytes32(0x00));
        sysMapSet(slot, newValue, bytes32(index));
        sysMapSet(indexSlot, bytes32(index), newValue);
    }

    //============================view & pure============================

    function sysUniqueIndexMapSize(bytes32 slot) internal view returns (uint256){
        return sysMapLen(slot);
    }

    //returns index, 0 mean not exist
    function sysUniqueIndexMapGetIndex(bytes32 slot, bytes32 value) internal view returns (uint256){
        return uint256(sysMapGet(slot, value));
    }

    function sysUniqueIndexMapGetValue(bytes32 slot, uint256 index) internal view returns (bytes32){
        bytes32 indexSlot = calcIndexSlot(slot);
        return sysMapGet(indexSlot, bytes32(index));
    }

    // index => value
    function calcIndexSlot(bytes32 slot) internal pure returns (bytes32){
        return calcNewSlot(slot, "index");
    }
}




/** 
 *  SourceUnit: g:\project\HeLianGongShi\XSwap\contracts\rewardPool\ChachaPoolStorage.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.17;

////import "./SlotData.sol";

//this is just a normal mapping, but which holds size and you can specify slot
/*
both key and value shouldn't be 0x00
the key must be unique, the value would be whatever

slot
  key --- value
    a --- 1
    b --- 2
    c --- 3
    c --- 4   X   not allowed
    d --- 3
    e --- 0   X   not allowed
    0 --- 9   X   not allowed

*/
contract EnhancedMap is SlotData {

    constructor() {}

    //set value to 0x00 to delete
    function sysEnhancedMapSet(bytes32 slot, bytes32 key, bytes32 value) internal {
        require(key != bytes32(0x00), "sysEnhancedMapSet, notEmptyKey");
        sysMapSet(slot, key, value);
    }

    function sysEnhancedMapAdd(bytes32 slot, bytes32 key, bytes32 value) internal {
        require(key != bytes32(0x00), "sysEnhancedMapAdd, notEmptyKey");
        require(value != bytes32(0x00), "EnhancedMap add, the value shouldn't be empty");
        require(sysMapGet(slot, key) == bytes32(0x00), "EnhancedMap, the key already has value, can't add duplicate key");
        sysMapSet(slot, key, value);
    }

    function sysEnhancedMapDel(bytes32 slot, bytes32 key) internal {
        require(key != bytes32(0x00), "sysEnhancedMapDel, notEmptyKey");
        require(sysMapGet(slot, key) != bytes32(0x00), "sysEnhancedMapDel, the key doesn't has value, can't delete empty key");
        sysMapSet(slot, key, bytes32(0x00));
    }

    function sysEnhancedMapReplace(bytes32 slot, bytes32 key, bytes32 value) public {
        require(key != bytes32(0x00), "sysEnhancedMapReplace, notEmptyKey");
        require(value != bytes32(0x00), "EnhancedMap replace, the value shouldn't be empty");
        require(sysMapGet(slot, key) != bytes32(0x00), "EnhancedMap, the key doesn't has value, can't replace it");
        sysMapSet(slot, key, value);
    }

    function sysEnhancedMapGet(bytes32 slot, bytes32 key) internal view returns (bytes32){
        require(key != bytes32(0x00), "sysEnhancedMapGet, notEmptyKey");
        return sysMapGet(slot, key);
    }

    function sysEnhancedMapSize(bytes32 slot) internal view returns (uint256){
        return sysMapLen(slot);
    }

}




/** 
 *  SourceUnit: g:\project\HeLianGongShi\XSwap\contracts\rewardPool\ChachaPoolStorage.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.17;

contract Base {
    constructor () {

    }

    //0x20 - length
    //0x53c6eaee8696e4c5200d3d231b29cc6a40b3893a5ae1536b0ac08212ffada877
    bytes constant notFoundMark = abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("404-method-not-found")))))));


    //return the payload of returnData, stripe the leading length
    function returnAsm(bool isRevert, bytes memory returnData) pure internal {
        assembly{
            let length := mload(returnData)
            switch isRevert
            case 0x00{
                return (add(returnData, 0x20), length)
            }
            default{
                revert (add(returnData, 0x20), length)
            }
        }
    }

    modifier nonPayable(){
        require(msg.value == 0, "nonPayable");
        _;
    }

}




/** 
 *  SourceUnit: g:\project\HeLianGongShi\XSwap\contracts\rewardPool\ChachaPoolStorage.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.17;

library ChachaPoolType {


    uint256  constant internal _NOT_ENTERED = 1;
    uint256  constant internal _ENTERED = 2;


    uint256 constant internal PRECISION = 1e36;

    struct PersonInfo {
        uint256 chachaStaked;
        uint256 vchachaStaked;
        uint256 vchachaRewardEarned;
        uint256 vchachaCumulativeRewards;
        //==============
        uint256 vchachaVesting;
        uint256 chachaReserved;
        uint256 vchachaVested;
        uint256 vchachaCumulativeVestedAmount;
    }

}




/** 
 *  SourceUnit: g:\project\HeLianGongShi\XSwap\contracts\rewardPool\ChachaPoolStorage.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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
                set._indexes[lastValue] = valueIndex;
                // Replace lastValue's index to valueIndex
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




/** 
 *  SourceUnit: g:\project\HeLianGongShi\XSwap\contracts\rewardPool\ChachaPoolStorage.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.17;

////import "./Base.sol";
////import "./EnhancedMap.sol";
////import "./EnhancedUniqueIndexMap.sol";


contract Proxy is Base, EnhancedMap, EnhancedUniqueIndexMap {
    constructor (address admin) {
        require(admin != address(0));
        sysSaveSlotData(adminSlot, bytes32(uint256(uint160(admin))));
        sysSaveSlotData(userSigZeroSlot, bytes32(uint256(0)));
        sysSaveSlotData(outOfServiceSlot, bytes32(uint256(0)));
        sysSaveSlotData(revertMessageSlot, bytes32(uint256(1)));
        sysSaveSlotData(transparentSlot, bytes32(uint256(0)));

    }

    bytes32 constant adminSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("adminSlot"))))));

    bytes32 constant revertMessageSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("revertMessageSlot"))))));

    bytes32 constant outOfServiceSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("outOfServiceSlot"))))));

    //address <===>  index EnhancedUniqueIndexMap
    //0x2f80e9a12a11b80d2130b8e7dfc3bb1a6c04d0d87cc5c7ea711d9a261a1e0764
    bytes32 constant delegatesSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("delegatesSlot"))))));

    //bytes4 abi ===> address, both not 0x00
    //0xba67a9e2b7b43c3c9db634d1c7bcdd060aa7869f4601d292a20f2eedaf0c2b1c
    bytes32 constant userAbiSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("userAbiSlot"))))));

    bytes32 constant userAbiSearchSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("userAbiSearchSlot"))))));

    //0xe2bb2e16cbb16a10fab839b4a5c3820d63a910f4ea675e7821846c4b2d3041dc
    bytes32 constant userSigZeroSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("userSigZeroSlot"))))));

    bytes32 constant transparentSlot = keccak256(abi.encodePacked(keccak256(abi.encodePacked(keccak256(abi.encodePacked("transparentSlot"))))));


    event DelegateSet(address delegate, bool activated);
    event AbiSet(bytes4 abi, address delegate, bytes32 slot);
    event PrintBytes(bytes data);
    //===================================================================================

    //
    function sysCountDelegate() view public returns (uint256){
        return sysUniqueIndexMapSize(delegatesSlot);
    }

    function sysGetDelegateAddress(uint256 index) view public returns (address){
        return address(uint160(uint256(sysUniqueIndexMapGetValue(delegatesSlot, index))));
    }

    function sysGetDelegateIndex(address addr) view public returns (uint256) {
        return uint256(sysUniqueIndexMapGetIndex(delegatesSlot, bytes32(uint256(uint160(addr)))));
    }

    function sysGetDelegateAddresses() view public returns (address[] memory){
        uint256 count = sysCountDelegate();
        address[] memory delegates = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            delegates[i] = sysGetDelegateAddress(i + 1);
        }
        return delegates;
    }

    //add delegates on current version
    function sysAddDelegates(address[] memory _inputs) external onlyAdmin {
        for (uint256 i = 0; i < _inputs.length; i ++) {
            sysUniqueIndexMapAdd(delegatesSlot, bytes32(uint256(uint160(_inputs[i]))));
            emit DelegateSet(_inputs[i], true);
        }
    }

    //delete delegates
    //be careful, if you delete a delegate, the index will change
    function sysDelDelegates(address[] memory _inputs) external onlyAdmin {
        for (uint256 i = 0; i < _inputs.length; i ++) {

            //travers all abis to delete those abis mapped to the given address
            uint256 j;
            uint256 k;
            /*bytes4[] memory toDeleteSelectors = new bytes4[](count + 1);
            uint256 pivot = 0;*/
            uint256 count = sysCountSelectors();

            /*for (j = 0; j < count; j ++) {
                bytes4 selector;
                address delegate;
                (selector, delegate) = sysGetUserSelectorAndDelegateByIndex(j + 1);
                if (delegate == _inputs[i]) {
                    toDeleteSelectors[pivot] = selector;
                    pivot++;
                }
            }
            pivot = 0;
            while (toDeleteSelectors[pivot] != bytes4(0x00)) {
                sysSetUserSelectorAndDelegate(toDeleteSelectors[pivot], address(0));
                pivot++;
            }*/
            k = 1;
            for (j = 0; j < count; j++) {
                bytes4 selector;
                address delegate;
                (selector, delegate) = sysGetSelectorAndDelegateByIndex(k);
                if (delegate == _inputs[i]) {
                    _sysSetSelectorAndDelegate(selector, address(0));
                }
                else {
                    k++;
                }
            }

            if (sysGetSigZero() == _inputs[i]) {
                _sysSetSigZero(address(0x00));
            }

            sysUniqueIndexMapDelArrange(delegatesSlot, bytes32(uint256(uint160(_inputs[i]))));
            emit DelegateSet(_inputs[i], false);
        }
    }

    //add and delete delegates
    function sysReplaceDelegates(address[] memory _delegatesToDel, address[] memory _delegatesToAdd) external onlyAdmin {
        require(_delegatesToDel.length == _delegatesToAdd.length, "sysReplaceDelegates, length does not match");
        for (uint256 i = 0; i < _delegatesToDel.length; i ++) {
            sysUniqueIndexMapReplace(delegatesSlot, bytes32(uint256(uint160(_delegatesToDel[i]))), bytes32(uint256(uint160(_delegatesToAdd[i]))));
            emit DelegateSet(_delegatesToDel[i], false);
            emit DelegateSet(_delegatesToAdd[i], true);
        }
    }

    //=============================================

    function sysGetSigZero() view public returns (address){
        return address(uint160(uint256(sysLoadSlotData(userSigZeroSlot))));
    }

    function sysSetSigZero(address _input) external onlyAdmin {
        _sysSetSigZero(_input);
    }

    function _sysSetSigZero(address _input) internal {
        sysSaveSlotData(userSigZeroSlot, bytes32(uint256(uint160(_input))));
    }

    function sysGetAdmin() view public returns (address){
        return address(uint160(uint256(sysLoadSlotData(adminSlot))));
    }

    function sysSetAdmin(address _input) external onlyAdmin {
        sysSaveSlotData(adminSlot, bytes32(uint256(uint160(_input))));
    }

    function sysGetRevertMessage() view public returns (uint256){
        return uint256(sysLoadSlotData(revertMessageSlot));
    }

    function sysSetRevertMessage(uint256 _input) external onlyAdmin {
        sysSaveSlotData(revertMessageSlot, bytes32(_input));
    }

    function sysGetOutOfService() view public returns (uint256){
        return uint256(sysLoadSlotData(outOfServiceSlot));
    }

    function sysSetOutOfService(uint256 _input) external onlyAdmin {
        sysSaveSlotData(outOfServiceSlot, bytes32(_input));
    }

    function sysGetTransparent() view public returns (uint256){
        return uint256(sysLoadSlotData(transparentSlot));
    }

    function sysSetTransparent(uint256 _input) external onlyAdmin {
        sysSaveSlotData(transparentSlot, bytes32(_input));
    }

    //=============================================

    //abi and delegates should not be 0x00 in mapping;
    //set delegate to 0x00 for delete the entry
    function sysSetSelectorsAndDelegates(bytes4[] memory selectors, address[] memory delegates) external onlyAdmin {
        require(selectors.length == delegates.length, "sysSetUserSelectorsAndDelegates, length does not matchs");
        for (uint256 i = 0; i < selectors.length; i ++) {
            _sysSetSelectorAndDelegate(selectors[i], delegates[i]);
        }
    }

    function _sysSetSelectorAndDelegate(bytes4 selector, address delegate) internal {

        require(selector != bytes4(0x00), "sysSetSelectorAndDelegate, selector should not be selector");
        //require(delegates[i] != address(0x00));
        address oldDelegate = address(uint160(uint256(sysEnhancedMapGet(userAbiSlot, bytes32(selector)))));
        if (oldDelegate == delegate) {
            //if oldDelegate == 0 & delegate == 0
            //if oldDelegate == delegate != 0
            //do nothing here
        }
        if (oldDelegate == address(0x00)) {
            //delegate != 0
            //adding new value
            sysEnhancedMapAdd(userAbiSlot, bytes32(selector), bytes32(uint256(uint160(delegate))));
            sysUniqueIndexMapAdd(userAbiSearchSlot, bytes32(selector));
        }
        if (delegate == address(0x00)) {
            //oldDelegate != 0
            //deleting new value
            sysEnhancedMapDel(userAbiSlot, bytes32(selector));
            sysUniqueIndexMapDel(userAbiSearchSlot, bytes32(selector));

        } else {
            //oldDelegate != delegate & oldDelegate != 0 & delegate !=0
            //updating
            sysEnhancedMapReplace(userAbiSlot, bytes32(selector), bytes32(uint256(uint160(delegate))));
        }
    }

    function sysGetDelegateBySelector(bytes4 selector) view public returns (address){
        return address(uint160(uint256(sysEnhancedMapGet(userAbiSlot, bytes32(selector)))));
    }

    function sysCountSelectors() view public returns (uint256){
        return sysEnhancedMapSize(userAbiSlot);
    }

    function sysGetSelector(uint256 index) view public returns (bytes4){
        bytes4 selector = bytes4(sysUniqueIndexMapGetValue(userAbiSearchSlot, index));
        return selector;
    }

    function sysGetSelectorAndDelegateByIndex(uint256 index) view public returns (bytes4, address){
        bytes4 selector = sysGetSelector(index);
        address delegate = sysGetDelegateBySelector(selector);
        return (selector, delegate);
    }

    function sysGetSelectorsAndDelegates() view public returns (bytes4[] memory selectors, address[] memory delegates){
        uint256 count = sysCountSelectors();
        selectors = new bytes4[](count);
        delegates = new address[](count);
        for (uint256 i = 0; i < count; i ++) {
            (selectors[i], delegates[i]) = sysGetSelectorAndDelegateByIndex(i + 1);
        }
    }

    function sysClearSelectorsAndDelegates() external onlyAdmin {
        uint256 count = sysCountSelectors();
        for (uint256 i = 0; i < count; i ++) {
            bytes4 selector;
            address delegate;
            //always delete the first, after 'count' times, it will clear all
            (selector, delegate) = sysGetSelectorAndDelegateByIndex(1);
            _sysSetSelectorAndDelegate(selector, address(0x00));
        }
    }

    //=====================internal functions=====================

    receive() payable external {
        process();
    }

    fallback() payable external {
        process();
    }


    //since low-level address.delegateCall is available in solidity,
    //we don't need to write assembly
    function process() internal outOfService {

        if (msg.sender == sysGetAdmin() && sysGetTransparent() == 1) {
            revert("admin cann't call normal function in Transparent mode");
        }

        /*
        the default transfer will set data to empty,
        so that the msg.data.length = 0 and msg.sig = bytes4(0x00000000),

        however some one can manually set msg.sig to 0x00000000 and tails more man-made data,
        so here we have to forward all msg.data to delegates
        */
        address targetDelegate;

        //for look-up table
        /*        if (msg.sig == bytes4(0x00000000)) {
                    targetDelegate = sysGetUserSigZero();
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }

                    targetDelegate = sysGetSystemSigZero();
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }
                } else {
                    targetDelegate = sysGetUserDelegate(msg.sig);
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }

                    //check system abi look-up table
                    targetDelegate = sysGetSystemDelegate(msg.sig);
                    if (targetDelegate != address(0x00)) {
                        delegateCallExt(targetDelegate, msg.data);
                    }
                }*/

        if (msg.sig == bytes4(0x00000000)) {
            targetDelegate = sysGetSigZero();
            if (targetDelegate != address(0x00)) {
                delegateCallExt(targetDelegate, msg.data);
            }

        } else {
            targetDelegate = sysGetDelegateBySelector(msg.sig);
            if (targetDelegate != address(0x00)) {
                delegateCallExt(targetDelegate, msg.data);
            }

        }

        //goes here means this abi is not in the system abi look-up table
        discover();

        //hit here means not found selector
        if (sysGetRevertMessage() == 1) {
            revert(string(abi.encodePacked(sysPrintAddressToHex(address(this)), ", function selector not found : ", sysPrintBytes4ToHex(msg.sig))));
        } else {
            revert();
        }

    }

    function discover() internal {
        bool found = false;
        bool error;
        bytes memory returnData;
        address targetDelegate;
        uint256 len = sysCountDelegate();
        for (uint256 i = 0; i < len; i++) {
            targetDelegate = sysGetDelegateAddress(i + 1);
            (found, error, returnData) = redirect(targetDelegate, msg.data);


            if (found) {
                /*if (msg.sig == bytes4(0x00000000)) {
                    sysSetSystemSigZero(targetDelegate);
                } else {
                    sysSetSystemSelectorAndDelegate(msg.sig, targetDelegate);
                }*/

                returnAsm(error, returnData);
            }
        }
    }

    function delegateCallExt(address targetDelegate, bytes memory callData) internal {
        bool found = false;
        bool error;
        bytes memory returnData;
        (found, error, returnData) = redirect(targetDelegate, callData);
        require(found, "delegateCallExt to a delegate in the map but finally not found, this shouldn't happen");
        returnAsm(error, returnData);
    }

    //since low-level ```<address>.delegatecall(bytes memory) returns (bool, bytes memory)``` can return returndata,
    //we use high-level solidity for better reading
    function redirect(address delegateTo, bytes memory callData) internal returns (bool found, bool error, bytes memory returnData){
        require(delegateTo != address(0), "delegateTo must not be 0x00");
        bool success;
        (success, returnData) = delegateTo.delegatecall(callData);
        if (success == true && keccak256(returnData) == keccak256(notFoundMark)) {
            //the delegate returns ```notFoundMark``` notFoundMark, which means invoke goes to wrong contract or function doesn't exist
            return (false, true, returnData);
        } else {
            return (true, !success, returnData);
        }

    }

    function sysPrintBytesToHex(bytes memory input) internal pure returns (string memory){
        bytes memory ret = new bytes(input.length * 2);
        bytes memory alphabet = "0123456789abcdef";
        for (uint256 i = 0; i < input.length; i++) {
            bytes32 t = bytes32(input[i]);
            bytes32 tt = t >> 31 * 8;
            uint256 b = uint256(tt);
            uint256 high = b / 0x10;
            uint256 low = b % 0x10;
            bytes1 highAscii = alphabet[high];
            bytes1 lowAscii = alphabet[low];
            ret[2 * i] = highAscii;
            ret[2 * i + 1] = lowAscii;
        }
        return string(ret);
    }

    function sysPrintAddressToHex(address input) internal pure returns (string memory){
        return sysPrintBytesToHex(
            abi.encodePacked(input)
        );
    }

    function sysPrintBytes4ToHex(bytes4 input) internal pure returns (string memory){
        return sysPrintBytesToHex(
            abi.encodePacked(input)
        );
    }

    function sysPrintUint256ToHex(uint256 input) internal pure returns (string memory){
        return sysPrintBytesToHex(
            abi.encodePacked(input)
        );
    }

    modifier onlyAdmin(){
        require(msg.sender == sysGetAdmin(), "only admin");
        _;
    }

    modifier outOfService(){
        if (sysGetOutOfService() == uint256(1)) {
            if (sysGetRevertMessage() == 1) {
                revert(string(abi.encodePacked("Proxy is out-of-service right now")));
            } else {
                revert();
            }
        }
        _;
    }

}




/** 
 *  SourceUnit: g:\project\HeLianGongShi\XSwap\contracts\rewardPool\ChachaPoolStorage.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.17;

////import {EnumerableSet} from "../dependency/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

////import "./ChachaPoolType.sol";

contract ChachaPoolLayout {

    using EnumerableSet for EnumerableSet.UintSet;

    address internal _owner;
    uint256 internal _reentrancyGuard;

    address internal _chachaAddress;
    address internal _vchachaAddress;
    address internal _passAddress;

    uint256 public _startTime;

    uint256 internal _lastUpdateRewardTime;
    //in sec
    uint256 internal _rewardRate;
    uint256 internal _rewardPerPowerStored;

    //who => tokenAddress => amount
    mapping(address => mapping(address => uint256)) internal _depositBalance;
    //tokenAddress => amount
    mapping(address => uint256) internal _depositTotalBalance;


    //who => chacha+vchacha
    mapping(address => uint256) internal _stakeBalance;
    uint256 internal _stakeTotalBalance;

    //pass stands for ChaChas Swap Pass
    mapping(address => EnumerableSet.UintSet) internal _passBalance;
    mapping(uint256 => address) internal _passSearch;
    uint256 internal _passTotalBalance;

    //stake and nft -> power
    mapping(address => uint256) internal _powerBalance;
    uint256 internal _powerTotalBalance;


    //if transferred clear this, transferred need to be zero
    mapping(address => uint256) internal _averageStakeBalance;

    mapping(address => uint256) internal _userRewardPerPowerPaid;

    //who => rewards(vchacha), if claim, reduce this
    mapping(address => uint256) internal _vchachaRewards;
    //cumulative vchacha rewards,  if transferred clear, transferred need to be zero
    mapping(address => uint256) internal _vchachaCumulativeRewards;
    //transferred
    mapping(address => bool) internal _transferred;
    //=======================================================

    address internal _chachaVestSupplier;

    //vchacha locked for vesting, if vested, move this to _vchachaCumulativeVestedAmount!!!
    mapping(address => uint256) internal _vchachaVestingAmount;
    //chacha reserved for vesting, _depositBalance[chacha] should be enough to cover
    mapping(address => uint256) internal _chachaReservedAmount;
    //(v)chacha vested,  reduce while claim
    mapping(address => uint256) internal _chachaVestedAmount;
    //vchacha vested total,  only increase, cleared while withdraw!, should be 0 while NO vesting
    mapping(address => uint256) internal _vchachaCumulativeVestedAmount;
    mapping(address => uint256) internal _lastVestingTime;

    //transfer sender => receiver
    mapping(address => address) internal _pendingTransferRequest;

}



/** 
 *  SourceUnit: g:\project\HeLianGongShi\XSwap\contracts\rewardPool\ChachaPoolStorage.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.17;

////import "./ChachaPoolLayout.sol";

////import "../lib/proxy/Proxy.sol";

contract ChachaPoolStorage is Proxy, ChachaPoolLayout {

    constructor (
        uint256 startTime_,
        uint256 rewardPerDay,
        address chachaAddress_,
        address vchachaAddress_,
        address passAddress_,
        address chachaVestSupplier_
    )
    Proxy(msg.sender){

        _reentrancyGuard = ChachaPoolType._NOT_ENTERED;
        _owner = msg.sender;

        if (startTime_ == 0) {
            startTime_ = block.timestamp;
        }

        _chachaAddress = chachaAddress_;
        _vchachaAddress = vchachaAddress_;
        _passAddress = passAddress_;
        _rewardRate = rewardPerDay / 86400;
        _chachaVestSupplier = chachaVestSupplier_;
        _startTime = startTime_;
        _lastUpdateRewardTime = _startTime;
    }
}