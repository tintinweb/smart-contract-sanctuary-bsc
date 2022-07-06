/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// File: contracts/mpu1155.sol


// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/EnumerableSet.sol



pragma solidity >=0.6.0 <0.8.0;

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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/Counters.sol



pragma solidity >=0.6.0 <0.8.0;


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/introspection/IERC165.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC1155/IERC1155Receiver.sol



pragma solidity >=0.6.0 <0.8.0;


/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC1155/IERC1155.sol



pragma solidity >=0.6.2 <0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// File: contracts/mpu1155.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;
pragma abicoder v2;





interface IProxy{
    function isMintableAccount(address _address) external view returns(bool);
    function isBurnAccount(address _address) external view returns(bool);
    function isTransferAccount(address _address) external view returns(bool);
    function isPauseAccount(address _address) external view returns(bool);
    function isSuperAdmin(address _address) external view returns(bool);
}

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity >=0.6.0 <0.8.0;

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

contract Auction is IERC1155Receiver,ReentrancyGuard{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    
    IERC1155 public TokenX;

    IProxy public proxy;
    
    mapping(address => conductedAuctionList)conductedAuction;
     
     mapping(address => mapping(uint256 =>uint256))participatedAuction;
     
     mapping(address => histo)history;
     
     mapping(address => uint256[])collectedArts;
     
     struct histo{
        uint256[] list;
     }
     
     struct conductedAuctionList{
        uint256[] list;
     }
     
    //mapping(uint256 => auction)auctiondetails;
    
    //mapping(address => mapping(uint256 => uint256))biddersdetails;
    
    uint256 public auctionTime = uint256(5 days);   
    
    Counters.Counter private totalAuctionId;
    
    enum auctionStatus { ACTIVE, OVER }
    
    auction[] internal auctions;
    
    EnumerableSet.UintSet TokenIds;

    address payable market;
    
    address public vaultaddress;

    uint256 comission = 2 ;
    
    event AdminListedNFT1155(address user,uint256 nftid,uint256 quantity,uint256 price);
    event AdminUnlistedNFT1155(address user,uint256 nftid,uint256 price,uint256 timestamp);
    event AdminPauselistedNFT1155(address user,uint256 nftid,uint256 timestamp);
    event AdminUnpauselistedNFT1155(address user,uint256 nftid,uint256 timestamp);
    event PurchasedNFT1155(address user,uint256 boughtnftid,uint256 price,uint256 comission);
    event UserlistedNFTtoMarket1155(address user,uint256 nftid,uint256 price,uint256 timestamp);
    event UserNFTtoMarketSold1155(address user,uint256 nftid,uint256 price,uint256 comission);
    event UserNFTDirectTransferto1155(address fromaddress,uint256 nftid,address toaddress,uint256 price,uint256 comission,uint256 timestamp);
    event AdminWithdrawFromEscrow1155(address user,uint256 balance,address transferaddress,uint256 timestamp);
    event WithdrawNFTfromMarkettoWallet1155(uint256 id,address withdrawaddress,uint256 comission,uint256 timestamp);
    event TransferedNFTfromMarkettoVault1155(uint256 id,address vault,uint256 timestamp);
    event AdminTransferNFT1155(address admin,uint256 tokenid,address user,uint256 timestamp);
    event MarketCommissionSet1155(address admin,uint256 comissionfee,uint256 timestamp);
    event AdminSetBid1155(address admin,uint256 time,uint256 timestamp);
    event UserSetBid1155(address admin,uint256 time,uint256 timestamp);
    event BidWinner1155(address user,uint256 bidid,uint256 nftid,uint256 timestamp);

    struct auction{
        uint256 auctionId;
        uint256 amount;
        bytes data;
        uint256 start;
        uint256 end;
        uint256 tokenId;
        address auctioner;
        address highestBidder;
        uint256 highestBid;
        address[] prevBid;
        uint256[] prevBidAmounts;
        auctionStatus status;
    }
 
    constructor(IERC1155 _tokenx,IProxy _proxy){
        TokenX = _tokenx;
        proxy=_proxy;
    }
    
    mapping(uint256 => bool) public pauseStatus;

    function setVaultAddress(address _vaultaddress) public{
        vaultaddress=_vaultaddress;
    }

    function setComission(uint256 _comission) public{
        comission=_comission;
        emit MarketCommissionSet1155(msg.sender,_comission,block.timestamp);
    }

    function adminPause(uint256 _auctionid) public{
        require( proxy.isSuperAdmin(msg.sender) == true,'You are not superadmin');
        auction memory _auction= auctions[_auctionid];
        pauseStatus[_auctionid]=true;
        emit AdminPauselistedNFT1155(msg.sender,_auction.tokenId,block.timestamp);
    }

    function adminUnPause(uint256 _auctionid) public{
        require(proxy.isSuperAdmin(msg.sender) == true,'You are not superadmin');
        auction memory _auction= auctions[_auctionid];
        pauseStatus[_auctionid]=false;
        emit AdminUnpauselistedNFT1155(msg.sender,_auction.tokenId,block.timestamp);
    }
     function _ownerOf(uint256 tokenId) internal view returns (bool) {
    return TokenX.balanceOf(msg.sender, tokenId) != 0;
    }
    
    function adminAuction(uint256 _tokenId,uint256 _price,uint256 _time,uint256 amount,bytes memory data)public returns(uint256){
        require( proxy.isSuperAdmin(msg.sender) == true,'You are not superadmin');
	    require(_ownerOf(_tokenId) == true, "Auction your NFT");
	    
	    auction memory _auction = auction({
	    auctionId : totalAuctionId.current(),
        amount:amount,
        data:data,
        start: block.timestamp,
        end : block.timestamp.add(_time * 86400),
        tokenId: _tokenId,
        auctioner: msg.sender,
        highestBidder: msg.sender,
        highestBid: _price,
        prevBid : new address[](0),
        prevBidAmounts : new uint256[](0),
        status: auctionStatus.ACTIVE
	    });
	    
	    conductedAuctionList storage list = conductedAuction[msg.sender];
	    list.list.push(totalAuctionId.current());
	    auctions.push(_auction);
	    TokenX.safeTransferFrom(address(msg.sender), address(this), _tokenId, amount, data);
	    emit AdminSetBid1155(msg.sender,_time,block.timestamp);
	    totalAuctionId.increment();
	    return uint256(totalAuctionId.current());
    }

     function userAuction(uint256 _tokenId,uint256 _price,uint256 _time,uint256 amount,bytes memory data)public returns(uint256){
	    require(_ownerOf(_tokenId) == true, "Auction your NFT");
	    
	    auction memory _auction = auction({
	    auctionId : totalAuctionId.current(),
        amount:amount,
        data:data,
        start: block.timestamp,
        end : block.timestamp.add(_time * 86400),
        tokenId: _tokenId,
        auctioner: msg.sender,
        highestBidder: msg.sender,
        highestBid: _price,
        prevBid : new address[](0),
        prevBidAmounts : new uint256[](0),
        status: auctionStatus.ACTIVE
	    });
	    
	    conductedAuctionList storage list = conductedAuction[msg.sender];
	    list.list.push(totalAuctionId.current());
	    auctions.push(_auction);
        TokenX.safeTransferFrom(address(msg.sender), address(this), _tokenId, amount, data);
	    emit UserSetBid1155(msg.sender,_time,block.timestamp);
	    totalAuctionId.increment();
	    return uint256(totalAuctionId.current());
    }

    function adminListedNFT(uint256 _tokenId,uint256 _price,uint256 amount,bytes memory data) public returns(uint256){
        require( proxy.isSuperAdmin(msg.sender) == true,'You are not superadmin');
        require(_ownerOf(_tokenId) == true, "Auction your NFT");
        auction memory _auction = auction({
	    auctionId : totalAuctionId.current(),
        data:data,
        amount:amount,
        start: block.timestamp,
        end : block.timestamp.add(auctionTime),
        tokenId: _tokenId,
        auctioner: msg.sender,
        highestBidder: msg.sender,
        highestBid: _price,
        prevBid : new address[](0),
        prevBidAmounts : new uint256[](0),
        status: auctionStatus.ACTIVE
	    });

        auctions.push(_auction);
	    TokenX.safeTransferFrom(address(msg.sender),address(this),_tokenId,amount,data);
	    
	    totalAuctionId.increment();
        emit AdminListedNFT1155(msg.sender,_tokenId,_price,amount);
	    return uint256(totalAuctionId.current());
    }

    function changePrice(uint256 _auctionId,uint256 price) public{
        auction storage auction = auctions[_auctionId];
         require(msg.sender == auction.auctioner,'You are not allowed' );
         auction.highestBid=price;
    }

     function buyAdminListedNFT(uint256 _auctionId) public {
        require(pauseStatus[_auctionId] ==false,'Auction id is paused');
        require(auctions[_auctionId].auctioner == msg.sender,"only auctioner");
        require(uint256(auctions[_auctionId].end) >= uint256(block.number),"already Finshed");
        
        auction storage auction = auctions[_auctionId];
        auction.end = uint32(block.number);
        auction.status = auctionStatus.OVER;

        uint256 marketFee = auction.highestBid.mul(comission).div(100);
        msg.sender.transfer(auctions[_auctionId].highestBid.sub(marketFee));
        market.transfer(marketFee);
        TokenX.safeTransferFrom(address(this),auctions[_auctionId].highestBidder,auctions[_auctionId].tokenId,auctions[_auctionId].amount,"0x");
        emit PurchasedNFT1155(auctions[_auctionId].highestBidder,auction.tokenId,auctions[_auctionId].highestBid,marketFee);

    }

    
    function userListedNFT(uint256 _tokenId,uint256 _price,uint256 amount,bytes memory data) public returns(uint256){
         require(_ownerOf(_tokenId) == true, "Auction your NFT");
        auction memory _auction = auction({
	    auctionId : totalAuctionId.current(),
        amount:amount,
        data:data,
        start: block.timestamp,
        end : block.timestamp.add(auctionTime),
        tokenId: _tokenId,
        auctioner: msg.sender,
        highestBidder: msg.sender,
        highestBid: _price,
        prevBid : new address[](0),
        prevBidAmounts : new uint256[](0),
        status: auctionStatus.ACTIVE
	    });

        auctions.push(_auction);
	    TokenX.safeTransferFrom(address(msg.sender),address(this),_tokenId,amount,data);
	    
	    totalAuctionId.increment();
        emit UserlistedNFTtoMarket1155(msg.sender,_tokenId,_price,block.timestamp);
	    return uint256(totalAuctionId.current());
    }

   

    function buyUserListedNFT(uint256 _auctionId) public {
        require(pauseStatus[_auctionId] ==false,'Auction id is paused');
        require(auctions[_auctionId].auctioner == msg.sender,"only auctioner");
        require(uint256(auctions[_auctionId].end) >= uint256(block.number),"already Finshed");
        
        auction storage auction = auctions[_auctionId];
        auction.end = uint32(block.number);
        auction.status = auctionStatus.OVER;

        uint256 marketFee = auction.highestBid.mul(comission).div(100);
        msg.sender.transfer(auctions[_auctionId].highestBid.sub(marketFee));
        market.transfer(marketFee);
        TokenX.safeTransferFrom(address(this),auctions[_auctionId].highestBidder,auctions[_auctionId].tokenId,auctions[_auctionId].amount,auctions[_auctionId].data);
        emit UserNFTtoMarketSold1155(auctions[_auctionId].highestBidder,auction.tokenId,auctions[_auctionId].highestBid,marketFee);

    }

    function adminUnlistedNFT(uint256 _auctionId) public{
        require(pauseStatus[_auctionId] ==false,'Auction id is paused');
        require(auctions[_auctionId].auctioner == msg.sender,"only auctioner");
        require(uint256(auctions[_auctionId].end) >= uint256(block.number),"already Finshed");
        
        auction storage auction = auctions[_auctionId];
        emit AdminUnlistedNFT1155(msg.sender,auction.tokenId,auction.highestBid,block.timestamp);
        auction.end = uint32(block.number);
        auction.status = auctionStatus.OVER;
        auction.highestBid=0;
        auction.highestBidder=address(0);
        
        TokenX.safeTransferFrom(address(this),msg.sender,auctions[_auctionId].tokenId,auctions[_auctionId].amount,auctions[_auctionId].data);
       
    }
    
    function placeBid(uint256 _auctionId)public payable returns(bool){
        require(pauseStatus[_auctionId] ==false,'Auction id is paused');
        require(auctions[_auctionId].highestBid < msg.value,"Place a higher Bid");
        require(auctions[_auctionId].auctioner != msg.sender,"Not allowed");
        require(auctions[_auctionId].end > block.timestamp,"Auction Finished");
       
        auction storage auction = auctions[_auctionId];
        auction.prevBid.push(auction.highestBidder);
        auction.prevBidAmounts.push(auction.highestBid);
        if(participatedAuction[auction.highestBidder][_auctionId] > 0){
        participatedAuction[auction.highestBidder][_auctionId] = participatedAuction[auction.highestBidder][_auctionId].add(auction.highestBid); 
        }else{
            participatedAuction[auction.highestBidder][_auctionId] = auction.highestBid;
        }
        
        histo storage history = history[msg.sender];
        history.list.push(_auctionId);
        
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
        return true;
    }
    
    function finishAuction(uint256 _auctionId) public{
        require(pauseStatus[_auctionId] ==false,'Auction id is paused');
        require(auctions[_auctionId].auctioner == msg.sender,"only auctioner");
        require(uint256(auctions[_auctionId].end) >= uint256(block.number),"already Finshed");
        
        auction storage auction = auctions[_auctionId];
        auction.end = uint32(block.number);
        auction.status = auctionStatus.OVER;
        
        uint256 marketFee = auction.highestBid.mul(comission).div(100);
        
        if(auction.prevBid.length > 0){
            
        for(uint256 i = 1; i < auction.prevBid.length; i++){
            if(participatedAuction[auctions[_auctionId].prevBid[i]][_auctionId] == auctions[_auctionId].prevBidAmounts[i] ){
            address payable give = payable(auctions[_auctionId].prevBid[i]);
            uint256 repay = auctions[_auctionId].prevBidAmounts[i];
            give.transfer(repay); 
            }
        }
        collectedArts[auctions[_auctionId].highestBidder].push(auctions[_auctionId].tokenId);
        msg.sender.transfer(auctions[_auctionId].highestBid.sub(marketFee));
        market.transfer(marketFee);
        emit BidWinner1155(auctions[_auctionId].highestBidder,_auctionId,auctions[_auctionId].tokenId,block.timestamp);
        TokenX.safeTransferFrom(address(this),auctions[_auctionId].highestBidder,auctions[_auctionId].tokenId,auctions[_auctionId].amount,auctions[_auctionId].data);
        }
    
    }

    // function userNFTDirectTransferto(uint256 _tokenId,address _to) public{
    //      TokenX.safeTransferFrom(msg.sender,_to,_tokenId);
    //      emit userNFTDirectTransferto(msg.sender,_tokenId,_to,);
    // }

    function adminWithdrawFromEscrow(address payable _to) public nonReentrant{
        require( proxy.isSuperAdmin(msg.sender) == true,'You are not superadmin');
        emit AdminWithdrawFromEscrow1155(msg.sender,address(this).balance,_to,block.timestamp);
        _to.transfer(address(this).balance);
    }

    function adminWithdrawFromEscrow(uint256 amount) public nonReentrant{
          require( proxy.isSuperAdmin(msg.sender) == true,'You are not superadmin');
          msg.sender.transfer(amount);
    }

    function withdrawNFTfromMarkettoWallet(uint256 _tokenId,address _to,uint256 amount,bytes memory data) public{
         msg.sender.transfer(comission);
         TokenX.safeTransferFrom(address(this),_to,_tokenId,amount,data);
         emit WithdrawNFTfromMarkettoWallet1155(_tokenId,_to,comission,block.timestamp);
    }

    function transferedNFTfromMarkettoVault(uint256 _tokenId,address _vaultaddress,uint256 amount,bytes memory data) public{
         TokenX.safeTransferFrom(address(this),_vaultaddress,_tokenId,amount,data);
         emit TransferedNFTfromMarkettoVault1155(_tokenId,vaultaddress,block.timestamp);
    }

    function  adminTransferNFT(address _to,uint256 _tokenId,uint256 amount,bytes memory data) public{
        require( proxy.isSuperAdmin(msg.sender) == true,'You are not superadmin');
        emit AdminTransferNFT1155(msg.sender,_tokenId,_to,block.timestamp);
        TokenX.safeTransferFrom(msg.sender,_to,_tokenId,amount,data);
    }
    
    function auctionStatusCheck(uint256 _auctionId)public view returns(bool){
        if(auctions[_auctionId].end > block.timestamp){
            return true;
        }else{
            return false;
        }
    }
    
    function auctionInfo(uint256 _auctionId)public view returns( uint256 auctionId,
        uint256 start,
        uint256 end,
        uint256 tokenId,
        address auctioner,
        address highestBidder,
        uint256 highestBid,
        uint256 status){
            
            auction storage auction = auctions[_auctionId];
            auctionId = _auctionId;
            start = auction.start;
            end =auction.end;
            tokenId = auction.tokenId;
            auctioner = auction.auctioner;
            highestBidder = auction.highestBidder;
            highestBid = auction.highestBid;
            status = uint256(auction.status);
        }
        
    function bidHistory(uint256 _auctionId) public view returns(address[]memory,uint256[]memory){
            return (auctions[_auctionId].prevBid,auctions[_auctionId].prevBidAmounts);
        }
        
    function participatedAuctions(address _user) public view returns(uint256[]memory){
        
        return history[_user].list;
           
    }
    
    function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external override returns (bytes4) {
    require(msg.sender == address(TokenX), "received from unauthenticated contract");
    TokenIds.add(id);
    return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
  }

   function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external override returns (bytes4) {
    require(msg.sender == address(TokenX), "received from unauthenticated contract");

    return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
  }

  function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
    return true;
  }
    
    function totalAuction() public view returns(uint256){
       return auctions.length;
    }
    
    function conductedAuctions(address _user)public view returns(uint256[]memory){
        return conductedAuction[_user].list;
    }
    
    function collectedArtsList(address _user)public view returns(uint256[] memory){
        return collectedArts[_user];
    }
}