/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

pragma solidity ^0.8.15;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

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

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function approve(address spender, uint256 amount) external returns (bool);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "e0");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "e1");
        }
    }
}


// abstract contract ReentrancyGuard {
//     uint256 private constant _NOT_ENTERED = 1;
//     uint256 private constant _ENTERED = 2;
//     uint256 private _status;

//     constructor() internal {
//         _status = _NOT_ENTERED;
//     }

//     modifier nonReentrant() {
//         require(_status != _ENTERED, "e0");
//         _status = _ENTERED;
//         _;
//         _status = _NOT_ENTERED;
//     }
// }

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


interface IERC721Enumerable {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}


interface swapRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
}

interface rewardOsPlus {
    function refererAddressList(address _user) external view returns (address);

    function addRewardList(address _user, uint256 _rewardAmount, uint256 _type) external;

    function refererRate() external view returns (uint256);

    function userRate() external view returns (uint256);
}


contract nftOrderPool is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    address payable public devAddress;
    IERC20 public ETH;
    uint256 public orderNum = 0;
    uint256 public swapFee = 5;
    mapping(address => bool) public erc20tokenWhiteList;
    mapping(IERC721Enumerable => bool) public erc721tokenWhiteList;

    EnumerableSet.UintSet private okOrderList;
    mapping(IERC721Enumerable => EnumerableSet.UintSet) private nftOkOrderList;
    mapping(address => EnumerableSet.UintSet) private userOkOrderList;

    bool public useRewardOsPlus = false;
    rewardOsPlus public rewardOsPlusAddress;
    swapItem public swapConfig;

    struct swapItem {
        swapRouter routerAddress;
        swapRouter routerAddress2;
        IERC20 rewardToken;
        address[] swapErc20Path;
        address[] swapEthPath;
    }


    struct orderItem {
        uint256 orderId;
        address payable owner;
        IERC721Enumerable nftToken;
        uint256 tokenId;
        address erc20Token;
        uint256 price;
        bool orderStatus;
        string orderMd5;
        uint256 time;
        uint256 blocokNum;
        string name;
        string symbol;
        string tokenURI;
    }

    struct massInfoItem {
        orderItem orderItem2;
        string name2;
        string symbol2;
        uint256 decimals2;
        uint256 price2;
        string tokenURI2;
    }

    mapping(uint256 => orderItem) public orderItemInfo;
    mapping(IERC721Enumerable => uint256[]) public nftAddressOrderList;
    mapping(uint256 => bool) public orderStatusList;
    mapping(address => uint256[]) public userOrderList;
    mapping(string => bool) public orderMd5StatusList;
    mapping(string => uint256) public orderMd5List;
    mapping(IERC721Enumerable => mapping(uint256 => uint256)) public nftTokenLastOrderIdList;

    event createNftOrderEvent(uint256 orderId, address owner, IERC721Enumerable nftToken, uint256 tokenId, address erc20Token, uint256 price, bool orderStatus, string orderMd5, uint256 time, uint256 blocokNum);
    event widthDrawEvent(uint256 _orderId, address owner, IERC721Enumerable nftToken, uint256 tokenId);
    event swapEvent(uint256 _orderId, IERC721Enumerable nftToken, uint256 tokenId, address erc20Token, address owner, address buyer, uint256 price, uint256 fee, uint256 toUser);

    constructor()  {
        devAddress = payable(msg.sender);
    }

    function setSwapConfig(swapRouter _routerAddress, swapRouter _routerAddress2, IERC20 _rewardToken, address[]  memory _swapErc20Path, address[]  memory _swapEthPath) external onlyOwner {
        swapConfig = swapItem(_routerAddress, _routerAddress2, _rewardToken, _swapErc20Path, _swapEthPath);
    }

    function setEth(IERC20 _ETH) external onlyOwner {
        ETH = _ETH;
    }

    function setRewardOsPlus(bool _useRewardOsPlus, rewardOsPlus _rewardOsPlusAddress) external onlyOwner {
        useRewardOsPlus = _useRewardOsPlus;
        rewardOsPlusAddress = _rewardOsPlusAddress;
    }

    function setDevAddress(address payable _devAddress) external onlyOwner {
        devAddress = _devAddress;
    }

    function setSwapFee(uint256 _fee) public onlyOwner {
        swapFee = _fee;
    }

    function setErc20WhiteList(address[] memory _addressList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _addressList.length; i++) {
            erc20tokenWhiteList[_addressList[i]] = _status;
        }
    }

    function setErc721WhiteList(IERC721Enumerable[] memory _addressList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _addressList.length; i++) {
            erc721tokenWhiteList[_addressList[i]] = _status;
        }
    }

    function getTokenIdSaleStatus(IERC721Enumerable _nftToken, uint256 _tokenId) public view returns (bool, uint256, massInfoItem memory) {
        if (nftTokenLastOrderIdList[_nftToken][_tokenId] > 0) {
            (orderItem memory orderItem2, string memory name2, string memory symbol2, uint256 decimals2, uint256 price2,string memory tokenURI2) = getTokenInfoByIndex(nftTokenLastOrderIdList[_nftToken][_tokenId]);
            return (orderItemInfo[nftTokenLastOrderIdList[_nftToken][_tokenId]].orderStatus, nftTokenLastOrderIdList[_nftToken][_tokenId], massInfoItem(orderItem2, name2, symbol2, decimals2, price2, tokenURI2));
        } else {
            (orderItem memory orderItem2, string memory name2, string memory symbol2, uint256 decimals2, uint256 price2,string memory tokenURI2) = getTokenInfoByIndex(0);
            if (orderItemInfo[nftTokenLastOrderIdList[_nftToken][_tokenId]].nftToken == _nftToken && orderItemInfo[nftTokenLastOrderIdList[_nftToken][_tokenId]].tokenId == _tokenId) {
                return (orderItemInfo[nftTokenLastOrderIdList[_nftToken][_tokenId]].orderStatus, nftTokenLastOrderIdList[_nftToken][_tokenId], massInfoItem(orderItem2, name2, symbol2, decimals2, price2, tokenURI2));
            } else {
                return (false, 0, massInfoItem(orderItem2, name2, symbol2, decimals2, price2, tokenURI2));
            }
        }
    }

    function createNftOrder(IERC721Enumerable _nftToken, uint256 _tokenId, address _erc20Token, uint256 _price, string memory _orderMd5, uint256 _time) public nonReentrant {
        require(erc20tokenWhiteList[_erc20Token], "e001");
        require(orderMd5StatusList[_orderMd5] == false, "e002");
        require(erc721tokenWhiteList[_nftToken], "e003");
        _nftToken.transferFrom(msg.sender, address(this), _tokenId);
        orderItemInfo[orderNum] = orderItem(orderNum, payable(msg.sender), _nftToken, _tokenId, _erc20Token, _price, true, _orderMd5, _time, block.number, _nftToken.name(), _nftToken.symbol(), _nftToken.tokenURI(_tokenId));
        emit createNftOrderEvent(orderNum, msg.sender, _nftToken, _tokenId, _erc20Token, _price, true, _orderMd5, _time, block.number);
        nftAddressOrderList[_nftToken].push(orderNum);
        orderStatusList[orderNum] = true;
        orderMd5List[_orderMd5] = orderNum;
        userOrderList[msg.sender].push(orderNum);
        nftTokenLastOrderIdList[_nftToken][_tokenId] = orderNum;

        okOrderList.add(orderNum);
        nftOkOrderList[_nftToken].add(orderNum);
        userOkOrderList[msg.sender].add(orderNum);

        orderNum = orderNum.add(1);
        orderMd5StatusList[_orderMd5] = true;
    }

    function createNftOrderWithEth(IERC721Enumerable _nftToken, uint256 _tokenId, uint256 _price, string memory _orderMd5, uint256 _time) public nonReentrant {
        require(orderMd5StatusList[_orderMd5] == false, "e001");
        require(erc721tokenWhiteList[_nftToken], "e002");
        _nftToken.transferFrom(msg.sender, address(this), _tokenId);
        orderItemInfo[orderNum] = orderItem(orderNum, payable(msg.sender), _nftToken, _tokenId, address(0), _price, true, _orderMd5, _time, block.number, _nftToken.name(), _nftToken.symbol(), _nftToken.tokenURI(_tokenId));
        emit createNftOrderEvent(orderNum, msg.sender, _nftToken, _tokenId, address(0), _price, true, _orderMd5, _time, block.number);
        nftAddressOrderList[_nftToken].push(orderNum);
        orderStatusList[orderNum] = true;
        orderMd5List[_orderMd5] = orderNum;
        userOrderList[msg.sender].push(orderNum);
        nftTokenLastOrderIdList[_nftToken][_tokenId] = orderNum;

        okOrderList.add(orderNum);
        nftOkOrderList[_nftToken].add(orderNum);
        userOkOrderList[msg.sender].add(orderNum);

        orderNum = orderNum.add(1);
        orderMd5StatusList[_orderMd5] = true;
    }

    function widthDraw(uint256 _orderId) public nonReentrant {
        require(orderStatusList[_orderId] == true, "e001");
        require(orderItemInfo[_orderId].owner == msg.sender, "e002");
        orderItemInfo[_orderId].nftToken.transferFrom(address(this), msg.sender, orderItemInfo[_orderId].tokenId);
        orderItemInfo[_orderId].orderStatus = false;
        orderStatusList[_orderId] = false;

        okOrderList.remove(_orderId);
        nftOkOrderList[orderItemInfo[_orderId].nftToken].remove(_orderId);
        userOkOrderList[msg.sender].remove(_orderId);

        emit widthDrawEvent(_orderId, msg.sender, orderItemInfo[_orderId].nftToken, orderItemInfo[_orderId].tokenId);
    }
    
    function setApprovedForSwapAndFarm(uint256 _amount) external onlyOwner {
        require(address(swapConfig.routerAddress2) != address(0));
        IERC20(swapConfig.swapErc20Path[0]).approve(address(swapConfig.routerAddress2), _amount);
    }

    function swap(uint256 _orderId) public nonReentrant {
        require(orderStatusList[_orderId] == true, "e001");
        //orderItem memory _orderItem = orderItemInfo[_orderId];
        require(IERC20(orderItemInfo[_orderId].erc20Token).balanceOf(msg.sender) >= orderItemInfo[_orderId].price, "e002");
        uint256 fee = orderItemInfo[_orderId].price.mul(swapFee).div(100);
        uint256 toUser = orderItemInfo[_orderId].price.sub(fee);
        IERC20(orderItemInfo[_orderId].erc20Token).safeTransferFrom(msg.sender, orderItemInfo[_orderId].owner, toUser);


        if (useRewardOsPlus) {
            uint256 devFee = fee.mul(50).div(100);
            uint256 rewardAmount = fee.sub(devFee);
            IERC20(orderItemInfo[_orderId].erc20Token).safeTransferFrom(msg.sender, devAddress, devFee);
            IERC20(orderItemInfo[_orderId].erc20Token).safeTransferFrom(msg.sender, address(this), rewardAmount);
            IERC20(orderItemInfo[_orderId].erc20Token).approve(address(swapConfig.routerAddress), rewardAmount);
             (uint256[] memory amounts2) = swapConfig.routerAddress2.swapExactTokensForTokens(
                rewardAmount,
                0,
                swapConfig.swapErc20Path,
                address(this),
                block.timestamp
            );
            rewardAmount = amounts2[1];
            {
                address referer = rewardOsPlusAddress.refererAddressList(msg.sender);
                if (referer == address(0)) {
                    swapConfig.rewardToken.safeTransfer(address(1), rewardAmount);
                } else {
                    uint256 rewardAmountForUser = rewardAmount.mul(rewardOsPlusAddress.userRate()).div(100);
                    uint256 rewardAmountForReferer = rewardAmount.sub(rewardAmountForUser);
                    swapConfig.rewardToken.safeTransfer(msg.sender, rewardAmountForUser);
                    swapConfig.rewardToken.safeTransfer(referer, rewardAmountForReferer);
                }
                rewardOsPlusAddress.addRewardList(msg.sender, rewardAmount, 5);
            }

        } else {
            IERC20(orderItemInfo[_orderId].erc20Token).safeTransferFrom(msg.sender, devAddress, fee);
        }


        orderItemInfo[_orderId].nftToken.transferFrom(address(this), msg.sender, orderItemInfo[_orderId].tokenId);
        orderStatusList[_orderId] = false;
        orderItemInfo[_orderId].orderStatus = false;

        okOrderList.remove(_orderId);
        nftOkOrderList[orderItemInfo[_orderId].nftToken].remove(_orderId);
        userOkOrderList[orderItemInfo[_orderId].owner].remove(_orderId);

        emit swapEvent(_orderId, orderItemInfo[_orderId].nftToken, orderItemInfo[_orderId].tokenId, orderItemInfo[_orderId].erc20Token, orderItemInfo[_orderId].owner, msg.sender, orderItemInfo[_orderId].price, fee, toUser);
    }

    function swapWithEth(uint256 _orderId) public payable nonReentrant {
        require(orderStatusList[_orderId] == true, "e001");
        require(msg.value == orderItemInfo[_orderId].price, "e002");
        uint256 fee = orderItemInfo[_orderId].price.mul(swapFee).div(100);
        uint256 toUser = orderItemInfo[_orderId].price.sub(fee);
        orderItemInfo[_orderId].owner.transfer(toUser);

        if (useRewardOsPlus) {
            uint256 devFee = fee.mul(50).div(100);
            uint256 rewardAmount = fee.sub(devFee);
            devAddress.transfer(devFee);
            (uint256[] memory amounts) = swapConfig.routerAddress.swapExactETHForTokens{value : rewardAmount}(
                0,
                swapConfig.swapEthPath,
                address(this),
                block.timestamp
            );
            (uint256[] memory amounts2) = swapConfig.routerAddress2.swapExactTokensForTokens(amounts[1], 0, swapConfig.swapErc20Path, address(this), block.timestamp);
            rewardAmount = amounts2[1];
            {
                address referer = rewardOsPlusAddress.refererAddressList(msg.sender);
                if (referer == address(0)) {
                    swapConfig.rewardToken.safeTransfer(address(1), rewardAmount);
                } else {
                    uint256 rewardAmountForUser = rewardAmount.mul(rewardOsPlusAddress.userRate()).div(100);
                    uint256 rewardAmountForReferer = rewardAmount.sub(rewardAmountForUser);
                    swapConfig.rewardToken.safeTransfer(msg.sender, rewardAmountForUser);
                    swapConfig.rewardToken.safeTransfer(referer, rewardAmountForReferer);
                }
                rewardOsPlusAddress.addRewardList(msg.sender, rewardAmount, 5);
            }
        } else {
            devAddress.transfer(fee);
        }

        orderItemInfo[_orderId].nftToken.transferFrom(address(this), msg.sender, orderItemInfo[_orderId].tokenId);
        orderStatusList[_orderId] = false;
        orderItemInfo[_orderId].orderStatus = false;

        okOrderList.remove(_orderId);
        nftOkOrderList[orderItemInfo[_orderId].nftToken].remove(_orderId);
        userOkOrderList[orderItemInfo[_orderId].owner].remove(_orderId);

        emit swapEvent(_orderId, orderItemInfo[_orderId].nftToken, orderItemInfo[_orderId].tokenId, orderItemInfo[_orderId].erc20Token, orderItemInfo[_orderId].owner, msg.sender, orderItemInfo[_orderId].price, fee, toUser);
    }

    function getWrongTokens(IERC20 _token) public onlyOwner {
        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "e001");
        _token.safeTransfer(msg.sender, amount);
    }

    function getStatusOkInfoList(uint256[] memory _orderIdList) public view returns (massInfoItem[] memory) {
        uint256 okNum = 0;
        for (uint256 i = 0; i < _orderIdList.length; i++) {
            if (orderItemInfo[_orderIdList[i]].orderStatus == true) {
                okNum = okNum.add(1);
            }
        }
        uint256 k = 0;
        massInfoItem[] memory x = new massInfoItem[](okNum);
        for (uint256 i = 0; i < _orderIdList.length; i++) {
            if (orderItemInfo[_orderIdList[i]].orderStatus == true) {
                (orderItem memory orderItem2, string memory name2, string memory symbol2, uint256 decimals2, uint256 price2,string memory tokenURI2) = getTokenInfoByIndex(_orderIdList[i]);
                x[k] = massInfoItem(orderItem2, name2, symbol2, decimals2, price2, tokenURI2);
                k = k.add(1);
            }
        }
        return x;
    }

    function getStatusOkIdList(uint256[] memory _orderIdList) public view returns (uint256[] memory) {
        uint256 okNum = 0;
        for (uint256 i = 0; i < _orderIdList.length; i++) {
            if (orderItemInfo[_orderIdList[i]].orderStatus == true) {
                okNum = okNum.add(1);
            }
        }
        uint256 k = 0;
        uint256[] memory x = new uint256[](okNum);
        for (uint256 i = 0; i < _orderIdList.length; i++) {
            if (orderItemInfo[_orderIdList[i]].orderStatus == true) {
                x[k] = _orderIdList[i];
                k = k.add(1);
            }
        }
        return x;
    }

    function getTokenInfoByIndex(uint256 index) public view returns (orderItem memory orderItem2, string memory name2, string memory symbol2, uint256 decimals2, uint256 price2, string memory tokenURI2){
        orderItem2 = orderItemInfo[index];
        if (orderItem2.erc20Token == address(0)) {
            name2 = ETH.name();
            symbol2 = ETH.symbol();
            decimals2 = ETH.decimals();
        } else {
            name2 = IERC20(orderItem2.erc20Token).name();
            symbol2 = IERC20(orderItem2.erc20Token).symbol();
            decimals2 = IERC20(orderItem2.erc20Token).decimals();
        }
        price2 = orderItem2.price.mul(1e18).div(10 ** decimals2);
        tokenURI2 = orderItem2.nftToken.tokenURI(orderItem2.tokenId);
    }

    function getTokenInfoByOrderMd5(string memory _orderMd5) public view returns (orderItem memory orderItem2, string memory name2, string memory symbol2, uint256 decimals2, uint256 price2){
        orderItem2 = orderItemInfo[orderMd5List[_orderMd5]];
        if (orderItem2.erc20Token == address(0)) {
            name2 = ETH.name();
            symbol2 = ETH.symbol();
            decimals2 = ETH.decimals();
        } else {
            name2 = IERC20(orderItem2.erc20Token).name();
            symbol2 = IERC20(orderItem2.erc20Token).symbol();
            decimals2 = IERC20(orderItem2.erc20Token).decimals();
        }
        price2 = orderItem2.price.mul(1e18).div(10 ** decimals2);
    }

    function getUserOkOrderIdList(address _user) public view returns (uint256[] memory) {
        uint256[] memory userOrderIdList = userOrderList[_user];
        uint256[] memory userOkOrderIdList = getStatusOkIdList(userOrderIdList);
        return userOkOrderIdList;
    }

    function getUserOkOrderInfoList(address _user) public view returns (massInfoItem[] memory) {
        uint256[] memory userOrderIdList = userOrderList[_user];
        massInfoItem[] memory userOkOrderIdList = getStatusOkInfoList(userOrderIdList);
        return userOkOrderIdList;
    }

    function getOkOrderList() external view returns (uint256[] memory OkOrderList_) {
        OkOrderList_ = okOrderList.values();
    }

    function getOkOrderListByIndexList(uint256[] memory _indexList) external view returns (uint256[] memory OkOrderList_) {
        OkOrderList_ = new uint256[](_indexList.length);
        for (uint256 i = 0; i < _indexList.length; i++) {
            OkOrderList_[i] = okOrderList.at(_indexList[i]);
        }
    }

    function getNftOkOrderList(IERC721Enumerable _nftToken) external view returns (uint256[] memory nftOkOrderList_) {
        nftOkOrderList_ = nftOkOrderList[_nftToken].values();
    }

    function getNftOkOrderListByIndexList(IERC721Enumerable _nftToken, uint256[] memory _indexList) external view returns (uint256[] memory nftOkOrderList_) {
        nftOkOrderList_ = new uint256[](_indexList.length);
        for (uint256 i = 0; i < _indexList.length; i++) {
            nftOkOrderList_[i] = nftOkOrderList[_nftToken].at(_indexList[i]);
        }
    }

    function getUserOkOrderList(address _user) external view returns (uint256[] memory userOkOrderList_) {
        userOkOrderList_ = userOkOrderList[_user].values();
    }

    function getUserOkOrderListByIndexList(address _user, uint256[] memory _indexList) external view returns (uint256[] memory userOkOrderList_) {
        userOkOrderList_ = new uint256[](_indexList.length);
        for (uint256 i = 0; i < _indexList.length; i++) {
            userOkOrderList_[i] = userOkOrderList[_user].at(_indexList[i]);
        }
    }

}