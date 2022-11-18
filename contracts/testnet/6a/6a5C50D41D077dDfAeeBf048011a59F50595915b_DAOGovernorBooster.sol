// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
pragma solidity ^0.8.4;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import {IProjects} from "./interfaces/IProjects.sol";
import {IConfigStore} from "./interfaces/IConfigStore.sol";
import {IDAOGovernorBooster, IMembershipPass} from "./interfaces/IDAOGovernorBooster.sol";

contract DAOGovernorBooster is IDAOGovernorBooster, ERC1155Holder {
  modifier onlyAdmin() {
    if (configStore.superAdmin() != msg.sender) revert UnAuthorized();
    _;
  }
  modifier onlyProjectOwner(uint256 _projectId) {
    if (msg.sender != projects.ownerOf(_projectId)) revert UnAuthorized();
    _;
  }

  /*╔═════════════════════════════╗
    ║   Private Stored Properties ║
    ╚═════════════════════════════╝*/

  mapping(address => mapping(uint256 => uint256)) private _recordCount;

  /*╔═════════════════════════════╗
    ║   Private Stored Constants  ║
    ╚═════════════════════════════╝*/
  // Total seconds of 30 days(30 * 24 * 60 * 60 = 2592000)
  // @TODO 60 * 60
  uint256 private constant SECONDS_IN_MONTH = 2592000;

  /*╔═════════════════════════════╗
    ║    Public Stored Constants  ║
    ╚═════════════════════════════╝*/
  // TODO 1eth=1e18 stake 1 ETH to propose, WETH with 18 decimals
  uint256 public constant PROPOSE_ETH = 1e15;

  IProjects public immutable projects;

  IConfigStore public immutable configStore;

  /*╔═════════════════════════════╗
    ║  Public Stored Properties   ║
    ╚═════════════════════════════╝*/
  // 10 => 10%, the minimum quorem needs for a proposal
  uint256 public proposalRate = 10;

  // Proposal ID, starts from 1
  uint256 public count;

  // proposal ID => StakeETH
  mapping(uint256 => uint256) public stakedETHOf;

  // proposal ID => proposal
  mapping(uint256 => Proposal) public proposalOf;

  // The ID of the DAO => the membershipPass address
  mapping(uint256 => IMembershipPass) public membershipPassOf;

  // Stake record ids
  uint256 public recordId;

  // Stake Pass Record ID => stake record
  mapping(uint256 => StakeRecord) public stakesOf;

  // The ID of the DAO => tierId => multiper
  mapping(uint256 => mapping(uint256 => uint256)) public tierReputationMultiplierOf;

  // The ID of the DAO => Voting Result
  mapping(uint256 => Vote) public votesOf;

  /*╔══════════════════╗
    ║   External VIEW  ║
    ╚══════════════════╝*/

  /**
   * @notice
   * Calculate the reputation points of the wallet address
   *
   * @param _projectId The project id
   * @param _owner The owner to query
   * @param _recordIds The stake record ids and ensure they belong to target project
   */
  function getReputation(
    uint256 _projectId,
    address _owner,
    uint256[] calldata _recordIds
  ) external view override returns (uint256 _reputation) {
    if (_recordIds.length == 0) return 0;

    for (uint256 i; i < _recordIds.length; ) {
      StakeRecord memory _record = stakesOf[_recordIds[i]];
      if (
        _projectId == _record.projectId &&
        _owner == _record.owner &&
        block.timestamp < _record.expiry
      ) {
        _reputation += _record.point;
      }
      unchecked {
        i++;
      }
    }
  }

  /*╔═════════════════════════╗
    ║   External Transaction  ║
    ╚═════════════════════════╝*/

  constructor(IProjects _projects, IConfigStore _configStore) {
    projects = _projects;
    configStore = _configStore;
  }

  /**
   * @notice
   * Setup / create the admin for the governor in the DAO
   *
   * @param _projectId The ID of the DAO
   * @param _multipliers Multiplier for tier reputations
   * @param _membershipPass Membership-pass of the DAO
   */
  function createGovernor(
    uint256 _projectId,
    uint256[] calldata _multipliers,
    address _membershipPass
  ) external override {
    if (!configStore.terminalRoles(msg.sender)) revert UnAuthorized();

    membershipPassOf[_projectId] = IMembershipPass(_membershipPass);
    for (uint256 i; i < _multipliers.length; ) {
      tierReputationMultiplierOf[_projectId][i] = _multipliers[i];
      unchecked {
        i++;
      }
    }

    emit CreateGovernor(_projectId, _membershipPass, _multipliers);
  }

  /**
   * @notice
   * Create a proposal
   *
   * @dev
   * There has different types of proposals, only the DAO Owner can create the proposal that enable to unlock the treasury
   *
   * @param _projectId The ID of the DAO
   * @param _properties The data properties of proposal
   * @param _target The address of Treasury account
   * @param _value The value of ETH
   * @param _signature The signature of the proposal
   * @param _calldata The data of the proposal
   */
  function propose(
    uint256 _projectId,
    ProposalParameter calldata _properties,
    address _target,
    uint256 _value,
    string calldata _signature,
    bytes calldata _calldata
  ) external payable override onlyProjectOwner(_projectId) {
    if (_properties.start >= _properties.end || block.timestamp >= _properties.end)
      revert BadPeriod();
    if (msg.value < PROPOSE_ETH) revert InsufficientBalance();
    // target contract can't be self
    if (_target == address(this)) revert TargetIsSelf();

    // Increment the count, which will be used as the proposal ID.
    count++;

    stakedETHOf[count] = msg.value;

    bytes32 _hash = keccak256(abi.encodePacked(_target, _value, _signature, _calldata));

    // uint256 quorum =  _ceilDiv(votesOf[_projectId].totalVoters);
    proposalOf[count] = Proposal({
      id: count,
      hash: _hash,
      projectId: _projectId,
      ipfsHash: _properties.ipfsHash,
      start: _properties.start,
      end: _properties.end,
      minVotes: _ceilDiv(votesOf[_projectId].totalVotes),
      // @TODO temporary use 1 person for test
      minVoters: 1,
      // minVoters: quorum > 10 ? quorum : 10,
      state: _properties.start > block.timestamp ? ProposalState.Active : ProposalState.Pending
    });

    emit ProposalCreated(
      _projectId,
      msg.sender,
      count,
      _properties,
      _target,
      _value,
      _signature,
      _calldata
    );
  }

  /**
   * @notice
   * Execute the proposal
   *
   * @param _projectId The ID of the DAO
   * @param _proposalId The ID of the proposal to execute
   * @param _proposalResult The proposal result, 0=true 1=false
   * @param _signatureBySigner the signature signed by signer
   */
  function execute(
    uint256 _projectId,
    uint256 _proposalId,
    uint8 _proposalResult,
    bytes memory _signatureBySigner,
    address _target,
    uint256 _value,
    string memory _signature,
    bytes memory _data
  ) external override onlyProjectOwner(_projectId) returns (bytes memory _executeReturns) {
    Proposal storage _proposal = proposalOf[_proposalId];
    if (_proposal.id != _proposalId) revert UnknowProposal();
    if (
      block.timestamp < _proposal.end ||
      _proposal.state == ProposalState.Executed ||
      _proposal.state == ProposalState.Reverted
    ) revert BadPeriod();

    if (!_isAuthorized(msg.sender, _proposalId, _proposalResult, _signatureBySigner))
      revert UnAuthorized();

    if (_proposal.hash != keccak256(abi.encodePacked(_target, _value, _signature, _data)))
      revert TransactionNotMatch();

    _proposal.state = ProposalState.Executed;

    if (_proposalResult == 0) {
      bytes memory _callData;

      if (bytes(_signature).length == 0) {
        _callData = _data;
      } else {
        _callData = abi.encodePacked(bytes4(keccak256(bytes(_signature))), _data);
      }
      // solhint-disable-next-line avoid-low-level-calls
      (bool _success, bytes memory _returnData) = _target.call{value: _value}(_callData);
      if (!_success) revert TransactionReverted();
      _executeReturns = _returnData;
    }
    // refund staked eth in this proposal
    uint256 _staked = stakedETHOf[_proposalId];
    stakedETHOf[_proposalId] = 0;
    Address.sendValue(payable(msg.sender), _staked);

    emit ExecuteProposal(_projectId, msg.sender, _proposalId, _proposalResult);
  }

  /**
   * @notice
   * Admin can withdraw the locked eth of reverted proposals
   *
   * @param _proposalIds reverted proposal ids
   */
  function withdraw(uint256[] calldata _proposalIds) external override onlyAdmin {
    uint256 _totalAmount;
    for (uint256 i = 0; i < _proposalIds.length; i++) {
      if (proposalOf[_proposalIds[i]].state != ProposalState.Reverted) revert BadPeriod();
      if (stakedETHOf[_proposalIds[i]] == 0) revert InsufficientBalance();

      _totalAmount += stakedETHOf[_proposalIds[i]];
      stakedETHOf[_proposalIds[i]] = 0;
    }

    Address.sendValue(payable(msg.sender), _totalAmount);

    emit Withdraw(msg.sender, _proposalIds, _totalAmount);
  }

  /**
   * @notice
   * Admin can revert the incorrect proposal
   *
   * @param _proposalId the proposal id which try to revert
   */
  function revertProposal(uint256 _proposalId) external override onlyAdmin {
    if (proposalOf[_proposalId].id == 0) revert UnknowProposal();

    proposalOf[_proposalId].state = ProposalState.Reverted;

    emit RevertProposal(proposalOf[_proposalId].projectId, _proposalId);
  }

  /**
   * @notice
   * Stake Membership-pass to get reputation
   *
   * @param _projectId The ID of the DAO that user want to stake
   * @param _membershipPass Membership-Pass details
   */
  function stakePass(uint256 _projectId, PassStake[] calldata _membershipPass) external override {
    uint256 _size = _membershipPass.length;
    if (_size == 0) revert InvalidRecord();
    if (membershipPassOf[_projectId] == IMembershipPass(address(0))) revert ZeroAddress();

    uint256 _reputation;
    uint256[] memory _tiers = new uint256[](_size);
    uint256[] memory _amounts = new uint256[](_size);
    uint256[] memory _recordIds = new uint256[](_size);
    for (uint8 i; i < _size; i++) {
      recordId++;
      _tiers[i] = _membershipPass[i].tier;
      _amounts[i] = _membershipPass[i].amount;
      _recordIds[i] = recordId;
      if (_amounts[i] == 0 || _membershipPass[i].duration == 0) revert BadPass();
      uint256 _point = tierReputationMultiplierOf[_projectId][_tiers[i]] *
        _membershipPass[i].duration * // TODO: Duration should be based on 1 month, 3 months, 6 months, 12 months
        _amounts[i];
      stakesOf[recordId] = StakeRecord({
        owner: msg.sender,
        tier: _tiers[i],
        amount: _amounts[i],
        stakeAt: block.timestamp,
        expiry: block.timestamp + SECONDS_IN_MONTH * _membershipPass[i].duration,
        point: _point,
        projectId: _projectId
      });
      _reputation += _point;
    }
    membershipPassOf[_projectId].safeBatchTransferFrom(
      msg.sender,
      address(this),
      _tiers,
      _amounts,
      "0x00"
    );
    // TODO: if Gold Pass: 3pts, Silver: 2pts |  lock 1 month => *1, lock 3 momth => *3
    // how to store the data for user lock Pass multiple times. (數據儲存問題、迴圈查詢、)
    votesOf[_projectId].totalVotes += _reputation;

    // first time to stake
    if (_recordCount[msg.sender][_projectId] == 0) votesOf[_projectId].totalVoters += 1;
    _recordCount[msg.sender][_projectId] += _size;

    emit StakePass(_projectId, msg.sender, _reputation, _tiers, _amounts, _recordIds);
  }

  /**
   * @notice
   * Unstake MembershipPass
   *
   * @param _projectId The project to unstake
   * @param _recordIds The record ids to unstake
   */
  function unStakePass(uint256 _projectId, uint256[] calldata _recordIds) external override {
    uint256 _size = _recordIds.length;

    if (_size == 0) revert InvalidRecord();

    uint256 _reputation;
    uint256[] memory _tiers = new uint256[](_size);
    uint256[] memory _amounts = new uint256[](_size);
    for (uint8 i; i < _size; ) {
      StakeRecord memory _record = stakesOf[_recordIds[i]];
      if (_record.owner != msg.sender) revert UnAuthorized();
      if (block.timestamp < _record.expiry) revert NotExpired();
      _reputation += _record.point;
      _tiers[i] = _record.tier;
      _amounts[i] = _record.amount;
      delete stakesOf[_recordIds[i]];
      unchecked {
        i++;
      }
    }
    membershipPassOf[_projectId].safeBatchTransferFrom(
      address(this),
      msg.sender,
      _tiers,
      _amounts,
      "0x00"
    );

    votesOf[_projectId].totalVotes -= _reputation;
    _recordCount[msg.sender][_projectId] -= _size;
    if (_recordCount[msg.sender][_projectId] == 0) {
      votesOf[_projectId].totalVoters -= 1;
    }

    emit UnStakePass(_projectId, msg.sender, _reputation, _tiers, _amounts, _recordIds);
  }

  /*╔═════════════════════════════╗
    ║   Private Helper Functions  ║
    ╚═════════════════════════════╝*/

  /**
   * @notice
   * Verify the signature
   *
   * @param _from the proposal creator
   * @param _proposalId the target proposal
   * @param _proposalResult the result of proposal 0=true 1=false
   * @param _signature signature signed by signer address
   */
  function _isAuthorized(
    address _from,
    uint256 _proposalId,
    uint8 _proposalResult,
    bytes memory _signature
  ) private view returns (bool) {
    return
      configStore.signerAddress() ==
      ECDSA.recover(
        ECDSA.toEthSignedMessageHash(
          keccak256(abi.encodePacked(_from, _proposalId, _proposalResult))
        ),
        _signature
      );
  }

  /**
   * @notice
   * Returns the integer division of points. The result is rounded up
   *
   * @param _point points
   */
  function _ceilDiv(uint256 _point) private view returns (uint256 _ceiled) {
    _ceiled = (_point * proposalRate + 100 - 1) / 100;
    if (_ceiled == 0) _ceiled = 1;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IConfigStore {
  event SetBaseProjectURI(string uri);

  event SetBaseMembershipPassURI(string uri);

  event SetBaseContractURI(string uri);

  event SetSigner(address signer);

  event SetSuperAdmin(address admin);

  event SetDevTreasury(address devTreasury);

  event SetTapFee(uint256 fee);

  event SetContributeFee(uint256 fee);

  event SetClaimFee(uint256 fee);

  event SetMinLockRate(uint256 minLockRate);

  event RoyaltyFeeSenderChanged(address royaltyFeeSender, bool isAdd);

  event TerminalRoleChanged(address terminal, bool grant);

  event MintRoleChanged(address account, bool grant);

  error BadTapFee();

  error ZeroAddress();

  function baseProjectURI() external view returns (string memory);

  function baseMembershipPassURI() external view returns (string memory);

  function baseContractURI() external view returns (string memory);

  function signerAddress() external view returns (address);

  function superAdmin() external view returns (address);

  function devTreasury() external view returns (address);

  function tapFee() external view returns (uint256);

  function contributeFee() external view returns (uint256);

  function claimFee() external view returns (uint256);

  function minLockRate() external view returns (uint256);

  function royaltyFeeSenderWhiteList(address _sender) external view returns (bool);

  function terminalRoles(address) external view returns (bool);

  function mintRoles(address) external view returns (bool);

  function setBaseProjectURI(string calldata _uri) external;

  function setBaseMembershipPassURI(string calldata _uri) external;

  function setBaseContractURI(string calldata _uri) external;

  function setSigner(address _admin) external;

  function setSuperAdmin(address _signer) external;

  function setDevTreasury(address _devTreasury) external;

  function setTapFee(uint256 _fee) external;

  function setContributeFee(uint256 _fee) external;

  function setClaimFee(uint256 _fee) external;

  function setMinLockRate(uint256 _lockRate) external;

  function addRoyaltyFeeSender(address _sender) external;

  function removeRoyaltyFeeSender(address _sender) external;

  function grantTerminalRole(address _terminal) external;

  function revokeTerminalRole(address _terminal) external;

  function grantMintRole(address _terminal) external;

  function revokeMintRole(address _terminal) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IMembershipPass} from "./IMembershipPass.sol";

interface IDAOGovernorBooster {
  enum ProposalState {
    Pending,
    Active,
    Expired,
    Reverted,
    Executed
  }

  struct Proposal {
    string ipfsHash;
    uint256 id;
    uint256 projectId;
    bytes32 hash;
    uint256 start;
    uint256 end;
    uint256 minVoters;
    uint256 minVotes;
    ProposalState state;
  }

  struct ProposalParameter {
    string ipfsHash;
    uint256 start;
    uint256 end;
  }

  struct Vote {
    uint256 totalVoters;
    uint256 totalVotes;
  }

  struct PassStake {
    uint256 tier;
    uint256 amount; // ERC721: 1
    uint8 duration; // duartion in day
  }

  struct StakeRecord {
    address owner;
    uint256 tier;
    uint256 amount; // ERC721: 1
    uint256 point;
    uint256 stakeAt;
    uint256 expiry;
    uint256 projectId;
  }

  event CreateGovernor(uint256 indexed projectId, address membershipPass, uint256[] multipers);

  event ProposalCreated(
    uint256 indexed projectId,
    address indexed from,
    uint256 proposalId,
    ProposalParameter properties,
    address target,
    uint256 value,
    string signature,
    bytes proposalCalldata
  );

  event ExecuteProposal(
    uint256 indexed projectId,
    address indexed from,
    uint256 proposalId,
    uint8 proposalResult
  );

  event RevertProposal(uint256 indexed projectId, uint256 proposalId);

  event StakePass(
    uint256 indexed projectId,
    address indexed from,
    uint256 points,
    uint256[] tierIds,
    uint256[] amounts,
    uint256[] recordIds
  );

  event UnStakePass(
    uint256 indexed projectId,
    address indexed from,
    uint256 points,
    uint256[] tierIds,
    uint256[] amounts,
    uint256[] recordIds
  );

  event Withdraw(address indexed from, uint256[] proposalIds, uint256 totalAmount);

  error InsufficientBalance();
  error UnknowProposal();
  error BadPeriod();
  error TransactionNotMatch();
  error TransactionReverted();
  error BadPass();
  error NotExpired();
  error InvalidRecord();
  error ZeroAddress();
  error TargetIsSelf();
  error UnAuthorized();

  function getReputation(
    uint256 _projectId,
    address _owner,
    uint256[] calldata _recordIds
  ) external returns (uint256);

  function createGovernor(
    uint256 _projectId,
    uint256[] calldata _multipers,
    address _membershipPass
  ) external;

  function propose(
    uint256 _projectId,
    ProposalParameter calldata _properties,
    address _target,
    uint256 _value,
    string calldata _signature,
    bytes calldata _calldata
  ) external payable;

  function execute(
    uint256 _projectId,
    uint256 _proposalId,
    uint8 _proposeResult,
    bytes calldata _signatureBySigner,
    address _target,
    uint256 _value,
    string calldata _signature,
    bytes calldata _data
  ) external returns (bytes memory);

  function withdraw(uint256[] calldata _proposalIds) external;

  function revertProposal(uint256 _proposalId) external;

  function stakePass(uint256 _projectId, PassStake[] calldata _membershipPass) external;

  function unStakePass(uint256 _projectId, uint256[] calldata _recordIds) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IMembershipPass is IERC1155, IERC2981 {
  event MintPass(address indexed recepient, uint256 indexed tier, uint256 amount);

  event BatchMintPass(address indexed recepient, uint256[] tiers, uint256[] amounts);

  error BadTierSize();
  error ZeroAddress();
  error BadCapacity();
  error BadFee();
  error InsufficientBalance();

  function royaltyInfo(uint256 _tier, uint256 _salePrice)
    external
    view
    override
    returns (address receiver, uint256 royaltyAmount);

  function mintPassForMember(
    address _recepient,
    uint256 _token,
    uint256 _amount
  ) external;

  function batchMintPassForMember(
    address _recepient,
    uint256[] calldata _tokens,
    uint256[] calldata _amounts
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IConfigStore} from "./IConfigStore.sol";

interface IProjects is IERC721 {
  error EmptyHandle();
  error TakenedHandle();
  error UnAuthorized();

  event Create(uint256 indexed projectId, address indexed owner, bytes32 handle, address caller);

  function count() external view returns (uint256);

  function configStore() external view returns (IConfigStore);

  function handleOf(uint256 _projectId) external returns (bytes32 handle);

  function projectFor(bytes32 _handle) external returns (uint256 projectId);

  function exists(uint256 _projectId) external view returns (bool);

  function create(address _owner, bytes32 _handle) external returns (uint256 id);
}