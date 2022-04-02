/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// hevm: flattened sources of src/truth/darwinia/DarwiniaLightClient.sol
// SPDX-License-Identifier: MIT AND Apache-2.0
pragma solidity >=0.8.0 <0.9.0;
pragma abicoder v2;

////// src/interfaces/ILightClient.sol

/* pragma solidity ^0.8.0; */

interface ILightClient {
    function verify_messages_proof(
        bytes32 outlane_data_hash,
        uint32 chain_pos,
        uint32 lane_pos,
        bytes calldata encoded_proof
    ) external view returns (bool);

    function verify_messages_delivery_proof(
        bytes32 inlane_data_hash,
        uint32 chain_pos,
        uint32 lane_pos,
        bytes calldata encoded_proof
    ) external view returns (bool);
}

////// src/utils/ScaleCodec.sol
/* pragma solidity ^0.8.0; */

library ScaleCodec {
    // Decodes a SCALE encoded uint256 by converting bytes (bid endian) to little endian format
    function decodeUint256(bytes memory data) internal pure returns (uint256) {
        uint256 number;
        for (uint256 i = data.length; i > 0; i--) {
            number = number + uint256(uint8(data[i - 1])) * (2**(8 * (i - 1)));
        }
        return number;
    }

    // Decodes a SCALE encoded compact unsigned integer
    function decodeUintCompact(bytes memory data)
        internal
        pure
        returns (uint256 v)
    {
        uint8 b = readByteAtIndex(data, 0); // read the first byte
        uint8 mode = b & 3; // bitwise operation

        if (mode == 0) {
            // [0, 63]
            return b >> 2; // right shift to remove mode bits
        } else if (mode == 1) {
            // [64, 16383]
            uint8 bb = readByteAtIndex(data, 1); // read the second byte
            uint64 r = bb; // convert to uint64
            r <<= 6; // multiply by * 2^6
            r += b >> 2; // right shift to remove mode bits
            return r;
        } else if (mode == 2) {
            // [16384, 1073741823]
            uint8 b2 = readByteAtIndex(data, 1); // read the next 3 bytes
            uint8 b3 = readByteAtIndex(data, 2);
            uint8 b4 = readByteAtIndex(data, 3);

            uint32 x1 = uint32(b) | (uint32(b2) << 8); // convert to little endian
            uint32 x2 = x1 | (uint32(b3) << 16);
            uint32 x3 = x2 | (uint32(b4) << 24);

            x3 >>= 2; // remove the last 2 mode bits
            return uint256(x3);
        } else if (mode == 3) {
            // [1073741824, 4503599627370496]
            // solhint-disable-next-line
            uint8 l = b >> 2; // remove mode bits
            require(
                l > 32,
                "Not supported: number cannot be greater than 32 bytes"
            );
        } else {
            revert("Code should be unreachable");
        }
    }

    // Read a byte at a specific index and return it as type uint8
    function readByteAtIndex(bytes memory data, uint8 index)
        internal
        pure
        returns (uint8)
    {
        return uint8(data[index]);
    }

    // Sources:
    //   * https://ethereum.stackexchange.com/questions/15350/how-to-convert-an-bytes-to-address-in-solidity/50528
    //   * https://graphics.stanford.edu/~seander/bithacks.html#ReverseParallel

    function reverse256(uint256 input) internal pure returns (uint256 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00) >> 8) |
            ((v & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) << 8);

        // swap 2-byte long pairs
        v = ((v & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000) >> 16) |
            ((v & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) << 16);

        // swap 4-byte long pairs
        v = ((v & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000) >> 32) |
            ((v & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) << 32);

        // swap 8-byte long pairs
        v = ((v & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000) >> 64) |
            ((v & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) << 64);

        // swap 16-byte long pairs
        v = (v >> 128) | (v << 128);
    }

    function reverse128(uint128 input) internal pure returns (uint128 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00FF00FF00FF00FF00FF00FF00) >> 8) |
            ((v & 0x00FF00FF00FF00FF00FF00FF00FF00FF) << 8);

        // swap 2-byte long pairs
        v = ((v & 0xFFFF0000FFFF0000FFFF0000FFFF0000) >> 16) |
            ((v & 0x0000FFFF0000FFFF0000FFFF0000FFFF) << 16);

        // swap 4-byte long pairs
        v = ((v & 0xFFFFFFFF00000000FFFFFFFF00000000) >> 32) |
            ((v & 0x00000000FFFFFFFF00000000FFFFFFFF) << 32);

        // swap 8-byte long pairs
        v = (v >> 64) | (v << 64);
    }

    function reverse64(uint64 input) internal pure returns (uint64 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00FF00FF00) >> 8) |
            ((v & 0x00FF00FF00FF00FF) << 8);

        // swap 2-byte long pairs
        v = ((v & 0xFFFF0000FFFF0000) >> 16) |
            ((v & 0x0000FFFF0000FFFF) << 16);

        // swap 4-byte long pairs
        v = (v >> 32) | (v << 32);
    }

    function reverse32(uint32 input) internal pure returns (uint32 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00) >> 8) |
            ((v & 0x00FF00FF) << 8);

        // swap 2-byte long pairs
        v = (v >> 16) | (v << 16);
    }

    function reverse16(uint16 input) internal pure returns (uint16 v) {
        v = input;

        // swap bytes
        v = (v >> 8) | (v << 8);
    }

    function encode256(uint256 input) internal pure returns (bytes32) {
        return bytes32(reverse256(input));
    }

    function encode128(uint128 input) internal pure returns (bytes16) {
        return bytes16(reverse128(input));
    }

    function encode64(uint64 input) internal pure returns (bytes8) {
        return bytes8(reverse64(input));
    }

    function encode32(uint32 input) internal pure returns (bytes4) {
        return bytes4(reverse32(input));
    }

    function encode16(uint16 input) internal pure returns (bytes2) {
        return bytes2(reverse16(input));
    }

    function encode8(uint8 input) internal pure returns (bytes1) {
        return bytes1(input);
    }
}

////// src/spec/BEEFYCommitmentScheme.sol

/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

/* import "../utils/ScaleCodec.sol"; */

contract BEEFYCommitmentScheme {
    using ScaleCodec for uint32;
    using ScaleCodec for uint64;
    /**
     * Next BEEFY authority set
     * @param id ID of the next set
     * @param len Number of validators in the set
     * @param root Merkle Root Hash build from BEEFY AuthorityIds
    */
    struct NextValidatorSet {
        uint64 id;
        uint32 len;
        bytes32 root;
    }

    /**
     * The payload being signed
     * @param network Source chain network identifier
     * @param messageRoot Darwnia message root commitment hash
     * @param nextValidatorSet Next BEEFY authority set
    */
    struct Payload {
        bytes32 network;
        bytes32 messageRoot;
        NextValidatorSet nextValidatorSet;
    }

    /**
     * The Commitment, with its payload, is the core thing we are trying to verify with this contract.
     * It contains a next validator set or not and a MMR root that commits to the darwinia history,
     * including past blocks and can be used to verify darwinia blocks.
     * @param payload the payload of the new commitment in beefy justifications (in
     *  our case, this is a next validator set and a new MMR root for all past darwinia blocks)
     * @param blockNumber block number for the given commitment
     * @param validatorSetId validator set id that signed the given commitment
     */
    struct Commitment {
        Payload payload;
        uint32 blockNumber;
        uint64 validatorSetId;
    }

    bytes4 internal constant PAYLOAD_SCALE_ENCOD_PREFIX = 0x04646280;

    function hash(Commitment memory commitment)
        public
        pure
        returns (bytes32)
    {
        /**
         * Encode and hash the Commitment
         */
        return keccak256(
            abi.encodePacked(
                PAYLOAD_SCALE_ENCOD_PREFIX,
                hash(commitment.payload),
                commitment.blockNumber.encode32(),
                commitment.validatorSetId.encode64()
            )
        );
    }

    function hash(Payload memory payload)
        internal
        pure
        returns (bytes32)
    {
        /**
         * Encode and hash the Payload
         */
        return keccak256(
            abi.encodePacked(
                payload.network,
                payload.messageRoot,
                encode(payload.nextValidatorSet)
            )
        );
    }

    function encode(NextValidatorSet memory nextValidatorSet)
        internal
        pure
        returns (bytes memory)
    {
        /**
         * Encode the NextValidatorSet
         */
        return abi.encodePacked(
                nextValidatorSet.id.encode64(),
                nextValidatorSet.len.encode32(),
                nextValidatorSet.root
            );
    }

}

////// src/truth/darwinia/BEEFYAuthorityRegistry.sol

/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

/**
 * @title A contract storing state on the current BEEFY authority set
 * @dev Stores the authority set as a Merkle root
 *  0  |   1   |    2   |  .. x   3 |     4
 *     [       )
 */
contract BEEFYAuthorityRegistry {
    /* Events */

    event BEEFYAuthoritySetUpdated(uint64 id, uint32 len, bytes32 root);

    /* State */

    /**
     * @notice Authority set supposed to sign the BEEFY commitment.
     * @dev The current authority set id
     */
    uint64 public authoritySetId;
    /**
     * @dev The current length of authority set
     */
    uint32 public authoritySetLen;
    /**
     * @dev The current merkle root of authority set
     */
    bytes32 public authoritySetRoot;

    /**
     * @notice Updates the current authority set
     * @param _authoritySetId The new authority set id
     * @param _authoritySetLen The new length of authority set
     * @param _authoritySetRoot The new authority set root
     */
    function _updateAuthoritySet(uint64 _authoritySetId, uint32 _authoritySetLen, bytes32 _authoritySetRoot) internal {
        authoritySetId = _authoritySetId;
        authoritySetLen = _authoritySetLen;
        authoritySetRoot = _authoritySetRoot;
        emit BEEFYAuthoritySetUpdated(_authoritySetId, _authoritySetLen, _authoritySetRoot);
    }
}

////// src/utils/Bits.sol
// Code from https://github.com/ethereum/solidity-examples
/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

library Bits {
    uint256 internal constant ONE = uint256(1);
    uint256 internal constant ONES = type(uint256).max;

    // Sets the bit at the given 'index' in 'self' to '1'.
    // Returns the modified value.
    function setBit(uint256 self, uint8 index) internal pure returns (uint256) {
        return self | (ONE << index);
    }

    // Sets the bit at the given 'index' in 'self' to '0'.
    // Returns the modified value.
    function clearBit(uint256 self, uint8 index)
        internal
        pure
        returns (uint256)
    {
        return self & ~(ONE << index);
    }

    // Sets the bit at the given 'index' in 'self' to:
    //  '1' - if the bit is '0'
    //  '0' - if the bit is '1'
    // Returns the modified value.
    function toggleBit(uint256 self, uint8 index)
        internal
        pure
        returns (uint256)
    {
        return self ^ (ONE << index);
    }

    // Get the value of the bit at the given 'index' in 'self'.
    function bit(uint256 self, uint8 index) internal pure returns (uint8) {
        return uint8((self >> index) & 1);
    }

    // Check if the bit at the given 'index' in 'self' is set.
    // Returns:
    //  'true' - if the value of the bit is '1'
    //  'false' - if the value of the bit is '0'
    function bitSet(uint256 self, uint8 index) internal pure returns (bool) {
        return (self >> index) & 1 == 1;
    }

    // Checks if the bit at the given 'index' in 'self' is equal to the corresponding
    // bit in 'other'.
    // Returns:
    //  'true' - if both bits are '0' or both bits are '1'
    //  'false' - otherwise
    function bitEqual(
        uint256 self,
        uint256 other,
        uint8 index
    ) internal pure returns (bool) {
        return ((self ^ other) >> index) & 1 == 0;
    }

    // Get the bitwise NOT of the bit at the given 'index' in 'self'.
    function bitNot(uint256 self, uint8 index) internal pure returns (uint8) {
        return uint8(1 - ((self >> index) & 1));
    }

    // Computes the bitwise AND of the bit at the given 'index' in 'self', and the
    // corresponding bit in 'other', and returns the value.
    function bitAnd(
        uint256 self,
        uint256 other,
        uint8 index
    ) internal pure returns (uint8) {
        return uint8(((self & other) >> index) & 1);
    }

    // Computes the bitwise OR of the bit at the given 'index' in 'self', and the
    // corresponding bit in 'other', and returns the value.
    function bitOr(
        uint256 self,
        uint256 other,
        uint8 index
    ) internal pure returns (uint8) {
        return uint8(((self | other) >> index) & 1);
    }

    // Computes the bitwise XOR of the bit at the given 'index' in 'self', and the
    // corresponding bit in 'other', and returns the value.
    function bitXor(
        uint256 self,
        uint256 other,
        uint8 index
    ) internal pure returns (uint8) {
        return uint8(((self ^ other) >> index) & 1);
    }

    // Gets 'numBits' consecutive bits from 'self', starting from the bit at 'startIndex'.
    // Returns the bits as a 'uint'.
    // Requires that:
    //  - '0 < numBits <= 256'
    //  - 'startIndex < 256'
    //  - 'numBits + startIndex <= 256'
    function bits(
        uint256 self,
        uint8 startIndex,
        uint16 numBits
    ) internal pure returns (uint256) {
        require(0 < numBits && startIndex < 256 && startIndex + numBits <= 256);
        return (self >> startIndex) & (ONES >> (256 - numBits));
    }

    // Computes the index of the highest bit set in 'self'.
    // Returns the highest bit set as an 'uint8'.
    // Requires that 'self != 0'.
    function highestBitSet(uint256 self) internal pure returns (uint8 highest) {
        require(self != 0);
        uint256 val = self;
        for (uint8 i = 128; i >= 1; i >>= 1) {
            if (val & (((ONE << i) - 1) << i) != 0) {
                highest += i;
                val >>= i;
            }
        }
    }

    // Computes the index of the lowest bit set in 'self'.
    // Returns the lowest bit set as an 'uint8'.
    // Requires that 'self != 0'.
    function lowestBitSet(uint256 self) internal pure returns (uint8 lowest) {
        require(self != 0);
        uint256 val = self;
        for (uint8 i = 128; i >= 1; i >>= 1) {
            if (val & ((ONE << i) - 1) == 0) {
                lowest += i;
                val >>= i;
            }
        }
    }
}

////// src/utils/Bitfield.sol

/* pragma solidity ^0.8.0; */

/* import "./Bits.sol"; */

contract Bitfield {
    using Bits for uint256;

    /**
     * @dev Constants used to efficiently calculate the hamming weight of a bitfield. See
     * https://en.wikipedia.org/wiki/Hamming_weight#Efficient_implementation for an explanation of those constants.
     */
    uint256 internal constant M1 =
        0x5555555555555555555555555555555555555555555555555555555555555555;
    uint256 internal constant M2 =
        0x3333333333333333333333333333333333333333333333333333333333333333;
    uint256 internal constant M4 =
        0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
    uint256 internal constant M8 =
        0x00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff;
    uint256 internal constant M16 =
        0x0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff;
    uint256 internal constant M32 =
        0x00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff;
    uint256 internal constant M64 =
        0x0000000000000000ffffffffffffffff0000000000000000ffffffffffffffff;
    uint256 internal constant M128 =
        0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;

    uint256 internal constant ONE = uint256(1);

    uint256[20] internal BIG_PRIME = [
        1000003,1000033,1000037,1000039,1000081,1000099,1000117,1000121,1000133,1000151,
        1000159,1000171,1000183,1000187,1000193,1000199,1000211,1000213,1000231,1000249
    ];

    /**
     * @notice Draws a random number, derives an index in the bitfield, and sets the bit if it is in the `prior` and not
     * yet set. Repeats that `n` times.
     */
    function randomNBitsWithPriorCheck(
        uint256 seed,
        uint256 prior,
        uint256 n,
        uint256 length
    ) internal view returns (uint256 bitfield) {
        require(
            n <= countSetBits(prior),
            "`n` must be <= number of set bits in `prior`"
        );
        require(
            length < 256,
            "length too large"
        );

        uint256 prime = BIG_PRIME[seed%20];
        uint256 begin = uint256(keccak256(abi.encode(seed))) % 1000000 + 1;
        uint256 found = 0;

        for (uint256 i = 0; found < n; i++) {
            uint8 index = uint8((prime * (begin + i)) % length);

           // require randomly seclected bit to be set in prior
            if (!isSet(prior, index)) {
                continue;
            }

            // require a not yet set (new) bit to be set
            if (isSet(bitfield, index)) {
                continue;
            }

            bitfield = set(bitfield, index);

            found++;
        }

        return bitfield;
    }

    function createBitfield(uint8[] memory bitsToSet)
        internal
        pure
        returns (uint256 bitfield)
    {
        for (uint256 i = 0; i < bitsToSet.length; i++) {
            bitfield = set(bitfield, bitsToSet[i]);
        }

        return bitfield;
    }

    /**
     * @notice Calculates the number of set bits by using the hamming weight of the bitfield.
     * The alogrithm below is implemented after https://en.wikipedia.org/wiki/Hamming_weight#Efficient_implementation.
     * Further improvements are possible, see the article above.
     */
    function countSetBits(uint256 x) internal pure returns (uint256) {
        x = (x & M1) + ((x >> 1) & M1); //put count of each  2 bits into those  2 bits
        x = (x & M2) + ((x >> 2) & M2); //put count of each  4 bits into those  4 bits
        x = (x & M4) + ((x >> 4) & M4); //put count of each  8 bits into those  8 bits
        x = (x & M8) + ((x >> 8) & M8); //put count of each 16 bits into those 16 bits
        x = (x & M16) + ((x >> 16) & M16); //put count of each 32 bits into those 32 bits
        x = (x & M32) + ((x >> 32) & M32); //put count of each 64 bits into those 64 bits
        x = (x & M64) + ((x >> 64) & M64); //put count of each 128 bits into those 128 bits
        x = (x & M128) + ((x >> 128) & M128); //put count of each 256 bits into those 256 bits
        return x;
    }

    function isSet(uint256 self, uint8 index)
        internal
        pure
        returns (bool)
    {
        return self.bit(index) == 1;
    }

    function set(uint256 self, uint8 index) internal pure returns (uint256) {
        return self.setBit(index);
    }

    function clear(uint256 self, uint8 index) internal pure returns (uint256) {
        return self.clearBit(index);
    }
}

////// src/utils/ECDSA.sol

/* pragma solidity ^0.8.0; */

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
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
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        // Check the signature length
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098)
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

////// src/utils/SparseMerkleProof.sol

/* pragma solidity ^0.8.0; */

/// @title A verifier for sparse merkle tree.
/// @author echo
/// @notice Sparse Merkle Tree is constructed from 2^n-length leaves, where n is the tree depth
///  equal to log2(number of leafs) and it's initially hashed using the `keccak256` hash function as the inner nodes.
///  Inner nodes are created by concatenating child hashes and hashing again.
library SparseMerkleProof {

    function hash_node(bytes32 left, bytes32 right)
        internal
        pure
        returns (bytes32 hash)
    {
        assembly {
            mstore(0x00, left)
            mstore(0x20, right)
            hash := keccak256(0x00, 0x40)
        }
        return hash;
    }

    /// @notice Verify that a specific leaf element is part of the Sparse Merkle Tree at a specific position in the tree.
    //
    /// @param root The root of the merkle tree
    /// @param leaf The leaf which needs to be proven
    /// @param pos The position of the leaf, index starting with 0
    /// @param proof The array of proofs to help verify the leaf's membership, ordered from leaf to root
    /// @return A boolean value representing the success or failure of the verification
    function singleVerify(
        bytes32 root,
        bytes32 leaf,
        uint256 pos,
        bytes32[] memory proof
    ) internal pure returns (bool) {
        uint256 depth = proof.length;
        uint256 index = (1 << depth) + pos;
        bytes32 value = leaf;
        for (uint256 i = 0; i < depth; i++) {
            if (index & 1 == 0) {
                value = hash_node(value, proof[i]);
            } else {
                value = hash_node(proof[i], value);
            }
            index /= 2;
        }
        return value == root && index == 1;
    }

    /// @notice Verify that multi leafs in the Sparse Merkle Tree with generalized indices.
    /// @dev Indices are required to be sorted highest to lowest.
    /// @param root The root of the merkle tree
    /// @param depth Depth of the merkle tree. Equal to log2(number of leafs)
    /// @param indices The indices of the leafs, index starting whith 0
    /// @param leaves The leaves which need to be proven
    /// @param decommitments A list of decommitments required to reconstruct the merkle root
    /// @return A boolean value representing the success or failure of the verification
    function multiVerify(
        bytes32 root,
        uint256 depth,
        bytes32 indices,
        bytes32[] memory leaves,
        bytes32[] memory decommitments
    )
        internal
        pure
        returns (bool)
    {
        uint256 n = leaves.length;
        require(n <= 32, "LENGTH_TOO_LARGE");
        require(depth <= 8, "DEPTH_TOO_LARGE");

        // Dynamically allocate index and hash queue
        uint256[] memory tree_indices = new uint256[](n + 1);
        bytes32[] memory hashes = new bytes32[](n + 1);
        uint256 head = 0;
        uint256 tail = 0;
        uint256 di = 0;

        // Queue the leafs
        for(; tail < n; ++tail) {
            tree_indices[tail] = (1 << depth) + uint8(indices[tail]);
            hashes[tail] = leaves[tail];
        }

        // Itterate the queue until we hit the root
        while (true) {
            uint256 index = tree_indices[head];
            bytes32 hash = hashes[head];
            head = (head + 1) % (n + 1);

            // Merkle root
            if (index == 1) {
                return hash == root;
            // Even node, take sibbling from decommitments
            } else if (index & 1 == 0) {
                hash = hash_node(hash, decommitments[di++]);
            // Odd node with sibbling in the queue
            } else if (head != tail && tree_indices[head] == index - 1) {
                hash = hash_node(hashes[head], hash);
                head = (head + 1) % (n + 1);
            // Odd node with sibbling from decommitments
            } else {
                hash = hash_node(decommitments[di++], hash);
            }
            tree_indices[tail] = index / 2;
            hashes[tail] = hash;
            tail = (tail + 1) % (n + 1);
        }

        // resolve warning
        return false;
    }
}

////// src/truth/darwinia/DarwiniaLightClient.sol

/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

/* import "./BEEFYAuthorityRegistry.sol"; */
/* import "../../utils/ECDSA.sol"; */
/* import "../../utils/Bitfield.sol"; */
/* import "../../utils/SparseMerkleProof.sol"; */
/* import "../../spec/BEEFYCommitmentScheme.sol"; */
/* import "../../interfaces/ILightClient.sol"; */

/**
 * @title A entry contract for the Ethereum-like light client
 * @author echo
 * @notice The light client is the trust layer of the bridge
 * @dev See https://hackmd.kahub.in/Nx9YEaOaTRCswQjVbn4WsQ?view
 */
contract DarwiniaLightClient is ILightClient, Bitfield, BEEFYCommitmentScheme, BEEFYAuthorityRegistry {

    /* Events */

    /**
     * @notice Notifies an observer that the prover's attempt at initital
     * verification was successful.
     * @dev Note that the prover must wait until `n` blocks have been mined
     * subsequent to the generation of this event before the 2nd tx can be sent
     * @param prover The address of the calling prover
     * @param blockNumber The blocknumber in which the initial validation
     * succeeded
     * @param id An identifier to provide disambiguation
     */
    event InitialVerificationSuccessful(
        address prover,
        uint256 blockNumber,
        uint256 id
    );

    /**
     * @notice Notifies an observer that the complete verification process has
     *  finished successfuly and the new commitmentHash will be accepted
     * @param prover The address of the successful prover
     * @param id the identifier used
     */
    event FinalVerificationSuccessful(
        address prover,
        uint256 id,
        bool isNew
    );

    event CleanExpiredCommitment(uint256 id);

    event NewMessageRoot(bytes32 messageRoot, uint256 blockNumber);

    /* Types */

    struct Signature {
        bytes32 r;
        bytes32 vs;
    }

    /**
     * The Proof is a collection of proofs used to verify the signatures from the signers signing
     * each new justification.
     * @param signatures an array of signatures from the chosen signers
     * @param positions an array of the positions of the chosen signers
     * @param decommitments multi merkle proof from the chosen validators proving that their addresses
     * are in the validator set
     */
    struct CommitmentMultiProof {
        uint256 depth;
        bytes32 positions;
        bytes32[] decommitments;
        Signature[] signatures;
    }


    /*
     * @param signature the signature of one validator
     * @param position the position of the validator, index starting at 0
     * @param signer the public key of the validator
     * @param proof proof required for validation of the public key in the validator merkle tree
     */
    struct CommitmentSingleProof {
        uint256 position;
        address signer;
        bytes32[] proof;
        Signature signature;
    }

    /**
     * The ValidationData is the set of data used to link each pair of initial and complete verification transactions.
     * @param senderAddress the sender of the initial transaction
     * @param commitmentHash the hash of the commitment they are claiming has been signed
     * @param blockNumber the block number for this commitment
     * @param validatorClaimsBitfield a bitfield signalling which validators they claim have signed
     */
    struct ValidationData {
        address senderAddress;
        uint32 blockNumber;
        bytes32 commitmentHash;
        uint256 validatorClaimsBitfield;
    }

    struct MessagesProof {
        MessageSingleProof chainProof;
        MessageSingleProof laneProof;
    }

    struct MessageSingleProof {
        bytes32 root;
        bytes32[] proof;
    }

    /* State */

    uint256 public currentId;
    bytes32 public latestChainMessagesRoot;
    uint256 public latestBlockNumber;
    mapping(uint256 => ValidationData) public validationData;

    /* Constants */

    /**
     * @dev Block wait period after `newSignatureCommitment` to pick the random block hash
    */
    uint256 public constant BLOCK_WAIT_PERIOD = 12;

    /**
     * @dev Block wait period after `newSignatureCommitment` to pick the random block hash
     *  120000000/2^25 = 3.57 ether is recommended for Ethereum
    */
    uint256 public constant MIN_SUPPORT = 4 wei;

    /**
     * @dev A vault to store expired commitment or malicious commitment slashed asset
     */
    address public immutable SLASH_VAULT;

    /**
     * @dev NETWORK Source chain network identify ('Crab', 'Darwinia', 'Pangolin')
     */
    bytes32 public immutable NETWORK;

    /**
     * @notice Deploys the LightClientBridge contract
     * @param network source chain network name
     * @param slashVault initial SLASH_VAULT
     * @param currentAuthoritySetId The id of the current authority set
     * @param currentAuthoritySetLen The length of the current authority set
     * @param currentAuthoritySetRoot The merkle tree of the current authority set
    */
    constructor(
        bytes32 network,
        address slashVault,
        uint64 currentAuthoritySetId,
        uint32 currentAuthoritySetLen,
        bytes32 currentAuthoritySetRoot
    ) {
        NETWORK = network;
        SLASH_VAULT = slashVault;
        _updateAuthoritySet(currentAuthoritySetId, currentAuthoritySetLen, currentAuthoritySetRoot);
    }

    /* Public Functions */

    function getFinalizedChainMessagesRoot() external view returns (bytes32) {
        return latestChainMessagesRoot;
    }

    function getFinalizedBlockNumber() external view returns (uint256) {
        return latestBlockNumber;
    }

    function validatorBitfield(uint256 id) external view returns (uint256) {
        return validationData[id].validatorClaimsBitfield;
    }

    function threshold() public view returns (uint256) {
        if (authoritySetLen <= 36) {
            return authoritySetLen - (authoritySetLen - 1) / 3;
        }
        return 25;
    }

    function createRandomBitfield(uint256 id)
        public
        view
        returns (uint256)
    {
        ValidationData storage data = validationData[id];
        return _createRandomBitfield(data);
    }

    function _createRandomBitfield(ValidationData storage data)
        internal
        view
        returns (uint256)
    {
        require(data.blockNumber > 0, "Bridge: invalid id");
        return
            randomNBitsWithPriorCheck(
                getSeed(data.blockNumber),
                data.validatorClaimsBitfield,
                threshold(),
                authoritySetLen
            );
    }

    function createInitialBitfield(uint8[] calldata bitsToSet)
        external
        pure
        returns (uint256)
    {
        return createBitfield(bitsToSet);
    }

    function verify_messages_proof(
        bytes32 outlane_data_hash,
        uint32 chain_pos,
        uint32 lane_pos,
        bytes calldata encoded_proof
    ) external override view returns (bool) {
        return validate_lane_data_match_root(outlane_data_hash, chain_pos, lane_pos, encoded_proof);
    }

    function verify_messages_delivery_proof(
        bytes32 inlane_data_hash,
        uint32 chain_pos,
        uint32 lane_pos,
        bytes calldata encoded_proof
    ) external override view returns (bool) {
        return validate_lane_data_match_root(inlane_data_hash, chain_pos, lane_pos, encoded_proof);
    }

    function validate_lane_data_match_root(
        bytes32 lane_hash,
        uint32 chain_pos,
        uint32 lane_pos,
        bytes calldata proof
    ) internal view returns (bool) {
        MessagesProof memory messages_proof = abi.decode(proof, (MessagesProof));
        // Validate that the commitment matches the commitment contents
        require(messages_proof.chainProof.root == latestChainMessagesRoot, "Lane: invalid ChainMessagesRoot");
        return validateLaneDataMatchRoot(
                lane_hash,
                chain_pos,
                lane_pos,
                messages_proof.chainProof,
                messages_proof.laneProof
            );
    }

    function validateLaneDataMatchRoot(
        bytes32 laneHash,
        uint256 chainPosition,
        uint256 lanePosition,
        MessageSingleProof memory chainProof,
        MessageSingleProof memory laneProof
    ) internal pure returns (bool) {
        return
            SparseMerkleProof.singleVerify(
                laneProof.root,
                laneHash,
                lanePosition,
                laneProof.proof
            )
            &&
            SparseMerkleProof.singleVerify(
                chainProof.root,
                laneProof.root,
                chainPosition,
                chainProof.proof
            );
    }

    /**
     * @notice Executed by the prover in order to begin the process of block
     * acceptance by the light client
     * @param commitmentHash contains the commitmentHash signed by the current authority set
     * @param validatorClaimsBitfield a bitfield containing a membership status of each
     * validator who has claimed to have signed the commitmentHash
     */
    function newSignatureCommitment(
        bytes32 commitmentHash,
        uint256 validatorClaimsBitfield,
        CommitmentSingleProof calldata commitmentSingleProof
    ) public payable returns (uint256) {
        /**
         * @dev Check that the bitfield actually contains enough claims to be succesful, ie, >= 2/3 + 1
         */
        require(
            countSetBits(validatorClaimsBitfield) >= authoritySetLen - (authoritySetLen - 1) / 3,
            "Bridge: Bitfield not enough validators"
        );

        verifySignature(
            commitmentSingleProof.signature,
            authoritySetRoot,
            commitmentSingleProof.signer,
            authoritySetLen,
            commitmentSingleProof.position,
            commitmentSingleProof.proof,
            commitmentHash
        );

        /**
         * @notice Lock up the sender stake as collateral
         */
        require(msg.value == MIN_SUPPORT, "Bridge: Collateral mismatch");

        // Accept and save the commitment
        validationData[currentId] = ValidationData(
            msg.sender,
            uint32(block.number),
            commitmentHash,
            validatorClaimsBitfield
        );

        emit InitialVerificationSuccessful(msg.sender, block.number, currentId);

        currentId = currentId + 1;
        return currentId;
    }

    /**
     * @notice Performs the second step in the validation logic
     * @param id an identifying value generated in the previous transaction
     * @param commitment contains the full commitment that was used for the commitmentHash
     * @param validatorProof a struct containing the data needed to verify all validator signatures
     */
    function completeSignatureCommitment(
        uint256 id,
        Commitment calldata commitment,
        CommitmentMultiProof calldata validatorProof
    ) public {
        verifyCommitment(id, commitment, validatorProof);

        bool isNew = processPayload(commitment.payload, commitment.blockNumber);

        /**
         * @dev We no longer need the data held in state, so delete it for a gas refund
         */
        delete validationData[id];

        /**
         * @notice If relayer do `completeSignatureCommitment` late or failed, `MIN_SUPPORT` will be slashed
         */
        payable(msg.sender).transfer(MIN_SUPPORT);

        emit FinalVerificationSuccessful(msg.sender, id, isNew);
    }

    /**
     * @notice Clean up the expired commitment and slash
     * @param id the identifier generated by submit commitment
     */
    function cleanExpiredCommitment(uint256 id) public {
        ValidationData storage data = validationData[id];
        require(block.number > data.blockNumber + BLOCK_WAIT_PERIOD + 256, "Bridge: Only expired");
        payable(SLASH_VAULT).transfer(MIN_SUPPORT);
        delete validationData[id];
        emit CleanExpiredCommitment(id);
    }

    /* Private Functions */

    function verifyCommitment(
        uint256 id,
        Commitment calldata commitment,
        CommitmentMultiProof calldata validatorProof
    ) private view {
        ValidationData storage data = validationData[id];

        /**
         * @dev verify that network is the same as `network`
         */
        require(
            commitment.payload.network == NETWORK,
            "Bridge: Commitment is not part of this network"
        );

        /**
         * @dev verify that sender is the same as in `newSignatureCommitment`
         */
        require(
            msg.sender == data.senderAddress,
            "Bridge: Sender address does not match original validation data"
        );

        uint256 randomBitfield = _createRandomBitfield(data);

        // Encode and hash the commitment
        bytes32 commitmentHash = hash(commitment);

        require(
            commitmentHash == data.commitmentHash,
            "Bridge: Commitment must match commitment hash"
        );

        verifyValidatorProofSignatures(
            randomBitfield,
            validatorProof,
            commitmentHash
        );
    }

    function roundUpToPow2(uint256 x) internal pure returns (uint256) {
        if (x <= 1) return 1;
        else return 2 * roundUpToPow2((x + 1) / 2);
    }

    function verifyValidatorProofSignatures(
        uint256 randomBitfield,
        CommitmentMultiProof calldata proof,
        bytes32 commitmentHash
    ) private view {
        verifyProofSignatures(
            authoritySetRoot,
            authoritySetLen,
            randomBitfield,
            proof,
            threshold(),
            commitmentHash
        );
    }

    function verifyProofSignatures(
        bytes32 root,
        uint256 len,
        uint256 bitfield,
        CommitmentMultiProof calldata proof,
        uint256 requiredNumOfSignatures,
        bytes32 commitmentHash
    ) private pure {

        require(
            proof.signatures.length == requiredNumOfSignatures,
            "Bridge: Number of signatures does not match required"
        );

        uint256 width = roundUpToPow2(len);
        /**
         *  @dev For each randomSignature, do:
         */
        bytes32[] memory leaves = new bytes32[](requiredNumOfSignatures);
        for (uint256 i = 0; i < requiredNumOfSignatures; i++) {
            uint8 pos = uint8(proof.positions[i]);

            require(pos < len, "Bridge: invalid signer position");
            /**
             * @dev Check if validator in bitfield
             */
            require(
                isSet(bitfield, pos),
                "Bridge: signer must be once in bitfield"
            );

            /**
             * @dev Remove validator from bitfield such that no validator can appear twice in signatures
             */
            bitfield = clear(bitfield, pos);

            address signer = ECDSA.recover(commitmentHash, proof.signatures[i].r, proof.signatures[i].vs);
            leaves[i] = keccak256(abi.encodePacked(signer));
        }

        require((1 << proof.depth) == width, "Bridge: invalid depth");
        require(
            SparseMerkleProof.multiVerify(
                root,
                proof.depth,
                proof.positions,
                leaves,
                proof.decommitments
            ),
            "Bridge: invalid multi proof"
        );
    }

    function verifySignature(
        Signature calldata signature,
        bytes32 root,
        address signer,
        uint256 len,
        uint256 position,
        bytes32[] calldata proof,
        bytes32 commitmentHash
    ) private pure {
        require(position < len, "Bridge: invalid signer position");

        /**
         * @dev Check if merkle proof is valid
         */
        require(
            checkAddrInSet(
                root,
                signer,
                position,
                proof
            ),
            "Bridge: signer must be in signer set at correct position"
        );

        /**
         * @dev Check if signature is correct
         */
        require(
            ECDSA.recover(commitmentHash, signature.r, signature.vs) == signer,
            "Bridge: Invalid Signature"
        );
    }

    /**
     * @notice Checks if an address is a member of the merkle tree
     * @param root the root of the merkle tree
     * @param addr The address to check
     * @param pos The position to check, index starting at 0
     * @param proof Merkle proof required for validation of the address
     * @return Returns true if the address is in the set
     */
    function checkAddrInSet(
        bytes32 root,
        address addr,
        uint256 pos,
        bytes32[] calldata proof
    ) public pure returns (bool) {
        bytes32 hashedLeaf = keccak256(abi.encodePacked(addr));
        return
            SparseMerkleProof.singleVerify(
                root,
                hashedLeaf,
                pos,
                proof
            );
    }

    /**
     * @notice Deterministically generates a seed from the block hash at the block number of creation of the validation
     * @dev Note that `blockhash(blockNum)` will only work for the 256 most recent blocks. If
     * `completeSignatureCommitment` is called too late, a new call to `newSignatureCommitment` is necessary to reset
     * validation data's block number
     * @param blockNumber block number
     * @return onChainRandNums an array storing the random numbers generated inside this function
     */
    function getSeed(uint256 blockNumber)
        private
        view
        returns (uint256)
    {
        /**
         * @dev verify that block wait period has passed
         */
        require(
            block.number > blockNumber + BLOCK_WAIT_PERIOD,
            "Bridge: Block wait period not over"
        );

        require(
            block.number <= blockNumber + BLOCK_WAIT_PERIOD + 256,
            "Bridge: Block number has expired"
        );

        uint256 randomSeedBlockNum = blockNumber + BLOCK_WAIT_PERIOD;
        // @note Create a hash seed from the block number
        bytes32 randomSeedBlockHash = blockhash(randomSeedBlockNum);

        return uint256(randomSeedBlockHash);
    }

    /**
     * @notice Perform some operation[s] using the payload
     * @param payload The payload variable passed in via the initial function
     * @param blockNumber The blockNumber variable passed in via the initial function
     */
    function processPayload(Payload calldata payload, uint256 blockNumber) private returns (bool) {
        if (blockNumber > latestBlockNumber) {
            latestChainMessagesRoot = payload.messageRoot;
            latestBlockNumber = blockNumber;

            applyAuthoritySetChanges(
                payload.nextValidatorSet.id,
                payload.nextValidatorSet.len,
                payload.nextValidatorSet.root
            );
            emit NewMessageRoot(latestChainMessagesRoot, blockNumber);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Check if the payload includes a new authority set,
     * and if it does then update the new authority set
     * @param newAuthoritySetId The id of the new authority set
     * @param newAuthoritySetLen The length of the new authority set
     * @param newAuthoritySetRoot The new merkle tree of the new authority set
     */
    function applyAuthoritySetChanges(
        uint64 newAuthoritySetId,
        uint32 newAuthoritySetLen,
        bytes32 newAuthoritySetRoot
    ) private {
        require(newAuthoritySetId == authoritySetId || newAuthoritySetId == authoritySetId + 1, "Bridge: Invalid new validator set id");
        if (newAuthoritySetId == authoritySetId + 1) {
            require(newAuthoritySetLen <= 256, "Bridge: Authority set too large");
            _updateAuthoritySet(
                newAuthoritySetId,
                newAuthoritySetLen,
                newAuthoritySetRoot
            );
        }
    }

}