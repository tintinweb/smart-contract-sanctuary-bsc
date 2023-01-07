// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

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
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
     * @dev Returns the number of values in the set. O(1).
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/ILaunchpadFactoryMasterV1.sol";
import "../interfaces/ILaunchpadBase.sol";

 abstract contract HMTLaunchpadFactoryBaseV1 is ReentrancyGuard,ILaunchpadFactoryMasterV1 {
    using Address for address payable;
    using SafeMath for uint256;
    address private _launchpadFactoryMasterOwner;
    // address private feeTo;
    // uint256 private _platformFee;
    uint256 private _presaleRaisedCurrencyFeeInPercent; // 5%
    uint256[2] private _presaleRaisedPlusSoldCurrencyFeeInPercent; // 2% raised ,2% sold Token
    address[] private  acceptedErc20TokenAddress;  // variable use to  accepted token to buy preSale Token
    mapping(address=>bool) private isAcceptedErc20TokenMap; // accepted ERC20 token Map

    modifier onlyOwner{
        require(msg.sender==_launchpadFactoryMasterOwner,"Ownable:Only FactoryMaster");
        _;
    }

    constructor(address owner){
        _presaleRaisedCurrencyFeeInPercent=500; // 5%
        _presaleRaisedPlusSoldCurrencyFeeInPercent = [200, 200]; // 2%,2%
        _launchpadFactoryMasterOwner=owner;

    }

    function getLaunchpadFactoryMasterOwner() public view override returns(address){
        return _launchpadFactoryMasterOwner;
    }

    // setter function to set ERC20 Token to Buy PreSale token
    function setAcceptedErc20Token(address _acceptedErc20TokenAddress) external onlyOwner {
      require(isAcceptedErc20TokenMap[_acceptedErc20TokenAddress] == false,"Added:ERC20");
      isAcceptedErc20TokenMap[_acceptedErc20TokenAddress] = true;
      acceptedErc20TokenAddress.push(_acceptedErc20TokenAddress);
    }
     
    // getter Function to get ERC20 Token List
    function getERC20TokenList() external view returns (address[] memory) {
        return acceptedErc20TokenAddress;
    }

    function  isAcceptedErc20Token(address _tokenAddress) external view override returns(bool){
        return isAcceptedErc20TokenMap[_tokenAddress];
    }


    function setPresaleRaisedCurrencyFeeInPercent(
        uint256 presaleRaisedCurrencyFeeInPercent
    ) external onlyOwner {
        require(presaleRaisedCurrencyFeeInPercent>=100 && presaleRaisedCurrencyFeeInPercent<=1000,"LaunchpadV1:Fee neither less than 1% nore more than 10%");
        _presaleRaisedCurrencyFeeInPercent = presaleRaisedCurrencyFeeInPercent;
    }


    // 100==1%
    function setPresaleRaisedPlusSoldCurrencyFeeInPercent(
        uint256 presaleRaisedFeeInPercent,
        uint256 presaleSoldFeeInPercent
    ) external onlyOwner {
        require(
            (presaleRaisedFeeInPercent >= 100 &&
                presaleRaisedFeeInPercent <= 1000) &&
                (presaleSoldFeeInPercent >=100 &&
                    presaleSoldFeeInPercent <= 1000),
            "LaunchpadV1:Fee neither less than 1% nore more than 10%"
        );
        _presaleRaisedPlusSoldCurrencyFeeInPercent[
            0
        ] = presaleRaisedFeeInPercent;
        _presaleRaisedPlusSoldCurrencyFeeInPercent[1] = presaleSoldFeeInPercent;
    }





    function getPresaleRaisedCurrencyFeeInPercent()
        public
        view override
        returns (uint256)
    {
        return _presaleRaisedCurrencyFeeInPercent;
    }

    // Recheck math during testing
    function getPresaleRaisedPlusSoldCurrencyFeeInPercent()
        public
        view
        override
        returns (uint256[2] memory)
    {
        return _presaleRaisedPlusSoldCurrencyFeeInPercent;
    }


        function getTotalTokenNeededForCreateLaunchpad(
        uint256 presaleRate,
        uint256 hardCap,
        uint256 listingRate,
        uint256 liquidtyPercentage,
        uint8 _feeOptions,
        uint8 _listingOptions
        ) public view override returns(uint256){
        if(_feeOptions==0){
            if(_listingOptions==0){
            uint256 totalRate=hardCap.mul(presaleRate);
            uint256 cutFeeRateByHardcap=hardCap.sub(hardCap.mul(_presaleRaisedCurrencyFeeInPercent).div(1e4));
            uint256 cutLiquidtyRateByCutFeeRateByHardcap=cutFeeRateByHardcap.mul(liquidtyPercentage.mul(1e2)).div(1e4);
            uint256 finalRate=totalRate.add(cutLiquidtyRateByCutFeeRateByHardcap.mul(listingRate));
            return finalRate.div(1e18);
            }else{
                return hardCap.mul(presaleRate).div(1e18);
            }

        }else{
            if(_listingOptions==0){
            uint256 totalRate=hardCap.mul(presaleRate);
            uint256 cutFeeRateByHardcapBNB=hardCap.sub(hardCap.mul(_presaleRaisedPlusSoldCurrencyFeeInPercent[0]).div(1e4));
            uint256 cutLiquidtyRateByCutFeeRateByHardcap=cutFeeRateByHardcapBNB.mul(liquidtyPercentage.mul(1e2)).div(1e4);
            uint256 finalRate=totalRate.add(totalRate.mul(_presaleRaisedPlusSoldCurrencyFeeInPercent[1]).div(1e4)).add(cutLiquidtyRateByCutFeeRateByHardcap.mul(listingRate));
            return finalRate.div(1e18);
            }else{
                uint256 totalRate=hardCap.mul(presaleRate);
                return (totalRate.add(totalRate.mul(_presaleRaisedPlusSoldCurrencyFeeInPercent[1]).div(1e4))).div(1e18);
            }
        }

    }
    // Recheck math during testing
    function getTotalTokenNeededForFairLaunchpad(
        uint256 totalSellingAmount,
        uint256 liquidtyPercentage,
        uint8 _feeOptions
        ) public view override returns(uint256){
        if(_feeOptions==0){
            uint256 cutLiquidtyRate=totalSellingAmount.mul(liquidtyPercentage.mul(1e2)).div(1e4);
            uint256 cutFeeRate=cutLiquidtyRate.mul(_presaleRaisedCurrencyFeeInPercent).div(1e4);
            uint256 finalRate=totalSellingAmount.add(cutLiquidtyRate.sub(cutFeeRate));
            return finalRate;


        }else{
            uint256 soldFeeRate=totalSellingAmount.add(totalSellingAmount.mul(_presaleRaisedPlusSoldCurrencyFeeInPercent[1]).div(1e4));
            uint256 cutLiquidtyRate=totalSellingAmount.mul(liquidtyPercentage.mul(1e2)).div(1e4);
            uint256 cutLiquidtyRateFeeFoRaised=cutLiquidtyRate.sub(cutLiquidtyRate.mul(_presaleRaisedPlusSoldCurrencyFeeInPercent[0]).div(1e4));
            uint256 finalRate=soldFeeRate.add(cutLiquidtyRateFeeFoRaised);
            return finalRate;
        }

    }

  
   function getTotalTokenNeededForSubscription(
        uint256 hardCap,
        uint256 subscriptionRate,
        uint256 listingRate,
        uint256 liquidtyPercentage,
        uint8 _feeOptions
        ) public view override  returns(uint256){
        if(_feeOptions==0){
            uint256 cutRate=hardCap.mul(1e18).div(subscriptionRate);
            uint256 cutLiquidtyRate=cutRate.mul(liquidtyPercentage.mul(1e2)).div(1e4);
            uint256 _listingRate=cutLiquidtyRate.mul(listingRate).div(1e18);
            uint256 cutFeeRate=_listingRate.sub(_listingRate.mul(_presaleRaisedCurrencyFeeInPercent).div(1e4));
            uint256 finalRate=hardCap.add(cutFeeRate);
            return finalRate;


        }else{
            uint256 totalRate=hardCap.add(hardCap.mul(_presaleRaisedPlusSoldCurrencyFeeInPercent[1]).div(1e4));
            uint256 cutRate=hardCap.mul(1e18).div(subscriptionRate);
            uint256 cutLiquidtyRate=cutRate.mul(liquidtyPercentage.mul(1e2)).div(1e4);
            uint256 _listingRate=cutLiquidtyRate.mul(listingRate).div(1e18);
            uint256 cutFeeRate=_listingRate.sub(_listingRate.mul(_presaleRaisedPlusSoldCurrencyFeeInPercent[0]).div(1e4));
            uint256 finalRate=totalRate.add(cutFeeRate);
            return finalRate;
        }

    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./HMTLaunchpadFactoryBaseV1.sol";
import "../interfaces/IERC20.sol";

contract HMTLaunchpadFactoryMasterV1 is HMTLaunchpadFactoryBaseV1 {
    using EnumerableSet for EnumerableSet.AddressSet;
    struct Launchpad{
        address presaleAddress;
        address presaleOwnerAddress;
        uint8 launchpadType;
        PresaleOwnerDetail presaleOwnerDetail;
    }

    struct PresaleOwnerDetail{
        bool isMintable;
        bool isAudit;
        bool isKyc;
        bool isInsured;
    }

    address private _feeTo;
    uint256 private _platformFee;
    uint256 private _emergencyWithdrawFeeInPercent;
    uint256 private _emergencyWithdrawTimeInMinutes;
    Launchpad[] private launchpadArray;
    EnumerableSet.AddressSet private launchpadFactories;
    mapping(address=>Launchpad[]) private presaleOwnerAddressToLaunchpadList;
    mapping(address => mapping(address => bool)) private presaleOwnerToPresaleToHasLaunchpad;
    mapping(address => bool) private isGenerated;
    constructor() HMTLaunchpadFactoryBaseV1(msg.sender) {
        _feeTo = msg.sender;
        _platformFee = 0.0001 ether;
        _emergencyWithdrawFeeInPercent=1000; // Emergency withdrawal takes user contribution (with 10% penalty) 1%=100
        _emergencyWithdrawTimeInMinutes=5; // Emergency withdrawal time in which they can withdrawal their contribution 
    }

    modifier onlyAllowedFactory() {
        require(
            launchpadFactories.contains(msg.sender),
            "Not a whitelisted factory"
        );
        _;
    }


    function setFeeTo(address feeReceivingAddress) external onlyOwner {
        _feeTo = feeReceivingAddress;
    }

    function getFeeTo() public view override returns(address){
        return _feeTo;
    }

    // Fee set
    function setPlatformFee(uint256 platformFee) external onlyOwner {
        _platformFee = platformFee;
    }
    function setEmergencyWithdrawTimeInMinutes(uint256 emergencyWithdrawTimeInMinutes) external onlyOwner {
        _emergencyWithdrawTimeInMinutes = emergencyWithdrawTimeInMinutes;
    }

    function setEmergencyWithdrawFeeInPercent(uint256 emergencyWithdrawFeeInPercent) external onlyOwner {
        require(emergencyWithdrawFeeInPercent>=100,"1% minimum");
        _emergencyWithdrawFeeInPercent = emergencyWithdrawFeeInPercent;
    }

    function addLaunchpadFactory(address factory) public onlyOwner {
        launchpadFactories.add(factory);
    }

    // Fee get
    function getPlatformFee() public view override returns (uint256) {
        return _platformFee;
    }

    function getEmergencyWithdrawFeeInPercent() public view override returns(uint256){
        return _emergencyWithdrawFeeInPercent;
    }

    function getEmergencyWithdrawTimeInMinutes() public view override returns(uint256){
        return _emergencyWithdrawTimeInMinutes;
    }

    function addLaunchpadFactories(address[] memory factories) external onlyOwner {
        unchecked {
            for (uint256 i = 0; i < factories.length; i++) {
                addLaunchpadFactory(factories[i]);
            }
        }
    }

    function removeLaunchpadFactoryFactory(address factory) external onlyOwner {
        launchpadFactories.remove(factory);
    }

    function getAllAllowedFactories() public view returns (address[] memory) {
        address[] memory factories = new address[](launchpadFactories.length());
        unchecked {
            for (uint256 i = 0; i < launchpadFactories.length(); ++i) {
                factories[i] = launchpadFactories.at(i);
            }
        }
        return factories;
    }

    function isLaunchpadGenerated(address presaleAddress) external view returns (bool) {
        return isGenerated[presaleAddress];
    }

    function setLaunchpadDetail(address owner,address presaleAddress,uint8 launchpadType) public override  {
        require(!presaleOwnerToPresaleToHasLaunchpad[owner][presaleAddress],"Presale already exists");
        presaleOwnerAddressToLaunchpadList[owner].push(Launchpad(presaleAddress,owner,launchpadType,PresaleOwnerDetail(false,false,false,false)));
        launchpadArray.push(Launchpad(presaleAddress,owner,launchpadType,PresaleOwnerDetail(false,false,false,false)));
        presaleOwnerToPresaleToHasLaunchpad[owner][presaleAddress]=true;
        isGenerated[presaleAddress]=true;
    }

    function setPresaleOwnerDetail(
        address _presaleOwnerAddress,
        PresaleOwnerDetail memory _presaleOwnerDetail
        ) external onlyOwner  {
        unchecked{        
            for(uint256 i=0;i<launchpadArray.length;++i){
                if(launchpadArray[i].presaleOwnerAddress==_presaleOwnerAddress){
                    launchpadArray[i].presaleOwnerDetail=_presaleOwnerDetail;
                }
            }
        }
        unchecked{        
            for(uint256 i=0;i<presaleOwnerAddressToLaunchpadList[_presaleOwnerAddress].length;++i){
                if(presaleOwnerAddressToLaunchpadList[_presaleOwnerAddress][i].presaleOwnerAddress==_presaleOwnerAddress){
                     presaleOwnerAddressToLaunchpadList[_presaleOwnerAddress][i].presaleOwnerDetail=_presaleOwnerDetail;
                }
            }
        }

    }

    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferAnyERC20Tokens(address _presaleAddress,address _tokenAddress, address _to, uint _amount) external onlyOwner  {  
        ILaunchpadBase(_presaleAddress).transferAnyERC20Tokens(_tokenAddress,_to,_amount);
    }


    function getTotalLaunchpadCount() external view returns(uint256){
        return launchpadArray.length;
    }

    function getAllLaunchpad() public view  returns(Launchpad[] memory){
        return launchpadArray;
    }


    function getLaunchpadByOwnerAddressAndIndex(address owner, uint256 index)
        external
        view
        returns (Launchpad memory)
        {
        return presaleOwnerAddressToLaunchpadList[owner][index];
   
    }

    function getAllLaunchpadByOwner(address owner)
        external
        view
        returns (Launchpad[] memory)
       {

        return presaleOwnerAddressToLaunchpadList[owner];
    }

    function getLaunchpadByOwnerAndType(address owner, uint8 launchpadType)
        external
        view
        returns (Launchpad[] memory)
        {
        uint256 launchpadCount=0;
        uint256 currentIndex = 0;
        unchecked {
            for (
                uint256 i = 0;
                i < presaleOwnerAddressToLaunchpadList[owner].length;
                ++i
            ) {
                if (
                    presaleOwnerAddressToLaunchpadList[owner][i].launchpadType ==
                    launchpadType
                ) {
                    launchpadCount++;
                }
            }
        }
        Launchpad[] memory launchpad = new Launchpad[](launchpadCount);
        if (launchpadCount == 0) {
            return launchpad;
        }
        unchecked {
            for (
                uint256 i = 0;
                i < presaleOwnerAddressToLaunchpadList[owner].length;
                ++i
            ) {
                if (
                    presaleOwnerAddressToLaunchpadList[owner][i].launchpadType ==
                    launchpadType
                ) {
                    launchpad[
                        currentIndex
                    ] = presaleOwnerAddressToLaunchpadList[owner][i];
                    currentIndex++;
                }
            }
        }
        return launchpad;
    }

    function getAllLaunchpadsByType(uint8 launchpadType) external view returns ( Launchpad[] memory){
        uint256 launchpadCount=0;
        uint256 currentIndex = 0;
        unchecked {
            for (
                uint256 i = 0;
                i < launchpadArray.length;
                ++i
            ) {
                if(launchpadArray[i].launchpadType==launchpadType){
                    launchpadCount++;
                }
            }
        }
        Launchpad[] memory launchpad = new Launchpad[](launchpadCount);
        unchecked {
            for (
                uint256 i = 0;
                i < launchpadArray.length;
                ++i
            ) {
                if(launchpadArray[i].launchpadType==launchpadType){
                    launchpad[currentIndex] = launchpadArray[i];
                    currentIndex++;
                }
            }
        }
        return launchpad;
    }


    // TokenInfo
    function getTokenInfo(address _token) external view  returns(string memory,string memory,uint256,uint256) {
        return (IERC20(_token).name(),IERC20(_token).symbol(),IERC20(_token).decimals(),IERC20(_token).totalSupply());
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface ILaunchpadFactoryMasterV1{
   function setLaunchpadDetail(address owner,address presaleAddress,uint8 launchpadType) external;
   function getPresaleRaisedCurrencyFeeInPercent() external view returns(uint256);
   function getPresaleRaisedPlusSoldCurrencyFeeInPercent() external view returns(uint256[2] memory);
   function getPlatformFee() external view returns(uint256);
   function getEmergencyWithdrawFeeInPercent() external view returns(uint256);
   function getEmergencyWithdrawTimeInMinutes() external view returns(uint256);
   function getFeeTo() external view returns(address);
   function isAcceptedErc20Token(address _tokenAddress) external view  returns(bool);
   function getLaunchpadFactoryMasterOwner() external view  returns(address);
   function getTotalTokenNeededForFairLaunchpad(
        uint256 totalSellingAmount,
        uint256 liquidtyPercentage,
        uint8 _feeOptions
    ) external view  returns(uint256);
    function getTotalTokenNeededForCreateLaunchpad(
        uint256 presaleRate,
        uint256 hardCap,
        uint256 listingRate,
        uint256 liquidtyPercentage,
        uint8 _feeOptions,
        uint8 _listingOptions
    ) external view  returns(uint256);
    function getTotalTokenNeededForSubscription(
        uint256 hardCap,
        uint256 subscriptionRate,
        uint256 listingRate,
        uint256 liquidtyPercentage,
        uint8 _feeOptions
    ) external view  returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address) view external  returns (uint256);
    function transfer(address, uint256) external  returns (bool);
    function transferFrom(address, address, uint256) external  returns (bool);
    function approve(address, uint256) external  returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function symbol() view external  returns (string calldata);
    function name() view external  returns (string calldata);
    function decimals() view external  returns (uint256);
    function totalSupply() view external  returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface ILaunchpadBase{
    event CreatedPresale(
        address indexed owner,
        address indexed presaleAddress,
        LaunchpadType indexed launchpadType,
        uint256 createdTime
    );
    // State variables
    enum LaunchpadType{
        CreateLaunchpad,
        CreateFairLaunchpad,
        CreateDutchAuction,
        CreateSubscription
    }

       
    enum Status {
        Upcoming,
        Live,
        Ended,
        Cancelled
    }

    enum FeeOptions {
        RaisedCurrency,
        RaisedPlusSoldCurrency
    }

    enum PaymentOptions {
        NativeCoin,
        ERC20Token
    }
    function transferAnyERC20Tokens(address _tokenAddress, address _to, uint _amount) external;
    function _onlyPresaleOwner(address _presaleAddress) external  view  returns(bool);
    function _presaleLiveOrUpcoming(address _presaleAddress) external  view returns(bool);
}