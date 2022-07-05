/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// File: @openzeppelin/contracts/utils/Strings.sol


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

// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;


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
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
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
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// File: contracts/owner.sol


pragma solidity >=0.4.22 <0.9.0;

contract Owner {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(owner == msg.sender, "ERROR: ONLY OWNER");
    _;
  }

  function transferOwnership(address _owner) external onlyOwner {
    owner = _owner;
    emit OwnershipTransferred(msg.sender, owner);
  }
}

// File: contracts/eNFT.sol



pragma solidity >=0.4.22 <0.9.0;




interface STAKE {
  struct info {
    uint256 balance;
    uint256 deposited;
  }
  function data(address addr) external view returns (info memory);
}

interface ERC20TokenInterface {
  function transferFrom(address from, address to, uint256 amount) external;
  function allowance(address owner, address spender) external returns (uint256);
}

/// @author NotableNFT
/// @title Experience NFT smart contract 

contract eNFT is ERC721, Owner {
  event Redeemed(address indexed user, uint256 token);
  event Used(address indexed creator, uint256 token);
  event Traded(address indexed from, address indexed to, uint256 token, uint256 nonce);
  event Minted(address indexed creator, address indexed user, uint256 token, uint256 nonce);
  event NFTChanged(uint256 indexed token, uint256 start, uint256 expire, uint256 pending, uint8 status);
  event MetadataChanged(uint256 indexed token, string metadata);
  event cancelMNonce(address indexed user, uint256 nonce);
  event cancelTNonce(address indexed user, uint256 nonce);
  event revokedApproval(address user);

  struct NFT {
    uint256 start;
    uint256 expire;
    uint256 pending;
    uint8 status;
    bool locked;
    string metadata;
  }

  struct RoyaltyInfo {
    address[] creators;
    uint8[] dist;
  }
  mapping(uint256 => NFT) public data;
  mapping(uint256 => RoyaltyInfo) royalties;
  mapping(address => mapping(uint256 => uint256)) public nonce;
  mapping(address => mapping(uint256 => bool)) public tradeNonce;
  mapping(address => bool) public allowContract;
  mapping(address => bool) public allowedForApproval;
  
  address public authorizer;
  address public nProfit;
  address public nFund;
  STAKE public staking;

  uint256 public TRADE_PROFIT = 2;
  uint256 public PROFIT = 9;
  uint256 public TRADE_BASE = 4;
  uint256 public BASE = 85;
  uint256 public VALUE = 87;

  uint256 public totalSupply = 0;

  struct tier {
    uint256 holding;
    uint256 bonus;
  }
  tier[4] public cTiers;
  tier[4] public pTiers;

  constructor(address profit, address fund, address auth, address stake) ERC721("Experience NFT", "eNFT") {
    nProfit = profit;
    nFund = fund;
    staking = STAKE(stake);
    authorizer = auth;
    allowedForApproval[address(0)] = true;
  }

  function allowForApproval(address _contract) external onlyOwner {
    allowedForApproval[_contract] = true;
  }
  function disallowForApproval(address _contract) external onlyOwner {
    require(_contract != address(0), "ERROR: Address 0 has to be allowed for approvals");
    allowedForApproval[_contract] = false;
  }

  function approve(address to, uint256 tokenId) public override {
    require(allowedForApproval[to], "ERROR: NOT ALLOWED FOR APPROVAL");
    super.approve(to, tokenId);
  }

  function changeProfitAddress(address addr) external onlyOwner {
    nProfit = addr;
  }
  function changeFundAddress(address addr) external onlyOwner {
    nFund = addr;
  }
  function changeStakingAddress(address addr) external onlyOwner {
    staking = STAKE(addr);
  }
  function changeAuthorizationAddress(address addr) external onlyOwner {
    authorizer = addr;
  }

  function changeToken(uint256 _tokenId, uint256 _start, uint256 _expire, uint256 _pending, uint8 _status, address[] memory _creators, uint8[] memory _dist) external onlyOwner {
    require(_creators.length <= 10 && _dist.length == _creators.length - 1, "ERROR: ARRAY SIZE");
    data[_tokenId].start = _start;
    if (!data[_tokenId].locked) {
      data[_tokenId].expire = _expire;
      royalties[_tokenId].creators = _creators;
    }
    royalties[_tokenId].dist = _dist;
    data[_tokenId].pending = _pending;
    data[_tokenId].status = _status;
    emit NFTChanged(_tokenId, _start, _expire, _pending, _status);
  }

  function updateMetadata(uint256 _tokenId, string calldata _metadata) external onlyOwner {
    data[_tokenId].metadata = _metadata;
    emit MetadataChanged(_tokenId, _metadata);
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(tokenId <= totalSupply && totalSupply != 0, "ERC721Metadata: URI query for nonexistent token");
    return string(abi.encodePacked("ipfs://", data[tokenId].metadata));
  }

  function  setPercentages(uint256 tp, uint256 p, uint256 tb, uint256 b, uint256 v) external onlyOwner {
    TRADE_PROFIT = tp;
    PROFIT = p;
    TRADE_BASE = tb;
    BASE = b;
    VALUE = v;
  }

  function setCreatorTiers(tier calldata one, tier calldata two, tier calldata three, tier calldata four) external onlyOwner {
    cTiers[0] = one;
    cTiers[1] = two;
    cTiers[2] = three;
    cTiers[3] = four;
  }

  function setPurchaseTiers(tier calldata one, tier calldata two, tier calldata three, tier calldata four) external onlyOwner {
    pTiers[0] = one;
    pTiers[1] = two;
    pTiers[2] = three;
    pTiers[3] = four;
  }

  function getPrice(address user, uint256 _price) public view returns (uint256) {
    return _price - _price * getStakingBenefit(user, true) / 10000; // Allow 2 decimal points after %
  }

  function getStakingBenefit(address user, bool purchaser) public view returns (uint256) {
    tier[4] memory Tiers;
    if (purchaser) Tiers = pTiers;
    else Tiers = cTiers;
    uint256 balance = staking.data(user).balance;
    if (balance >= Tiers[0].holding) {
      for (uint256 i = 1; i < 4; i++) {
        if (balance < Tiers[i].holding) {
          return Tiers[i - 1].bonus;
        }
      }
      return Tiers[3].bonus;
    }
    return 0;
  }

  function cancelMintNonce(uint256 _nonce) external {
    require(nonce[msg.sender][_nonce] == 0, "ERROR: USED NONCE");
    nonce[msg.sender][_nonce] = 1;
    emit cancelMNonce(msg.sender, _nonce);
  }

  function cancelTradeNonce(uint256 _nonce) external {
    require(tradeNonce[msg.sender][_nonce] == false, "ERROR: USED NONCE");
    tradeNonce[msg.sender][_nonce] = true;
    emit cancelTNonce(msg.sender, _nonce);
  }

  function tokenData(uint256 _tokenId) external view returns (NFT memory, address) {
    return (data[_tokenId], royalties[_tokenId].creators[0]);
  }

  function mint(address _currency, uint256[] memory _nums, address[] calldata _creators, uint8[] calldata _dist, bool _locked, string memory _metadata, bytes calldata _signature) external {
    require(_creators.length <= 10 && _dist.length == _creators.length - 1, "ERROR: ARRAY SIZE");
    require(nonce[_creators[0]][_nums[3]] == 0, "ERROR: USED NONCE");
    require(mintSigner(_currency, _nums, _creators, _dist, _locked, _metadata, _signature) == authorizer, "ERROR: BAD SIGNATURE");
    uint256 requiredAmount = getPrice(msg.sender, _nums[0]);

    totalSupply += 1;
    nonce[_creators[0]][_nums[3]] = totalSupply;
    _mint(msg.sender, totalSupply);
    data[totalSupply] = NFT(_nums[1], _nums[2], 0, 0, _locked, _metadata);
    royalties[totalSupply] = RoyaltyInfo(_creators, _dist);
    distributeFunds(msg.sender, _currency, totalSupply, _nums[0], requiredAmount, false, _creators, _dist);
    emit Minted(_creators[0], msg.sender, totalSupply, _nums[3]);
  }

  function trade(address _buyer, address _currency, uint256 _price, uint256 _tokenId, uint256 _nonce, uint256 _timestamp, bytes calldata signature) external {
    require(tradeNonce[ownerOf(_tokenId)][_nonce] == false, "ERROR: USED NONCE");
    require(_timestamp >= (block.timestamp - 1 days) && _timestamp < block.timestamp, "ERROR: TIME"); 
    require(tradeSigner(_currency, _price, _tokenId, ownerOf(_tokenId), _buyer, _nonce, _timestamp, signature) == authorizer, "ERROR: BAD SIGNATURE");
    require(allowContract[ownerOf(_tokenId)], "ERROR: SELLER HAS NOT AUTHORIZED THE CONTRACT");
    uint256 requiredAmount = getPrice(_buyer, _price);

    tradeNonce[ownerOf(_tokenId)][_nonce] = true;
    distributeFunds(_buyer, _currency, _tokenId, _price, requiredAmount, true, royalties[_tokenId].creators, royalties[_tokenId].dist);
    emit Traded(ownerOf(_tokenId), _buyer, _tokenId, _nonce);
    _transfer(ownerOf(_tokenId), _buyer, _tokenId);
  }

  function mintETH(uint256[] memory _nums, address[] calldata _creators, uint8[] calldata _dist, bool _locked, string memory _metadata, bytes calldata _signature) external payable {
    require(_creators.length <= 10 && _dist.length == _creators.length - 1, "ERROR: ARRAY SIZE");
    require(nonce[_creators[0]][_nums[3]] == 0, "ERROR: USED NONCE");
    require(mintSigner(address(0), _nums, _creators, _dist, _locked, _metadata, _signature) == authorizer, "ERROR: BAD SIGNATURE");
    uint256 requiredAmount = getPrice(msg.sender, _nums[0]);
    require(msg.value >= requiredAmount, "ERROR: PAYMENT AMOUNT");
    if (msg.value > requiredAmount) payable(msg.sender).transfer(msg.value - requiredAmount);    

    totalSupply += 1;
    nonce[_creators[0]][_nums[3]] = totalSupply;
    _mint(msg.sender, totalSupply);
    data[totalSupply] = NFT(_nums[1], _nums[2], 0, 0, _locked, _metadata);
    royalties[totalSupply] = RoyaltyInfo(_creators, _dist);
    distributeFundsETH(totalSupply, _nums[0], false, _creators, _dist);
    emit Minted(_creators[0], msg.sender, totalSupply, _nums[3]);
  }

  function tradeETH(uint256 _price, uint256 _tokenId, uint256 _nonce, uint256 _timestamp, bytes calldata signature) external payable {
    require(tradeNonce[ownerOf(_tokenId)][_nonce] == false, "ERROR: USED NONCE");
    require(_timestamp >= (block.timestamp - 1 days) && _timestamp < block.timestamp, "ERROR: TIME"); 
    require(tradeSigner(address(0), _price, _tokenId, ownerOf(_tokenId), msg.sender, _nonce, _timestamp, signature) == authorizer, "ERROR: BAD SIGNATURE");
    require(allowContract[ownerOf(_tokenId)], "ERROR: SELLER HAS NOT AUTHORIZED THE CONTRACT");
    uint256 requiredAmount = getPrice(msg.sender, _price);
    require(msg.value >= requiredAmount, "ERROR: PAYMENT AMOUNT");
    if (msg.value > requiredAmount) payable(msg.sender).transfer(msg.value - requiredAmount);

    tradeNonce[ownerOf(_tokenId)][_nonce] = true;
    distributeFundsETH(_tokenId, _price, true, royalties[_tokenId].creators, royalties[_tokenId].dist);
    emit Traded(ownerOf(_tokenId), msg.sender, _tokenId, _nonce);
    _transfer(ownerOf(_tokenId), msg.sender, _tokenId);
  }

  function redeem(uint256 _tokenId, uint256 timestamp, bytes calldata signature) external {
    require(msg.sender == ownerOf(_tokenId), "ERROR: ONLY OWNER CAN REDEEM");
    require(block.timestamp >= data[_tokenId].start && block.timestamp < data[_tokenId].expire, "ERROR: TIME");
    require(data[_tokenId].status == 0 || (data[_tokenId].status == 1 && (block.timestamp - 90 days) >= data[_tokenId].pending), "ERROR: TOKEN CANNOT BE REDEEMED");
    require(redeemSigner(_tokenId, timestamp, signature) == authorizer && (block.timestamp - 1 days) < timestamp && timestamp < block.timestamp, "ERROR: BAD SIGNATURE");
    data[_tokenId].status = 1;
    data[_tokenId].pending = block.timestamp;
    emit Redeemed(msg.sender, _tokenId); 
  }

  function used(uint256 _tokenId) external {
    require(msg.sender == royalties[_tokenId].creators[0], "ERROR: ONLY THE MAIN CREATOR CAN CHANGE STATUS TO USED");
    require(data[_tokenId].status == 1 && (block.timestamp - 90 days) < data[_tokenId].pending, "ERROR: TOKEN STATUS CANNOT BE SET TO USED");
    data[_tokenId].status = 2;
    emit Used(msg.sender, _tokenId);
  }

  function redeemable(uint256 _tokenId) external {
    require(data[_tokenId].status == 1 && (block.timestamp - 90 days) >= data[_tokenId].pending, "ERROR: CANNOT REVERT TOKEN BACK TO REDEEMABLE");
    data[_tokenId].status = 0;
    data[_tokenId].pending = 0;
  }

  function distributeFunds(address _buyer, address _currency, uint256 _tokenId, uint256 _price, uint256 _required, bool _trade, address[] memory _creators, uint8[] memory _dist) internal {
    uint256 sent;
    uint256 base;
    ERC20TokenInterface tkn = ERC20TokenInterface(_currency);

    if (_trade) {
      tkn.transferFrom(_buyer, nProfit, _price * TRADE_PROFIT / 100);
      sent = (_price * TRADE_PROFIT / 100);
      tkn.transferFrom(_buyer, ownerOf(_tokenId), _price * VALUE / 100);
      sent += _price * VALUE / 100;
      base = TRADE_BASE;
    } else {
      tkn.transferFrom(_buyer, nProfit, _price * PROFIT / 100);
      sent = (_price * PROFIT / 100);
      base = BASE;
    }

    uint256 last = 100;
    uint256 cut;
    for (uint256 i = 0; i < _dist.length; i++) {
      cut = (_price * (base * 100 + getStakingBenefit(_creators[i], false)) / 10000) * _dist[i] / 100;
      tkn.transferFrom(_buyer, _creators[i], cut);
      sent += cut;
      last -= _dist[i];
    }
    cut = (_price * (base * 100 + getStakingBenefit(_creators[_dist.length], false)) / 10000) * last / 100;
    tkn.transferFrom(_buyer, _creators[_dist.length], cut);
    sent += cut;

    tkn.transferFrom(_buyer, nFund, _required - sent);
  }

  function distributeFundsETH(uint256 _tokenId, uint256 _price, bool _trade, address[] memory _creators, uint8[] memory _dist) internal {
    uint256 sent;
    uint256 base;

    if (_trade) {
      payable(nProfit).transfer(_price * TRADE_PROFIT / 100);
      sent = (_price * TRADE_PROFIT / 100);
      payable(ownerOf(_tokenId)).transfer(_price * VALUE / 100);
      sent += _price * VALUE / 100;
      base = TRADE_BASE;
    } else {
      payable(nProfit).transfer(_price * PROFIT / 100);
      sent = (_price * PROFIT / 100);
      base = BASE;
    }

    uint256 last = 100;
    uint256 cut;
    for (uint256 i = 0; i < _dist.length; i++) {
      cut = (_price * (base * 100 + getStakingBenefit(_creators[i], false)) / 10000) * _dist[i] / 100;
      payable(_creators[i]).transfer(cut);
      sent += cut;
      last -= _dist[i];
    }
    cut = (_price * (base * 100 + getStakingBenefit(_creators[_dist.length], false)) / 10000) * last / 100;
    payable(_creators[_dist.length]).transfer(cut);
    sent += cut;

    payable(nFund).transfer(msg.value - sent);
  }

  function royaltyInfoArray(uint256 _tokenId, uint256 _salePrice) external view returns (address[12] memory receiver, uint256[12] memory royaltyAmount) {
    uint256 sent;

    address[12] memory receivers;
    uint256[12] memory amounts;

    address[] memory _creators = royalties[_tokenId].creators;
    uint8[] memory _dist = royalties[_tokenId].dist;

    receivers[0] = nProfit;
    amounts[0] = _salePrice * PROFIT / 100;
    sent = (_salePrice * PROFIT / 100);

    uint256 last = 100;
    for (uint256 i = 0; i < _dist.length; i++) {
      receivers[2 + i] = _creators[i];
      amounts[2 + i] = (_salePrice * (BASE * 100 + getStakingBenefit(_creators[i], false)) / 10000) * _dist[i] / 100;
      sent += amounts[2 + i];
      last -= _dist[i];
    }
    receivers[2 + _dist.length] = _creators[_dist.length];
    amounts[2 + _dist.length] = (_salePrice * (BASE * 100 + getStakingBenefit(_creators[_dist.length], false)) / 10000) * last / 100;
    sent += amounts[2 + _dist.length];

    receivers[1] = nFund;
    amounts[1] = _salePrice - sent;
    return (receivers, amounts);
  }

  function redeemSigner(uint256 _tokenId, uint256 timestamp, bytes calldata _signature) public pure returns (address) {
    bytes memory _data = abi.encodePacked(_tokenId, timestamp);
    return ECDSA.recover(
        ECDSA.toEthSignedMessageHash(keccak256(_data)),
        _signature
      );
  }

  function tradeSigner(address _currency, uint256 _price, uint256 _tokenId, address _owner, address _buyer, uint256 _nonce, uint256 _timestamp, bytes calldata _signature) public pure returns (address) {
    bytes memory _data = abi.encodePacked(_currency, _price, _tokenId, _owner, _buyer, _nonce, _timestamp);
    return ECDSA.recover(
        ECDSA.toEthSignedMessageHash(keccak256(_data)),
        _signature
      );
  }

  function mintSigner(address _currency, uint256[] memory _nums, address[] memory _creators, uint8[] memory _dist, bool _locked, string memory _metadata, bytes calldata _signature) public pure returns (address) {
    bytes memory _data = abi.encodePacked(_currency, _nums[0], _nums[1], _nums[2], _nums[3], _locked, _metadata);
    for (uint256 i = 0; i < _creators.length - 1; i++) {
      _data = abi.encodePacked(_data, _creators[i], _dist[i]);
    }
    _data = abi.encodePacked(_data, _creators[_creators.length - 1]);
    return ECDSA.recover(
        ECDSA.toEthSignedMessageHash(keccak256(_data)),
        _signature
      );
  }

  function approveContract() external {
    allowContract[msg.sender] = true;
  }

  function revokeContractApproval() external {
    allowContract[msg.sender] = false;
    emit revokedApproval(msg.sender);
  }
  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal view override {
    require(data[tokenId].status != 1 || (data[tokenId].status == 1 && (block.timestamp - 90 days) >= data[tokenId].pending), "ERROR: PENDING TOKENS CANNOT BE TRANSFERRED");
  }
}