/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
pragma experimental ABIEncoderV2;

library EnumerableSet {
    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

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


interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    //     function transfer(address recipient, uint256 amount) external returns (bool);
    // function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);
}


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

library SafeBEP20 {
    using SafeMath for uint256;
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, 'e0');
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), 'e1');
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

interface Token is IERC20 {
    function mint(address _to, uint256 _amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function MinerList(address _address) external returns (bool);
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

interface pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IERC721Enumerable {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function mintForMiner(address _to, uint256 _tokenId) external returns (bool, uint256);

    function allPriceList(uint256 _tokenId) external view returns (uint256);

    function canMintList(uint256 _tokenId) external view returns (bool);

    function tokenIdPersistList(uint256 _tokenID) external view returns (bool);

    function MinerList(address _address) external view returns (bool);
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

interface MasterChefForErc20 {
    function depositByProxy(address _user, uint256 _pid, uint256 _depositAmount) external;
}

contract MasterChefForCOSODV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IERC20;
    PoolConfigItem public PoolConfig;
    swapItem public swapConfig;

    struct swapItem {
        swapRouter routerAddress;
        IERC20 usdtToken;
        IERC20 pairAddress;
        address[] swapErc20Path;
        MasterChefForErc20 farmAddress;
    }

    struct PoolConfigItem {
        boolConfigItem boolConfig;
        uint256ConfigItem uint256Config;
        uint256 minRewardNum;
        uint256 minRewardNumForBurnId;
    }

    struct boolConfigItem {
        bool useMintMode;
        bool poolStatus;
        bool limitWithdrawTime;
        bool limitGetRewardTime;
    }

    struct uint256ConfigItem {
        uint256 cakePerBlock;
        uint256 BONUS_MULTIPLIER;
        uint256 daoNftTokenStakingLength;
        uint256 cosoNftTokenStakingLength;
        uint256 startBlock;
        uint256 bonusEndBlock;
        uint256 lastRewardBlock;
        uint256 stakingNumForPool;
        uint256 accCakePerShare;
        uint256 refererrate;
        uint256 claimMinLength;
    }

    address public devaddr;
    Token public cake;
    IERC721Enumerable public daoNftToken;
    IERC721Enumerable public cosoNftToken;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.UintSet private ValidatorList;
    EnumerableSet.UintSet private burnIdList;
    EnumerableSet.AddressSet private stakingAddress;
    mapping(address => bool) private hasBurlPool;
    mapping(uint256 => address) public burnToPoolAddressList;
    mapping(uint256 => daoNftTokenItem) private daoNftTokenInfoList;
    mapping(address => uint256) public staking_time;
    mapping(address => uint256) public unlock_time;
    mapping(address => uint256) public claim_time;
    mapping(address => uint256) public pending_list;
    mapping(address => uint256) public allrewardList;
    mapping(address => EnumerableSet.UintSet) private userStakingTokenForPoolIdListSet;
    mapping(uint256 => address) public stakingNftOlderOwnerList;
    mapping(address => UserInfo) public userInfo;
    mapping(address => uint256) public daoRewardNumList;
    mapping(uint256 => EnumerableSet.UintSet) private daoNftToknVoteIdList;

    struct UserInfo {
        bool hasBeenDaoList;
        bool hasBurlPool;
        uint256 myDaoNftTokenId;
        uint256 votedDaoNftTokenId;
        uint256 amount;
        uint256 rewardDebt;
    }

    struct daoNftTokenItem {
        uint256 _tokenId;
        uint256 _stakingTime;
        uint256 _unlockTime;
        address _owner;
        bool _staked;
        uint256 _burnId;
    }

    struct daoNftToknVoteIdItem {
        uint256 daoNftTokenId;
        //uint256[] VoteIdList;
        uint256 num;
        daoNftTokenItem daoNftTokenItem;
    }

    event safeCakeTransferEvent(address _to, uint256 _amount, uint256 cakeBalance);

    constructor () {
        devaddr = msg.sender;
        PoolConfig.boolConfig = boolConfigItem(true, true, true, true);
        PoolConfig.uint256Config = uint256ConfigItem(0.1 * 10 ** 18, 1, 3600 * 24 * 365, 3600 * 24 * 365, block.timestamp, block.timestamp.add(3600 * 24 * 365), block.timestamp, 0, 0, 20, 0);
    }

    function setSwapConfig(swapRouter _routerAddress, IERC20 _usdtToken, IERC20 _pairAddress, address[] calldata _swapErc20Path, MasterChefForErc20 _farmAddress) external onlyOwner {
        swapConfig = swapItem(_routerAddress, _usdtToken, _pairAddress, _swapErc20Path, _farmAddress);
    }

    function setPool(uint256 _startBlock, uint256 _bonusEndBlock, bool _poolStatus) external onlyOwner {
        PoolConfig.uint256Config.startBlock = _startBlock;
        PoolConfig.uint256Config.bonusEndBlock = _bonusEndBlock;
        PoolConfig.boolConfig.poolStatus = _poolStatus;
    }

    function setGetReward(bool _limitGetRewardTime, uint256 _claimMinLength, uint256 _minRewardNum, uint256 _minRewardNumForBurnId) external onlyOwner {
        PoolConfig.boolConfig.limitGetRewardTime = _limitGetRewardTime;
        PoolConfig.uint256Config.claimMinLength = _claimMinLength;
        PoolConfig.minRewardNum = _minRewardNum;
        PoolConfig.minRewardNumForBurnId = _minRewardNumForBurnId;
    }

    function setCakePerBlockAndCake(Token _cake, uint256 _cakePerBlock, bool _useMintMode) external onlyOwner {
        PoolConfig.boolConfig.useMintMode = _useMintMode;
        if (_useMintMode) {
            require(_cake.MinerList(address(this)), "e001");
        }
        updatePool();
        cake = _cake;
        PoolConfig.uint256Config.cakePerBlock = _cakePerBlock;
    }

    function setNftToken(IERC721Enumerable _daoNftToken, IERC721Enumerable _cosoNftToken) external onlyOwner {
        daoNftToken = _daoNftToken;
        cosoNftToken = _cosoNftToken;
    }

    function setStakingLength(uint256 _daoNftTokenStakingLength_days, uint256 _cosoNftTokenStakingLength_days) external onlyOwner {
        PoolConfig.uint256Config.daoNftTokenStakingLength = _daoNftTokenStakingLength_days * 3600 * 24;
        PoolConfig.uint256Config.cosoNftTokenStakingLength = _cosoNftTokenStakingLength_days * 3600 * 24;
    }

    function addValidators(uint256[] memory _daoNftTokenIDList) external onlyOwner {
        for (uint256 i = 0; i < _daoNftTokenIDList.length; i++) {
            uint256 _daoNftTokenID = _daoNftTokenIDList[i];
            require(!ValidatorList.contains(_daoNftTokenID), "e001");
            ValidatorList.add(_daoNftTokenID);
            daoNftTokenInfoList[_daoNftTokenID]._tokenId = _daoNftTokenID;
        }
    }

    function activeValidator(uint256 _daoNftTokenID) external {
        if (userInfo[msg.sender].myDaoNftTokenId == 0) {
            userInfo[msg.sender].myDaoNftTokenId = _daoNftTokenID;
        } else {
            require(userInfo[msg.sender].myDaoNftTokenId == _daoNftTokenID, "e001");
        }
        require(ValidatorList.contains(_daoNftTokenID), "e002");
        require(!userInfo[msg.sender].hasBeenDaoList, "e003");
        daoNftToken.transferFrom(msg.sender, address(this), _daoNftTokenID);
        userInfo[msg.sender].hasBeenDaoList = true;
        daoNftTokenInfoList[_daoNftTokenID]._owner = msg.sender;
        daoNftTokenInfoList[_daoNftTokenID]._staked = true;
        daoNftTokenInfoList[_daoNftTokenID]._stakingTime = block.timestamp;
    }

    function withdrawDaoNftToken() external {
        uint256 _daoNftTokenID = userInfo[msg.sender].myDaoNftTokenId;
        require(_daoNftTokenID > 0, "e001");
        require(daoNftTokenInfoList[_daoNftTokenID]._owner == msg.sender, "e002");
        require(block.timestamp >= daoNftTokenInfoList[_daoNftTokenID]._stakingTime.add(PoolConfig.uint256Config.daoNftTokenStakingLength), "e003");
        daoNftToken.transferFrom(address(this), msg.sender, _daoNftTokenID);
        daoNftTokenInfoList[_daoNftTokenID]._staked = false;
        daoNftTokenInfoList[_daoNftTokenID]._stakingTime = 0;
        userInfo[msg.sender].hasBeenDaoList = false;
    }

    function burnToPool(uint256 _burnId) external {
        require(userInfo[msg.sender].myDaoNftTokenId == 0, "e001");
        require(!userInfo[msg.sender].hasBeenDaoList, "e001");
        require(!userInfo[msg.sender].hasBurlPool, "e002");
        cosoNftToken.transferFrom(msg.sender, address(1), _burnId);
        hasBurlPool[msg.sender] = true;
        burnToPoolAddressList[_burnId] = msg.sender;
        burnIdList.add(_burnId);
    }

    function activeBurnValidator(uint256 _burnId, uint256 _daoNftTokenID) external onlyOwner {
        require(!ValidatorList.contains(_daoNftTokenID), "e001");
        daoNftToken.transferFrom(msg.sender, address(this), _daoNftTokenID);
        ValidatorList.add(_daoNftTokenID);
        address toAddDaoAddress = burnToPoolAddressList[_burnId];
        require(!userInfo[toAddDaoAddress].hasBeenDaoList, "e001");
        daoNftTokenInfoList[_daoNftTokenID]._tokenId = _daoNftTokenID;
        userInfo[toAddDaoAddress].hasBeenDaoList = true;
        userInfo[toAddDaoAddress].myDaoNftTokenId = _daoNftTokenID;
        daoNftTokenInfoList[_daoNftTokenID]._owner = toAddDaoAddress;
        daoNftTokenInfoList[_daoNftTokenID]._staked = true;
        daoNftTokenInfoList[_daoNftTokenID]._stakingTime = block.timestamp;
        daoNftTokenInfoList[_daoNftTokenID]._burnId = _burnId;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (!PoolConfig.boolConfig.poolStatus || block.timestamp < PoolConfig.uint256Config.startBlock || _from >= PoolConfig.uint256Config.bonusEndBlock) {
            return 0;
        }
        if (_to <= PoolConfig.uint256Config.bonusEndBlock) {
            return _to - _from;
        } else {
            return PoolConfig.uint256Config.bonusEndBlock - _from;
        }
    }

    function updatePool() public {
        if (block.timestamp <= PoolConfig.uint256Config.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = PoolConfig.uint256Config.stakingNumForPool;
        if (lpSupply == 0) {
            PoolConfig.uint256Config.lastRewardBlock = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(PoolConfig.uint256Config.lastRewardBlock, block.timestamp);
        uint256 cakeReward = multiplier.mul(PoolConfig.uint256Config.cakePerBlock);
        if (PoolConfig.boolConfig.useMintMode && cake.MinerList(address(this))) {
            cake.mint(address(this), cakeReward);
        }
        PoolConfig.uint256Config.accCakePerShare = PoolConfig.uint256Config.accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        PoolConfig.uint256Config.lastRewardBlock = block.timestamp;
    }

    function pendingCake(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 lpSupply = PoolConfig.uint256Config.stakingNumForPool;
        uint256 accCakePerShare2 = PoolConfig.uint256Config.accCakePerShare;
        if (block.timestamp > PoolConfig.uint256Config.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(PoolConfig.uint256Config.lastRewardBlock, block.timestamp);
            uint256 cakeReward = multiplier.mul(PoolConfig.uint256Config.cakePerBlock);
            accCakePerShare2 = accCakePerShare2.add(cakeReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCakePerShare2).div(1e12).sub(user.rewardDebt);
    }

    function deposit(uint256 _daoNftTokenID, uint256[] memory _tokenIdList) external nonReentrant {
        address _user = msg.sender;
        UserInfo storage user = userInfo[_user];
        if (user.votedDaoNftTokenId == 0) {
            userInfo[_user].votedDaoNftTokenId = _daoNftTokenID;
        } else {
            require(user.votedDaoNftTokenId == _daoNftTokenID, "e001");
        }
        require(_tokenIdList.length > 0, "e002");
        require(PoolConfig.boolConfig.poolStatus, "e003");
        require(daoNftTokenInfoList[_daoNftTokenID]._staked, "e004");
        updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(PoolConfig.uint256Config.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                pending_list[_user] = pending_list[_user].add(pending);
            }
        }
        if (_tokenIdList.length > 0) {
            for (uint256 i = 0; i < _tokenIdList.length; i++) {
                uint256 _tokenId = _tokenIdList[i];
                cosoNftToken.transferFrom(_user, address(this), _tokenId);
                userStakingTokenForPoolIdListSet[_user].add(_tokenId);
                stakingNftOlderOwnerList[_tokenId] = msg.sender;
                daoNftToknVoteIdList[_daoNftTokenID].add(_tokenId);
            }
            uint256 addAmount = _tokenIdList.length;
            PoolConfig.uint256Config.stakingNumForPool = PoolConfig.uint256Config.stakingNumForPool.add(addAmount);
            uint256 oldStaking = user.amount;
            uint256 newStaking = user.amount.add(addAmount);
            user.amount = user.amount.add(addAmount);
            uint256 oldUnlockTime;
            uint256 newUnlockTime;
            if (unlock_time[_user] == 0) {
                oldUnlockTime = block.timestamp.add(PoolConfig.uint256Config.cosoNftTokenStakingLength);
            } else {
                oldUnlockTime = unlock_time[msg.sender];
            }
            if (oldUnlockTime >= block.timestamp) {
                newUnlockTime = oldStaking.mul(oldUnlockTime.sub(block.timestamp)).add(addAmount.mul(PoolConfig.uint256Config.cosoNftTokenStakingLength)).div(newStaking);
            } else {
                newUnlockTime = addAmount.mul(PoolConfig.uint256Config.cosoNftTokenStakingLength).div(newStaking);
            }
            unlock_time[_user] = block.timestamp.add(newUnlockTime);
            staking_time[_user] = block.timestamp;
        }
        user.rewardDebt = user.amount.mul(PoolConfig.uint256Config.accCakePerShare).div(1e12);
        if (!stakingAddress.contains(_user)) {
            stakingAddress.add(_user);
        }
        if (claim_time[_user] == 0) {
            claim_time[_user] = block.timestamp;
        }
    }

    function withdraw(uint256[] memory _tokenIdList) external {
        address _user = msg.sender;
        updatePool();
        if (PoolConfig.boolConfig.limitWithdrawTime) {
            require(block.timestamp > unlock_time[msg.sender], "e001");
        }
        UserInfo storage user = userInfo[_user];
        uint256 _daoNftTokenID = user.votedDaoNftTokenId;
        uint256 pending = user.amount.mul(PoolConfig.uint256Config.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            pending_list[_user] = pending_list[_user].add(pending);
        }
        for (uint256 i = 0; i < _tokenIdList.length; i++) {
            uint256 _tokenId = _tokenIdList[i];
            if (userStakingTokenForPoolIdListSet[_user].contains(_tokenId)) {
                cosoNftToken.transferFrom(address(this), _user, _tokenId);
                user.amount = user.amount.sub(1);
                PoolConfig.uint256Config.stakingNumForPool = PoolConfig.uint256Config.stakingNumForPool.sub(1);
                userStakingTokenForPoolIdListSet[_user].remove(_tokenId);
                stakingNftOlderOwnerList[_tokenId] = address(0);
                daoNftToknVoteIdList[_daoNftTokenID].remove(_tokenId);
            }
        }
        user.rewardDebt = user.amount.mul(PoolConfig.uint256Config.accCakePerShare).div(1e12);
        if (userStakingTokenForPoolIdListSet[_user].length() == 0) {
            stakingAddress.remove(msg.sender);
            userInfo[_user].votedDaoNftTokenId = 0;
        }
    }

    function withdrawAll() external {
        if (PoolConfig.boolConfig.limitWithdrawTime) {
            require(block.timestamp > unlock_time[msg.sender], "e001");
        }
        updatePool();
        address _user = msg.sender;
        UserInfo storage user = userInfo[_user];
        uint256 _daoNftTokenID = user.votedDaoNftTokenId;
        uint256 pending = user.amount.mul(PoolConfig.uint256Config.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            pending_list[_user] = pending_list[_user].add(pending);
        }
        uint256[] memory userCosoList = userStakingTokenForPoolIdListSet[_user].values();
        for (uint i = 0; i < userCosoList.length; i++) {
            cosoNftToken.transferFrom(address(this), _user, userCosoList[i]);
            user.amount = user.amount.sub(1);
            PoolConfig.uint256Config.stakingNumForPool = PoolConfig.uint256Config.stakingNumForPool.sub(1);
            userStakingTokenForPoolIdListSet[_user].remove(userCosoList[i]);
            daoNftToknVoteIdList[_daoNftTokenID].remove(userCosoList[i]);
            stakingNftOlderOwnerList[userCosoList[i]] = address(0);
        }
        user.rewardDebt = user.amount.mul(PoolConfig.uint256Config.accCakePerShare).div(1e12);
        stakingAddress.remove(msg.sender);
        userInfo[_user].votedDaoNftTokenId = 0;
    }

    function _getReward(address _user, uint256 _farm_pid) private {
        if (PoolConfig.boolConfig.limitGetRewardTime) {
            require(block.timestamp >= claim_time[_user].add(PoolConfig.uint256Config.claimMinLength), "e001");
        }
        updatePool();
        claim_time[_user] = block.timestamp;
        UserInfo storage user = userInfo[_user];
        uint256 _daoNftTokenID = user.votedDaoNftTokenId;
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(PoolConfig.uint256Config.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                pending_list[_user] = pending_list[_user].add(pending);
            }
        }
        user.rewardDebt = user.amount.mul(PoolConfig.uint256Config.accCakePerShare).div(1e12);
        if (pending_list[_user] > 0) {
            uint256 allAmount = pending_list[_user];
            swapAndDepositFarm(_user, _daoNftTokenID, allAmount, _farm_pid);
            pending_list[_user] = 0;
        }
    }

    function swapAndDepositFarm(address _user, uint256 _daoNftTokenID, uint256 _allAmount, uint256 _farm_pid) internal {
        uint256 rewardAmount = _allAmount.mul(PoolConfig.uint256Config.refererrate).div(100);
        uint256 userAmount = _allAmount.sub(rewardAmount);
        allrewardList[_user] = allrewardList[_user].add(userAmount);
        uint256 halfAmount = _allAmount.mul(50).div(100);
        (uint256[] memory amounts) = swapConfig.routerAddress.swapExactTokensForTokens(halfAmount, 0, swapConfig.swapErc20Path, address(this), block.timestamp);
        (,,uint256 lpAmount) = swapConfig.routerAddress.addLiquidity(address(swapConfig.usdtToken), address(cake), amounts[1], halfAmount, 0, 0, address(this), block.timestamp);
        address _owner = daoNftTokenInfoList[_daoNftTokenID]._owner;
        bool _staked = daoNftTokenInfoList[_daoNftTokenID]._staked;
        uint256 rewardLpAmount = lpAmount.mul(PoolConfig.uint256Config.refererrate).div(100);
        uint256 userLpAmount = lpAmount.sub(rewardLpAmount);
        swapConfig.farmAddress.depositByProxy(_user, _farm_pid, userLpAmount);
        if (_staked && ((daoNftToknVoteIdList[_daoNftTokenID].length() >= PoolConfig.minRewardNum && daoNftTokenInfoList[_daoNftTokenID]._burnId == 0) || (daoNftToknVoteIdList[_daoNftTokenID].length() >= PoolConfig.minRewardNumForBurnId && daoNftTokenInfoList[_daoNftTokenID]._burnId > 0))) {
            swapConfig.farmAddress.depositByProxy(_owner, _farm_pid, rewardLpAmount);
            daoRewardNumList[_owner] = daoRewardNumList[_owner].add(rewardAmount);
        } else {
            swapConfig.pairAddress.safeTransfer(address(1), rewardLpAmount);
        }
    }

    function setApprovedForSwapAndFarm(uint256 _amount) external onlyOwner {
        require(address(cake) != address(0));
        require(address(swapConfig.routerAddress) != address(0));
        require(address(swapConfig.usdtToken) != address(0));
        require(address(swapConfig.pairAddress) != address(0));
        require(address(swapConfig.farmAddress) != address(0));
        cake.approve(address(swapConfig.routerAddress), _amount);
        swapConfig.usdtToken.approve(address(swapConfig.routerAddress), _amount);
        swapConfig.pairAddress.approve(address(swapConfig.farmAddress), _amount);
    }

    function getReward(uint256 _farm_pid) external {
        _getReward(msg.sender, _farm_pid);
    }

    function safeCakeTransfer(address _to, uint256 _amount) internal {
        uint256 cakeBalance = cake.balanceOf(address(this));
        if (_amount > cakeBalance) {
            cake.transfer(_to, cakeBalance);
        } else {
            cake.transfer(_to, _amount);
        }
        emit safeCakeTransferEvent(_to, _amount, cakeBalance);
    }

    function setdev(address _devaddr) external onlyOwner {
        devaddr = _devaddr;
    }

    function getStakingAddressItem(uint256 _index) public view returns (address) {
        return stakingAddress.at(_index);
    }

    function getStakingAddressList(uint256[] memory _indexList) public view returns (address[] memory AddressList) {
        AddressList = new address[](_indexList.length);
        for (uint256 i = 0; i < _indexList.length; i++) {
            AddressList[i] = stakingAddress.at(_indexList[i]);
        }
    }

   function userStakingTokenIdList(address _user, uint256 _index) external view returns (uint256) {
        return userStakingTokenForPoolIdListSet[_user].values()[_index];
    }

    function userStakingNumList(address _user) public view returns (uint256) {
        return userStakingTokenForPoolIdListSet[_user].length();
    }
    
    function getStakingAddressNum() public view returns (uint256) {
        return stakingAddress.length();
    }

    function getBurnIdList() external view returns (uint256[] memory) {
        return burnIdList.values();
    }

    function getBurnId(uint256 _index) external view returns (uint256 _tokenId, address _burnAddress) {
        _tokenId = burnIdList.at(_index);
        _burnAddress = burnToPoolAddressList[_tokenId];
    }

    function getBurnIdNum() external view returns (uint256) {
        return burnIdList.length();
    }

    function getValidatorLists() external view returns (uint256[] memory, uint256) {
        return (ValidatorList.values(), ValidatorList.length());
    }

    function getDaoNftToknVoteIdList(uint256 _daoNftTokenID) public view returns (daoNftToknVoteIdItem memory _daoNftToknVoteIds) {
        _daoNftToknVoteIds.daoNftTokenId = _daoNftTokenID;
        _daoNftToknVoteIds.daoNftTokenItem = daoNftTokenInfoList[_daoNftTokenID];
        _daoNftToknVoteIds.num = daoNftToknVoteIdList[_daoNftTokenID].length();
    }

    function getAllDaoNftToknVoteIdList() public view returns (daoNftToknVoteIdItem[] memory _daoNftToknVoteIdsList) {
        uint256[] memory ValidatorLists = ValidatorList.values();
        _daoNftToknVoteIdsList = new daoNftToknVoteIdItem[](ValidatorLists.length);
        for (uint256 i = 0; i < ValidatorLists.length; i++) {
            _daoNftToknVoteIdsList[i] = getDaoNftToknVoteIdList(ValidatorLists[i]);
        }
    }

    function getUserStakingTokenForPoolIdListSet(address _user) external view returns (uint256[] memory, uint256) {
        return (userStakingTokenForPoolIdListSet[_user].values(), userStakingTokenForPoolIdListSet[_user].length());
    }

    struct userPoolInfoItem {
        PoolConfigItem _PoolConfig;
        UserInfo _UserInfo;
        Token _cake;
        IERC721Enumerable _daoNftToken;
        IERC721Enumerable _cosoNftToken;
        uint256 staking_time;
        uint256 unlock_time;
        uint256 claim_time;
        uint256 pending_list;
        uint256 allrewardList;
        uint256 daoRewardNumList;
        uint256[] userStakingIdList;
        uint256 userStakingNum;
    }
    
    function getPoolInfo(address _user) external view returns (userPoolInfoItem memory userPoolInfo) {
        userPoolInfo._PoolConfig = PoolConfig;
        userPoolInfo._UserInfo = userInfo[_user];
        userPoolInfo._daoNftToken = daoNftToken;
        userPoolInfo._cosoNftToken = cosoNftToken;
        userPoolInfo.staking_time = staking_time[_user];
        userPoolInfo.unlock_time = unlock_time[_user];
        userPoolInfo.claim_time = claim_time[_user];
        userPoolInfo.pending_list = pending_list[_user];
        userPoolInfo.allrewardList = allrewardList[_user];
        userPoolInfo.daoRewardNumList = daoRewardNumList[_user];
        userPoolInfo.userStakingIdList = userStakingTokenForPoolIdListSet[_user].values();
        userPoolInfo.userStakingNum = userStakingTokenForPoolIdListSet[_user].length();
    }

    function takeErc20Token(IERC20 _token) external onlyOwner {
        _token.safeTransfer(msg.sender, _token.balanceOf(address(this)));
    }

    function takeErc721Token(IERC721Enumerable _token, uint256[] memory _tokenIdList) external onlyOwner {
        for (uint256 i = 0; i < _tokenIdList.length; i++) {
            uint256 _tokenId = _tokenIdList[i];
            _token.transferFrom(address(this), msg.sender, _tokenId);
        }
    }
}