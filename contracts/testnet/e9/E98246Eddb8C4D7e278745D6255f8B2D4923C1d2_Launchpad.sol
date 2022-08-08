/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

pragma solidity >=0.4.22 <0.9.0;


// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)
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

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IBEP1155 {
    function getOwner() external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function getPriceTicket(uint256 _id) external view returns (uint256);
}

interface IVRFOracleOraichain {
    function randomnessRequest(uint256 _seed, bytes calldata _data) external returns (bytes32 reqId);

    function getFee() external returns (uint256);
}

contract Launchpad {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint256 private flag;
    address public orai;
    address public oracle;
    uint256 public random;
    bytes32 public reqId;
    uint256 public winUsers;
    address public eventAddress;
    EnumerableSet.AddressSet internal attemptList;
    EnumerableSet.AddressSet internal winnerList;

    function attemptLauchpad() public payable {
        require(msg.value >= IBEP1155(eventAddress).getPriceTicket(0), "Error, ticket cost more");
        require(!attemptList.contains(msg.sender), "Error, user attempted already");
        attemptList.add(msg.sender);
        // totalUsers = totalUsers + 1;
    }

    function clearList(EnumerableSet.AddressSet storage list) internal {
        for (uint256 i = 0; i < list.length(); i++) {
            list.remove(list.at(0));
        }
    }

    function checkFlag() public view returns (uint256) {
        return flag;
    }

    function withdraw() public {
        payable(address(msg.sender)).transfer(address(this).balance);
    }

    function checkLeftBNB() public view returns  (uint256) {
        return address(this).balance;
    }

    function getTotalAttemptLength() public view returns (uint256) {
        return attemptList.length();
    }

    function getTotalWinnerLength() public view returns (uint256) {
        return winnerList.length();
    }

    function getAttemptAtIndex(uint256 index) public view returns (address) {
        return attemptList.at(index);
    }

    function getWinnerAtIndex(uint256 index) public view returns (address) {
        return winnerList.at(index);
    }

    function setLaunchpad1155Single(
        address ticketAddress,
        uint256 _ticketId,
        uint256 _amount
    ) public {
        require(flag == 0, "Another event is using launchpad");
        require(msg.sender == IBEP1155(ticketAddress).getOwner(), "Caller is not owner!");

        for (uint256 i = 0; i < attemptList.length(); i++) {
            attemptList.remove(attemptList.at(0));
        }

        for (uint256 i = 0; i < winnerList.length(); i++) {
            winnerList.remove(winnerList.at(0));
        }
        // totalUsers = 0;
        eventAddress = ticketAddress;
        IBEP1155(ticketAddress).safeTransferFrom(msg.sender, address(this), _ticketId, _amount, "0x");
        winUsers = _amount;
        flag = 1;
    }

    function setWinnerUser(address winner) internal {
        winnerList.add(winner);
        attemptList.remove(winner);
    }

    function initOracle (address _oraiToken, address _oracle) public {
        orai = _oraiToken;
        oracle = _oracle;
    }

    function randomnessRequest(uint256 _seed) public {
        IERC20(orai).approve(oracle, IVRFOracleOraichain(oracle).getFee());
        bytes memory data = abi.encode(address(this), this.fulfillRandomness.selector);
        reqId = IVRFOracleOraichain(oracle).randomnessRequest(_seed, data);
    }

    function fulfillRandomness(bytes32 _reqId, uint256 _random) external {
        require(msg.sender == oracle, "Caller must is oracle");
        random = _random;
        getWinners();
        transferTicket();
        refund();
        flag = 0;
    }

    function testFulfillRandomness (uint256 _random) external {
        random = _random;
        getWinners();
        transferTicket();
        refund();
        flag = 0;
    }

    function refund() internal {
        address attemptAddress;
        for (uint256 i = 0; i < getTotalAttemptLength(); i++) {
            attemptAddress = getAttemptAtIndex(i);
            payable(attemptAddress).transfer(IBEP1155(eventAddress).getPriceTicket(0));
        }
        if(getTotalAttemptLength() != 0) payable(IBEP1155(eventAddress).getOwner()).transfer((IBEP1155(eventAddress).getPriceTicket(0))*winUsers);
    }

    function transferTicket() internal {
        address winnerAddress;
        for (uint256 i = 0; i < getTotalWinnerLength(); i++) {
            winnerAddress = getWinnerAtIndex(i);
            IBEP1155(eventAddress).safeTransferFrom(address(this), winnerAddress, 0, 1, "0x");
        }
    }

    function getWinners() public {
        require(random != 0, "wait for random");
        uint256 tmpMod;
        address winnerAddress;
        uint256 totalUsers = attemptList.length();
        if (totalUsers == 0) {
            for (uint256 i = 0; i < winUsers; i++) {
                winnerList.add(IBEP1155(eventAddress).getOwner());
            }
        }
        if (totalUsers < winUsers) {
            if(totalUsers == 0) {
                for (uint256 i = 0; i < winUsers; i++) {
                    winnerList.add(IBEP1155(eventAddress).getOwner());
                }
            }
            else {
                for (uint256 i = 0; i < totalUsers; i++) {
                    winnerAddress = getAttemptAtIndex(0);
                    setWinnerUser(winnerAddress);
                }
                for (uint256 i = 0; i < winUsers-totalUsers; i++) {
                    winnerList.add(IBEP1155(eventAddress).getOwner());
                }
            }
            
        }
        else {
            for (uint256 i = 0; i < winUsers; i++) {
                tmpMod = random % (totalUsers-i);
                winnerAddress = getAttemptAtIndex(tmpMod);
                setWinnerUser(winnerAddress);
//                random = uint256(random) / uint256(totalUsers) + (totalUsers + i);
            }
        }
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns (bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns (bytes4){
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    fallback () external payable { }
}