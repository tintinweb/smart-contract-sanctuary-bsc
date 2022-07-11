// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCastUpgradeable {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT

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
library EnumerableSetUpgradeable {
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

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
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

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract NodeStakingPool is Initializable, OwnableUpgradeable, PausableUpgradeable {
    using SafeERC20 for IERC20;
    using SafeCastUpgradeable for uint256;

    uint256 private constant ACCUMULATED_MULTIPLIER = 1e12;

    // Info of each user + id.
    struct NodeStakingUserInfo {
        uint256 stakeTime; // next reward block
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 pendingReward; // Reward but not harvest
        // TODO: if switch from 1 to 0, transfer reward to user before set stakeTime to 0
        // bool status; // 0: inactive, 1: active

        //   pending reward = (user.amount * accRewardPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a  Here's what happens:
        //   1. The pool's `accRewardPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    IERC20 public stakeToken; // Address of LP token contract.
    uint256 public stakeTokenSupply; // Total lp tokens deposited to this
    uint256 public totalRunningNode; // Total lp tokens deposited to this
    uint256 public lastRewardBlock; // Last block number that rewards distribution occurs.
    uint256 public accRewardPerShare; // Accumulated rewards per share, times 1e12. See below.
    uint256 public requireStakeAmount; // stake amount need for user to run node

    struct LockWithdrawReward {
        uint256 reward;
        uint256 applicableAt;
    }

    string public name;
    string public symbol;
    // The reward token!
    IERC20 public rewardToken;
    // Total rewards for each block.
    uint256 public rewardPerBlock;
    // The reward distribution address
    address public rewardDistributor;
    // Info of each user that stakes LP tokens.
    mapping(address => mapping(uint256 => NodeStakingUserInfo)) public userInfo;
    // The block number when rewards mining starts.
    uint256 public startBlockNumber;
    // The block number when rewards mining ends.
    uint256 public endBlockNumber;
    // withdraw period
    uint256 public withdrawPeriod;
    // withdraw period
    uint256 public lockupDuration;
    // the weight of provider to earn reward
    mapping(address => uint256) public userRunningNode;
    mapping(address => uint256) public userNodeCount;
    // pending reward in withdraw period
    mapping(address => mapping(uint256 => LockWithdrawReward)) public pendingRewardInWithdrawPeriod;

    event NodeStakingDeposit(address user, uint256 amount, uint256 userNodeId, uint256 backendNodeId);
    event NodeStakingEnableAddress(address user, uint256 userNodeId);
    event NodeStakingDisableAddress(address user, uint256 userNodeId);
    event NodeStakingWithdraw(address user, uint256 amount);
    event NodeStakingRewardsHarvested(address user, uint256 amount);
    event SetRequireStakeAmount(uint256 amount);
    event SetEndBlock(uint256 block);
    event SetRewardDistributor(address rewardDistributor);
    event SetRewardPerBlock(uint256 rewardPerBlock);
    event SetPoolInfor(
        uint256 rewardPerBlock,
        uint256 endBlock,
        uint256 lockupDuration,
        uint256 withdrawPeriod,
        address rewardDistributor
    );

    /**
     * @notice Initialize the contract, get called in the first time deploy
     * @param _rewardToken the reward token address
     * @param _rewardPerBlock the number of reward tokens that got unlocked each block
     * @param _startBlock the block number when farming start
     */
    function initialize(
        string memory _name,
        string memory _symbol,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _endBlock,
        IERC20 _stakeToken,
        uint256 _lockupDuration,
        uint256 _withdrawPeriod,
        address _rewardDistributor
    ) external initializer {
        __Ownable_init();
        transferOwnership(tx.origin);
        require(address(_rewardToken) != address(0), "NodeStakingPool: invalid reward token address");
        require(_startBlock < _endBlock, "NodeStakingPool: invalid start block or end block");
        require(_lockupDuration > 0, "NodeStakingPool: lockupDuration must be gt 0");
        require(_withdrawPeriod > 0, "NodeStakingPool: withdrawPeriod must be gt 0");

        name = _name;
        symbol = _symbol;
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlockNumber = _startBlock;
        endBlockNumber = _endBlock;
        lockupDuration = _lockupDuration;
        withdrawPeriod = _withdrawPeriod;
        rewardDistributor = _rewardDistributor;

        lastRewardBlock = block.number > startBlockNumber ? block.number : startBlockNumber;
        stakeToken = _stakeToken;
        stakeTokenSupply = 0;
        totalRunningNode = 0;
        requireStakeAmount = 0;
        accRewardPerShare = 0;
        updatePool();
    }

    /**
     * @notice Pause contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Set require stake amount
     * @param _requireStakeAmount amount want to set
     */
    function setRequireStakeAmount(uint256 _requireStakeAmount) external onlyOwner {
        requireStakeAmount = _requireStakeAmount;
        emit SetRequireStakeAmount(_requireStakeAmount);
    }

    /**
     * @notice Set the reward distributor. Can only be called by the owner.
     * @param _rewardDistributor the reward distributor
     */
    function setRewardDistributor(address _rewardDistributor) external onlyOwner {
        require(_rewardDistributor != address(0), "NodeStakingPool: invalid reward distributor");
        rewardDistributor = _rewardDistributor;
        emit SetRewardDistributor(_rewardDistributor);
    }

    function setPoolInfor(
        uint256 _rewardPerBlock,
        uint256 _endBlock,
        uint256 _lockupDuration,
        uint256 _withdrawPeriod,
        address _rewardDistributor
    ) external onlyOwner {
        require(_endBlock > block.number, "NodeStakingPool: end block must be gt block.number");
        require(_lockupDuration > 0, "NodeStakingPool: lockupDuration must be gt 0");
        require(_withdrawPeriod > 0, "NodeStakingPool: withdrawPeriod must be gt 0");

        updatePool();

        rewardPerBlock = _rewardPerBlock;
        endBlockNumber = _endBlock;
        lockupDuration = _lockupDuration;
        withdrawPeriod = _withdrawPeriod;
        rewardDistributor = _rewardDistributor;

        emit SetPoolInfor(_rewardPerBlock, _endBlock, _lockupDuration, _withdrawPeriod, _rewardDistributor);
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external {
        updatePool();
        rewardPerBlock = _rewardPerBlock;

        emit SetRewardPerBlock(_rewardPerBlock);
    }

    /**
     * @notice Set the end block number. Can only be called by the owner.
     */
    function setEndBlock(uint256 _endBlockNumber) external onlyOwner {
        require(_endBlockNumber > block.number, "NodeStakingPool: invalid reward distributor");
        endBlockNumber = _endBlockNumber;
        emit SetEndBlock(_endBlockNumber);
    }

    /**
     * @notice Return time multiplier over the given _from to _to block.
     * @param _from the number of starting block
     * @param _to the number of ending block
     */
    function timeMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (endBlockNumber > 0 && _to > endBlockNumber) {
            return endBlockNumber > _from ? endBlockNumber - _from : 0;
        }
        return _to - _from;
    }

    /**
     * @notice View function to see pending rewards on frontend.
     * @param _user the address of the user
     */
    function pendingReward(address _user, uint256 _nodeId) public view returns (uint256) {
        NodeStakingUserInfo storage user = userInfo[_user][_nodeId];

        // TODO: reward debt = accRewardPerShare before
        uint256 _accRewardPerShare = accRewardPerShare;
        if (user.stakeTime > 0 && block.number > lastRewardBlock && totalRunningNode != 0) {
            uint256 multiplier = timeMultiplier(lastRewardBlock, block.number);
            uint256 poolReward = multiplier * rewardPerBlock;
            _accRewardPerShare = _accRewardPerShare + ((poolReward * ACCUMULATED_MULTIPLIER) / totalRunningNode);
        }
        return user.pendingReward + ((_accRewardPerShare / ACCUMULATED_MULTIPLIER) - user.rewardDebt);
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function updatePool() public {
        if (block.number <= lastRewardBlock) {
            return;
        }
        if (totalRunningNode == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = timeMultiplier(lastRewardBlock, block.number);
        uint256 poolReward = multiplier * rewardPerBlock;
        // TODO: stakeTokenSupply or count*requireAmount
        accRewardPerShare = (accRewardPerShare + ((poolReward * ACCUMULATED_MULTIPLIER) / (totalRunningNode)));
        lastRewardBlock = block.number;
    }

    /**
     * @notice Deposit LP tokens to the farm for reward allocation.
     */
    function deposit(uint256 nodeId) external {
        uint256 _amount = requireStakeAmount;

        uint256 index = userNodeCount[msg.sender]++;
        NodeStakingUserInfo storage user = userInfo[msg.sender][index];
        // if admin enable staking record, stakeTime will be update
        // user.stakeTime = block.number;
        user.amount = _amount;
        stakeTokenSupply = stakeTokenSupply + _amount;
        stakeToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        emit NodeStakingDeposit(msg.sender, _amount, index, nodeId);
    }

    // TODO: set pool
    function setPool() external {}

    function enableAddress(address _user, uint256 _nodeId) external onlyOwner {
        NodeStakingUserInfo storage user = userInfo[_user][_nodeId];

        require(user.stakeTime == 0, "NodeStakingPool: node already enabled");
        updatePool();

        user.stakeTime = block.number;
        userRunningNode[_user] = userRunningNode[_user] + 1;
        totalRunningNode = totalRunningNode + 1;

        emit NodeStakingEnableAddress(msg.sender, _nodeId);
    }

    function disableAddress(address _user, uint256 _nodeId) external onlyOwner {
        NodeStakingUserInfo storage user = userInfo[_user][_nodeId];

        require(user.stakeTime > 0, "NodeStakingPool: node already disabled");
        // require(isInWithdrawTime(user.stakeTime), "NodeStakingPool: not in withdraw time");
        updatePool();
        if (user.stakeTime > 0) {
            uint256 pending = ((accRewardPerShare) / ACCUMULATED_MULTIPLIER) - user.rewardDebt;

            if (pending > 0) {
                user.pendingReward = user.pendingReward + pending;
            }
        }
        user.stakeTime = 0;
        user.rewardDebt = (accRewardPerShare) / ACCUMULATED_MULTIPLIER;
        totalRunningNode = totalRunningNode - 1;
        userRunningNode[_user] = userRunningNode[_user] - 1;
    }

    /**
     * @notice Withdraw LP tokens from
     * @param _nodeId nodeId to withdraw
     * @param _harvestReward whether the user want to claim the rewards or not
     */
    function withdraw(uint256 _nodeId, bool _harvestReward) external {
        NodeStakingUserInfo storage user = userInfo[msg.sender][_nodeId];
        require(isInWithdrawTime(user.stakeTime), "NodeStakingPool: not in withdraw time");
        require(user.amount > 0, "NodeStakingPool: have not any token to withdraw");

        uint256 amount = user.amount;

        _withdraw(_nodeId, _harvestReward);

        stakeToken.safeTransfer(address(msg.sender), amount);
        emit NodeStakingWithdraw(msg.sender, amount);
    }

    /**
     * @notice Harvest proceeds msg.sender
     */
    function claimReward(uint256 _nodeId) public returns (uint256) {
        updatePool();
        NodeStakingUserInfo storage user = userInfo[msg.sender][_nodeId];
        uint256 multiplier = timeMultiplier(user.stakeTime, block.number);
        uint256 totalPending = pendingReward(msg.sender, _nodeId);

        user.pendingReward = 0;
        user.rewardDebt = (accRewardPerShare) / (ACCUMULATED_MULTIPLIER);

        uint256 lockReward = _getWithdrawPendingReward(_nodeId, multiplier, totalPending);
        if (totalPending > 0) {
            safeRewardTransfer(msg.sender, totalPending - lockReward);
        }

        // TODO: claim pending reward in withdraw time
        LockWithdrawReward storage record = pendingRewardInWithdrawPeriod[msg.sender][_nodeId];
        if (record.applicableAt > block.number) {
            safeRewardTransfer(msg.sender, record.reward);
            record.reward = 0;
        }

        if (lockReward > 0) {
            // TODO: next locking time
            record.applicableAt = getNextStartLockingTime(user.stakeTime);
            record.reward += lockReward;

            if (record.applicableAt <= block.number) {
                safeRewardTransfer(msg.sender, record.reward);
                record.reward = 0;
            }
        }
        emit NodeStakingRewardsHarvested(msg.sender, totalPending);
        return totalPending;
    }

    /**
     * @notice Withdraw LP tokens from
     * @param _nodeId nodeId to withdraw
     * @param _harvestReward whether the user want to claim the rewards or not
     */
    function _withdraw(uint256 _nodeId, bool _harvestReward) private {
        NodeStakingUserInfo storage user = userInfo[msg.sender][_nodeId];
        uint256 _amount = user.amount;
        // require(isInWithdrawTime(user.stakeTime), "NodeStakingPool: not in withdraw time");

        if (_harvestReward) {
            claimReward(_nodeId);
        } else {
            updatePool();
            // user have stake time = user deposited
            if (user.stakeTime > 0) {
                uint256 pending = ((accRewardPerShare) / ACCUMULATED_MULTIPLIER) - user.rewardDebt;
                if (pending > 0) {
                    user.pendingReward = user.pendingReward + pending;
                }
            }
        }
        user.amount = 0;
        user.stakeTime = 0;
        user.rewardDebt = (accRewardPerShare) / ACCUMULATED_MULTIPLIER;
        stakeTokenSupply = stakeTokenSupply - _amount;
    }

    function isInWithdrawTime(uint256 _startTime) public view returns (bool) {
        uint256 duration = block.number - _startTime;
        // tmp is the times that done lockupDuration
        uint256 tmp = duration / (lockupDuration + withdrawPeriod);
        uint256 currentTime = duration - tmp * (lockupDuration + withdrawPeriod);

        return currentTime >= lockupDuration;
    }

    function getNextStartLockingTime(uint256 _startTime) public view returns (uint256) {
        if (_startTime == 0) return block.number;
        uint256 duration = block.number - _startTime;
        // multiplier is the times that done lockupDuration
        uint256 multiplier = duration / (lockupDuration + withdrawPeriod);

        return _startTime + (multiplier + 1) * (lockupDuration + withdrawPeriod);
    }

    /**
     * @notice Safe reward transfer function, just in case if reward distributor dose not have enough reward tokens.
     * @param _to address of the receiver
     * @param _amount amount of the reward token
     */
    function safeRewardTransfer(address _to, uint256 _amount) internal {
        uint256 bal = rewardToken.balanceOf(rewardDistributor);

        require(_amount <= bal, "NodeStakingPool: not enough reward token");

        rewardToken.safeTransferFrom(rewardDistributor, _to, _amount);
    }

    // TODO: lượng reward trong withdraw period
    function _getWithdrawPendingReward(
        uint256 _nodeId,
        uint256 _totalStakeTime,
        uint256 _totalReward
    ) private returns (uint256) {
        NodeStakingUserInfo storage user = userInfo[msg.sender][_nodeId];
        require(user.stakeTime > 0, "NodeStakingPool: NodeStakingPool: node already disabled");

        bool isInWithdrawTime = isInWithdrawTime(user.stakeTime);
        if (!isInWithdrawTime) {
            return 0;
        }

        // get time in withdraw period
        uint256 nextLockingTime = getNextStartLockingTime(user.stakeTime);
        uint256 duration = withdrawPeriod - (nextLockingTime - block.number);
        require(_totalStakeTime > duration, "NodeStakingPool: haven't reward to claim");
        uint256 reward = (duration * _totalReward) / _totalStakeTime;

        return reward;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "./NodeStaking.sol";
import "./interfaces/IPool.sol";

contract NodeStakingPoolFactory is Initializable, OwnableUpgradeable, PausableUpgradeable {
    // Array of created Pools Address
    address[] public allPools;
    // Mapping from User token. From tokens to array of created Pools for token
    mapping(address => mapping(address => address[])) public getPools;
    event NodeStakingPoolCreated(
        address registedBy,
        string name,
        string symbol,
        address rewardToken,
        address stakeToken,
        address pool,
        uint256 poolId
    );

    function initialize() external initializer {
        __Ownable_init();
    }

    /**
     * @notice Pause contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Get the number of all created pools
     * @return Return number of created pools
     */
    function allPoolsLength() public view returns (uint256) {
        return allPools.length;
    }

    /**
     * @notice Get the created pools by token address
     * @dev User can retrieve their created pool by address of tokens
     * @param _creator Address of created pool user
     * @param _token Address of token want to query
     * @return Created NodeStakingPool Address
     */
    function getCreatedPoolsByToken(address _creator, address _token) public view returns (address[] memory) {
        return getPools[_creator][_token];
    }

    /**
     * @notice Retrieve number of pools created for specific token
     * @param _creator Address of created pool user
     * @param _token Address of token want to query
     * @return Return number of created pool
     */
    function getCreatedPoolsLengthByToken(address _creator, address _token) public view returns (uint256) {
        return getPools[_creator][_token].length;
    }

    /**
     * @notice Register NodeStakingPool for tokens
     * @dev To register, you MUST have an ERC20 token
     */
    function registerPool(
        string memory _name,
        string memory _symbol,
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _endBlock,
        address _stakeToken,
        uint256 _lockupDuration,
        uint256 _withdrawPeriod,
        address _rewardDistributor
    ) external whenNotPaused returns (address pool) {
        require(_stakeToken != address(0), "NodeStakingPoolFactory: not allow zero address");
        require(_rewardToken != address(0), "NodeStakingPoolFactory: not allow zero address");

        bytes memory bytecode = type(NodeStakingPool).creationCode;
        uint256 tokenIndex = getCreatedPoolsLengthByToken(msg.sender, _rewardToken);
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, _rewardToken, tokenIndex));
        assembly {
            pool := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IPool(pool).initialize(
            _name,
            _symbol,
            IERC20(_rewardToken),
            _rewardPerBlock,
            _startBlock,
            _endBlock,
            IERC20(_stakeToken),
            _lockupDuration,
            _withdrawPeriod,
            _rewardDistributor
        );
        getPools[msg.sender][_rewardToken].push(pool);
        allPools.push(pool);
        emit NodeStakingPoolCreated(msg.sender, _name, _symbol, _rewardToken, _stakeToken, pool, allPools.length - 1);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPool {
    function initialize(
        string memory _name,
        string memory _symbol,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _endBlock,
        IERC20 _stakeToken,
        uint256 _lockupDuration,
        uint256 _withdrawPeriod,
        address _rewardDistributor
    ) external;
}