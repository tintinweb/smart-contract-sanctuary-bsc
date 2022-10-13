/**
 *Submitted for verification at BscScan.com on 2022-10-13
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


// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

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

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
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
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: Libraries/utils/MerkleProof.sol

pragma solidity 0.8.2;

abstract contract MerkleProof {
  function _verify(
    bytes32 root,
    bytes32 leaf,
    bytes32[] memory proof
  ) internal pure returns (bool) {
    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];
      if (computedHash <= proofElement) computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      else computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
    }
    return computedHash == root;
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: Offchain/IEBSChainManager.sol


pragma solidity 0.8.2;

interface IEBSChainManager {
    function currentBlock() external view returns (uint256);
    function header(uint256 blockNumber) external view returns(bytes32 previousHash, bytes32 merkleRoot, bytes32 r, bytes32 s, uint8 v, uint256 timeSubmitted);
    function verifyTxData(uint256 blockNumber, bytes32 txRoot, bytes32 leaf, bytes32[] memory proof) external view returns (bool);
    function verifyTxRoot(uint256 blockNumber, bytes32 leaf, bytes32[] memory proof) external view returns (bool);
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

// File: @openzeppelin/contracts/interfaces/IERC1155.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155.sol)

pragma solidity ^0.8.0;


// File: Marketplace/IERC20Wrapper.sol


pragma solidity 0.8.2;


interface IERC20Wrapper is IERC1155 {
  receive () external payable;

  function getTokenID(address _token) external view returns (uint256 tokenID);
  function getIdAddress(uint256 _id) external view returns (address token) ;
  function getNTokens() external view;
  function onERC1155Received(address _operator, address payable _from, uint256 _id, uint256 _value, bytes calldata _data ) external returns(bytes4);
  function onERC1155BatchReceived(address _operator, address payable _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}
// File: Libraries/control/IEBSControl.sol


pragma solidity 0.8.2;

interface IEBSControl {
    function checkSignerValidSignature(bytes calldata sign, bytes32 messages) external returns (bool);
    function checkUserValidSignature(bytes calldata sign, bytes32 messages, address user) external view returns (bool);
    function isAdmin(address user) external view returns (bool);
    function isMinter(address user) external view returns (bool);
    function isOperator(address user) external view returns (bool);
    function isZKOperator(address user) external view returns (bool);
    function isBlacklistUser(address user) external view returns (bool);
    function isWhitelistUser(address user) external view returns (bool);
    function checkKey(bytes32 accessKey) external view returns(bool);
    function usedHash(bytes32 hash_) external view returns (bool);
    function useSignature(bytes32 hashSign) external;
}
// File: Libraries/constant/EBSAddress.sol


pragma solidity 0.8.2;




abstract contract EBSAddress {
    address constant public EBS_MARKETPLACE = 0x484c51fFd89DB203Ea9f1F07F605863121879088;
    address constant public EBS_PREORDER = 0xEc6862A77b162FCb558EC968A91810717FF4d6d0;
    IEBSControl constant public EBS_CONTROL = IEBSControl(0xEad382916F2960fD8a04E76D50144688C70b1207);
    IERC20Wrapper constant public EBS_WRAPPER1 = IERC20Wrapper(payable(0x481496565dd08462D8FfEaA6Bea910A234cdA216));
    IERC20Wrapper constant public EBS_WRAPPER2 = IERC20Wrapper(payable(0x0e61a0287C07C11b991aF8294B3a3F0ad89428CD));
    address constant public EBS_ZK_CLONE_FACOTRY = 0xBE8ed2602fF818715938e2C45d3f312a45Dda8F5;
    address constant public EBS_ZK_MANAGER = 0xB73fC80Fc1BF81c6EBdb2fd63e2A10dD631cc5F9;
    address constant public EBS_ZK_MANAGER_CALLER = 0xF86F726B5A44778FB573A593ea48Fae9F28c620c;
    IEBSChainManager constant public EBS_CHAIN_MANAGER = IEBSChainManager(0x5a1024eB65289f68acb704c5260A1312165a3d50);
}
// File: Libraries/control/EBSPauser.sol


pragma solidity 0.8.2;



abstract contract EBSPauser is EBSAddress, Pausable {
    modifier notBlacklistUser() {
        require(!(EBS_CONTROL.isBlacklistUser(msg.sender)), "EBSPauser: Blacklist user");
        _;
    }

    modifier onlyWhitelistUser() {
        require(EBS_CONTROL.isWhitelistUser(msg.sender), "EBSPauser: Not Whitelist user");
        _;
    }

    modifier onlyOperator() {
        require(EBS_CONTROL.isOperator(msg.sender), "EBSPauser: Must have OPERATOR_ROLE");
        _;
    }

    modifier onlyZKOperator() {
        require(EBS_CONTROL.isZKOperator(msg.sender), "EBSPauser: Must have ZK_OPERATOR_ROLE");
        _;
    }

    modifier onlyMinter() {
        require(EBS_CONTROL.isMinter(msg.sender), "EBSPauser: Must have MINTER_ROLE");
        _;
    }

    modifier onlyAdmin() {
        require(EBS_CONTROL.isAdmin(msg.sender), "EBSPauser: Must have ADMIN_ROLE");
        _;
    }

    modifier onlyFromManagerCaller(){
        require(EBS_CONTROL.isAdmin(msg.sender) || msg.sender == EBS_ZK_MANAGER_CALLER, "EBSPauser: Invalid caller");
        _;
    }

    function pause() external whenNotPaused{
        require(EBS_CONTROL.isAdmin(msg.sender), "EBSPauser: Must have ADMIN_ROLE");
        _pause();
    }

    function unpause() external whenPaused{
        require(EBS_CONTROL.isAdmin(msg.sender), "EBSPauser: Must have ADMIN_ROLE");
        _unpause();
    }
}
// File: Offchain/EBSChainManager.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.2;





contract EBSChainManager is EBSPauser, MerkleProof {
    using Counters for Counters.Counter;
    Counters.Counter private _lastBlockNumber;

    mapping(uint256 => bytes32) private _previousHash;
    mapping(uint256 => bytes32) private _merkleRoot;
    mapping(uint256 => bytes32) private _r;
    mapping(uint256 => bytes32) private _s;
    mapping(uint256 => uint8) private _v;
    mapping(uint256 => uint256) private _timeSubmitted;
    mapping(uint256 => mapping(bytes32 => bool)) private _exist;

    event HeaderSubmitted(
        address signer, 
        uint256 blockNumber
    );

    function currentBlock() external view returns (uint256){
        return _lastBlockNumber.current();
    }

    function header(
        uint256 blockNumber
    ) external view returns(
        bytes32 previousHash,
        bytes32 merkleRoot,
        bytes32 r,
        bytes32 s,
        uint8 v,
        uint256 timeSubmitted
    ){
        previousHash = _previousHash[blockNumber];
        merkleRoot = _merkleRoot[blockNumber];
        r =_r[blockNumber];
        s = _s[blockNumber];
        v = _v[blockNumber];
        timeSubmitted = _timeSubmitted[blockNumber];
    }

    function verifyTxData(
        uint256 blockNumber,
        bytes32 txRoot,
        bytes32 leaf,
        bytes32[] memory proof
    ) public view returns (bool) {
        if(!_exist[blockNumber][txRoot]) return false;

        return _verify(txRoot, leaf, proof);
    }

    function verifyTxRoot(
        uint256 blockNumber,
        bytes32 leaf,
        bytes32[] memory proof
    ) public view returns (bool) {
        bytes32 merkleRoot = _merkleRoot[blockNumber];
        return _verify(merkleRoot, leaf, proof);
    }

    function submitBlockHeader(bytes memory header_, bytes memory txRoots_) onlyMinter external returns (bool success) {
        bytes32 blockNumber_;
        bytes32 previousHash_;
        bytes32 merkleRoot_;
        bytes32 sigR_;
        bytes32 sigS_;
        bytes1 sigV_;
        bytes32 root_;

        assembly {
            let data := add(header_, 0x20)
            blockNumber_ := mload(data)
            previousHash_ := mload(add(data, 32))
            merkleRoot_ := mload(add(data, 64))
            sigR_ := mload(add(data, 96))
            sigS_ := mload(add(data, 128))
            sigV_ := mload(add(data, 160))
            if lt(sigV_, 27) { sigV_ := add(sigV_, 27)}
        }

        require(uint256(blockNumber_) == _lastBlockNumber.current() + 1, "EBSChainManager: Invalid block number");

        bytes32 blockHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(blockNumber_, previousHash_, merkleRoot_, txRoots_)));

        require(EBS_CONTROL.isZKOperator(ECDSA.recover(blockHash, uint8(sigV_), sigR_, sigS_)), "EBSChainManager: Signer must have ZK_OPERATOR_ROLE");

        _previousHash[uint256(blockNumber_)] = previousHash_;
        _merkleRoot[uint256(blockNumber_)] = merkleRoot_;
        _r[uint256(blockNumber_)] = sigR_;
        _s[uint256(blockNumber_)] = sigS_;
        _v[uint256(blockNumber_)] = uint8(sigV_);
        _timeSubmitted[uint256(blockNumber_)] = block.timestamp;

        for (uint256 i = 0; i <= txRoots_.length - 32; i += 32) {
            assembly {
                root_ := mload(add(add(txRoots_, 0x20), i))
            }

            _exist[uint256(blockNumber_)][root_] = true;
        }

        _lastBlockNumber.increment();

        emit HeaderSubmitted(msg.sender, uint256(blockNumber_));
        return true;
    }
}