/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// File: ISpaceNFT.sol



pragma solidity ^0.8.0;

interface ISpaceNFT {
    /**
     * interface for mint function
     */
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function safeTransferFromMarket(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function totalSupply(uint256 id) external view returns (uint256);
}
// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;


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
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

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
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;


/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: nft market.sol



pragma solidity ^0.8.4;








// Order Type: 0 - buy order, 1 - sell order
// item is nft

contract SpaceNFTMarket is ReentrancyGuard, Ownable, ERC1155Holder {

    // Mapping from token Id to (from buy order creator address in market to buy orders)
    mapping(uint => mapping(address => MarketOrder)) public buyOrders;
    // Mapping from token Id to (from sell order creator address in market to sell orders)
    mapping(uint => mapping(address => MarketOrder)) public sellOrders;

    // Mapping from token Id to array with buyers addresses
    mapping(uint => address[]) public buyers;
    // Mapping from token Id to array with sellers addresses
    mapping(uint => address[]) public sellers;

    // Buy order's address to array index mapping
    mapping(address => uint) public buyOrderIndexes;
    // Sell order's address to array index mapping
    mapping(address => uint) public sellOrderIndexes;

    uint public maxTokenId; // Max token id in erc1155 _spacenft contract

    address payable public feeReceiver;
    // Owner of this contract must be the same as owner of the nft contract
    address public spacenft;

    constructor(address _feeReceiver, address _spacenft) {
        feeReceiver = payable(_feeReceiver);
        spacenft = payable(_spacenft);
    }

    struct MarketOrder {
        bool active;
        bool sellOrder;
        address itemOwner; // order id
        uint tokenId;
        uint tokenAmount;
        uint price;
    }


    // ---------------------- EVENTS ----------------------


    event ItemCreated(
        address itemOwner,
        address indexed nftContract,
        uint indexed tokenId,
        uint indexed tokenAmount
    );

    event SellOrderListed(
        address itemSeller, // order id
        address indexed nftContract,
        uint indexed tokenId,
        uint indexed tokenAmount,
        uint price
    );

    event BuyOrderListed(
        address itemBuyer, // order id
        address indexed nftContract,
        uint indexed tokenId,
        uint indexed tokenAmount,
        uint offeredPrice
    );

    event ItemSold(
        address oldItemOwner, // order id
        address newItemOwner,
        address indexed nftContract,
        uint indexed tokenId,
        uint indexed tokenAmount,
        uint price
    );

    event Canceled(
        address orderCreator, // order id
        uint orderType // 0 - buy order, 1 - sell order
    );

    event FeeReceiverOwnershipTransferred(
        address payable indexed previousReceiver,
        address payable indexed newReceiver
    );


    // ---------------------- MODIFIERS ----------------------


    modifier tokenIdExists(uint tokenId) {
        require(tokenId <= maxTokenId, "Market: Non-existent token Id");
        _;
    }

    modifier tokenAmountIsNotZero(uint tokenAmount) {
        require(tokenAmount > 0, "Market: Token amount is zero");
        _;
    }


    // ---------------------- WRITE FUNCTIONS ----------------------

    // mint nft with main nft contract
    // tokenId must go up: 0, 1, 2, 3, 4, etc.
    function createMarketItem(
        uint tokenId,
        uint tokenAmount
    )
    public onlyOwner
    tokenAmountIsNotZero(tokenAmount)
    {
        ISpaceNFT(spacenft).mint(owner(), tokenId, tokenAmount, "");

        if (tokenId > maxTokenId) {
            maxTokenId = tokenId;
        }

        emit ItemCreated(
            owner(),
            spacenft,
            tokenId,
            tokenAmount
        );
    }

    /**
    * @param offeredPrice must be in wei, for example, 0.01 bnb:
    *  offeredPrice = 0.01 * 10 ** 18 == 10000000000000000
    */
    function listBuyOrder(
        uint tokenId,
        uint tokenAmount,
        uint offeredPrice
    )
    public payable nonReentrant
    tokenIdExists(tokenId)
    tokenAmountIsNotZero(tokenAmount)
    {
        address buyOrderCreator = _msgSender();

        require(
            buyOrders[tokenId][buyOrderCreator].active == false,
            "Market: ListBuyOrder: Buy order from this buyer already exists"
        );
        require(offeredPrice > 0, "Market: ListBuyOrder: Offered price must be at least 1 wei");

        uint totalPrice = offeredPrice * tokenAmount;
        require(
            msg.value >= totalPrice,
            "Market: ListBuyOrder: msg.value must be equal to or greater then offered price * amount"
        );

        uint totalSupply = ISpaceNFT(spacenft).totalSupply(tokenId);
        require(tokenAmount <= totalSupply, "Market: ListBuyOrder: Token amount exceeds possible");

        MarketOrder memory marketOrder = MarketOrder(
            true,
            false,
            buyOrderCreator,
            tokenId,
            tokenAmount,
            offeredPrice
        );

        buyOrders[tokenId][buyOrderCreator] = marketOrder;
        buyOrderIndexes[buyOrderCreator] = buyers[tokenId].length;
        buyers[tokenId].push(buyOrderCreator);

        emit BuyOrderListed(
            buyOrderCreator,
            spacenft,
            tokenId,
            tokenAmount,
            offeredPrice
        );
    }

    /**
    * @param price must be in wei, for example, 0.01 bnb:
    *  price = 0.01 * 10 ** 18 == 10000000000000000
    *
    *  first must be call setApprovalForAll(address operator, bool approved) from msg.sender (user account)
    *  in erc1155 contract
    */
    function listSellOrder(
        uint tokenId,
        uint tokenAmount,
        uint price
    )
    public nonReentrant
    tokenIdExists(tokenId)
    tokenAmountIsNotZero(tokenAmount)
    {
        address sellOrderCreator = _msgSender();

        require(
            sellOrders[tokenId][sellOrderCreator].active == false,
            "Market: ListSellOrder: Sell order from this seller already exists"
        );
        require(
            IERC1155(spacenft).balanceOf(sellOrderCreator, tokenId) >= tokenAmount,
            "Market: ListSellOrder: Token amount must be equal balance"
        );
        require(price > 0, "Market: ListSellOrder: Price must be at least 1 wei");

        ISpaceNFT(spacenft)
        .safeTransferFromMarket(sellOrderCreator, address(this), tokenId, tokenAmount, "");

        MarketOrder memory marketOrder = MarketOrder(
            true,
            true,
            sellOrderCreator,
            tokenId,
            tokenAmount,
            price
        );

        sellOrders[tokenId][sellOrderCreator] = marketOrder;
        sellOrderIndexes[sellOrderCreator] = sellers[tokenId].length;
        sellers[tokenId].push(sellOrderCreator);

        emit SellOrderListed(
            sellOrderCreator,
            spacenft,
            tokenId,
            tokenAmount,
            price
        );
    }

    /*
    * @param msg.value must be in wei, for example, 0.01 bnb:
    *   msg.value = 0.01 * 10 ** 18 == 10000000000000000
    */
    function buyMarketItem(
        uint tokenId,
        address sellOrderCreator,
        uint tokenAmount
    )
    public payable nonReentrant
    tokenIdExists(tokenId)
    tokenAmountIsNotZero(tokenAmount)
    {
        MarketOrder storage sellOrder = sellOrders[tokenId][sellOrderCreator];

        address buyer = _msgSender();

        require(buyer != sellOrder.itemOwner, "Market: BuyMarketItem: Buyer cannot be seller");
        require(sellOrder.active, "Market: BuyMarketItem: Sell Order is not active");

        require(tokenAmount <= sellOrder.tokenAmount, "Market: BuyMarketItem: Token amount exceeds possible");

        uint totalPrice = sellOrder.price * tokenAmount;
        require(msg.value >= totalPrice, "Market: BuyMarketItem: Insufficient payment");

        uint fee = totalPrice * 1 / 100;
        // 1% for tx in BNB

        payable(feeReceiver).transfer(fee);
        payable(sellOrder.itemOwner).transfer(totalPrice - fee);

        ISpaceNFT(spacenft) // (sellOrder.nftAddress)
        .safeTransferFromMarket(address(this), buyer, sellOrder.tokenId, tokenAmount, "");

        sellOrder.tokenAmount -= tokenAmount;

        emit ItemSold(
            sellOrder.itemOwner,
            buyer,
            spacenft,
            sellOrder.tokenId,
            tokenAmount,
            sellOrder.price
        );

        if (sellOrder.tokenAmount == 0) {
            deleteSellOrder(sellOrder);
        }

    }

    function sellMarketItem(
        uint tokenId,
        address buyOrderCreator,
        uint tokenAmount
    )
    public nonReentrant
    tokenIdExists(tokenId)
    tokenAmountIsNotZero(tokenAmount)
    {
        MarketOrder storage buyOrder = buyOrders[tokenId][buyOrderCreator];

        address seller = _msgSender();

        require(
            IERC1155(spacenft).balanceOf(seller, tokenId) >= tokenAmount,
            "Market: SellMarketItem: Seller balance is less than the specified number of tokens"
        );
        require(seller != buyOrder.itemOwner, "Market: SellMarketItem: Seller cannot be buyer");
        require(buyOrder.active, "Market: SellMarketItem: Sell Order is not active");

        require(tokenAmount <= buyOrder.tokenAmount, "Market: SellMarketItem: Token amount exceeds possible");

        uint totalPrice = buyOrder.price * tokenAmount;
        uint fee = totalPrice * 1 / 100;
        // 1% for tx in BNB
        payable(feeReceiver).transfer(fee);
        payable(seller).transfer(totalPrice - fee);

        ISpaceNFT(spacenft)
        .safeTransferFromMarket(seller, buyOrder.itemOwner, buyOrder.tokenId, tokenAmount, "");

        buyOrder.tokenAmount -= tokenAmount;

        emit ItemSold(
            seller,
            buyOrder.itemOwner,
            spacenft,
            buyOrder.tokenId,
            tokenAmount,
            buyOrder.price
        );

        if (buyOrder.tokenAmount == 0) {
            deleteBuyOrder(buyOrder);
        }

    }

    function cancelBuyOrder(
        uint tokenId
    )
    public nonReentrant
    tokenIdExists(tokenId)
    {
        address buyOrderCreator = _msgSender();
        MarketOrder storage buyOrder = buyOrders[tokenId][buyOrderCreator];

        require(buyOrder.active, "Market: CancelBuyOrder: Order is not active");

        payable(buyOrder.itemOwner).transfer(buyOrder.tokenAmount * buyOrder.price);

        deleteBuyOrder(buyOrder);

        emit Canceled(buyOrderCreator, 0);
        // order type: 0 - buy, 1 - sell
    }

    function cancelSellOrder(
        uint tokenId
    )
    public nonReentrant
    tokenIdExists(tokenId)
    {
        address sellOrderCreator = _msgSender();
        MarketOrder storage sellOrder = sellOrders[tokenId][sellOrderCreator];

        require(sellOrder.active, "Market: CancelSellOrdere: Order is not active");

        ISpaceNFT(spacenft)
        .safeTransferFromMarket(address(this), sellOrder.itemOwner, sellOrder.tokenId, sellOrder.tokenAmount, "");

        deleteSellOrder(sellOrder);

        emit Canceled(sellOrderCreator, 1);
        // order type: 0 - buy, 1 - sell
    }

    function editPriceForMySellOrder(
        uint newPrice,
        uint tokenId
    )
    public onlyOwner nonReentrant
    tokenIdExists(tokenId)
    returns (uint)
    {
        address sellOrderCreator = _msgSender();
        MarketOrder storage sellOrder = sellOrders[tokenId][sellOrderCreator];
        require(sellOrder.active, "Market: EditPrice: Sell order is not active");

        return sellOrder.price = newPrice;
    }

    function editTokenAmountForMySellOrder(
        uint newTokenAmount,
        uint tokenId
    )
    public onlyOwner nonReentrant
    tokenIdExists(tokenId)
    tokenAmountIsNotZero(newTokenAmount)
    returns (uint)
    {
        address sellOrderCreator = _msgSender();
        MarketOrder storage sellOrder = sellOrders[tokenId][sellOrderCreator];
        require(sellOrder.active, "Market: EditPrice: Sell order is not active");

        uint oldTokenAmount = sellOrder.tokenAmount;

        if (newTokenAmount > oldTokenAmount) {
            uint shortfall = newTokenAmount - oldTokenAmount;
            ISpaceNFT(spacenft)
            .safeTransferFromMarket(sellOrderCreator, address(this), tokenId, shortfall, "");
        } else if (newTokenAmount < oldTokenAmount) {
            uint rest = oldTokenAmount - newTokenAmount;
            ISpaceNFT(spacenft)
            .safeTransferFromMarket(address(this), sellOrderCreator, tokenId, rest, "");
        }

        return sellOrder.tokenAmount = newTokenAmount;
    }


    // change feeReceiver address
    function changeFeeReceiver(address payable newFeeReceiver) public onlyOwner {
        require(newFeeReceiver != address(0), "Market: ChangeFeeReceiver: New receiver is the zero address");

        address payable oldReceiver = feeReceiver;
        feeReceiver = newFeeReceiver;

        emit FeeReceiverOwnershipTransferred(oldReceiver, newFeeReceiver);
    }


    // ---------------------- VIEW FUNCTIONS ----------------------


    function fetchAllBuyOrdersByTokenId(
        uint tokenId
    )
    external view
    tokenIdExists(tokenId)
    returns (MarketOrder[] memory)
    {
        MarketOrder[] memory marketOrders = new MarketOrder[](buyers[tokenId].length);

        for (uint i = 0; i < buyers[tokenId].length; i++) {
            marketOrders[i] = buyOrders[tokenId][buyers[tokenId][i]];
        }

        return marketOrders;
    }

    function fetchAllSellOrdersByTokenId(
        uint tokenId
    )
    external view
    tokenIdExists(tokenId)
    returns (MarketOrder[] memory)
    {
        MarketOrder[] memory marketOrders = new MarketOrder[](sellers[tokenId].length);

        for (uint i = 0; i < sellers[tokenId].length; i++) {
            marketOrders[i] = sellOrders[tokenId][sellers[tokenId][i]];
        }

        return marketOrders;
    }

    function fetchOrderItemByOrderCreator(
        address orderCreator,
        uint tokenId,
        uint orderType // 0 - buy order, 1 - sell order
    )
    external view
    tokenIdExists(tokenId)
    returns (MarketOrder memory)
    {
        return orderType == 0
        ? buyOrders[tokenId][orderCreator]
        : sellOrders[tokenId][orderCreator];
    }

    function deleteBuyOrder(MarketOrder storage deletedOrder) internal {
        uint tokenId = deletedOrder.tokenId;
        MarketOrder storage lastBuyOrder = buyOrders[tokenId][buyers[tokenId][buyers[tokenId].length - 1]];

        buyers[tokenId][buyOrderIndexes[deletedOrder.itemOwner]] = lastBuyOrder.itemOwner;
        buyOrderIndexes[lastBuyOrder.itemOwner] = buyOrderIndexes[deletedOrder.itemOwner];
        delete buyOrderIndexes[deletedOrder.itemOwner];

        buyers[tokenId].pop();
        delete buyOrders[tokenId][deletedOrder.itemOwner];
    }

    function deleteSellOrder(MarketOrder storage deletedOrder) internal {
        uint tokenId = deletedOrder.tokenId;
        MarketOrder storage lastSellOrder = sellOrders[tokenId][sellers[tokenId][sellers[tokenId].length - 1]];

        sellers[tokenId][sellOrderIndexes[deletedOrder.itemOwner]] = lastSellOrder.itemOwner;
        sellOrderIndexes[lastSellOrder.itemOwner] = sellOrderIndexes[deletedOrder.itemOwner];
        delete sellOrderIndexes[deletedOrder.itemOwner];

        sellers[tokenId].pop();
        delete sellOrders[tokenId][deletedOrder.itemOwner];
    }
}