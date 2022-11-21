/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)


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

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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

// File: @openzeppelin/contracts/utils/structs/EnumerableMap.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableMap.sol)


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
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32`) since v4.6.0
 * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
 * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an array of EnumerableMap.
 * ====
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        bytes32 value
    ) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
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
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function get(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), errorMessage);
        return value;
    }

    // UintToUintMap

    struct UintToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToUintMap storage map,
        uint256 key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
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
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToUintMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key), errorMessage));
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
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
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key), errorMessage))));
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        AddressToUintMap storage map,
        address key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
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
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        AddressToUintMap storage map,
        address key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key))), errorMessage));
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Bytes32ToUintMap storage map,
        bytes32 key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
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
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (key, uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, key);
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        Bytes32ToUintMap storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, key, errorMessage));
    }
}

// File: contracts/Users.sol


contract Users is Context {
    using SafeMath for uint256;
    
    address topInviteAddr;  // 默认顶级邀请账户
    
    // 等级
    uint8 public constant USER_LEVEL_V0 = 0;    // V0
    uint8 public constant USER_LEVEL_V1 = 1;    // V1
    uint8 public constant USER_LEVEL_V2 = 2;    // V2
    uint8 public constant USER_LEVEL_V3 = 3;    // V3
    
    mapping(address => uint8) usersToLevel; // 会员等级
    mapping(address => address) usersToSuperior;  // 会员绑定上级
    mapping(address => EnumerableSet.AddressSet) directRecommend;  // 用户的直推列表
    mapping(address => uint256) teamCount;  // 用户团队人数
    mapping(address => uint256) userBuyMaxPackageAmount;   // 用户当前购买的最高金额
    mapping(address => uint256) userBuyMaxPackageKey;   // 用户当前购买的最高金额对应的key
    mapping(address => uint256) userUnlockMaxPackageAmount;   // 用户当前解锁的最高金额
    mapping(address => uint256) userUnlockMaxPackageKey;   // 用户当前解锁的最高的key
    
    modifier onlyBindSuperior() {
        require(usersToSuperior[_msgSender()] != address(0) || _msgSender() == topInviteAddr, "User: Not bound to superior");
        _;
    }

    function _grantLevel(address _address, uint8 _level) internal {
        require(_level >= USER_LEVEL_V1 && _level <= USER_LEVEL_V3,"Users: levels are not set correctly");
        usersToLevel[_address] = _level;
    }

    function _getUserLevel(address _address) view internal returns(uint8) {
        return usersToLevel[_address];
    }

    /// @notice 获取用户等级
    /// @return 用户等级标识
    function getUserLevel() view public returns(uint8) {
        return _getUserLevel(_msgSender());
    }

    function setUserLevel(address _address, uint8 level) public {
        _grantLevel(_address, level);
    }

    /// @notice 绑定上级地址，不可以重复绑定
    /// @param _superior 上级地址
    function bindSuperior(address _superior) public {
        require(_msgSender() != topInviteAddr, "User: Top-level users cannot bind superiors");
        require(_superior != _msgSender(), "User: the same address");
        require(_superior != address(0), "User: superior is the zero address");
        require(usersToSuperior[_msgSender()] == address(0), "User: already bound to a superior");
        require(!EnumerableSet.contains(directRecommend[_superior], _msgSender()), "User: already bound to a superior");
        // TODO 上级是否购买过资产包,并且解锁社区
        require(userBuyMaxPackageAmount[_superior] > 0, "User: The superior has not purchased the asset package");
        require(userUnlockMaxPackageAmount[_superior] > 0, "User: The superior has not unlocked the asset package");

        usersToSuperior[_msgSender()] = _superior;
        EnumerableSet.add(directRecommend[_superior], _msgSender());
        _incTeamCount(_msgSender());
    }

    function _incTeamCount(address _initAddress) private {
        address _tmpAddress = _initAddress;
        do {
            address _superior = _getSuperior(_tmpAddress);
            if (_superior != address(0)) {
               teamCount[_superior] = teamCount[_superior].add(1);
            }
            _tmpAddress = _superior;
        } while (_tmpAddress != address(0));
    }

    function _getSuperior(address _address) view internal returns(address) {
        return usersToSuperior[_address];
    }

    /// @notice 获取上级
    /// @return address 上级地址
    function getSuperior() view public returns(address) {
        return _getSuperior(_msgSender());
    }
    
    function _getDirectRecommendCount(address _address) view internal returns(uint256) {
        return EnumerableSet.length(directRecommend[_address]);
    }

    /// @notice 获取直推人数
    /// @return uint256
    function getDirectRecommendCount() view public returns(uint256) {
        return _getDirectRecommendCount(_msgSender());
    }

    /// @notice 获取团队人数
    /// @return uint256
    function getTeamCount() view public returns(uint256) {
        return teamCount[_msgSender()];
    }
}
// File: contracts/ThreeM2022.sol


/// @title 主合约
/// @author Langyao
contract ThreeM2022 is Users, Ownable {
    using SafeMath for uint256;
    
    // USDT合約
    IERC20 contractUsdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);      // BSC 

    // 手续费地址
    address private handlerFeeAddress;
    // 技术运维地址
    address private technologyAddress;
    // 平台地址
    address private platformAddress;
    // 管理员地址
    address private MaintenanceAddress;

    // 资产包
    EnumerableMap.UintToUintMap assetPackage;
    mapping(address => uint256) selfBuyAmount;
    mapping(address => uint256) teamBuyAmount;      // 团队业绩

    uint8 constant private MANAGEMENT_AWARD_RATIO_TOTAL = 17;   // 总管理奖比例（百分比）
    uint8 constant private PINGJI_AWARD_RATIO_TOTAL = 8;        // 总平级奖比例（百分比）
    mapping(uint8 => uint8) MANAGEMENT_AWARD_RATIO; // 管理奖比例（百分比）
    mapping(uint8 => uint8) PINGJI_AWARD_RATIO;     // 平级奖比例 (百分比)

    event EsetMaintenanceAddress(address _newAddress);
    event EsetPlatformAddress(address _newAddress);
    event EsetTechnologyAddress(address _newAddress);
    event EsetHandlerFeeAddress(address _newAddress);

    constructor(address _topInviteAddr, address[] memory _addresses, uint8[] memory _levels) {
        MaintenanceAddress = _msgSender();

        // 设置初始投入金额通道（通道，通道唯一标识，金额）
        EnumerableMap.set(assetPackage, 1, 100 * 10**18);
        EnumerableMap.set(assetPackage, 2, 500 * 10**18);
        EnumerableMap.set(assetPackage, 3, 1000 * 10**18);
        EnumerableMap.set(assetPackage, 4, 3000 * 10**18);
        EnumerableMap.set(assetPackage, 5, 5000 * 10**18);
        EnumerableMap.set(assetPackage, 6, 10000 * 10**18);

        MANAGEMENT_AWARD_RATIO[USER_LEVEL_V1] = 8;
        MANAGEMENT_AWARD_RATIO[USER_LEVEL_V2] = 14;
        MANAGEMENT_AWARD_RATIO[USER_LEVEL_V3] = 17;

        PINGJI_AWARD_RATIO[USER_LEVEL_V1] = 4;
        PINGJI_AWARD_RATIO[USER_LEVEL_V2] = 3;
        PINGJI_AWARD_RATIO[USER_LEVEL_V3] = 1;

        require(_topInviteAddr != address(0), "Users: topInviteAddr are zero");
        require(_addresses.length == _levels.length,"Users: The number of parameters is not equal");
        topInviteAddr = _topInviteAddr;
        userBuyMaxPackageAmount[topInviteAddr] = 10000 * 10**18;
        userUnlockMaxPackageAmount[topInviteAddr] = 10000 * 10**18;
        userUnlockMaxPackageKey[topInviteAddr] = 6;

        for (uint i = 0; i < _addresses.length; i++) {
            _grantLevel(_addresses[i], _levels[i]);
            userBuyMaxPackageAmount[_addresses[i]] = 10000 * 10**18;
            userUnlockMaxPackageAmount[_addresses[i]] = 10000 * 10**18;
            userUnlockMaxPackageKey[_addresses[i]] = 6;
            _addSelfAmount(_addresses[i], 10000 * 10**18);
            _addTeamAmount(_addresses[i], 10000 * 10**18);
        }
    }

    modifier onlyMaintenance() {
        require(MaintenanceAddress == _msgSender(), "ThreeM2022: not MaintenanceAddress");
        _;
    }
    
    /*****************************************************************************
    *                           地址设置 START                                    *
    ******************************************************************************/
    function getHandlerFeeAddress() view public onlyOwner returns(address) {
        return handlerFeeAddress;
    }

    function setHandlerFeeAddress(address _address) public onlyOwner {
        require(_address != address(0),"ThreeM2022: the zero address");
        handlerFeeAddress = _address;
        emit EsetHandlerFeeAddress(_address);
    }

    function getTechnologyAddress() view public onlyOwner returns(address) {
        return technologyAddress;
    }

    function setTechnologyAddress(address _address) public onlyOwner {
        require(_address != address(0),"ThreeM2022: the zero address");
        technologyAddress = _address;
        emit EsetTechnologyAddress(_address);
    }

    function getPlatformAddress() view public onlyOwner returns(address) {
        return platformAddress;
    }

    function setPlatformAddress(address _address) public onlyOwner {
        require(_address != address(0),"ThreeM2022: the zero address");
        platformAddress = _address;
        emit EsetPlatformAddress(_address);
    }

    function getMaintenanceAddress() view public onlyOwner returns(address) {
        return MaintenanceAddress;
    }

    function setMaintenanceAddress(address _address) public onlyOwner {
        require(_address != address(0),"ThreeM2022: the zero address");
        MaintenanceAddress = _address;
        emit EsetMaintenanceAddress(_address);
    }
    /*****************************************************************************
    *                           地址设置 END                                      *
    ******************************************************************************/

    /// @notice 获取通道的总数量
    /// @return 通道的个数
    function getAssetPackagelLength() view public returns(uint) {
        return EnumerableMap.length(assetPackage);
    }

    /// @notice 获取通道键值
    /// @param _index 索引
    /// @return uint256 键
    /// @return uint256 投资金额（单位wei）
    function getAssetPackageByIndex(uint256 _index) view public returns(uint256,uint256) {
        return EnumerableMap.at(assetPackage, _index);
    }

    /// @notice 设置资产包金额
    /// @param pkgkey 资产包key
    /// @param amount 金额，单位（wei）
    function setAssetPackage(uint256 pkgkey, uint256 amount) public onlyOwner {
        require(EnumerableMap.contains(assetPackage, pkgkey), "ThreeM2022: Asset package does not exist");
        uint256 assetPackagePrice = EnumerableMap.get(assetPackage, pkgkey);   // 
        require(assetPackagePrice == 0, "ThreeM2022: already set");
        EnumerableMap.set(assetPackage, pkgkey, amount);
    }

    /// @notice 购买资产包
    function buyAssetPackage(uint256 key) public onlyBindSuperior {
        require(EnumerableMap.contains(assetPackage, key), "ThreeM2022: Asset package does not exist");
        uint256 assetPackagePrice = EnumerableMap.get(assetPackage, key);   // 
        require(assetPackagePrice > 0, "ThreeM2022: Asset pack not open");
        require(assetPackagePrice <= contractUsdtToken.allowance(_msgSender(), address(this)), "ThreeM2022: Access denied");
        contractUsdtToken.transferFrom(_msgSender(), address(this), assetPackagePrice);
        
        buyTotalNumber[key][_msgSender()] += assetPackagePrice;
        if (userBuyMaxPackageAmount[_msgSender()] < assetPackagePrice) {
            userBuyMaxPackageAmount[_msgSender()] = assetPackagePrice;
            userBuyMaxPackageKey[_msgSender()] = key;
        }
        
        _addSelfAmount(_msgSender(),assetPackagePrice);
        _addTeamAmount(_msgSender(),assetPackagePrice);
        _performDistribution(key, assetPackagePrice);
        _upgradeLevel();

        if (userDynamicIncome[_msgSender()] == 0) {
            if (!EnumerableSet.contains(dividensUser[key], _msgSender())) {
                EnumerableSet.add(dividensUser[key], _msgSender());
            }
        }

    }

    /// @notice 解锁资产包
    function unlockAssetPackage() public onlyBindSuperior {
        uint256 assetPackagePrice;
        if (EnumerableMap.contains(assetPackage, userBuyMaxPackageKey[_msgSender()])) {
            assetPackagePrice = EnumerableMap.get(assetPackage, userBuyMaxPackageKey[_msgSender()]);   // 
        } else {
            assetPackagePrice = 0;
        }
        require(assetPackagePrice > userUnlockMaxPackageAmount[_msgSender()], "ThreeM2022: Please unlock higher asset packs");
        require(assetPackagePrice <= contractUsdtToken.allowance(_msgSender(), address(this)), "ThreeM2022: Access denied");
        contractUsdtToken.transferFrom(_msgSender(), address(this), assetPackagePrice);

        _addDividendPool(userBuyMaxPackageKey[_msgSender()], assetPackagePrice);
        userUnlockMaxPackageAmount[_msgSender()] = assetPackagePrice;
        userUnlockMaxPackageKey[_msgSender()] = userBuyMaxPackageKey[_msgSender()];
    }

    /// @notice 获取用户当前购买的最高金额
    function getBuyMaxPackageAmount() view public returns(uint256) {
        return userBuyMaxPackageAmount[_msgSender()];
    }

    /// @notice 获取用户当前解锁的最高金额
    function getMaxUnlockPackageAmount() view public returns(uint256) {
        return userUnlockMaxPackageAmount[_msgSender()];
    }

    /// @notice 获取解锁金额
    function getUnlockAmount() view public returns(uint256) {
        uint256 assetPackagePrice;
        if (EnumerableMap.contains(assetPackage, userBuyMaxPackageKey[_msgSender()])) {
            assetPackagePrice = EnumerableMap.get(assetPackage, userBuyMaxPackageKey[_msgSender()]);   // 
        } else {
            assetPackagePrice = 0;
        }

        if (assetPackagePrice <= userUnlockMaxPackageAmount[_msgSender()]) {
            return 0;
        }
        return assetPackagePrice;
    }

    /// @notice 获取个人业绩
    function getSelfBuyAmount() view public returns(uint256) {
        return selfBuyAmount[_msgSender()];
    }

    /// @notice 获取团队业绩
    function getTeamBuyAmount() view public returns(uint256) {
        return teamBuyAmount[_msgSender()];
    }

    function _addSelfAmount(address _address, uint256 amount) internal {
        selfBuyAmount[_address] += amount;
    }

    function _addTeamAmount(address _address, uint256 amount) internal {
        address currentAddress = _address;
        address superior;
        do {
            superior = _getSuperior(currentAddress);
            if (superior != address(0)) {
                teamBuyAmount[superior] += amount;
            }
            currentAddress = superior;
        } while (superior != address(0));
    }

    function _upgradeLevel() internal {
        address currentAddres = _msgSender();
        address superior;
        uint8 superiorLevel;
        uint8 newLevel;

        do {
            superior = usersToSuperior[currentAddres];
            if (superior != address(0)) {
                superiorLevel = _getUserLevel(superior);
                if (superiorLevel != USER_LEVEL_V3) {
                    newLevel = _getNewLevel(superior);
                    if (superiorLevel < newLevel) {
                        _grantLevel(superior, newLevel);
                        // 获得动态收益资格，则不可以获得静态收益了
                    }
                }
            }
            currentAddres = superior;
        } while (superior != address(0));
    }

    function _getNewLevel(address _address) view internal returns(uint8) {
        uint8 superiorLevel = _getUserLevel(_address);
        uint8 newLevel = superiorLevel;
        /*
            升级条件：
                V1  直推3个V0，直推3人下单，团队业绩1200U
                V2  直推3个V1，团队业绩3600U
                V3  直推3个V2，团队业绩10800U
         */
        if (superiorLevel < USER_LEVEL_V1) {
            if (teamBuyAmount[_address] >= 1200 * 10**18) {
                if (EnumerableSet.length(directRecommend[_address]) >= 3) {
                    uint buyCount;
                    for (uint i = 0; i < EnumerableSet.length(directRecommend[_address]); i++) {
                        if (userBuyMaxPackageAmount[EnumerableSet.at(directRecommend[_address], i)] > 0) {
                            buyCount++;
                            if (buyCount == 3) {
                                break;
                            }
                        }
                    }
                    if (buyCount >= 3) {
                        newLevel = USER_LEVEL_V1;
                    }
                }
            }
        }

        if (superiorLevel < USER_LEVEL_V2) {
            if (EnumerableSet.length(directRecommend[_address]) >= 3) {
                uint v1Count;
                for (uint i = 0; i < EnumerableSet.length(directRecommend[_address]); i++) {
                    if (_getUserLevel(EnumerableSet.at(directRecommend[_address], i)) >= USER_LEVEL_V1) {
                        v1Count++;
                        if (v1Count >= 3) {
                            break;
                        }
                    }
                }
                if (v1Count >= 3) {
                    newLevel = USER_LEVEL_V2;
                }                
            }
        }

        if (superiorLevel < USER_LEVEL_V3) {
            if (EnumerableSet.length(directRecommend[_address]) >= 3) {
                uint v2Count;
                for (uint i = 0; i < EnumerableSet.length(directRecommend[_address]); i++) {
                    if (_getUserLevel(EnumerableSet.at(directRecommend[_address], i)) >= USER_LEVEL_V2) {
                        v2Count++;
                        if (v2Count >= 3) {
                            break;
                        }
                    }
                }
                if (v2Count >= 3) {
                    newLevel = USER_LEVEL_V3;
                }                
            }
        }

        return newLevel;
    }


    /******************************************************************************
    *                           静态分红 START                                     *
    ******************************************************************************/
    /// @notice 静态分红池
    /// @dev (资产包key => (分红时间 => 分红金额))
    mapping(uint => mapping(uint => uint256)) dividendPool;
    /// @notice 每天分红人数
    mapping(uint => mapping(uint => uint256)) dayDividendsCount;

    // 静态分红条件 ---------------
    /*
        逻辑：1. 用户自己购买了资产包，判断团队是否有用户下单，没有则直接具有分红资格
             2. 分红之后，判断用户的静态收益是否是总投入的2倍，达到2倍直接出局，去掉下次分红资格
     */
    mapping(uint => EnumerableSet.AddressSet) dividensUser;         // 具有分红资格的用户
    mapping(uint => mapping(uint => EnumerableSet.AddressSet)) hasDividensUser;      // 已经分红的用户
    mapping(uint => mapping(address => uint256)) buyTotalNumber;    // 用户总投入
    mapping(uint => mapping(address => uint256)) staticIncome;      // 用户静态收益统计
    mapping(uint => mapping(address => bool)) teamHasBuy;           // 团队是否有用户下单
    // 静态分红条件 ---------------
    
    event AddDividend(uint indexed pkgkey, uint indexed ts, uint256 amount);

    function _addDividendPool(uint pkgkey, uint256 amount) internal {
        uint ts = block.timestamp + 86400 - (block.timestamp % 86400) - 28800;   // 一天一次
        dividendPool[pkgkey][ts] = dividendPool[pkgkey][ts].add(amount);
        emit AddDividend(pkgkey, ts, amount);
    }

    /// @notice 静态收益统计
    /// @param pkgkey 资产包key
    /// @return uint256 静态收益统计
    function getStaticIncome(uint pkgkey) view public returns(uint256) {
        return staticIncome[pkgkey][_msgSender()];
    }

    /// @notice 获取分红池金额
    /// @param pkgkey 资产包key
    /// @param ts 时间，每天0点的时间戳，代表当天的分红池
    /// @return uint256 分红池金额
    function getDividendPoll(uint pkgkey, uint ts) view public onlyMaintenance returns(uint256) {
        return dividendPool[pkgkey][ts];
    }

    /// @dev 获取当前可分红的人数
    function getDividendUserCount(uint pkgkey) view public onlyMaintenance returns(uint256) {
        return EnumerableSet.length(dividensUser[pkgkey]);
    } 

    /// @dev 获取当前可分红的人
    function getDividendUser(uint pkgkey, uint256 index) view public onlyMaintenance returns(address) {
        require(EnumerableMap.contains(assetPackage, pkgkey), "ThreeM2022: Asset package does not exist");
        return EnumerableSet.at(dividensUser[pkgkey], index);
    }

    /// @dev 已经分红的用户的人数
    function getHasDividendUserCount(uint pkgkey, uint ts) view public onlyMaintenance returns(uint256) {
        return EnumerableSet.length(hasDividensUser[pkgkey][ts]);
    }

    /// @dev 已经分红的用户
    function getHasDividendUser(uint pkgkey, uint ts, uint256 index) view public onlyMaintenance returns(address) {
        return EnumerableSet.at(hasDividensUser[pkgkey][ts], index);
    }

    /// @notice 全网分红
    function dividendsForAll(uint pkgkey, uint ts, address[] memory users) public onlyMaintenance {
        require(ts < block.timestamp, "Dividend time not yet");
        uint256 dividendPoolAmount = dividendPool[pkgkey][ts];
        require(dividendPoolAmount > 0, "has paid dividends");
        if (dayDividendsCount[pkgkey][ts] == 0) {
            dayDividendsCount[pkgkey][ts] = EnumerableSet.length(dividensUser[pkgkey]);
            require(dayDividendsCount[pkgkey][ts] > 0, "no one can pay dividends");
        }
        require(dayDividendsCount[pkgkey][ts].sub(EnumerableSet.length(hasDividensUser[pkgkey][ts])) >= users.length, "The number of dividends is greater than the remaining number");

        uint256 dividendAmount = dividendPoolAmount.div(dayDividendsCount[pkgkey][ts]);

        for (uint i = 0; i < users.length; i++) {
            if (EnumerableSet.contains(hasDividensUser[pkgkey][ts], users[i])) continue;
            _dividendOne(pkgkey, ts, users[i], dividendAmount);
        }
    }

    function _dividendOne(uint pkgkey, uint ts, address _address, uint256 dividendAmount) internal {
        // 计算实际的分红数量，未分红完的分给平台
        uint256 trueDividendAmount;
        uint256 burnDividendAmount;
        trueDividendAmount = buyTotalNumber[pkgkey][_address].mul(2).sub(staticIncome[pkgkey][_address]);
        if (trueDividendAmount <= dividendAmount) {
            EnumerableSet.remove(dividensUser[pkgkey], _address);
        }

        if (trueDividendAmount < dividendAmount) {
            burnDividendAmount = dividendAmount.sub(trueDividendAmount);
        } else {
            trueDividendAmount = dividendAmount;
        }
        if (trueDividendAmount > 0) {
            contractUsdtToken.transfer(_address, trueDividendAmount.mul(1000 - HANDLER_FEE_RATIO).div(1000));
            staticIncome[pkgkey][_address] += trueDividendAmount.mul(1000 - HANDLER_FEE_RATIO).div(1000);
            contractUsdtToken.transfer(handlerFeeAddress, trueDividendAmount.mul(HANDLER_FEE_RATIO).div(1000));
        }
        
        if (burnDividendAmount > 0) {
            contractUsdtToken.transfer(platformAddress, burnDividendAmount);
        }

        EnumerableSet.add(hasDividensUser[pkgkey][ts], _address);
    }

    /// @notice 静态收益统计
    /// @return uint256 静态收益统计
    function getStaticIncomeAll() view public returns(uint256) {
        uint256 value;
        uint256 pkgkey;
        for (uint i = 0; i < EnumerableMap.length(assetPackage); i++) {
            (pkgkey,) = EnumerableMap.at(assetPackage, i);
            value += staticIncome[pkgkey][_msgSender()];
        }
        return value;
    }

    function _removeDividensUserAll(address _address) internal {
        uint256 pkgkey;
        for (uint i = 0; i < EnumerableMap.length(assetPackage); i++) {
            (pkgkey,) = EnumerableMap.at(assetPackage, i);
            if (EnumerableSet.contains(dividensUser[pkgkey], _address)) {
                EnumerableSet.remove(dividensUser[pkgkey], _address);
            }
        }
    }

    function _removeDividensUserAll() internal {
        uint256 pkgkey;
        for (uint i = 0; i < EnumerableMap.length(assetPackage); i++) {
            (pkgkey,) = EnumerableMap.at(assetPackage, i);
            if (EnumerableSet.contains(dividensUser[pkgkey], _msgSender())) {
                EnumerableSet.remove(dividensUser[pkgkey], _msgSender());
            }
        }
    }
    /******************************************************************************
    *                           静态分红 END                                       *
    ******************************************************************************/
    
    /******************************************************************************
    *                           动态收益 START                                     *
    ******************************************************************************/
    uint8 constant private MAINTENANCE_FEE_RATIO = 5;   // 技术运维费（百分比）
    uint8 constant private DIRECT_RECOMMEND_RATIO = 48; // 直推奖比例 (百分比)
    uint8 constant private DIRECT_RECOMMEND_TO_DIVIDEND_POOL = 2; // 直推奖分到分红池 (百分比)
    uint8 constant private HANDLER_FEE_RATIO = 5;       // 手续费比例（千分比）
    uint8 constant private MANAGE_AWARD_TO_DIVIDEND_POOL_RATIO = 20; // 管理奖分发，进入分红池比例（千分比）
    uint16 constant private MANAGE_AWARD_TRUE_RATIO = 980;    // 实际管理奖比例（千分比），扣除手续费、分红池
    uint8 constant private DIVIDEND_POOL_RATIO = 20;    // 分红池比例（百分比）

    mapping(address => uint256) userDynamicIncome;           // 用户动态收益统计


    event ManageAward(address indexed _address, uint256 amount);
    event PingjiAward(address indexed _address, uint256 amount);
    event BurnAward(uint256 amount);

    /// @notice 获取用户动态收益
    function getDynamicIncome() view public returns(uint256) {
        return userDynamicIncome[_msgSender()];
    }

    /// @dev 增加动态收益
    function _incDynamicIncome(address _address, uint256 amount) internal {
        if (userDynamicIncome[_address] == 0) {
            _removeDividensUserAll(_address);
        }
        userDynamicIncome[_address] = userDynamicIncome[_address].add(amount);
    }

    function _managementAward(uint pkgkey, uint256 amount) internal {
        address currentAddress = _msgSender();
        uint8 currentLevel = _getUserLevel(_msgSender());
        address superior;
        bool canPingji = true;
        uint256 pingjiToPlatform = amount.mul(PINGJI_AWARD_RATIO_TOTAL).div(100);
        uint256 manageSuplusAmount = amount.mul(MANAGEMENT_AWARD_RATIO_TOTAL).div(100);
        uint256 manageAmount;
        uint256 manageAmountTrue;
        uint256 userAmount;

        do {
            superior = _getSuperior(currentAddress);
            if (canPingji == true) {
                canPingji = false;
                if (currentLevel > 0) {
                    if (_pingjiAward(currentAddress, currentLevel, pkgkey, amount)) {
                        pingjiToPlatform = pingjiToPlatform.sub(_getPingjiAmount(amount, currentLevel));
                    }
                }
            }

            if (_getUserLevel(superior) > currentLevel) {
                canPingji = true;
                if (userUnlockMaxPackageAmount[superior] < amount) {
                    userAmount = userUnlockMaxPackageAmount[superior];
                } else {
                    userAmount = amount;
                }
                manageAmount = userAmount.mul(MANAGEMENT_AWARD_RATIO[usersToLevel[superior]]).div(100);
                if (currentLevel > 0) {
                    manageAmount -= userAmount.mul(MANAGEMENT_AWARD_RATIO[currentLevel]).div(100);
                }
                manageAmount = manageAmount.mul(MANAGE_AWARD_TRUE_RATIO).div(1000);
                manageSuplusAmount = manageSuplusAmount.sub(manageAmount);
                manageAmountTrue = manageAmount.mul(1000 - HANDLER_FEE_RATIO).div(1000);

                contractUsdtToken.transfer(superior, manageAmountTrue);
                contractUsdtToken.transfer(handlerFeeAddress, manageAmount.sub(manageAmountTrue));    
                
                currentLevel = usersToLevel[superior];
                _incDynamicIncome(superior, manageAmountTrue);
                emit ManageAward(superior, manageAmountTrue);       
            }
            currentAddress = superior;
        } while (currentAddress != address(0));

        if (pingjiToPlatform > 0) {
            // 谁都拿不到平级的话，全部给到平台
            contractUsdtToken.transfer(platformAddress, pingjiToPlatform);
        }

        // 烧伤 + 分红池
        _addDividendPool(pkgkey, manageSuplusAmount);
        emit BurnAward(manageSuplusAmount); 
    }

    event E_pingjiAward(address _address, uint8 level);

    function _pingjiAward(address _address, uint8 level, uint pkgkey, uint256 amount) internal returns(bool) {
        address currentAddress = _address;
        address superior;
        bool loop = true;
        bool isPingji = false;

        do {
            superior = _getSuperior(currentAddress);
            emit E_pingjiAward(superior, level);
            if (_getUserLevel(superior) == level) {
                loop = false;
                isPingji = true;
                uint256 pingjiToDividend;
                uint256 pingjiAmount;
                uint256 pingjiAmountTrue;
                uint256 userAmount;

                pingjiAmount = _getPingjiAmount(amount, level);
                if (userUnlockMaxPackageAmount[superior] < amount) {
                    userAmount = userUnlockMaxPackageAmount[superior];
                    pingjiAmount = _getPingjiAmount(userAmount, level);
                    pingjiAmountTrue = pingjiAmount.mul(MANAGE_AWARD_TRUE_RATIO).div(1000);
                    pingjiToDividend = _pingjiToDividend(amount, pingjiAmountTrue, level);
                } else {
                    userAmount = amount;
                    pingjiAmountTrue = pingjiAmount.mul(MANAGE_AWARD_TRUE_RATIO).div(1000);
                    pingjiToDividend = pingjiAmount.sub(pingjiAmountTrue);
                }        
                contractUsdtToken.transfer(superior, pingjiAmountTrue.mul(1000 - HANDLER_FEE_RATIO).div(1000));
                contractUsdtToken.transfer(handlerFeeAddress, pingjiAmountTrue.mul(HANDLER_FEE_RATIO).div(1000));    

                _incDynamicIncome(superior, pingjiAmountTrue.mul(1000 - HANDLER_FEE_RATIO).div(1000));
                emit PingjiAward(superior, pingjiAmountTrue.mul(1000 - HANDLER_FEE_RATIO).div(1000));            
                // 烧伤 + 分红池
                _addDividendPool(pkgkey, pingjiToDividend);
                emit BurnAward(pingjiToDividend);    
            }
            currentAddress = superior;
        } while (loop == true && currentAddress != address(0));    
        return isPingji;
    }

    function _getPingjiAmount(uint256 amount, uint8 level) view internal returns(uint256) {
        return amount.mul(PINGJI_AWARD_RATIO[level]).div(100);
    }

    function _pingjiToDividend(uint256 amount, uint256 pingjiAmountTrue, uint8 currentLevel) view internal returns(uint256) {
       return amount.sub(pingjiAmountTrue).mul(PINGJI_AWARD_RATIO[currentLevel]).div(100);
    }

    /// @dev 直推奖
    function _directRecommendAward(uint pkgkey, uint256 amount) internal {
        address superior = usersToSuperior[_msgSender()];
        uint256 toDividendPoolAmount = amount.mul(DIRECT_RECOMMEND_TO_DIVIDEND_POOL).div(100);
        
        if (superior != address(0)) {
            uint256 directAmount;
            uint256 directAmountTrue;

            if (userUnlockMaxPackageAmount[superior] < amount) {
                directAmount = userUnlockMaxPackageAmount[superior].mul(DIRECT_RECOMMEND_RATIO).div(100);
                toDividendPoolAmount = toDividendPoolAmount.add(amount.mul(DIRECT_RECOMMEND_RATIO).div(100).sub(directAmount));
            } else {
                directAmount = amount.mul(DIRECT_RECOMMEND_RATIO).div(100);
            }
            directAmountTrue = directAmount.mul(1000 - HANDLER_FEE_RATIO).div(1000);
            
            contractUsdtToken.transfer(superior, directAmountTrue);
            contractUsdtToken.transfer(handlerFeeAddress, directAmount.sub(directAmountTrue));
            _incDynamicIncome(superior, directAmountTrue);    
        } else {
            toDividendPoolAmount = toDividendPoolAmount.add(amount.mul(DIRECT_RECOMMEND_RATIO).div(100));
        }

        _addDividendPool(pkgkey, toDividendPoolAmount);
    }

    /// @dev 技术运维费
    function _maintenanceFee(uint256 amount) internal {
        uint256 maintenanceFee = amount.mul(MAINTENANCE_FEE_RATIO).div(100);
        contractUsdtToken.transfer(technologyAddress, maintenanceFee);
    }

    /// @dev 执行分发
    function _performDistribution(uint pkgkey, uint256 amount) internal {
        _addDividendPool(pkgkey, amount.mul(DIVIDEND_POOL_RATIO).div(100));
        _directRecommendAward(pkgkey, amount);
        _managementAward(pkgkey, amount);
        _maintenanceFee(amount);
    }

    function withdraw(uint256 amount) public onlyOwner {
        contractUsdtToken.transfer(owner(), amount);
    }

    function destroy() public virtual {
        require(
            msg.sender == owner(),
            "Only the owner of this Contract could destroy It!"
        );
        selfdestruct(payable(owner()));
    }
}