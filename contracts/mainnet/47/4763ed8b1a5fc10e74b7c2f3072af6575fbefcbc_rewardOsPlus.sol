/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

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

        (bool success,) = recipient.call{value : amount}("");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value : value}(data);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

// interface IERC20 {
//     /**
//      * @dev Emitted when `value` tokens are moved from one account (`from`) to
//      * another (`to`).
//      *
//      * Note that `value` may be zero.
//      */
//     event Transfer(address indexed from, address indexed to, uint256 value);

//     /**
//      * @dev Emitted when the allowance of a `spender` for an `owner` is set by
//      * a call to {approve}. `value` is the new allowance.
//      */
//     event Approval(address indexed owner, address indexed spender, uint256 value);

//     /**
//      * @dev Returns the amount of tokens in existence.
//      */
//     function totalSupply() external view returns (uint256);

//     /**
//      * @dev Returns the amount of tokens owned by `account`.
//      */
//     function balanceOf(address account) external view returns (uint256);

//     /**
//      * @dev Moves `amount` tokens from the caller's account to `to`.
//      *
//      * Returns a boolean value indicating whether the operation succeeded.
//      *
//      * Emits a {Transfer} event.
//      */
//     function transfer(address to, uint256 amount) external returns (bool);

//     /**
//      * @dev Returns the remaining number of tokens that `spender` will be
//      * allowed to spend on behalf of `owner` through {transferFrom}. This is
//      * zero by default.
//      *
//      * This value changes when {approve} or {transferFrom} are called.
//      */
//     function allowance(address owner, address spender) external view returns (uint256);

//     /**
//      * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
//      *
//      * Returns a boolean value indicating whether the operation succeeded.
//      *
//      * IMPORTANT: Beware that changing an allowance with this method brings the risk
//      * that someone may use both the old and the new allowance by unfortunate
//      * transaction ordering. One possible solution to mitigate this race
//      * condition is to first reduce the spender's allowance to 0 and set the
//      * desired value afterwards:
//      * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
//      *
//      * Emits an {Approval} event.
//      */
//     function approve(address spender, uint256 amount) external returns (bool);

//     /**
//      * @dev Moves `amount` tokens from `from` to `to` using the
//      * allowance mechanism. `amount` is then deducted from the caller's
//      * allowance.
//      *
//      * Returns a boolean value indicating whether the operation succeeded.
//      *
//      * Emits a {Transfer} event.
//      */
//     function transferFrom(
//         address from,
//         address to,
//         uint256 amount
//     ) external returns (bool);
// }

contract rewardOsPlus is Ownable {
    using Address for address;
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => rewardItem) public userRewardList;
    mapping(address => mapping(address => rewardItem)) public userRewardPerCustomerList;
    mapping(address => bool) public whiteList;
    mapping(address => address) public refererAddressList;
    mapping(address => uint256) public refererTimeList;
    mapping(address => string) public whiteListType;
    mapping(address => EnumerableSet.AddressSet) private customerAddressList;
    uint256 public refererRate = 80;
    uint256 public userRate = 20;
    rewardItemStatusItem public rewardItemStatusList;
    mapping(address => rewardInfoItem[]) public rewardNum1List;
    mapping(address => rewardInfoItem[]) public rewardNum2List;
    mapping(address => rewardInfoItem[]) public rewardNum3List;
    mapping(address => rewardInfoItem[]) public rewardNum4List;
    mapping(address => rewardInfoItem[]) public rewardNum5List;
    mapping(address => rewardInfoItem[]) public rewardNum6List;

    struct rewardInfoItem {
        uint256 _time;
        address _user;
        address _referer;
        uint256 _rewardAmount;
    }

    struct rewardItemStatusItem {
        bool rewardNum1Status; //swapReward
        bool rewardNum2Status; //p2pmarketReward
        bool rewardNum3Status; //lanchpadReward
        bool rewardNum4Status; //stkaingReward
        bool rewardNum5Status; //nftmarketReward
        bool rewardNum6Status;
    }

    struct rewardItemForRefererItem {
        uint256 rewardNum1; //swapReward
        uint256 rewardNum2; //p2pmarketReward
        uint256 rewardNum3; //lanchpadReward
        uint256 rewardNum4; //stkaingReward
        uint256 rewardNum5; //nftmarketReward
        uint256 rewardNum6;
    }

    struct rewardItemForUserItem {
        uint256 rewardNum1; //swapReward
        uint256 rewardNum2; //p2pmarketReward
        uint256 rewardNum3; //lanchpadReward
        uint256 rewardNum4; //stkaingReward
        uint256 rewardNum5; //nftmarketReward
        uint256 rewardNum6;
    }

    struct rewardItem {
        rewardItemForRefererItem rewardItemForReferer;
        rewardItemForUserItem rewardItemForUser;
    }

    modifier onlyWhiteList() {
        require(whiteList[_msgSender()], "k001");
        _;
    }

    event addRewardListEvent(address _contractAddress, address _user, address _referer, uint256 _rewardAmount, uint256 _time, string _type, string _whiteListType);

    constructor ()  {
        rewardItemStatusList = rewardItemStatusItem(true, true, true, true, true, true);
        refererAddressList[deadAddress] = msg.sender;
    }

    function setRewardItemStatusList(bool _rewardNum1Status, bool _rewardNum2Status, bool _rewardNum3Status, bool _rewardNum4Status, bool _rewardNum5Status, bool _rewardNum6Status
    ) external onlyOwner {
        rewardItemStatusList.rewardNum1Status = _rewardNum1Status;
        rewardItemStatusList.rewardNum2Status = _rewardNum2Status;
        rewardItemStatusList.rewardNum3Status = _rewardNum3Status;
        rewardItemStatusList.rewardNum4Status = _rewardNum4Status;
        rewardItemStatusList.rewardNum5Status = _rewardNum5Status;
        rewardItemStatusList.rewardNum6Status = _rewardNum6Status;
    }

    function addWhiteList(address[] memory _list, string[] memory _typeList) external onlyOwner {
        for (uint256 i = 0; i < _list.length; i++) {
            //require(_list[i].isContract(), "e001");
            whiteList[_list[i]] = true;
            whiteListType[_list[i]] = _typeList[i];
        }
    }

    function removeWhiteList(address[] memory _list) external onlyOwner {
        for (uint256 i = 0; i < _list.length; i++) {
            //require(_list[i].isContract(), "e001");
            whiteList[_list[i]] = false;
        }
    }
    
    function blindReferer(address _referer) external {
        require(!_referer.isContract(), "k001");
        require(_referer != address(0), "k002");
        require(refererAddressList[_referer] != address(0),"ke003");
        require(refererAddressList[msg.sender] == address(0), "k004");
        require(!customerAddressList[msg.sender].contains(_referer), "k005");
        refererAddressList[msg.sender] = _referer;
        customerAddressList[_referer].add(msg.sender);
        refererTimeList[msg.sender] = block.timestamp;
    }

    function setRewardRate(uint256 _refererRate, uint256 _userRate) external onlyOwner {
        refererRate = _refererRate;
        userRate = _userRate;
    }

    function addRewardList(address _user, uint256 _rewardAmount, uint256 _type) external onlyWhiteList {
        //require(msg.sender.isContract(), "e001");
        uint256 rewardItemForRefererAmount;
        uint256 rewardItemForUserAmount;
        address _referer = refererAddressList[_user];
        if (_referer == address(0)) {
            rewardItemForRefererAmount = _rewardAmount;
            rewardItemForUserAmount = 0;
        } else {
            rewardItemForRefererAmount = _rewardAmount.mul(refererRate).div(100);
            rewardItemForUserAmount = _rewardAmount.sub(rewardItemForRefererAmount);
        }
        if (_type == 1) {
            userRewardList[_referer].rewardItemForReferer.rewardNum1 = userRewardList[_referer].rewardItemForReferer.rewardNum1.add(rewardItemForRefererAmount);
            userRewardList[_user].rewardItemForUser.rewardNum1 = userRewardList[_user].rewardItemForUser.rewardNum1.add(rewardItemForUserAmount);
            userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum1 = userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum1.add(rewardItemForRefererAmount);
            if (rewardItemStatusList.rewardNum1Status) {
                rewardNum1List[_referer].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForRefererAmount));
                rewardNum1List[_user].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForUserAmount));
            }
        } else if (_type == 2) {
            userRewardList[_referer].rewardItemForReferer.rewardNum2 = userRewardList[_referer].rewardItemForReferer.rewardNum2.add(rewardItemForRefererAmount);
            userRewardList[_user].rewardItemForUser.rewardNum2 = userRewardList[_user].rewardItemForUser.rewardNum2.add(rewardItemForUserAmount);
            userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum2 = userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum2.add(rewardItemForRefererAmount);
            if (rewardItemStatusList.rewardNum2Status) {
                rewardNum2List[_referer].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForRefererAmount));
                rewardNum2List[_user].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForUserAmount));
            }
        } else if (_type == 3) {
            userRewardList[_referer].rewardItemForReferer.rewardNum3 = userRewardList[_referer].rewardItemForReferer.rewardNum3.add(rewardItemForRefererAmount);
            userRewardList[_user].rewardItemForUser.rewardNum3 = userRewardList[_user].rewardItemForUser.rewardNum3.add(rewardItemForUserAmount);
            userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum3 = userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum3.add(rewardItemForRefererAmount);
            if (rewardItemStatusList.rewardNum3Status) {
                rewardNum3List[_referer].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForRefererAmount));
                rewardNum3List[_user].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForUserAmount));
            }
        } else if (_type == 4) {
            userRewardList[_referer].rewardItemForReferer.rewardNum4 = userRewardList[_referer].rewardItemForReferer.rewardNum4.add(rewardItemForRefererAmount);
            userRewardList[_user].rewardItemForUser.rewardNum4 = userRewardList[_user].rewardItemForUser.rewardNum4.add(rewardItemForUserAmount);
            userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum4 = userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum4.add(rewardItemForRefererAmount);
            if (rewardItemStatusList.rewardNum4Status) {
                rewardNum4List[_referer].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForRefererAmount));
                rewardNum4List[_user].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForUserAmount));
            }
        } else if (_type == 5) {
            userRewardList[_referer].rewardItemForReferer.rewardNum5 = userRewardList[_referer].rewardItemForReferer.rewardNum5.add(rewardItemForRefererAmount);
            userRewardList[_user].rewardItemForUser.rewardNum5 = userRewardList[_user].rewardItemForUser.rewardNum5.add(rewardItemForUserAmount);
            userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum5 = userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum5.add(rewardItemForRefererAmount);
            if (rewardItemStatusList.rewardNum5Status) {
                rewardNum5List[_referer].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForRefererAmount));
                rewardNum5List[_user].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForUserAmount));
            }
        } else if (_type == 6) {
            userRewardList[_referer].rewardItemForReferer.rewardNum6 = userRewardList[_referer].rewardItemForReferer.rewardNum6.add(rewardItemForRefererAmount);
            userRewardList[_user].rewardItemForUser.rewardNum6 = userRewardList[_user].rewardItemForUser.rewardNum6.add(rewardItemForUserAmount);
            userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum6 = userRewardPerCustomerList[_referer][_user].rewardItemForReferer.rewardNum6.add(rewardItemForRefererAmount);
            if (rewardItemStatusList.rewardNum6Status) {
                rewardNum6List[_referer].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForRefererAmount));
                rewardNum6List[_user].push(rewardInfoItem(block.timestamp, _user, _referer, rewardItemForUserAmount));
            }
        }
        emit addRewardListEvent(msg.sender, _user, _referer, rewardItemForRefererAmount, block.timestamp, "rewardItemForReferer", whiteListType[msg.sender]);
        if (rewardItemForUserAmount > 0) {
            emit addRewardListEvent(msg.sender, _user, _referer, rewardItemForUserAmount, block.timestamp, "rewardItemForUser", whiteListType[msg.sender]);
        }
    }

    function getCustomerAddressList(address _user) public view returns (address[] memory CustomerList, uint256 Num) {
        CustomerList = customerAddressList[_user].values();
        Num = customerAddressList[_user].length();
    }

    function getCustomerAddressListByIndexList(address _user, uint256[] memory _indexList) public view returns (address[] memory CustomerList, uint256 Num) {
        Num = _indexList.length;
        CustomerList = new address[](Num);
        for (uint256 i = 0; i < Num; i++) {
            CustomerList[i] = customerAddressList[_user].at(_indexList[i]);
        }
    }

    function getRewardList(address _user) external view returns (rewardItem[] memory RewardList, uint256[] memory _refererTimeList) {
        (address[] memory CustomerList, uint256 Num) = getCustomerAddressList(_user);
        RewardList = new rewardItem[](Num);
        _refererTimeList = new uint256[](Num);
        for (uint256 i = 0; i < Num; i++) {
            RewardList[i] = userRewardPerCustomerList[_user][CustomerList[i]];
            _refererTimeList[i] = refererTimeList[CustomerList[i]];
        }
    }

    function getRewardListByIndexList(address _user, uint256[] memory _indexList) external view returns (rewardItem[] memory RewardList, uint256[] memory _refererTimeList) {
        (address[] memory CustomerList, uint256 Num) = getCustomerAddressListByIndexList(_user, _indexList);
        RewardList = new rewardItem[](Num);
        _refererTimeList = new uint256[](Num);
        for (uint256 i = 0; i < Num; i++) {
            RewardList[i] = userRewardPerCustomerList[_user][CustomerList[i]];
            _refererTimeList[i] = refererTimeList[CustomerList[i]];
        }
    }
}