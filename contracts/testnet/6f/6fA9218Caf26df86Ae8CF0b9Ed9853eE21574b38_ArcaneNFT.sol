/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

//  * SPDX-License-Identifier: MIT


pragma solidity ^0.8.16;

abstract contract isStone {
    /*=== Strings ===*/
    string public fireStone = "https://bafybeigwfydbmmzdqvi6c5zuocpwegabnhtoki7qxrvk7kvdr6ey5mfd3e.ipfs.nftstorage.link/";
    string public waterStone = "https://bafybeieyx6iavex5butju6wiqwtqcgqbchilovx47pwv7mvg6v2wnwk72q.ipfs.nftstorage.link/";
    string public soulStone = "https://bafybeihbbzdhy3s7mda2chhb4mtvq4rj2eo4jqc2lnvxdkvdvc66voi6mu.ipfs.nftstorage.link/";
    string public lifeStone = "https://bafybeifkfjkw7s5ht3rtckvdtl5cng7r6ugcrdlbzuf5fenmbvlxv7a3pu.ipfs.nftstorage.link/";
}
// File: Contract/SafeMathInt.sol



/*
MIT License

Copyright (c) 2018 requestnetwork
Copyright (c) 2018 Fragments, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity ^0.8.16;

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}
// File: Contract/SafeMathUint.sol



pragma solidity ^0.8.16;

/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
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

// File: Contract/LibraryStruct.sol


pragma solidity ^0.8.16;

library NFTStruct {
    /*=== Structs ===*/
    struct CreateNFT {
        address payable userAdmin; // Dono da NFT
        uint256 idNFT; // ID da NFT
        uint256 initialValue; // Valor Inicial Aportado na NFT
        uint256 percentBoost; // Porcentagem de Boost da NFT
        uint256 valueBoost; // Valor Inicial + Boost
        uint256 startVesting; // Bloco Inicial do Periodo de Vesting
        uint256 endVesting; // Bloco Final do Periodo de Vesting
        uint256 startBlock; // Bloco Inicial do Stake
        string nameNFT; // Define o Nome da NFT
        bool isUser; // Verifica se é Dono dessa NFT
        bool isStaking; // Verifica se está em Staking
        bool isPrivateSale; // Verifica se está na Private-Sale
        bool isPreSale; // Verifica se está na Pre-Venda
        bool isShareholder; // Verifica se é Cotista
    }
    struct CountNFT {
        uint256 counter; 
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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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

// File: @openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

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

// File: @openzeppelin/contracts/token/ERC1155/ERC1155.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;







/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
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
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// File: @openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/extensions/ERC1155URIStorage.sol)

pragma solidity ^0.8.0;



/**
 * @dev ERC1155 token with storage based token URI management.
 * Inspired by the ERC721URIStorage extension
 *
 * _Available since v4.6._
 */
abstract contract ERC1155URIStorage is ERC1155 {
    using Strings for uint256;

    // Optional base URI
    string private _baseURI = "";

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the concatenation of the `_baseURI`
     * and the token-specific uri if the latter is set
     *
     * This enables the following behaviors:
     *
     * - if `_tokenURIs[tokenId]` is set, then the result is the concatenation
     *   of `_baseURI` and `_tokenURIs[tokenId]` (keep in mind that `_baseURI`
     *   is empty per default);
     *
     * - if `_tokenURIs[tokenId]` is NOT set then we fallback to `super.uri()`
     *   which in most cases will contain `ERC1155._uri`;
     *
     * - if `_tokenURIs[tokenId]` is NOT set, and if the parents do not have a
     *   uri value set, then the result is empty.
     */
    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        string memory tokenURI = _tokenURIs[tokenId];

        // If token URI is set, concatenate base URI and tokenURI (via abi.encodePacked).
        return bytes(tokenURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenURI)) : super.uri(tokenId);
    }

    /**
     * @dev Sets `tokenURI` as the tokenURI of `tokenId`.
     */
    function _setURI(uint256 tokenId, string memory tokenURI) internal virtual {
        _tokenURIs[tokenId] = tokenURI;
        emit URI(uri(tokenId), tokenId);
    }

    /**
     * @dev Sets `baseURI` as the `_baseURI` for all tokens
     */
    function _setBaseURI(string memory baseURI) internal virtual {
        _baseURI = baseURI;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: Contract/DividendsNFT.sol

/**
 * Develop by CPTRedHawk
 * @ Esse contrato Foi desenvolvido por https://t.me/redhawknfts
 * Feito para uso Exclusivo do Projeto Arcane Cards: https://t.me/ArcaneCards
 * Caso queira ter uma plataforma similar, gentileza chamar no Telegram!
 * Esse Contrato possui um sistema completo de Pré-Venda, Whitelist, NFTs, Stake e Marketplace
 * E também possui um sistema inovador que paga aos usuarios por fazerem Stake em NFT, dividendos em BNB
 * Entrega teu caminho ao senhor, e tudo ele o fará! Salmos 37
 */

pragma solidity ^0.8.16;






contract DividendsPaying is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    // Magnitude consegue pagar a quantidade de Recompensa mesmo que seja um Saldo Pequeno
    uint256  public magnitude = 2**128;
    // Multiplicador de Dividendos
    uint256 public magnifiedDividendPerShare;
    // Total SUpply
    uint256 public totalSupply = 30000000 * 10**18;
    // Distribuição Total
    uint256 public totalDividendsDistributed;
    // define tempo de claim
    uint256 public timeClaim;

    // Utilizado para Evitar Bugs, Gera um grande Numero (magnifiedDividendCorrections / magnitude)
    mapping(address => int256) private magnifiedDividendCorrections;
    // Armazena Saldo de Retirada dos Dividendos
    mapping(address => uint256) public withdrawnDividends;
    // Armazena Saldo do Usuario
    mapping(address => uint256) public balanceUser;
    // Tempo de Claim
    mapping(address => uint256) public claimWait;


    receive() external payable {
        distributeDividends();
    }

    function distributeDividends() internal {
        if(msg.value > 0) {
            // Faz a soma dos Dividendos
            magnifiedDividendPerShare += (msg.value).mul(magnitude).div(totalSupply);
            // Pega o Total de Dividendos já distribuidos
            totalDividendsDistributed += msg.value;
        }
    }

    function addBalance(address recipient, uint256 amount) external onlyOwner {
        balanceUser[recipient] += amount;
        uint256 balance = balanceUser[recipient];
        magnifiedDividendCorrections[recipient] = balance.toInt256Safe();
    }
    function newBalance(address sender, address recipient, uint256 amount) external onlyOwner  {
        int256 _magCorrection = magnifiedDividendPerShare.mul(amount).toInt256Safe();
        balanceUser[sender] -= amount;
        balanceUser[recipient] += amount;
        magnifiedDividendCorrections[sender] = magnifiedDividendCorrections[sender].add(_magCorrection);
        magnifiedDividendCorrections[recipient] = magnifiedDividendCorrections[recipient].sub(_magCorrection);
    }
    function changeTimeClaim(uint256 _timeClaim) external onlyOwner {
        timeClaim = _timeClaim;
    }
    function withdrawableDividendOf(address owner) public view returns(uint256) {
        return accumulativeDividendOf(owner).sub(withdrawnDividends[owner]);
    }
    function accumulativeDividendOf(address owner) public view returns(uint256) {
        // Estrutura owner
        uint256 balance = balanceUser[owner];
        return magnifiedDividendPerShare.mul(balance).toInt256Safe().add(magnifiedDividendCorrections[owner]).toUint256Safe().div(magnitude);
    }
    function withdrawMyReward(address user) public nonReentrant {
        uint256 time = block.timestamp;
        uint256 timeGet = claimWait[user];
        require(time > timeGet, "Aguardar tempo de Bloqueio");
        claimWait[user] = block.timestamp + timeClaim;
        uint256 balance =  withdrawableDividendOf(user);
        if(balance > 0) {
            withdrawnDividends[user] += balance;
            (bool success, ) = user.call{ value: balance }("");
            require(success, "Address: unable to send value, recipient may have reverted");
        }
    }
}
// File: Contract/GenerateRand.sol



pragma solidity ^0.8.16; 



contract Random is Ownable {
    using SafeMath for uint256;

    uint256 private randNonce;



    function randMod(uint256 modulus) private returns(uint256) {
        randNonce++;
        return uint256(keccak256(abi.encodePacked(block.number, _msgSender(), randNonce))) % modulus;
    }
    function generateRandMod() external onlyOwner returns(uint256) {
        uint256 rand = randMod(60);
        uint256 result;
        if (rand <= 40) {
            if(rand < 10) {
                result = 10;
            }
            else {
                result = rand;
            }
        }
        else if (rand > 40 && rand <= 45 ) {
            result = rand;
        }
        else if (rand > 45 && rand <= 50) {
            result = rand;
        }
        else if (rand > 50 && rand <= 55) {
            result = rand;
        }
        else if (rand > 55 && rand <= 58) {
            result = rand;
        }
        else if (rand > 58 && rand <= 60) {
            result = rand;
        }
        return result;
    }
}
// File: Contract/StakingRewards.sol


pragma solidity ^0.8.16;



abstract contract StakeSystem is Ownable {
    using SafeMath for uint256; // SafeMath para uint256
    /*=== Mapping ===*/
    mapping (address => uint256) public balanceUser; // Saldo 
    mapping (address => uint256) public rewards; // Recompensa
    mapping (address => uint256) public userRewardPerTokenPaid; // Recompensa Paga
    mapping (address => uint256) public harvestTime; // Tempo de Colheita
    /*=== Uints ===*/
    uint256 public lastUpdateTime; // Tempo Stake
    uint256 public periodFinish; // Encerramento Stake
    uint256 public rewardRate; // Gera a Recompensa por Token
    uint256 public rewardsDuration; // Duração da Pool
    uint256 public rewardPerTokenStored; // Armazena Recompensa Por Token
    uint256 private stakingDecimalRate = 10**18; // Fator Decimal
    uint256 public totalSupplyRewards; // Total Aportado dos Usuarios
    uint256 public harvTime; // Tempo entre Colheita
    /*=== Modifier ===*/
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastRewardTimeApplied();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    /*=== Private/Internal/Public ===*/
    function blockHarvest() internal {
        harvestTime[_msgSender()] = block.timestamp + harvTime;
    }
    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        return a < b ? a : b;
    }
    function lastRewardTimeApplied() public view returns(uint256) {
        return min(block.timestamp, periodFinish);
    }
    function rewardPerToken() public view returns(uint256) {
        if(totalSupplyRewards == 0) {
            return rewardPerTokenStored;
        }
        return 
            rewardPerTokenStored.add(lastRewardTimeApplied()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(stakingDecimalRate)
            .div(totalSupplyRewards));
    }
    function earned(address account) public view returns (uint256) {
        return         
            balanceUser[account]
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(stakingDecimalRate)
            .add(rewards[account]);
    }
    function harvestUser() public view returns(uint256) {
        uint256 currentTimes = block.timestamp;
        uint256 userHarv = harvestTime[_msgSender()];
        if(currentTimes >= userHarv) {
            return 0;
        }
        else {
            return userHarv - currentTimes;
        }
    }
    function getRewardForDuration() public view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }
    /*=== Administrativo ===*/
    function initRewards(uint256 rAmount, uint256 tDurantion) external onlyOwner updateReward(address(0)) {
        rewardRate = (rAmount * 10**18).div(tDurantion);
        periodFinish = block.timestamp + tDurantion;
        rewardsDuration = tDurantion;
        lastUpdateTime = block.timestamp;
    }
    function setHarvest(uint256 _harvTime) external onlyOwner {
        harvTime = _harvTime;
    }
}
// File: Contract/StakeNFT.sol

/**
 * Develop by CPTRedHawk
 * @ Esse contrato Foi desenvolvido por https://t.me/redhawknfts
 * Caso queira ter uma plataforma similar, gentileza chamar no Telegram!
 * Entrega teu caminho ao senhor, e tudo ele o fará! Salmos 37
 */
pragma solidity ^0.8.16; 










interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



contract ArcaneNFT is ERC1155URIStorage, Ownable, StakeSystem, isStone {
    using SafeMath for uint256; // SafeMath para uint256
    using NFTStruct for NFTStruct.CreateNFT; // Estrutura NFT
    using NFTStruct for NFTStruct.CountNFT; // EStrutura ID 
    /*=== Mapping ===*/
    mapping (uint256 => NFTStruct.CreateNFT) public createNFT; // Mapeamento das NFTs
    /*=== Address ===*/
    IBEP20 public token; // Endereço BEP20
    Random public randons; // Endereço RandMod
    DividendsPaying public dividends; // Endereço Dividendos
    address private receiveAddress;
    address private burnAddress = 0x000000000000000000000000000000000000dEaD;
    /*=== Uints ===*/
    uint256 public counterNFT; // Contador NFT
    uint256 private feeBNB; // Taxa em BNB
    uint256 public totalValueLocked; // Valor total em Stake
    uint256 public totalLiquidity; // Liquidez total na Pool
    uint256 private feeTax; // Taxa em ARC
    uint256 public totalFee; // Taxas Arrecadadas
    uint256 public timeOne = 1900000; //  21 Dias
    uint256 public timeTwo = 3100000; // 35 Dias
    /*=== Booleano ===*/
    bool private activeStake; // Ativa ou Desativa o Stake
    /*=== Constructor ===*/
    constructor(IBEP20 _token, uint256 _feeBNB) ERC1155("") {
        token = _token; // Define Endereço BEP20
        feeBNB = _feeBNB; // Define Taxa BNB
        randons = new Random(); // Define Endereço de Random
        dividends = new DividendsPaying(); // Define Endereço de Dividendos
    }
    /*=== Event ===*/
    event NewMint(address indexed from, address indexed to, uint256 indexed id);
    event NewStake(address indexed sender, uint256 indexed sAmount, uint256 indexed bAmount);
    event UriNFT(uint256 indexed id, string indexed newUri);
    /*=== Receive ===*/
    receive() external payable {}
    /*=== Modifier ===*/
    modifier decompose(uint256 id, address account) {
        require(vestingTime(id) == 0, "Tempo de Bloqueio precisa estar Zerado");
        NFTStruct.CreateNFT storage nft = createNFT[id];
         require(nft.userAdmin == account, "Voce precisa ser dono dessa NFT");
         if(nft.isShareholder) {
             revert("Cotista nao pode Desfazer NFT");
         }
        if(nft.isPreSale || nft.isPrivateSale) {
            revert("Voce nao pode desfazer essa NFT");
        }
        if(nft.isStaking) {
            revert("Precisa sair do Stake para Decompor essa NFT");
        }
        _;
    }
    /*=== Private/Internal ===*/
    function generateID() internal returns(uint256) {
        return counterNFT += 1; // Gera um novo ID 
    }
    function generateBlockTime(uint256 boost) internal view returns(uint256) {
        if(boost <= 40) {
            return timeOne;
        }
        else {
            return timeTwo;
        }
    }
    function vestingTime(uint256 id) public view returns(uint256) {
        NFTStruct.CreateNFT storage nft = createNFT[id];
        uint256 currentTimes = block.timestamp;
        uint256 endBlock = nft.endVesting;
        if(currentTimes >= endBlock) {
            return 0;
        }
        else {
            return endBlock - currentTimes;
        }
    }
    function randomOwner() public view returns(address) {
        return randons.owner();
    }
    function dividendsOwner() public view returns(address) {
        return dividends.owner();
    }
    function withdrawableDividendOf(address sender) public view returns(uint256) {
        return dividends.withdrawableDividendOf(sender);
    }
    function accumulativeDividendOf(address sender) public view returns(uint256) {
        return dividends.accumulativeDividendOf(sender);
    }
    function fetchMyNfts(address account) public view returns(NFTStruct.CreateNFT[] memory) {
        // Pega o Ultimo NFT mintado
        uint256 totalNft = counterNFT;
        // Cria o sistema de Iteração
        uint256 itemCount = 0;
        // Pega o Ultimo ID do _msgSender()
        uint256 currentIndex = 0;
        // Cria uma Iteração para o LOOP FOR pegando todas as Ids do OwnerNFT
        for (uint i = 0; i < totalNft; i++) {
            if (createNFT[i + 1].userAdmin == account) {
            itemCount += 1;
            }
        }
        // Gera uma Nova Iteração com os IDs já definidos de cada _msgSender()
        NFTStruct.CreateNFT[] memory items = new NFTStruct.CreateNFT[](itemCount);
        for (uint i = 0; i < totalNft; i++) {
            if (createNFT[i + 1].userAdmin == account) {
            uint currentId = i + 1;
            NFTStruct.CreateNFT storage currentItem = createNFT[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
            }
        }
        return items;
    }
    function stringCallData(uint256 id, string memory nftUri) private  {
        _setURI(id, nftUri); // Armazena URI
        emit UriNFT(id, nftUri); // Emite um Evento
    }
    // function stringsEquals(string memory s1, string memory s2) private pure returns (bool) {
    // bytes memory b1 = bytes(s1);
    // bytes memory b2 = bytes(s2);
    // uint256 l1 = b1.length;
    // if (l1 != b2.length) return false;
    // for (uint256 i=0; i<l1; i++) {
    //     if (b1[i] != b2[i]) return false;
    // }
    // return true;
    // }
    /*=== External/Public ===*/
    function castingNFT(uint256 tAmount, uint256 idStone) external payable {
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "Saldo em BNB nao definido");
        }
        require(activeStake, "Stake precisa ser ativado");
        require(tAmount > 0, "Amount precisa ser maior do que Zero");
        totalValueLocked += tAmount;
        uint256 initialTime = block.timestamp; 
        uint256 newID = generateID(); 
        uint256 autoBoost = randons.generateRandMod();
        NFTStruct.CreateNFT storage nft = createNFT[newID];
        nft.userAdmin = payable(_msgSender()); 
        nft.idNFT = newID; 
        nft.initialValue = tAmount;
        nft.percentBoost = autoBoost; 
        nft.valueBoost = (tAmount.mul(autoBoost).div(100)).add(tAmount);
        nft.startVesting = initialTime;
        nft.endVesting = initialTime.add(generateBlockTime(autoBoost));
        nft.isUser = true;
        IBEP20(token).transferFrom(_msgSender(), address(this), tAmount);
        require(idStone == 1 || idStone == 2 || idStone == 3 || idStone == 3 || idStone == 4,"Precisa definir String");
        if (idStone == 1){
            nft.nameNFT = "Fire Stone";
            stringCallData(newID, fireStone);
        }
        if (idStone == 2){
            nft.nameNFT = "Water Stone";
            stringCallData(newID, waterStone);
        }
        if (idStone == 3){
            nft.nameNFT = "Soul Stone";
            stringCallData(newID, soulStone);
        }
        if (idStone == 4){
            nft.nameNFT = "Life Stone";
            stringCallData(newID, lifeStone);
        }
        _mint(_msgSender(), newID, 1, "" );
        emit NewMint(address(0), _msgSender(), newID); // emite um evento
    }
    function startStake(uint256 id) external payable updateReward(_msgSender()) {
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "Saldo em BNB nao definido");
        }
        require(activeStake, "Stake precisa ser ativado");
        NFTStruct.CreateNFT storage nft = createNFT[id];
        if(nft.userAdmin == _msgSender()) {
            bool isTrue = nft.isStaking;
            uint256 sAmount = nft.initialValue;
            uint256 bAmount = nft.valueBoost;
            require(!isTrue, "NFT Ja esta em Staking");
            nft.isStaking = true;
            balanceUser[_msgSender()] += bAmount;
            totalSupplyRewards += sAmount;
            emit NewStake(_msgSender(), sAmount, bAmount);
        }
        else {
            revert("Voce precisa ser Dono da NFT");
        }
    }
    function stopStake(uint256 id) external payable updateReward(_msgSender()) {
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "Saldo em BNB nao definido");
        }
        NFTStruct.CreateNFT storage nft = createNFT[id];
        if(nft.userAdmin == _msgSender()) {
            bool isTrue = nft.isStaking;
            uint256 sAmount = nft.initialValue;
            uint256 bAmount = nft.valueBoost;
            require(isTrue, "NFT nao esta em Staking");
            nft.isStaking = false;
            balanceUser[_msgSender()] -= bAmount;
            totalSupplyRewards -= sAmount;
        }
        else {
            revert("Voce precisa ser Dono da NFT");
        }
    }
    function takeMyRewards() external payable updateReward(_msgSender())  {
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "ARC:Taxa Precisa ser Cobrada");
        }
        require(harvestUser() == 0, "Tempo de Colheita nao liberado");
        blockHarvest();
        uint256 reward = rewards[_msgSender()];
        if (reward > 0) {
            uint256 fee = reward.mul(feeTax).div(100);
            reward = reward.sub(fee);
            totalFee += fee;
            totalLiquidity -= reward;
            rewards[_msgSender()] = 0;
            IBEP20(token).transfer(_msgSender(), reward);
        }
        else {
            revert("ARC:Voce nao Possui Saldo de Recompensa");
        }
    }
    function decomposeNFT(uint256 id) external payable decompose(id, _msgSender()){
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "ARC:Taxa Precisa ser Cobrada");
        }
        NFTStruct.CreateNFT storage nft = createNFT[id];        
        nft.userAdmin = payable(address(0)); 
        nft.percentBoost = 0; 
        nft.valueBoost = 0;
        uint256 value = nft.initialValue;
        totalValueLocked -= value;
        IBEP20(token).transfer(_msgSender(), value);
        nft.initialValue = 0;
        _safeTransferFrom(_msgSender(), burnAddress, id, 1, "");
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public virtual  {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        NFTStruct.CreateNFT storage nft = createNFT[id];
        if(nft.userAdmin == _msgSender()) {
            if(nft.isStaking) revert("Precisa sair do Stake");
            nft.userAdmin = payable(to);
            if(nft.isShareholder) {
                dividends.newBalance(from, to, nft.valueBoost);
            }
            _safeTransferFrom(from, to, id, amount, "");
        }
        else {
            revert("Precisa ser o Dono dessa NFT");
        }
    }
    function getBNBShareHolder() public {
        dividends.withdrawMyReward(_msgSender());
    }
    function returnShareHolder(uint256 id) public view returns(bool) {
        NFTStruct.CreateNFT storage nft = createNFT[id];
        bool isTrue = nft.isShareholder;
        return isTrue;
    }
    /*=== Administrativo ===*/
    function ownerNFT(address recipient, uint256 idStone, uint256 tAmount, uint256 endBlocks, uint256 boost, bool presale, bool privatesale, bool shareholder) external onlyOwner {
        uint256 newID = generateID();
        uint256 autoBoost = boost;
        uint256 initialTime = block.timestamp;
        NFTStruct.CreateNFT storage nft = createNFT[newID];
        nft.userAdmin = payable(recipient); 
        nft.idNFT = newID;
        nft.initialValue = tAmount; 
        nft.percentBoost = autoBoost; 
        nft.valueBoost = (tAmount.mul(autoBoost).div(100)).add(tAmount);
        nft.startVesting = initialTime;
        nft.endVesting = initialTime + endBlocks;
        nft.isUser = true;
        nft.isPreSale = presale;
        nft.isPrivateSale = privatesale;
        nft.isShareholder = shareholder;
        if(shareholder) {
            dividends.addBalance(recipient, nft.valueBoost);
        }
        require(idStone == 1 || idStone == 2 || idStone == 3 || idStone == 3 || idStone == 4,"Precisa definir String");
        if (idStone == 1){
            nft.nameNFT = "Fire Stone";
            stringCallData(newID, fireStone);
        }
        if (idStone == 2){
            nft.nameNFT = "Water Stone";
            stringCallData(newID, waterStone);
        }
        if (idStone == 3){
            nft.nameNFT = "Soul Stone";
            stringCallData(newID, soulStone);
        }
        if (idStone == 4){
            nft.nameNFT = "Life Stone";
            stringCallData(newID, lifeStone);
        }
        _mint(recipient, newID, 1, "" );
    }
    function manualDecompose(uint256 percent, uint256 id) external onlyOwner {
        NFTStruct.CreateNFT storage nft = createNFT[id];    
        require(nft.isPreSale || nft.isPrivateSale, "Essa NFT nao esta em private ou pre-sale");    
        uint256 oldValue = nft.initialValue;
        uint256 newValue = nft.initialValue.mul(percent).div(100);
        nft.initialValue = oldValue.sub(newValue);
        nft.valueBoost -= newValue;
        totalValueLocked -= newValue;
        IBEP20(token).transfer(_msgSender(), newValue);
    }
    function setUri(uint256 tokenId, string calldata tokenURI) external onlyOwner {
        _setURI(tokenId, tokenURI);
    }
    function setFeeBNB(uint256 _feeBNB) external onlyOwner {
        feeBNB = _feeBNB;
    }
    function addPoolRewards(uint256 lAmount) external onlyOwner {
        uint256 liquidityAmount = lAmount * 10**18;
        totalLiquidity += liquidityAmount;
        IBEP20(token).transferFrom(_msgSender(), address(this), liquidityAmount);
    }
    function removePoolRewards() external onlyOwner {
        uint256 removeLiquidity = totalLiquidity;
        totalLiquidity -= removeLiquidity;
        IBEP20(token).transfer(_msgSender(), removeLiquidity);
    }
    function removeTotalValueLocked() external onlyOwner {
        uint256 locked = totalValueLocked;
        totalValueLocked -= locked;
        IBEP20(token).transfer(_msgSender(), locked);
    }
    function emergencialWithdraw(uint256 eAmount) external onlyOwner {
        IBEP20(token).transfer(_msgSender(), eAmount);
    }
    function withdrawBNBManually() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(receiveAddress).transfer(balance);
    }
    function setFeeTax(uint256 _feeTax) external onlyOwner {
        feeTax = _feeTax;
    }
    function setBlockTime(uint256 _timeOne, uint256 _timeTwo) external onlyOwner {
        timeOne = _timeOne;
        timeTwo = _timeTwo;
    }
    function changeToken(address _token) external onlyOwner {
        token = IBEP20(_token);
    }
    function changeReceive(address _receiveAddress) external onlyOwner {
        receiveAddress = _receiveAddress;
    }
    function statusStake(bool _activeStake) external onlyOwner {
        activeStake = _activeStake;
    }
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    function updateRandom(address newAddress) external onlyOwner {
      Random newRandom = Random(payable(newAddress));
      randons = newRandom;
    }
    function updateDividends(address newAddress) external onlyOwner {
      DividendsPaying newDividends = DividendsPaying(payable(newAddress));
      dividends = newDividends;
    }
    function changeTimeClaim(uint256 time) external onlyOwner {
        dividends.changeTimeClaim(time);
    }
}