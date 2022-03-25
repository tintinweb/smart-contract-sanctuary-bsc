// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/IProduct.sol";
import "./interfaces/ISesameCredit.sol";

contract Governance {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet voters;
    EnumerableSet.AddressSet products;

    uint256 public sesamePrice;
    address public voterToAdd;
    address public voterToRemove;
    address public productToAdd;
    address public productToRemove;

    address public immutable randomNumberGenerator;
    address public immutable feeCollector;
    address public immutable accountant;
    address public immutable sesameCredit;

    EnumerableSet.AddressSet approveAddVoter;
    EnumerableSet.AddressSet approveRemoveVoter;
    EnumerableSet.AddressSet approveAddProduct;
    EnumerableSet.AddressSet approveRemoveProduct;
    EnumerableSet.AddressSet approveSesameCredit;

    event ApproveAddVoter(address indexed by, address indexed voter);
    event ApproveRemoveVoter(address indexed by, address indexed voter);
    event ApproveAddProduct(address indexed by, address indexed product);
    event ApproveRemoveProduct(address indexed by, address indexed product);
    event ApproveSesameCredit(address indexed by, uint256 price);

    event AddVoter(address indexed voter);
    event RemoveVoter(address indexed voter);
    event AddProduct(address indexed product);
    event RemoveProduct(address indexed product);
    event SetSesameCredit(uint256 price);

    modifier onlyVoter() {
        require(voters.contains(msg.sender), "UNAUTHORIZED");
        _;
    }

    constructor(
        address _feeCollector,
        address _randomNumberGenerator,
        address _accountant,
        address _sesameCredit
    ) {
        voters.add(msg.sender);
        feeCollector = _feeCollector;
        randomNumberGenerator = _randomNumberGenerator;
        accountant = _accountant;
        sesameCredit = _sesameCredit;
    }

    function voterAt(uint256 index) public view returns (address) {
        return voters.at(index);
    }

    function isVoter(address _voter) public view returns (bool) {
        return voters.contains(_voter);
    }

    function productAt(uint256 index) public view returns (address) {
        return products.at(index);
    }

    function isProduct(address _product) public view returns (bool) {
        return products.contains(_product);
    }

    function voterCount() public view returns (uint256) {
        return voters.length();
    }

    function reset(EnumerableSet.AddressSet storage set) internal {
        uint256 size = set.length();
        for (uint256 i = 0; i < size; i++) {
            set.remove(set.at(0));
        }
    }

    function isAddVoterApproved(address _by) public view returns (bool) {
        return approveAddVoter.contains(_by);
    }

    function isRemoveVoterApproved(address _by) public view returns (bool) {
        return approveRemoveVoter.contains(_by);
    }

    function isAddProductApproved(address _by) public view returns (bool) {
        return approveAddProduct.contains(_by);
    }

    function isRemoveProductApproved(address _by) public view returns (bool) {
        return approveRemoveProduct.contains(_by);
    }

    function isSesameCreditApproved(address _by) public view returns (bool) {
        return approveSesameCredit.contains(_by);
    }

    function addVoter(address _voter) public onlyVoter {
        require(_voter != address(0), "ZERO ADDRESS");
        require(!voters.contains(_voter), "NOOP");
        if (voterToAdd != _voter) {
            voterToAdd = _voter;
            reset(approveAddVoter);
        }

        approveAddVoter.add(msg.sender);
        emit ApproveAddVoter(msg.sender, _voter);
        if (approveAddVoter.length() == voters.length()) {
            voters.add(_voter);
            reset(approveAddVoter);
            voterToAdd = address(0);
            emit AddVoter(_voter);
        }
    }

    function removeVoter(address _voter) public onlyVoter {
        require(voters.contains(_voter), "NOT FOUND");
        require(msg.sender != _voter, "UNAUTHORIZED");
        require(voters.length() > 2, "BAD REQUEST");
        if (voterToRemove != _voter) {
            voterToRemove = _voter;
            reset(approveRemoveVoter);
        }

        approveRemoveVoter.add(msg.sender);
        emit ApproveRemoveVoter(msg.sender, _voter);
        if (approveRemoveVoter.length() == voters.length() - 1) {
            voters.remove(_voter);
            reset(approveRemoveVoter);
            voterToRemove = address(0);
            emit RemoveVoter(_voter);
        }
    }

    function addProduct(address _product) public onlyVoter {
        require(_product != address(0), "ZERO ADDRESS");
        require(!products.contains(_product), "NOOP");
        if (productToAdd != _product) {
            productToAdd = _product;
            reset(approveAddProduct);
        }

        approveAddProduct.add(msg.sender);
        emit ApproveAddProduct(msg.sender, _product);
        if (approveAddProduct.length() == voters.length()) {
            products.add(_product);
            IProduct(_product).activate();
            reset(approveAddProduct);
            productToAdd = address(0);
            emit AddProduct(_product);
        }
    }

    function removeProduct(address _product) public onlyVoter {
        require(products.contains(_product), "NOT FOUND");
        if (productToRemove != _product) {
            productToRemove = _product;
            reset(approveRemoveProduct);
        }

        approveRemoveProduct.add(msg.sender);
        emit ApproveRemoveProduct(msg.sender, _product);
        if (approveRemoveProduct.length() == voters.length()) {
            products.remove(_product);
            IProduct(_product).deactivate();
            reset(approveRemoveProduct);
            productToRemove = address(0);
            emit RemoveProduct(_product);
        }
    }

    function setSesameCredit(uint256 _price) public onlyVoter {
        if (sesamePrice != _price) {
            sesamePrice = _price;
            reset(approveSesameCredit);
        }

        approveSesameCredit.add(msg.sender);
        emit ApproveSesameCredit(msg.sender, _price);
        if (approveSesameCredit.length() == voters.length()) {
            ISesameCredit(sesameCredit).updateAnswer(int256(_price));
            reset(approveSesameCredit);
            emit SetSesameCredit(_price);
        }
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IProduct {
    function pickWinner(uint256[] memory _rand, uint256 _round) external;

    function activate() external;

    function deactivate() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISesameCredit {
    function latestAnswer() external view returns (int256);

    function updateAnswer(int256 _answer) external;
}