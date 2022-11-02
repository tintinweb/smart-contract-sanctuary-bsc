// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.2;

import "./access/SignatureWriteAccessController.sol";
import "./interfaces/OnChainOracleInterface.sol";
import "./access/ECDSA.sol";
import "./interfaces/OracleUpdatableInterface.sol";

/**
 * @title Binance Oracle OnChain implementation
 * @notice OnChain acts as a staging area for price updates before sending them to the aggregators
 * @dev OnChainOracle is responsible for creating and owning aggregators when needed. It has two access controls
 * 1) Give write access control for off-chain nodes using msg.sender
 * 2) Check signature on the putBatch method
 * @author Sri Krishna Mannem
 */
contract OnChainOracle is SignatureWriteAccessController, OnChainOracleInterface {
  using ECDSA for bytes32;

  /// @notice Event with address of the last updater
  event Success(address leaderAddress);
  /// @notice Warn if a certain aggregator is not set
  event AggregatorNotSet(string pairName);

  /// @dev End aggregators to update. We need to create them manually if we add more pairs
  mapping(string => OracleUpdatableInterface) internal aggregators;

  /// @dev Current batchId. OnChain oracle only accepts next request with batchId + 1
  uint256 public batchId;

  /**
   *  @notice Signed batch update request from an authenticated off-chain Oracle
   */
  function putBatch(
    uint256 batchId_,
    bytes calldata message_,
    bytes calldata signature_
  ) external override checkAccess {
    require(batchId_ == batchId + 1, "Unexpected batchId received");

    (address source, uint64 timestamp, string[] memory pairs, int192[] memory prices) = _decodeBatchMessage(
      message_,
      signature_
    );
    require(isSignatureValid(source), "Batch write aborted due to wrong signature");
    require(pairs.length == prices.length, "Pairs and prices have unequal lengths");

    for (uint256 i = 0; i < pairs.length; ++i) {
      if (address(aggregators[pairs[i]]) != address(0)) {
        aggregators[pairs[i]].transmit(timestamp, prices[i]);
      } else {
        emit AggregatorNotSet(pairs[i]);
      }
    }
    batchId++;
    emit Success(msg.sender); //emit already authenticated leader's address
  }

  /**
   * @dev Create an aggregator for a pair, replace if already exists
   * @param pair_  the trading pair for which to create an aggregator
   * @param aggregatorAddress  address of the aggregator for the pair
   */
  function addAggregatorForPair(string calldata pair_, OracleUpdatableInterface aggregatorAddress)
    external
    override
    onlyOwner
  {
    aggregators[pair_] = aggregatorAddress;
  }

  /**
   * Retrieve the current writable aggregator for a pair
   * @param pair_  pair to get address of the aggregator
   * @return aggregator The current mapping of aggregators
   */
  function getAggregatorForPair(string calldata pair_) external view override onlyOwner returns (address) {
    return address(aggregators[pair_]);
  }

  function _decodeBatchMessage(bytes calldata message_, bytes calldata signature_)
    internal
    pure
    returns (
      address,
      uint64,
      string[] memory,
      int192[] memory
    )
  {
    address source = _getSource(message_, signature_);

    // Decode the message and check the version
    (string memory version, uint64 timestamp, string[] memory pairs, int192[] memory prices) = abi.decode(
      message_,
      (string, uint64, string[], int192[])
    );
    require(keccak256(abi.encodePacked(version)) == keccak256(abi.encodePacked("v1")), "Version of data must be 'v1'");
    return (source, timestamp, pairs, prices);
  }

  /**
   * @dev Recovers the source address which signed a message
   */
  function _getSource(bytes memory message_, bytes memory signature_) internal pure returns (address) {
    (bytes32 r, bytes32 s, uint8 v) = abi.decode(signature_, (bytes32, bytes32, uint8));
    return keccak256(message_).toEthSignedMessageHash().recover(v, r, s);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./OwnerIsCreator.sol";
import "../interfaces/AccessControllerInterface.sol";
import "../interfaces/SignatureAccessControllerInterface.sol";

/**
 * @title SignatureWriteAccessController
 * @notice Gives access to accounts explicitly added to an access list by the
 * controller's owner.
 * @dev Two types of accesses are controlled
 * 1) Senders of the transaction ie msg.sender
 * 2) Signers of the transaction (wallet addresses)
 */
contract SignatureWriteAccessController is
  AccessControllerInterface,
  SignatureAccessControllerInterface,
  OwnerIsCreator
{
  mapping(address => bool) internal s_accessList;
  mapping(address => bool) internal s_validSignaturesList;

  event AddedAccess(address user);
  event RemovedAccess(address user);
  event AddedSigner(address wallet);
  event RemovedSigner(address wallet);

  /***************************************************************************
   * Section: Transaction sender access
   **************************************************************************/
  /**
   * @notice Returns the access of an address
   * @param user The address to query
   */
  function hasAccess(address user, bytes memory) public view virtual override returns (bool) {
    return s_accessList[user];
  }

  /**
   * @notice Adds an address to the access list
   * @param user The address to add
   */
  function addAccess(address user) external onlyOwner {
    if (!s_accessList[user]) {
      s_accessList[user] = true;

      emit AddedAccess(user);
    }
  }

  /**
   * @notice Removes an address from the access list
   * @param user The address to remove
   */
  function removeAccess(address user) external onlyOwner {
    if (s_accessList[user]) {
      s_accessList[user] = false;

      emit RemovedAccess(user);
    }
  }

  /**
   * @dev reverts if the caller does not have access
   */
  modifier checkAccess() {
    require(hasAccess(msg.sender, msg.data), "No access");
    _;
  }

  /***************************************************************************
   * Section: Signature access
   **************************************************************************/
  /**
   * @notice Returns the access of a signing wallet
   * @dev Signature restriction cannot be disabled
   * @param signingWallet The address to query
   */
  function isSignatureValid(address signingWallet) public view virtual override returns (bool) {
    return s_validSignaturesList[signingWallet];
  }

  /**
   * @notice Adds a signer to the allowed signatures list
   * @param signingWallet The wallet address to allow
   */
  function addSigner(address signingWallet) external onlyOwner {
    if (!s_validSignaturesList[signingWallet]) {
      s_validSignaturesList[signingWallet] = true;
      emit AddedSigner(signingWallet);
    }
  }

  /**
   * @notice Removes a signer to the allowed signatures list
   * @param signingWallet The wallet address to remove access
   */
  function removeSigner(address signingWallet) external onlyOwner {
    if (s_validSignaturesList[signingWallet]) {
      s_validSignaturesList[signingWallet] = false;
      emit RemovedSigner(signingWallet);
    }
  }

  /**
   * @dev reverts if the transaction signature is invalid
   */
  modifier checkSignature(address signingWallet) {
    require(isSignatureValid(signingWallet), "Signature not valid");
    _;
  }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.2;

import "./OracleUpdatableInterface.sol";

/**
 * @title Binance Oracle OnChain
 * @notice OnChain acts as a staging area for price updates before sending them to the aggregators
 * @dev OnChainOracle is responsible for creating and owning aggregators when needed
 * @author Sri Krishna Mannem
 */
interface OnChainOracleInterface {
  /**
   *  @notice Signed batch update request from an authenticated off-chain Oracle
   */
  function putBatch(
    uint256 batchId_,
    bytes calldata message_,
    bytes calldata signature_
  ) external;

  /**
   * @dev Create an aggregator for a pair, replace if already exists
   * @param pair_  the trading pair for which to create an aggregator
   * @param aggregatorAddress  address of the aggregator for the pair
   */
  function addAggregatorForPair(string calldata pair_, OracleUpdatableInterface aggregatorAddress) external;

  /**
   * @param pair_  pair to get address of the aggregator
   * @return address The current mapping of aggregators
   */
  function getAggregatorForPair(string calldata pair_) external returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

pragma solidity 0.8.2;

import "../utils/Strings.sol";

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
    InvalidSignatureV // Deprecated in v4.8
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
pragma solidity 0.8.2;

interface OracleUpdatableInterface {
  function transmit(uint64 timestamp_, int192 newPrice_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

interface AccessControllerInterface {
  function hasAccess(address user, bytes calldata data) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./ConfirmedOwner.sol";

/**
 * @title The OwnerIsCreator contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

interface SignatureAccessControllerInterface {
  function isSignatureValid(address walletAddress) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "../interfaces/OwnableInterface.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");
    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) external override onlyOwner {
    require(to != address(0), "Cannot set owner to zero");
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() external view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity 0.8.2;

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