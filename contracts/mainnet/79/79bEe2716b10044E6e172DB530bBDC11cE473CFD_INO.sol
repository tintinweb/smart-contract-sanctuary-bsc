// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import 'erc721a/contracts/IERC721A.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';
import '@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol';
import {ITicketsCounter, ILockableStaking} from './Interfaces.sol';

contract INO is ERC721Holder, ERC1155Holder {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public immutable CHAIN_ID;

    ITicketsCounter public ticketsCounter;
    IERC20 public BUSD;
    address public admin;
    address public backend;

    enum Protocol {
        ERC721,
        ERC721A,
        ERC1155
    }

    enum DrawModel {
        ONE_ALLOCATION,
        MANY_ALLOCATIONS
    }

    struct InoDetails {
        DrawModel drawModel;
        Protocol protocol;
        address nft;
        address projectOwner;
        uint32 registrationStart;
        uint32 registrationEnd;
        uint256[2] ticketRatio; // [tickets, allocations]
        uint32 totalNftAmount;
        uint256 busdForAllocation;
        uint32 vestingTime;
    }

    struct INOInfo {
        InoDetails inoDetails;
        uint256 busdRaised;
        uint256[] nftIds;
        uint256[] nftAmounts;
        bool drawn;
        bool cancelled;
        uint256 seed;
    }

    struct UserInfo {
        uint16 index;
        uint256 tickets;
        uint256 allocations;
        uint32 vestingStart;
        uint256[] vestingNftIds;
        uint256[] vestingNftAmounts;
        bool claimed;
    }

    // INO id => participants
    mapping(uint256 => EnumerableSet.AddressSet) _participantsOf;
    // array of userIndexes, amount of userIndexed in array = allocations amount purchased by user
    mapping(uint256 => uint16[]) _allocationsAt;

    INOInfo[] _INOs;

    mapping(uint256 => mapping(address => UserInfo)) _userInfos;
    mapping(uint256 => mapping(address => ITicketsCounter.StakingLockDetails[])) _stakingLockDetails;

    event InoCreated(uint256 indexed inoId);
    event InoInfoChanged(uint256 indexed inoId);
    event Drawn(uint256 indexed inoId, uint256 indexed seed);
    event UserRegistered(uint256 indexed inoId, address indexed user, uint256 allocations);
    event Claimed(uint256 indexed inoId, address indexed user);
    event Cancelled(uint256 indexed inoId, string reason);

    modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin');
        _;
    }

    modifier onlyProjectOwner(uint256 inoIndex_) {
        require(msg.sender == _INOs[inoIndex_].inoDetails.projectOwner, 'only project owner');
        _;
    }

    modifier onlyApprovedIno(uint256 inoIndex_) {
        require(
            _INOs[inoIndex_].inoDetails.registrationStart != 0 && _INOs[inoIndex_].inoDetails.registrationEnd != 0,
            'ino without registration dates'
        );
        _;
    }

    constructor(
        ITicketsCounter ticketsCounter_,
        IERC20 BUSD_,
        address admin_,
        address backend_
    ) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        CHAIN_ID = chainId;
        ticketsCounter = ticketsCounter_;
        BUSD = BUSD_;
        admin = admin_;
        backend = backend_;
    }

    //------------------------------------------------
    // Admin functions
    //------------------------------------------------

    function createINO(InoDetails memory inoDetails_) external onlyAdmin returns (uint256 index) {
        index = _INOs.length;
        _INOs.push(
            INOInfo({
                inoDetails: inoDetails_,
                busdRaised: 0,
                nftIds: new uint256[](0),
                nftAmounts: new uint256[](0),
                drawn: false,
                cancelled: false,
                seed: 0
            })
        );
        emit InoCreated(index);
    }

    function draw(uint256 inoId_) external onlyAdmin onlyApprovedIno(inoId_) {
        INOInfo storage ino = _INOs[inoId_];
        require(!ino.drawn, 'drawn already');
        require(block.timestamp >= ino.inoDetails.registrationEnd, 'registration stage now');
        uint256 loadedNftAmount;
        if (ino.inoDetails.protocol == Protocol.ERC1155) {
            loadedNftAmount = _loadedNft1155Amount(inoId_);
        } else {
            loadedNftAmount = ino.nftIds.length;
        }
        require(
            loadedNftAmount >= _allocationsAt[inoId_].length || loadedNftAmount == ino.inoDetails.totalNftAmount,
            'not all nfts are loaded on contract yet'
        );
        ino.seed = uint256(keccak256(abi.encodePacked(block.timestamp)));
        ino.drawn = true;
        emit Drawn(inoId_, ino.seed);
    }

    function cancelINO(uint256 inoId_, string memory reason_) external onlyAdmin {
        INOInfo storage ino = _INOs[inoId_];
        require(!ino.cancelled, 'cancelled already');
        require(!ino.drawn, 'seed drawn already');
        ino.cancelled = true;
        emit Cancelled(inoId_, reason_);
    }

    function returnBusd(uint256 amount_, address receiver_) external onlyAdmin {
        BUSD.transfer(receiver_, amount_);
    }

    function returnLeftNfts(
        Protocol protocol_,
        address nft_,
        uint256 tokenId_,
        address receiver_,
        uint256 amount_
    ) external onlyAdmin {
        if (protocol_ == Protocol.ERC721) {
            IERC721(nft_).safeTransferFrom(address(this), receiver_, tokenId_);
        } else if (protocol_ == Protocol.ERC721A) {
            IERC721A(nft_).safeTransferFrom(address(this), receiver_, tokenId_);
        } else {
            IERC1155(nft_).safeTransferFrom(address(this), receiver_, tokenId_, amount_, '');
        }
    }

    function changeInoDetails(uint256 inoId_, InoDetails memory inoDetails_) external onlyAdmin {
        INOInfo storage ino = _INOs[inoId_];
        require(
            block.timestamp < ino.inoDetails.registrationStart ||
                ino.inoDetails.registrationStart == 0 ||
                ino.inoDetails.registrationEnd == 0,
            'registration is opened already'
        );
        ino.inoDetails = inoDetails_;
        emit InoInfoChanged(inoId_);
    }

    function changeTicketsCounter(ITicketsCounter tc_) external onlyAdmin {
        ticketsCounter = tc_;
    }

    function changeBackend(address backend_) external onlyAdmin {
        backend = backend_;
    }

    //------------------------------------------------
    // Project owner functions
    //------------------------------------------------

    function loadNft(
        uint256 inoId_,
        uint256 tokenId_,
        uint256 amount_
    ) external onlyProjectOwner(inoId_) {
        INOInfo storage ino = _INOs[inoId_];
        if (ino.inoDetails.protocol == Protocol.ERC721) {
            require(ino.nftIds.length < ino.inoDetails.totalNftAmount, 'limit');
            IERC721(ino.inoDetails.nft).safeTransferFrom(msg.sender, address(this), tokenId_);
        } else if (ino.inoDetails.protocol == Protocol.ERC721A) {
            require(ino.nftIds.length < ino.inoDetails.totalNftAmount, 'limit');
            IERC721A(ino.inoDetails.nft).safeTransferFrom(msg.sender, address(this), tokenId_);
        } else {
            require(_loadedNft1155Amount(inoId_) + amount_ <= ino.inoDetails.totalNftAmount, 'limit');
            IERC1155(ino.inoDetails.nft).safeTransferFrom(msg.sender, address(this), tokenId_, amount_, '');
            ino.nftAmounts.push(amount_);
        }
        ino.nftIds.push(tokenId_);
    }

    //------------------------------------------------
    // Participator functions
    //------------------------------------------------

    function register(uint256 index_, uint256 allocations_)
        external
        onlyApprovedIno(index_)
        returns (uint16 userIndex)
    {
        INOInfo storage ino = _INOs[index_];
        require(!ino.cancelled, 'cancelled');
        require(allocations_ > 0, 'no allocations amount');
        require(block.timestamp >= ino.inoDetails.registrationStart, 'registration not open yet');
        require(block.timestamp < ino.inoDetails.registrationEnd, 'registration is closed already');
        require(!_participantsOf[index_].contains(msg.sender), 'already registered');
        uint256 participantsLength = _participantsOf[index_].length();
        require(participantsLength < type(uint16).max, 'participants limit');

        uint256 ticketsForAllocations = (allocations_ * ino.inoDetails.ticketRatio[0]) / ino.inoDetails.ticketRatio[1];
        if (allocations_ % ino.inoDetails.ticketRatio[1] > 0) ticketsForAllocations++;
        require(ticketsForAllocations >= ino.inoDetails.ticketRatio[0], 'not enough tickets');

        ITicketsCounter.StakingLockDetails[] memory shouldLock = ticketsCounter.smartLockTickets(
            msg.sender,
            ino.inoDetails.registrationEnd,
            ticketsForAllocations
        );

        for (uint256 i = 0; i < shouldLock.length; i++) {
            ITicketsCounter.StakingLockDetails memory lockCase = shouldLock[i];
            if (lockCase.amount > 0) {
                lockCase.target.createLock(msg.sender, index_, ino.inoDetails.registrationEnd, lockCase.amount);
                _stakingLockDetails[index_][msg.sender].push(lockCase);
            }
        }

        uint256 busdToPay = ino.inoDetails.busdForAllocation * allocations_;
        BUSD.transferFrom(msg.sender, address(this), busdToPay);
        ino.busdRaised += busdToPay;

        userIndex = uint16(participantsLength);
        _participantsOf[index_].add(msg.sender);

        _userInfos[index_][msg.sender] = UserInfo({
            index: userIndex,
            tickets: ticketsForAllocations,
            allocations: allocations_,
            vestingStart: 0,
            vestingNftIds: new uint256[](0),
            vestingNftAmounts: new uint256[](0),
            claimed: false
        });
        for (uint256 i = 0; i < allocations_; i++) {
            _allocationsAt[index_].push(userIndex);
        }
        emit UserRegistered(index_, msg.sender, allocations_);
    }

    function sendToVesting(
        uint256 index_,
        uint256[] memory tokenIds_,
        uint256[] memory tokenAmounts_,
        bytes memory sig_
    ) external {
        INOInfo storage ino = _INOs[index_];
        require(_participantsOf[index_].contains(msg.sender), 'not registered');
        require(ino.inoDetails.vestingTime != 0);
        require(tokenIds_.length != 0, 'not winning');
        require(ino.drawn, 'not drawn');
        require(_userInfos[index_][msg.sender].vestingStart == 0, 'sent to vesting already');
        require(
            _verifySignature(
                ino.inoDetails.protocol,
                msg.sender,
                address(this),
                index_,
                CHAIN_ID,
                tokenIds_,
                tokenAmounts_,
                sig_
            ),
            'wrong signature'
        );
        _userInfos[index_][msg.sender].vestingStart = uint32(block.timestamp);
        _userInfos[index_][msg.sender].vestingNftIds = tokenIds_;
        if (ino.inoDetails.protocol == Protocol.ERC1155) {
            _userInfos[index_][msg.sender].vestingNftAmounts = tokenAmounts_;
        }
        _deleteExpiredLocks(index_, msg.sender);
        ticketsCounter.unlockTickets(msg.sender, _userInfos[index_][msg.sender].tickets);
    }

    function claimWithVesting(uint256 index_) external {
        INOInfo storage ino = _INOs[index_];
        UserInfo storage userInfo = _userInfos[index_][msg.sender];
        require(userInfo.vestingStart != 0, 'vesting not started');
        require(block.timestamp >= userInfo.vestingStart + ino.inoDetails.vestingTime, 'vesting period yet');
        _retrieveNFTs(index_, msg.sender, userInfo.vestingNftIds, userInfo.vestingNftAmounts);
    }

    function claimWithoutVesting(
        uint256 index_,
        uint256[] memory tokenIds_,
        uint256[] memory tokenAmounts_,
        bytes memory _sig
    ) external {
        INOInfo storage ino = _INOs[index_];
        require(_participantsOf[index_].contains(msg.sender), 'not registered');
        if (ino.cancelled) {
            _retrieveBusd(index_, msg.sender);
            _deleteExpiredLocks(index_, msg.sender);
            ticketsCounter.unlockTickets(msg.sender, _userInfos[index_][msg.sender].tickets);
            return;
        }
        require(ino.inoDetails.vestingTime == 0 || tokenIds_.length == 0, 'not possible to claim without vesting');
        require(ino.drawn, 'not drawn');
        require(
            _verifySignature(
                ino.inoDetails.protocol,
                msg.sender,
                address(this),
                index_,
                CHAIN_ID,
                tokenIds_,
                tokenAmounts_,
                _sig
            ),
            'wrong signature'
        );
        if (tokenIds_.length == 0) {
            _retrieveBusd(index_, msg.sender);
        } else {
            _retrieveNFTs(index_, msg.sender, tokenIds_, tokenAmounts_);
        }
        _deleteExpiredLocks(index_, msg.sender);
        ticketsCounter.unlockTickets(msg.sender, _userInfos[index_][msg.sender].tickets);
    }

    //------------------------------------------------
    // View functions
    //------------------------------------------------

    function getParticipants(uint256 index_) external view returns (address[] memory) {
        return _participantsOf[index_].values();
    }

    function isParticipant(uint256 index_, address user_) external view returns (bool) {
        return _participantsOf[index_].contains(user_);
    }

    function getParticipantByIndex(uint256 inoId_, uint16 index_) external view returns (address) {
        return _participantsOf[inoId_].at(index_);
    }

    function getAllocations(uint256 index_) external view returns (uint16[] memory) {
        return _allocationsAt[index_];
    }

    function getInoNftsInfo(uint256 inoId_)
        external
        view
        returns (
            Protocol,
            address,
            uint256[] memory,
            uint256[] memory
        )
    {
        INOInfo storage ino = _INOs[inoId_];
        return (ino.inoDetails.protocol, ino.inoDetails.nft, ino.nftIds, ino.nftAmounts);
    }

    function getInfoForDraw(uint256 inoId_)
        external
        view
        returns (
            DrawModel,
            Protocol,
            address[] memory,
            uint16[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256
        )
    {
        INOInfo storage ino = _INOs[inoId_];
        return (
            ino.inoDetails.drawModel,
            ino.inoDetails.protocol,
            _participantsOf[inoId_].values(),
            _allocationsAt[inoId_],
            ino.nftIds,
            ino.nftAmounts,
            ino.seed
        );
    }

    function getInoDetails(uint256 inoId_) external view returns (InoDetails memory inoDetails) {
        return (_INOs[inoId_].inoDetails);
    }

    function isInoCancelled(uint256 inoId_) external view returns (bool) {
        return (_INOs[inoId_].cancelled);
    }

    function getTotalInoAmount() external view returns (uint256) {
        return _INOs.length;
    }

    function getInoBusdRaised(uint256 inoId_) external view returns (uint256) {
        return _INOs[inoId_].busdRaised;
    }

    function getUserVestingNfts(uint256 inoId_, address user_)
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {
        UserInfo memory userInfo = _userInfos[inoId_][user_];
        return (userInfo.vestingNftIds, userInfo.vestingNftAmounts);
    }

    function userInfos(uint256 inoId_, address user_) external view returns (UserInfo memory) {
        return _userInfos[inoId_][user_];
    }

    function inoInfo(uint256 inoId_) external view returns (INOInfo memory) {
        return _INOs[inoId_];
    }

    //------------------------------------------------
    // Internal state modifying functions
    //------------------------------------------------

    function _retrieveNFTs(
        uint256 index_,
        address user_,
        uint256[] memory _tokenIds_,
        uint256[] memory _tokenAmounts_
    ) internal {
        require(!_userInfos[index_][user_].claimed, 'already claimed');
        Protocol protocol = _INOs[index_].inoDetails.protocol;
        if (protocol == Protocol.ERC721) {
            for (uint256 i = 0; i < _tokenIds_.length; i++) {
                IERC721(_INOs[index_].inoDetails.nft).safeTransferFrom(address(this), msg.sender, _tokenIds_[i]);
            }
        } else if (protocol == Protocol.ERC721A) {
            for (uint256 i = 0; i < _tokenIds_.length; i++) {
                IERC721A(_INOs[index_].inoDetails.nft).safeTransferFrom(address(this), msg.sender, _tokenIds_[i]);
            }
        } else {
            for (uint256 i = 0; i < _tokenIds_.length; i++) {
                IERC1155(_INOs[index_].inoDetails.nft).safeTransferFrom(
                    address(this),
                    msg.sender,
                    _tokenIds_[i],
                    _tokenAmounts_[i],
                    ''
                );
            }
        }
        _userInfos[index_][user_].claimed = true;
        emit Claimed(index_, user_);
    }

    function _retrieveBusd(uint256 index_, address user_) internal {
        require(!_userInfos[index_][user_].claimed, 'already claimed');
        BUSD.transfer(user_, _INOs[index_].inoDetails.busdForAllocation * _userInfos[index_][user_].allocations);
        _userInfos[index_][user_].claimed = true;
        emit Claimed(index_, user_);
    }

    function _deleteExpiredLocks(uint256 index, address user) internal {
        ITicketsCounter.StakingLockDetails[] storage lockedStakes = _stakingLockDetails[index][user];
        for (uint256 i = 0; i < lockedStakes.length; i++) {
            lockedStakes[i].target.deleteExpiredLock(user, index);
        }
        delete _stakingLockDetails[index][user];
    }

    //------------------------------------------------
    // Internal non state modifying functions
    //------------------------------------------------

    function _loadedNft1155Amount(uint256 inoId_) internal view returns (uint256 nftAmount) {
        INOInfo storage ino = _INOs[inoId_];
        for (uint256 i = 0; i < ino.nftAmounts.length; i++) {
            nftAmount += ino.nftAmounts[i];
        }
    }

    function _verifySignature(
        Protocol protocol_,
        address user_,
        address ino_,
        uint256 inoId_,
        uint256 chainId_,
        uint256[] memory tokenIds_,
        uint256[] memory tokenAmounts_,
        bytes memory sig_
    ) internal view returns (bool) {
        bytes32 hashedMessage;
        if (protocol_ == Protocol.ERC1155) {
            hashedMessage = _ethMessageHash(user_, ino_, inoId_, chainId_, tokenIds_, tokenAmounts_);
        } else {
            hashedMessage = _ethMessageHash(user_, ino_, inoId_, chainId_, tokenIds_);
        }
        return _recover(hashedMessage, sig_) == backend;
    }

    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash_ bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param sig_ bytes signature, the signature is generated using web3.eth.sign()
     */
    function _recover(bytes32 hash_, bytes memory sig_) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (sig_.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(sig_, 32))
            s := mload(add(sig_, 64))
            v := byte(0, mload(add(sig_, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash_, v, r, s);
        }
    }

    /**
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:" and hash the result
     */
    function _ethMessageHash(
        address user_,
        address ino_,
        uint256 inoId_,
        uint256 chainId_,
        uint256[] memory tokenIds_
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    '\x19Ethereum Signed Message:\n32',
                    keccak256(abi.encodePacked(user_, ino_, inoId_, chainId_, tokenIds_))
                )
            );
    }

    /**
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:" and hash the result
     */
    function _ethMessageHash(
        address user_,
        address ino_,
        uint256 inoId_,
        uint256 chainId_,
        uint256[] memory tokenIds_,
        uint256[] memory tokenAmounts_
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    '\x19Ethereum Signed Message:\n32',
                    keccak256(abi.encodePacked(user_, ino_, inoId_, chainId_, tokenIds_, tokenAmounts_))
                )
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILockableStaking {
    function createLock(
        address user,
        uint256 index,
        uint32 until,
        uint256 amount
    ) external;

    function deleteExpiredLock(address user, uint256 index) external;
}

interface IRefTreeStorage {
    function refererOf(address user) external view returns (address);

    function referralsOf(address referer) external view returns (address[] memory);

    function setReferer(address user, address referer) external;
}

interface ITicketsCounter {
    struct StakingLockDetails {
        uint256 amount;
        ILockableStaking target;
    }

    function smartLockTickets(
        address user,
        uint256 drawDate,
        uint256 ticketsRequested
    ) external returns (StakingLockDetails[] memory shouldLock);

    function countTickets(address user, uint256 drawDate)
        external
        view
        returns (uint256 totalTickets, uint256 usableTickets);

    function unlockTickets(address user, uint256 amount) external;
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.0.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

/**
 * @dev Interface of an ERC721A compliant contract.
 */
interface IERC721A {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * The caller cannot approve to their own address.
     */
    error ApproveToCaller();

    /**
     * The caller cannot approve to the current owner.
     */
    error ApprovalToCurrentOwner();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Keeps track of the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     *
     * Burned tokens are calculated here, use `_totalMinted()` if you want to count just minted tokens.
     */
    function totalSupply() external view returns (uint256);

    // ==============================
    //            IERC165
    // ==============================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // ==============================
    //            IERC721
    // ==============================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // ==============================
    //        IERC721Metadata
    // ==============================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}