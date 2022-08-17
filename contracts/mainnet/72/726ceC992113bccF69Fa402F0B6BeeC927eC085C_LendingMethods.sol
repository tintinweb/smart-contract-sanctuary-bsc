/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


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

// File: @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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
}

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

// File: contracts/lending/helpers/TrustNFTRelay.sol


pragma solidity ^0.8.0;







contract TrustNFTRelay is Ownable, ERC721Holder, ERC1155Holder {
    struct NFT {
        address nftAddress; // the adderess of the ERC721
        uint256 nftTokenId; // the unique identifier of the NFT token that the borrower uses as collateral
        uint8 nftTokenType; // the token types : ERC721 , ERC1155 , ...
    }

    // Send tokens from an account to another (+ payment fee)
    function transferPayment(
        address from,
        address payable to,
        address currency,
        uint256 quantity1,
        uint256 quantity2
    ) public {
        if (currency != address(0)) {
            require(
                IERC20(currency).transferFrom(from, to, quantity1),
                "Transfer of tokens to receiver failed"
            );
            require(
                IERC20(currency).transferFrom(from, owner(), quantity2),
                "Transfer of tokens to TrustNFT failed"
            );
        } else {
            require(to.send(quantity1), "Transfer of BNB to receiver failed");
            require(
                payable(owner()).send(quantity2),
                "Transfer of BNB to TrustNFT failed"
            );
        }
    }

    // Send NFTs from an account to another
    function transferNFT(
        address from,
        address to,
        NFT memory nft
    ) public {
        if (nft.nftTokenType == 0) {
            IERC721(nft.nftAddress).safeTransferFrom(from, to, nft.nftTokenId);
        } else {
            IERC1155(nft.nftAddress).safeTransferFrom(
                from,
                to,
                nft.nftTokenId,
                1,
                "0x00"
            );
        }
    }
}

// File: contracts/lending/lending/LendingCore.sol


pragma solidity ^0.8.0;



contract LendingCore is TrustNFTRelay {
    using SafeMath for uint256;
    using SafeMath for uint8;

    event NewLoan(
        address indexed owner,
        address indexed currency,
        uint256 indexed loanId,
        uint256 time,
        uint256 loanAmount,
        uint256 amountDue,
        NFT nft
    );

    event LoanApproved(
        address indexed lender,
        uint256 indexed loanId,
        uint256 loanPaymentEnd
    );
    event LoanCancelled(uint256 indexed loanId);
    event LoanTerminated(
        address indexed requester,
        uint256 indexed loanId,
        Status status
    );
    event LoanPayment(
        uint256 indexed loanId,
        uint256 amount,
        uint256 amountPaidAsInstallmentToLender,
        uint256 interestPerInstallement,
        uint256 platformFeePerInstallment,
        Status status
    );

    /*
     * Lending contract public & global variables:
     * id - the loan ID, id will be the actual loans mapping length
     * ltv - max allowed 60%
     * interestRate - 20% of the payment
     * interestRateToPlatform - 40% of interestRate
     * lenderFee - 1%
     * Status - provides the loans status:
     *   LISTED - loan is created
     *   APPROVED - lender found and assigned to loan
     *   LIQUIDATED - all loan payments are paid
     *   CANCELLED - loan is cancelled before a lender to be assigned
     *   WITHDRAWN - loan is LIQUIDATED and items are withdrawn to either lender or borrower
     */
    address public promissoryNoteAddress;
    address public lendingMethodsAddress;
    uint256 public id = 1; // the loan ID
    uint256 public ltv = 60; // 60%
    uint256 public interestRate = 20;
    uint256 public interestRateToPlatform = 40;
    uint32 public lenderFee = 100;
    enum Status {
        LISTED,
        APPROVED,
        LIQUIDATED,
        CANCELLED,
        WITHDRAWN
    }

    struct Installment {
        uint256 time; // the installment unix timestamp
        uint256 amount; // amount expected for each installment
        uint16 nrOfInstallments; // the number of installments that the borrower must pay
        uint256 nrOfPayments; // the number of installments paid
        uint8 defaultingLimit; // the number of installments allowed to be missed without getting defaulted
    }

    struct Loan {
        address payable borrower; // the address who receives the loan
        address payable lender; // the address who gives/offers the loan to the borrower
        address currency; // the token that the borrower lends, address(0) for BNB
        Status status; // the loan status
        NFT nft;
        Installment installment;
        uint256 loanAmount; // the amount, denominated in tokens (see next struct entry), the borrower lends
        uint256 nftValue; // important for determintng LTV which has to be under 50-60%
        uint256[2] startEnd; // startEnd[0] loan start date , startEnd[1] loan end date
        uint256 amountDue; // loanAmount + interest that needs to be paid back by borrower
        uint256 paidAmount; // the amount that has been paid back to the lender to date
    }

    mapping(uint256 => Loan) public loans;

    // Mapping for all the loans that are approved by the owner in order to be used in the promissory note
    mapping(uint256 => address) public promissoryPermissions;

    modifier isPromissoryNote() {
        require(
            msg.sender == promissoryNoteAddress,
            "Lending Methods: Access denied"
        );
        _;
    }

    /*
     * Determines if a loan has passed the maximum unpaid installments limit or not:
     * @ => TRUE = Loan has exceed the maximum unpaid installments limit, lender can terminate the loan and get the NFTs
     * @ => FALSE = Loan has not exceed the maximum unpaid installments limit, lender can not terminate the loan
     */
    function canBeTerminated(uint256 loanId) public view returns (bool) {
        require(
            loans[loanId].status == Status.APPROVED ||
                loans[loanId].status == Status.LIQUIDATED,
            "Loan is not yet approved"
        );

        // return last paid installment date + defaultingLimit * installment time interval <= block.timestamp
        return
            loans[loanId]
                .startEnd[0]
                .add(
                    loans[loanId].installment.nrOfPayments.mul(
                        loans[loanId].installment.time
                    )
                )
                .add(
                    loans[loanId].installment.defaultingLimit.mul(
                        loans[loanId].installment.time
                    )
                ) <= min(block.timestamp, loans[loanId].startEnd[1]);
    }

    // Require acceptable loan-to-value ratio
    function checkLtv(uint256 loanValue, uint256 nftValue) public view {
        require(loanValue <= nftValue.div(100).mul(ltv), "LTV too high");
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function getLoanStartEnd(uint256 loanId)
        external
        view
        returns (uint256[2] memory)
    {
        return loans[loanId].startEnd;
    }

    function getPromissoryPermission(uint256 loanId)
        external
        view
        returns (address)
    {
        require(
            loans[loanId].status == Status.APPROVED,
            "Loan is no longer approved"
        );
        return promissoryPermissions[loanId];
    }
}

// File: contracts/lending/lending/LendingMethods.sol


pragma solidity ^0.8.0;



contract LendingMethods is Ownable, LendingCore {
    using SafeMath for uint256;
    using SafeMath for uint16;

    // Borrower creates a loan
    function borrow(
        uint256 loanAmount,
        uint256 time,
        address currency,
        uint256 nftValue,
        NFT calldata nft
    ) external {
        require(
            time > 86400 &&
                loanAmount > 0 &&
                nft.nftAddress != address(0)
        );


        uint16 nrOfInstallments = 1;

        loans[id].nftValue = nftValue;

        // Check loan-to-value ration
        checkLtv(loanAmount, loans[id].nftValue);

        // Set loan fields
        loans[id].nft = nft;
        loans[id].loanAmount = loanAmount;
        loans[id].amountDue = loanAmount.mul(interestRate.add(100)).div(100); // interest rate >> 20%;
        loans[id].status = Status.LISTED;
        loans[id].borrower = payable(msg.sender);
        loans[id].currency = currency;

        // Computing the defaulting limit
        uint8 defaultingLimit;
        if (nrOfInstallments <= 3) {
            defaultingLimit = 1;
        } else if (nrOfInstallments <= 5) {
            defaultingLimit = 2;
        } else if (nrOfInstallments >= 6) {
            defaultingLimit = 3;
        }

        uint256 amount = loans[id].amountDue.mod(nrOfInstallments) > 0
            ? loans[id].amountDue.div(nrOfInstallments).add(1)
            : loans[id].amountDue.div(nrOfInstallments);

        loans[id].installment = Installment(
            time,
            amount,
            nrOfInstallments,
            0,
            defaultingLimit
        );

        // Transfer the items from lender to TrustNFT contract
        transferNFT(msg.sender, address(this), nft);

        // Fire event
        emit NewLoan(msg.sender, currency, id, time, loanAmount, loans[id].amountDue, nft);
        ++id;
    }

    // Lender lends to a loan
    function lend(uint256 loanId) external payable {
        require(loans[loanId].lender == address(0));
        require(loans[loanId].paidAmount == 0);
        require(loans[loanId].status == Status.LISTED);

        // Borrower assigned, status is 1, first installment (payment) completed
        loans[loanId].lender = payable(msg.sender);
        loans[loanId].startEnd[1] = block.timestamp.add(
            loans[loanId].installment.nrOfInstallments.mul(
                loans[loanId].installment.time
            )
        );
        loans[loanId].status = Status.APPROVED;
        loans[loanId].startEnd[0] = block.timestamp;

        // We check if currency is BNB
        if (loans[loanId].currency == address(0))
            require(
                msg.value >=
                    loans[loanId].loanAmount.add(
                        loans[loanId].loanAmount.div(lenderFee)
                    )
            );

        // We send the tokens here
        transferPayment(
            msg.sender,
            payable(loans[loanId].borrower),
            loans[loanId].currency,
            loans[loanId].loanAmount,
            loans[loanId].loanAmount.div(lenderFee)
        );

        emit LoanApproved(msg.sender, loanId, loans[loanId].startEnd[1]);
    }

    // Borrower cancels a loan
    function cancel(uint256 loanId) external {
        require(loans[loanId].lender == address(0));
        require(loans[loanId].borrower == msg.sender);
        require(loans[loanId].status != Status.CANCELLED);
        require(loans[loanId].status == Status.LISTED);
        loans[loanId].status = Status.CANCELLED;

        // We send the items back to him
        transferNFT(address(this), loans[loanId].borrower, loans[loanId].nft);

        emit LoanCancelled(loanId);
    }

    // Borrower pays installment for loan. Multiple installments accepted.
    function pay(uint256 loanId, uint256 amount) external payable {
        require(loans[loanId].borrower == msg.sender);
        require(loans[loanId].status == Status.APPROVED);
        require(loans[loanId].startEnd[1] >= block.timestamp);
        require(
            (msg.value > 0 &&
                loans[loanId].currency == address(0) &&
                msg.value == amount) ||
                (loans[loanId].currency != address(0) &&
                    msg.value == 0 &&
                    amount > 0)
        );

        uint256 paidByBorrower = msg.value > 0 ? msg.value : amount;
        uint256 amountPaidAsInstallmentToLender = paidByBorrower; // >> amount of installment that goes to lender
        uint256 interestPerInstallement = paidByBorrower.mul(interestRate).div(
            100
        ); // entire interest for installment
        uint256 platformFeePerInstallment = interestPerInstallement
            .mul(interestRateToPlatform)
            .div(100);

        amountPaidAsInstallmentToLender = amountPaidAsInstallmentToLender.sub(
            platformFeePerInstallment
        );

        loans[loanId].paidAmount = loans[loanId].paidAmount.add(paidByBorrower);
        loans[loanId].installment.nrOfPayments = loans[loanId]
            .installment
            .nrOfPayments
            .add(paidByBorrower.div(loans[loanId].installment.amount));

        if (loans[loanId].paidAmount >= loans[loanId].amountDue)
            loans[loanId].status = Status.LIQUIDATED;

        // We transfer the tokens to borrower here
        transferPayment(
            msg.sender,
            loans[loanId].lender,
            loans[loanId].currency,
            amountPaidAsInstallmentToLender,
            platformFeePerInstallment
        );

        emit LoanPayment(
            loanId,
            paidByBorrower,
            amountPaidAsInstallmentToLender,
            interestPerInstallement,
            platformFeePerInstallment,
            loans[loanId].status
        );
    }

    // Borrower can withdraw loan items if loan is LIQUIDATED
    // Lender can withdraw loan item is loan is DEFAULTED
    function terminate(uint256 loanId) external {
        require(
            msg.sender == loans[loanId].borrower ||
                msg.sender == loans[loanId].lender
        );
        require(loans[loanId].status != Status.WITHDRAWN);
        require(
            (block.timestamp >= loans[loanId].startEnd[1] ||
                loans[loanId].paidAmount >= loans[loanId].amountDue) ||
                canBeTerminated(loanId)
        );
        require(
            loans[loanId].status == Status.LIQUIDATED ||
                loans[loanId].status == Status.APPROVED
        );

        if (canBeTerminated(loanId)) {
            loans[loanId].status = Status.WITHDRAWN;

            // We send the items back to lender
            transferNFT(
                address(this),
                loans[loanId].lender,
                loans[loanId].nft
            );
        } else {
            if (
                block.timestamp >= loans[loanId].startEnd[1] &&
                loans[loanId].paidAmount < loans[loanId].amountDue
            ) {
                loans[loanId].status = Status.WITHDRAWN;

                // We send the items back to lender
                transferNFT(
                    address(this),
                    loans[loanId].lender,
                    loans[loanId].nft
                );
            } else if (loans[loanId].paidAmount >= loans[loanId].amountDue) {
                loans[loanId].status = Status.WITHDRAWN;

                // We send the items back to borrower
                transferNFT(
                    address(this),
                    loans[loanId].borrower,
                    loans[loanId].nft
                );
            }
        }

        emit LoanTerminated(msg.sender, loanId, loans[loanId].status);
    }

    /**
     * @notice Used by the Promissory Note contract to change the ownership of the loan when the Promissory Note NFT is sold
     * @param from The address of the current owner
     * @param to The address of the new owner
     * @param loanIds The ids of the loans that will be transferred to the new owner
     */
    function exchangePromissoryNote(
        address from,
        address payable to,
        uint256[] calldata loanIds
    ) external isPromissoryNote {
        for (uint256 i = 0; i < loanIds.length; ++i) {
            require(loans[loanIds[i]].lender == from);
            require(loans[loanIds[i]].status == Status.APPROVED);
            require(promissoryPermissions[loanIds[i]] == from);
            loans[loanIds[i]].lender = to;
            promissoryPermissions[loanIds[i]] = to;
        }
    }

    /**
     * @notice Used by the Promissory Note contract to approve a list of loans to be used as a Promissory Note NFT
     * @param loanIds The ids of the loans that will be approved
     */
    function setPromissoryPermissions(
        uint256[] calldata loanIds,
        address beneficiary
    ) external {
        require(beneficiary != address(0));
        for (uint256 i = 0; i < loanIds.length; ++i) {
            require(loans[loanIds[i]].lender == msg.sender);
            require(loans[loanIds[i]].status == Status.APPROVED);
            promissoryPermissions[loanIds[i]] = beneficiary;
        }
    }
}