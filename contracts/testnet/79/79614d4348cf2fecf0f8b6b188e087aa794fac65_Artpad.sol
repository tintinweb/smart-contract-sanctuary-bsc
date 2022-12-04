/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

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

// File: @openzeppelin/contracts/utils/cryptography/MerkleProof.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be proved to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and the sibling nodes in `proof`,
     * consuming from one or the other at each step according to the instructions given by
     * `proofFlags`.
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
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

// File: ArtPad.sol


pragma solidity ^0.8.9;






interface IStaking {
    function Stake(uint months, uint amount, address holder, address referral, uint tier) external;
    function Unstake(address holder) external;
    function getReward(address holder) external;
    function getFreezedTokens(address holder) external;
    function addPromo(string[] memory _promos, uint[] memory coins, uint amount) external;
    function activatePromo(string memory _promo, address holder) external returns(uint);
    function getHolderTier(address holder) external view returns(uint);
    function getHolderTimeCf(address holder) external view returns (uint);
    function getHolderTierCf(address holder) external view returns (uint);
}

contract Artpad is Ownable {

    using ECDSA for bytes32;

    uint public totalBoughtTokens;
    uint public price;
    uint public totalUsers;
    uint public totalWhiteList;
    uint public totalLottery;
    uint public totalCf;
    uint public baseAllocation;

    uint firstVestingTime;
    uint vestingTime;
    uint vestingPercent;
    uint numOfPayments;
    uint freeSalePercent;

    mapping(address => User) public users;
    mapping(uint => address) public idToUsers;
    mapping(address => uint) public referralEarned;
    mapping(address => bool) public whiteList;
    mapping(address => bool) public lottery;

    bool public sellingIsActive;
    bool public freeSale;

    IERC20 _usdt;
    IERC20 _usdc;
    IERC20 _busd;

    IERC20 wARTR;
    IStaking staking;

    IERC20 importToken;

    struct User {
        uint id;
        uint allocation;
        uint Cf;
        bool registratedBasic;
        uint tokenAmount;
        uint gotTokens;
        uint gotPayments;
        bool isPaid;
    }

    event Registration (uint indexed id, address indexed user);
    event ImportTokenPurchase (address indexed user, uint indexed amount);
    event ARTRPurchase (address indexed user, uint indexed amount);

    constructor(address _staking, address _wARTR, address _importToken) {
        _usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        _usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        _busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

        staking = IStaking(_staking);
        wARTR = IERC20(_wARTR);
        importToken = IERC20(_importToken);
    }

    ///@notice Registration

    function registerUserBasic(address userAddress) public {
        uint tier = staking.getHolderTier(userAddress);
        require(whiteList[userAddress] || lottery[userAddress] || tier >= 3, "You don't have allocation");
        users[userAddress].registratedBasic = true;

        totalUsers++;
        users[userAddress].id = totalUsers;
        idToUsers[totalUsers] = userAddress;

        uint tierCf = staking.getHolderTierCf(userAddress);
        uint timeCf = staking.getHolderTimeCf(userAddress);
        if (tierCf == 0)
        tierCf = 10;
        if (timeCf == 0)
        timeCf = 10;
        totalCf += tierCf * timeCf;
        users[userAddress].Cf = tierCf * timeCf;
        
        emit Registration(totalUsers, userAddress);
    }

    function registerAdmin(address userAddress) public onlyOwner {
        users[userAddress].registratedBasic = true;
        idToUsers[totalUsers] = userAddress;
        totalUsers++;

        uint tierCf = staking.getHolderTierCf(userAddress);
        uint timeCf = staking.getHolderTimeCf(userAddress);
        if (tierCf == 0)
        tierCf = 10;
        if (timeCf == 0)
        timeCf = 10;
        totalCf += tierCf * timeCf;
        users[userAddress].Cf = tierCf * timeCf;
        
        emit Registration(totalUsers, userAddress);
    }

    ///@notice Basic

    function Claim() public {
        address holder = _msgSender();
        require(!users[holder].isPaid, "All your tokens was paid");
        require(block.timestamp >= firstVestingTime && firstVestingTime != 0, "too early");
        uint readyPayments = ((block.timestamp - firstVestingTime)/vestingTime + 1) - users[holder].gotPayments;
        if (users[holder].gotPayments + readyPayments > numOfPayments)
            readyPayments = numOfPayments - users[holder].gotPayments;
        require(readyPayments > 0, "You don't have tokens to claim now");
        uint amount = readyPayments * ((users[holder].tokenAmount * vestingPercent)/100);
        if (users[holder].gotTokens + amount >= users[holder].tokenAmount) {
            amount = users[holder].tokenAmount - users[holder].gotTokens;
            users[holder].isPaid = true;
        }
        users[holder].gotPayments += readyPayments;
        users[holder].gotTokens += amount;
        importToken.transfer(holder, amount);
    }

    function buyForBNB(uint amount) public payable {
        address account = _msgSender();
        uint weiAmount = msg.value;
        require(sellingIsActive, "Selling is not active");
        require(account != address(0), "Receiver is the zero address");
        require(users[account].registratedBasic, "User doesn't registered");
        uint allocation = setUserAllocation(account);
        require(allocation >= amount, "Exceeded allocation");
        require(weiAmount >= amount * price, "Exceeded balance");
        totalBoughtTokens += amount;
        users[account].tokenAmount = amount;

        emit ImportTokenPurchase(account, amount);
    }

    function buyForUSDT(uint amount) public {
        address account = _msgSender();
        uint weiAmount = _usdt.balanceOf(account);
        require(sellingIsActive, "Selling is not active");
        require(account != address(0), "Receiver is the zero address");
        require(users[account].registratedBasic, "User doesn't registered");
        uint allocation = setUserAllocation(account);
        require(allocation >= amount, "Exceeded allocation");
        require(weiAmount >= amount * price, "Exceeded balance");
        _usdt.transferFrom(account, address(this), weiAmount);
        totalBoughtTokens += amount;
        users[account].tokenAmount = amount;

        emit ImportTokenPurchase(account, amount);
    }

    function buyForUSDC(uint amount) public {
        address account = _msgSender();
        uint weiAmount = _usdc.balanceOf(account);
        require(sellingIsActive, "Selling is not active");
        require(account != address(0), "Receiver is the zero address");
        require(users[account].registratedBasic, "User doesn't registered");
        uint allocation = setUserAllocation(account);
        require(allocation >= amount, "Exceeded allocation");
        require(weiAmount >= amount * price, "Exceeded balance");
        _usdc.transferFrom(account, address(this), weiAmount);
        totalBoughtTokens += amount;
        users[account].tokenAmount = amount;

        emit ImportTokenPurchase(account, amount);
    }

    function buyForBUSD(uint amount) public {
        address account = _msgSender();
        uint weiAmount = _busd.balanceOf(account);
        require(sellingIsActive, "Selling is not active");
        require(account != address(0), "Receiver is the zero address");
        require(users[account].registratedBasic, "User doesn't registered");
        uint allocation = setUserAllocation(account);
        require(allocation >= amount, "Exceeded allocation");
        require(weiAmount >= amount * price, "Exceeded balance");
        _busd.transferFrom(account, address(this), weiAmount);
        totalBoughtTokens += amount;
        users[account].tokenAmount = amount;

        emit ImportTokenPurchase(account, amount);
    }

    function buyFreeSaleforBNB(uint amount) public payable {
        address account = _msgSender();
        uint weiAmount = msg.value;
        require(freeSale, "Selling is not active");
        require(account != address(0), "Receiver is the zero address");
        require(users[account].registratedBasic, "User doesn't registered");
        require(amount <= getTotalTokens(), "exeeded token amount");
        if (freeSalePercent != 0) {
            uint allocation = setUserAllocation(account);
            require((allocation * freeSalePercent)/100 >= amount, "Exceeded allocation");
        }
        require(weiAmount >= amount * price, "Exceeded balance");
        totalBoughtTokens += amount;
        users[account].tokenAmount = amount;

        emit ImportTokenPurchase(account, amount);
    }

    function buyFreeSaleforUSDT(uint amount) public {
        address account = _msgSender();
        uint weiAmount = _usdt.balanceOf(account);
        require(freeSale, "Selling is not active");
        require(account != address(0), "Receiver is the zero address");
        require(users[account].registratedBasic, "User doesn't registered");
        require(amount <= getTotalTokens(), "exeeded token amount");
        if (freeSalePercent != 0) {
            uint allocation = setUserAllocation(account);
            require((allocation * freeSalePercent)/100 >= amount, "Exceeded allocation");
        }
        require(weiAmount >= amount * price, "Exceeded balance");
        _usdt.transferFrom(account, address(this), weiAmount);
        totalBoughtTokens += amount;
        users[account].tokenAmount = amount;

        emit ImportTokenPurchase(account, amount);
    }

    function buyFreeSaleforUSDC(uint amount) public {
        address account = _msgSender();
        uint weiAmount = _usdc.balanceOf(account);
        require(freeSale, "Selling is not active");
        require(account != address(0), "Receiver is the zero address");
        require(users[account].registratedBasic, "User doesn't registered");
        require(amount <= getTotalTokens(), "exeeded token amount");
        if (freeSalePercent != 0) {
            uint allocation = setUserAllocation(account);
            require((allocation * freeSalePercent)/100 >= amount, "Exceeded allocation");
        }
        require(weiAmount >= amount * price, "Exceeded balance");
        _usdc.transferFrom(account, address(this), weiAmount);
        totalBoughtTokens += amount;
        users[account].tokenAmount = amount;

        emit ImportTokenPurchase(account, amount);
    }

    function buyFreeSaleforBUSD(uint amount) public {
        address account = _msgSender();
        uint weiAmount = _busd.balanceOf(account);
        require(freeSale, "Selling is not active");
        require(account != address(0), "Receiver is the zero address");
        require(users[account].registratedBasic, "User doesn't registered");
        require(amount <= getTotalTokens(), "exeeded token amount");
        if (freeSalePercent != 0) {
            uint allocation = setUserAllocation(account);
            require((allocation * freeSalePercent)/100 >= amount, "Exceeded allocation");
        }
        require(weiAmount >= amount * price, "Exceeded balance");
        _busd.transferFrom(account, address(this), weiAmount);
        totalBoughtTokens += amount;
        users[account].tokenAmount = amount;

        emit ImportTokenPurchase(account, amount);
    }

    function setUserAllocation(address userAddress) internal returns (uint) {
        uint userCf = users[userAddress].Cf;
        uint userAllocation = (baseAllocation * userCf)/100;
        users[userAddress].allocation = userAllocation;
        return userAllocation;
    }

    function activatePromo(string memory _promo) external returns(uint) {
        address holder = _msgSender();
        return staking.activatePromo(_promo, holder);
    }

    function PullToStake(uint months, uint amount, address refferrer, uint tier) external {
        address holder = _msgSender();
        staking.Stake(months, amount, holder, refferrer, tier);
    }

    function unstake() external {
        address holder = _msgSender();
        staking.Unstake(holder);
    }

    function getReward() external {
        address holder = _msgSender();
        staking.getReward(holder);
    }

    function getFreezedTokens() external {
        address holder = _msgSender();
        staking.getFreezedTokens(holder);
    }

    ///@notice Settings

    function setPrice(uint newPrice) public onlyOwner {
        price = newPrice;
    }

    function setUSDC(address _new) public onlyOwner {
        _usdc = IERC20(_new);
    }

    function setUSDT(address _new) public onlyOwner {
        _usdt = IERC20(_new);
    }

    function setwARTR(address _new) public onlyOwner {
        wARTR = IERC20(_new);
    }

    function setStaking(address _new) public onlyOwner {
        staking = IStaking(_new);
    }

    function setImportToken(address _new) public onlyOwner {
        importToken = IERC20(_new);
    }

    function sellingActiveToggle() public onlyOwner {
        sellingIsActive = !sellingIsActive;
        if (sellingIsActive) {
            uint tokenLimit = getTotalTokens();
            baseAllocation = (tokenLimit*100)/totalCf;
        }
    }

    function setVesting(uint _firstVestingTime, uint _vestingTime, uint _vestingPercent) public onlyOwner {
        firstVestingTime = _firstVestingTime;
        vestingTime = _vestingTime;
        vestingPercent = _vestingPercent;
        if (100 % vestingPercent > 0)
            numOfPayments = 100/vestingPercent + 1;
        else numOfPayments = 100/vestingPercent;
    }

    function addWhiteList(address[] memory userAddress, uint amount) external onlyOwner {
        for (uint i = 0; i <= amount - 1; i++) {
            whiteList[userAddress[i]] = true;
        }
        totalWhiteList += amount;
    }

    function addLottery(address[] memory userAddress, uint amount) external onlyOwner {
        for (uint i = 0; i <= amount - 1; i++) {
            lottery[userAddress[i]] = true;
        }
        totalLottery += amount;
    }

    function addPromo(string[] memory _promos, uint[] memory coins, uint amount) external onlyOwner {
        staking.addPromo(_promos, coins, amount);
    }

    function freeSaleActiveToggle(uint percent) external onlyOwner {
        freeSale = !freeSale;
        freeSalePercent = percent;
    }

    ///@notice Info

    function isUserExists(address userAddress) public view returns (bool) {
        return (users[userAddress].id != 0);
    }

    function showAllocation(address userAddress) public view returns (uint) {
        uint userCf = users[userAddress].Cf;
        uint userAllocation = (baseAllocation * userCf)/100;
        return userAllocation;
    }

    function getTotalTokens() public view returns (uint) {
        return (importToken.balanceOf(address(this)));
    }
    
    function getUserData(address _holder) external view returns 
       (uint id,
        uint allocation,
        uint Cf,
        bool registratedBasic,
        uint tokenAmount,
        uint gotTokens,
        uint gotPayments,
        bool isPaid) {
            address holder = _holder;
            return 
            (users[holder].id,
            users[holder].allocation,
            users[holder].Cf,
            users[holder].registratedBasic,
            users[holder].tokenAmount,
            users[holder].gotTokens,
            users[holder].gotPayments,
            users[holder].isPaid);
    }


}