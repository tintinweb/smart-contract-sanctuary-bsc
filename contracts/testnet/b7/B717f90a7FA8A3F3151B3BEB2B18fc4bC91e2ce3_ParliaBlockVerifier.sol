// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../common/Types.sol";

import "../interfaces/IProofVerificationFunction.sol";

import "../libraries/MerklePatriciaProof.sol";

import "./PoSaBlockVerifier.sol";

contract ParliaBlockVerifier is IProofVerificationFunction, PoSaBlockVerifier {
    function verifyBlockWithoutQuorum(
        uint256 chainId,
        bytes calldata rawBlock,
        uint64 epochLength
    )
        external
        pure
        override
        returns (
            Types.BlockHeader memory blockHeader,
            address[] memory validatorSet
        )
    {
        (blockHeader, validatorSet) = _parseAndVerifyPoSaBlockHeader(
            chainId,
            rawBlock,
            epochLength
        );
        return (blockHeader, validatorSet);
    }

    function verifyBlockAndReachedQuorum(
        uint256 chainId,
        bytes[] calldata blockProofs,
        uint32 epochLength,
        IValidatorChecker validatorChecker
    )
        external
        view
        override
        returns (
            Types.BlockHeader memory firstBlock,
            address[] memory newValidatorSet
        )
    {
        bytes32 parentHash;
        address[] memory blockValidators = new address[](blockProofs.length);
        for (uint256 i = 0; i < blockProofs.length; i++) {
            (
                Types.BlockHeader memory blockHeader,
                address[] memory validatorSet
            ) = _parseAndVerifyPoSaBlockHeader(
                    chainId,
                    blockProofs[i],
                    epochLength
                );
            blockValidators[i] = blockHeader.coinbase;
            // first block is block with proof
            if (i == 0) {
                firstBlock = blockHeader;
            } else {
                require(
                    blockHeader.parentHash == parentHash,
                    "bad parent hash"
                );
            }
            if (blockHeader.blockNumber % epochLength == 0) {
                newValidatorSet = validatorSet;
            }
            parentHash = blockHeader.blockHash;
        }
        // clac next epoch, for zero epoch we can't check previous validators
        require(
            validatorChecker.checkValidatorsAndQuorumReached(
                chainId,
                blockValidators,
                firstBlock.blockNumber
            ),
            "quorum not reached"
        );
        return (firstBlock, newValidatorSet);
    }

    function verifyEpochBlock(
        uint256 chainId,
        bytes[] calldata blockProofs,
        uint32 epochLength,
        IValidatorChecker validatorChecker
    ) external view override returns (bool) {
        uint256 firstBlock;
        address[] memory blockValidators = new address[](blockProofs.length);
        for (uint256 i = 0; i < blockProofs.length; i++) {
            (
                Types.BlockHeader memory blockHeader,

            ) = _parseAndVerifyPoSaBlockHeader(
                    chainId,
                    blockProofs[i],
                    epochLength
                );
            blockValidators[i] = blockHeader.coinbase;
            if (i == 0) {
                firstBlock = blockHeader.blockNumber;
            }
        }
        // clac next epoch, for zero epoch we can't check previous validators
        return (
            validatorChecker.checkEpochBlock(
                chainId,
                blockValidators,
                firstBlock
            )
        );
    }

    function checkReceiptProof(
        bytes calldata rawReceipt,
        bytes32 receiptRoot,
        bytes calldata proofSiblings,
        bytes calldata proofPath
    ) external pure override returns (bool) {
        return
            MerklePatriciaProof.verify(
                keccak256(rawReceipt),
                proofPath,
                proofSiblings,
                receiptRoot
            );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Types {
    struct BlockHeader {
        bytes32 blockHash;
        bytes32 parentHash;
        uint64 blockNumber;
        address coinbase;
        bytes32 receiptsRoot;
        bytes32 txsRoot;
        bytes32 stateRoot;
    }

    struct State {
        address contractAddress;
        uint256 fromChain;
        uint256 toChain;
        address fromAddress;
        address toAddress;
        address fromToken;
        address toToken;
        uint256 totalAmount;
        TokenMetadata metadata;
    }

    struct TokenMetadata {
        string name;
        string symbol;
        uint256 originChain;
        address originAddress;
    }
}

// SPDX-License-Identifier: Apache-2.0

/*
 * @title MerklePatriciaVerifier
 * @author Sam Mayo ([email protected])
 *
 * @dev Library for verifing merkle patricia proofs.
 */
pragma solidity ^0.8.0;

import {RLPReader} from "./RLPReader.sol";
import "./Utils.sol";

library MerklePatriciaProof {
    /*
     * @dev Verifies a merkle patricia proof.
     * @param value The terminating value in the trie.
     * @param encodedPath The path in the trie leading to value.
     * @param rlpParentNodes The rlp encoded stack of nodes.
     * @param root The root hash of the trie.
     * @return The boolean validity of the proof.
     */
    function verify(
        bytes32 value,
        bytes calldata path,
        bytes calldata siblingsRlp,
        bytes32 root
    ) internal pure returns (bool) {
        RLPReader.RLPItem[] memory siblings = RLPReader.toList(
            RLPReader.toRlpItem(siblingsRlp)
        );

        bytes32 nodeKey = root;
        RLPReader.RLPItem[] memory currentNodeList;
        uint256 pathPtr = 0;

        bytes memory nibblePath = _getNibbleArray(path);
        if (nibblePath.length == 0) {
            return false;
        }
        for (uint256 i = 0; i < siblings.length; i++) {
            if (pathPtr > nibblePath.length) {
                return false;
            }
            if (nodeKey != keccak256(RLPReader.toBytes(siblings[i]))) {
                return false;
            }
            currentNodeList = RLPReader.toList(
                RLPReader.toRlpItem(RLPReader.toBytes(siblings[i]))
            );
            if (currentNodeList.length == 17) {
                if (pathPtr == nibblePath.length) {
                    return
                        keccak256(RLPReader.toBytes(currentNodeList[16])) ==
                        value;
                }
                uint8 nextPathNibble = uint8(nibblePath[pathPtr]);
                if (nextPathNibble > 16) {
                    return false;
                }
                nodeKey = bytes32(
                    RLPReader.toUintStrict(currentNodeList[nextPathNibble])
                );
                pathPtr += 1;
            } else if (currentNodeList.length == 2) {
                uint256 traversed = _nibblesToTraverse(
                    RLPReader.toBytes(currentNodeList[0]),
                    nibblePath,
                    pathPtr
                );
                if (pathPtr + traversed == nibblePath.length) {
                    return
                        keccak256(RLPReader.toBytes(currentNodeList[1])) ==
                        value;
                }
                if (traversed == 0) {
                    return false;
                }
                pathPtr += traversed;
                nodeKey = bytes32(RLPReader.toUintStrict(currentNodeList[1]));
            } else {
                return false;
            }
        }

        return false;
    }

    function _nibblesToTraverse(
        bytes memory encodedPartialPath,
        bytes memory path,
        uint256 pathPtr
    ) private pure returns (uint256) {
        uint256 len;
        // encodedPartialPath has elements that are each two hex characters (1 byte), but partialPath
        // and slicedPath have elements that are each one hex character (1 nibble)
        bytes memory partialPath = _getNibbleArray(encodedPartialPath);
        bytes memory slicedPath = new bytes(partialPath.length);

        // pathPtr counts nibbles in path
        // partialPath.length is a number of nibbles
        for (uint256 i = pathPtr; i < pathPtr + partialPath.length; i++) {
            bytes1 pathNibble = path[i];
            slicedPath[i - pathPtr] = pathNibble;
        }

        if (keccak256(partialPath) == keccak256(slicedPath)) {
            len = partialPath.length;
        } else {
            len = 0;
        }
        return len;
    }

    // bytes b must be hp encoded
    function _getNibbleArray(bytes memory b)
        private
        pure
        returns (bytes memory)
    {
        bytes memory nibbles;
        if (b.length == 0) {
            return nibbles;
        }
        uint8 offset;
        uint8 hpNibble = uint8(_getNthNibbleOfBytes(0, b));
        if (hpNibble == 1 || hpNibble == 3) {
            nibbles = new bytes(b.length * 2 - 1);
            bytes1 oddNibble = _getNthNibbleOfBytes(1, b);
            nibbles[0] = oddNibble;
            offset = 1;
        } else {
            nibbles = new bytes(b.length * 2 - 2);
            offset = 0;
        }
        for (uint256 i = offset; i < nibbles.length; i++) {
            nibbles[i] = _getNthNibbleOfBytes(i - offset + 2, b);
        }
        return nibbles;
    }

    function _getNthNibbleOfBytes(uint256 n, bytes memory str)
        private
        pure
        returns (bytes1)
    {
        return
            bytes1(
                n % 2 == 0 ? uint8(str[n / 2]) / 0x10 : uint8(str[n / 2]) % 0x10
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../common/Types.sol";
import "./IValidatorChecker.sol";

interface IProofVerificationFunction {
    function verifyBlockWithoutQuorum(
        uint256 chainId,
        bytes calldata rawBlock,
        uint64 epochLength
    )
        external
        view
        returns (
            Types.BlockHeader memory blockHeader,
            address[] memory validatorSet
        );

    function verifyBlockAndReachedQuorum(
        uint256 chainId,
        bytes[] calldata blockProofs,
        uint32 epochLength,
        IValidatorChecker validatorChecker
    )
        external
        view
        returns (
            Types.BlockHeader memory firstBlock,
            address[] memory newValidatorSet
        );

    function verifyEpochBlock(
        uint256 chainId,
        bytes[] calldata blockProofs,
        uint32 epochLength,
        IValidatorChecker validatorChecker
    ) external view returns (bool);

    function checkReceiptProof(
        bytes calldata rawReceipt,
        bytes32 receiptRoot,
        bytes calldata proofSiblings,
        bytes calldata proofPath
    ) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../common/Types.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../libraries/RLP.sol";

contract PoSaBlockVerifier {
    function _parseAndVerifyPoSaBlockHeader(
        uint256 chainId,
        bytes calldata rawBlock,
        uint64 epochLength
    )
        internal
        pure
        returns (
            Types.BlockHeader memory blockHeader,
            address[] memory newValidatorSet
        )
    {
        // support of >64 kB headers might make code much more complicated and such blocks doesn't exist
        require(rawBlock.length <= 65535, "rawBlock out of len");
        // open RLP and calc block header length after the prefix (it should be block proof length -3)
        uint256 it = RLP.openRlp(rawBlock);
        uint256 originalLength = RLP.itemLength(it);
        it = RLP.beginIteration(it);
        // parent hash
        blockHeader.parentHash = RLP.toBytes32(it);
        it = RLP.next(it);
        // uncle hash
        it = RLP.next(it);
        // extract block coinbase
        address coinbase = RLP.toAddress(it);
        it = RLP.next(it);
        // state root
        blockHeader.stateRoot = RLP.toBytes32(it);
        it = RLP.next(it);
        // txs root
        blockHeader.txsRoot = RLP.toBytes32(it);
        it = RLP.next(it);
        // receipts root
        blockHeader.receiptsRoot = RLP.toBytes32(it);
        it = RLP.next(it);
        // bloom filter
        it = RLP.next(it);
        // slow skip for variadic fields: difficulty, number, gas limit, gas used, time
        it = RLP.next(it);
        blockHeader.blockNumber = uint64(RLP.toUint256(it, RLP.itemLength(it)));
        it = RLP.next(RLP.next(RLP.next(RLP.next(it))));
        // calculate and remember offsets for extra data begin and end
        uint256 beforeExtraDataOffset = it;
        it = RLP.next(it);
        uint256 afterExtraDataOffset = it;
        // create chain id and extra data RLPs
        uint256 oldExtraDataPrefixLength = RLP.prefixLength(
            beforeExtraDataOffset
        );
        uint256 newExtraDataPrefixLength;
        {
            uint256 newEstExtraDataLength = afterExtraDataOffset -
                beforeExtraDataOffset -
                oldExtraDataPrefixLength -
                65;
            if (newEstExtraDataLength < 56) {
                newExtraDataPrefixLength = 1;
            } else {
                newExtraDataPrefixLength =
                    1 +
                    RLP.uintRlpPrefixLength(newEstExtraDataLength);
            }
        }
        bytes memory chainRlp = RLP.uintToRlp(chainId);
        // form signing data from block proof
        bytes memory signingData = new bytes(
            chainRlp.length +
                originalLength -
                oldExtraDataPrefixLength +
                newExtraDataPrefixLength -
                65
        );
        // init first 3 bytes of signing data with RLP prefix and encoded length
        {
            signingData[0] = 0xf9;
            uint256 bodyLength = signingData.length - 3;
            signingData[1] = bytes1(uint8(bodyLength >> 8));
            signingData[2] = bytes1(uint8(bodyLength >> 0));
        }
        // copy chain id rlp right after the prefix
        for (uint256 i = 0; i < chainRlp.length; i++) {
            signingData[3 + i] = chainRlp[i];
        }
        // copy block calldata to the signing data before extra data [0;extraData-65)
        assembly {
            // copy first bytes before extra data
            let dst := add(signingData, add(mload(chainRlp), 0x23)) // 0x20+3 (3 is a size of prefix for 64kB list)
            let src := add(rawBlock.offset, 3)
            let len := sub(beforeExtraDataOffset, src)
            calldatacopy(dst, src, len)
            // copy extra data with new prefix
            dst := add(add(dst, len), newExtraDataPrefixLength)
            src := add(beforeExtraDataOffset, oldExtraDataPrefixLength)
            len := sub(
                sub(
                    sub(afterExtraDataOffset, beforeExtraDataOffset),
                    oldExtraDataPrefixLength
                ),
                65
            )
            calldatacopy(dst, src, len)
            // copy rest (mix digest, nonce)
            dst := add(dst, len)
            src := afterExtraDataOffset
            len := 42 // its always 42 bytes
            calldatacopy(dst, src, len)
        }
        // patch extra data length inside RLP signing data
        {
            uint256 newExtraDataLength;
            uint256 patchExtraDataAt;
            assembly {
                newExtraDataLength := sub(
                    sub(
                        sub(afterExtraDataOffset, beforeExtraDataOffset),
                        oldExtraDataPrefixLength
                    ),
                    65
                )
                patchExtraDataAt := sub(
                    mload(signingData),
                    add(add(newExtraDataLength, newExtraDataPrefixLength), 42)
                )
            }
            // we don't need to cover more than 3 cases because we revert if block header >64kB
            if (newExtraDataPrefixLength == 4) {
                signingData[patchExtraDataAt + 0] = bytes1(uint8(0xb7 + 3));
                signingData[patchExtraDataAt + 1] = bytes1(
                    uint8(newExtraDataLength >> 16)
                );
                signingData[patchExtraDataAt + 2] = bytes1(
                    uint8(newExtraDataLength >> 8)
                );
                signingData[patchExtraDataAt + 3] = bytes1(
                    uint8(newExtraDataLength >> 0)
                );
            } else if (newExtraDataPrefixLength == 3) {
                signingData[patchExtraDataAt + 0] = bytes1(uint8(0xb7 + 2));
                signingData[patchExtraDataAt + 1] = bytes1(
                    uint8(newExtraDataLength >> 8)
                );
                signingData[patchExtraDataAt + 2] = bytes1(
                    uint8(newExtraDataLength >> 0)
                );
            } else if (newExtraDataPrefixLength == 2) {
                signingData[patchExtraDataAt + 0] = bytes1(uint8(0xb7 + 1));
                signingData[patchExtraDataAt + 1] = bytes1(
                    uint8(newExtraDataLength >> 0)
                );
            } else if (newExtraDataLength < 56) {
                signingData[patchExtraDataAt + 0] = bytes1(
                    uint8(0x80 + newExtraDataLength)
                );
            }
            // else can't be here, its unreachable
        }
        // save signature
        bytes memory signature = new bytes(65);
        assembly {
            calldatacopy(
                add(signature, 0x20),
                sub(afterExtraDataOffset, 65),
                65
            )
        }
        // recover signer from signature (genesis block doesn't have signature)
        if (blockHeader.blockNumber != 0) {
            if (signature[64] == bytes1(uint8(1))) {
                signature[64] = bytes1(uint8(28));
            } else {
                signature[64] = bytes1(uint8(27));
            }
            blockHeader.coinbase = ECDSA.recover(
                keccak256(signingData),
                signature
            );

            require(blockHeader.coinbase == coinbase, "bad coinbase");
        }
        // parse validators for zero block epoch
        if (blockHeader.blockNumber % epochLength == 0) {
            uint256 totalValidators = (afterExtraDataOffset -
                beforeExtraDataOffset +
                oldExtraDataPrefixLength -
                65 -
                32) / 20;
            newValidatorSet = new address[](totalValidators);
            for (uint256 i = 0; i < totalValidators; i++) {
                uint256 validator;
                assembly {
                    validator := calldataload(
                        add(
                            add(
                                add(
                                    beforeExtraDataOffset,
                                    oldExtraDataPrefixLength
                                ),
                                mul(i, 20)
                            ),
                            32
                        )
                    )
                }
                newValidatorSet[i] = address(uint160(validator >> 96));
            }
        }
        // calc block hash
        blockHeader.blockHash = keccak256(rawBlock);
        return (blockHeader, newValidatorSet);
    }

    function _parsePoSaBlockHeader(bytes calldata rawBlock)
        internal
        pure
        returns (Types.BlockHeader memory blockHeader)
    {
        uint256 it = RLP.beginRlp(rawBlock);
        // parent hash, uncle hash
        it = RLP.next(it);
        blockHeader.parentHash = RLP.toBytes32(it);
        it = RLP.next(it);
        // coinbase
        blockHeader.coinbase = RLP.toAddress(it);
        it = RLP.next(it);
        // state root, transactions root, receipts root
        blockHeader.stateRoot = RLP.toBytes32(it);
        it = RLP.next(it);
        blockHeader.txsRoot = RLP.toBytes32(it);
        it = RLP.next(it);
        blockHeader.receiptsRoot = RLP.toBytes32(it);
        it = RLP.next(it);
        // bloom, difficulty
        it = RLP.next(it);
        it = RLP.next(it);
        // block number, gas limit, gas used, time
        blockHeader.blockNumber = uint64(RLP.toUint256(it, RLP.itemLength(it)));
        it = RLP.next(it);
        it = RLP.next(it);
        it = RLP.next(it);
        it = RLP.next(it);
        // extra data
        it = RLP.next(it);
        // mix digest, nonce
        it = RLP.next(it);
        it = RLP.next(it);
        // calc block hash
        blockHeader.blockHash = keccak256(rawBlock);
        return blockHeader;
    }
}

// SPDX-License-Identifier: Apache-2.0

/*
 * @author Hamdi Allam [email protected]
 * Please reach out with any questions or concerns
 */
pragma solidity >=0.8.0;

library RLPReader {
    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint len;
        uint memPtr;
    }

    struct Iterator {
        RLPItem item; // Item that's being iterated over.
        uint nextPtr; // Position of the next item in the list.
    }

    /*
     * @dev Returns the next element in the iteration. Reverts if it has not next element.
     * @param self The iterator.
     * @return The next element in the iteration.
     */
    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self), "RLPReader donot have next");

        uint ptr = self.nextPtr;
        uint itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    /*
     * @dev Returns true if the iteration has more elements.
     * @param self The iterator.
     * @return true if the iteration has more elements.
     */
    function hasNext(Iterator memory self) internal pure returns (bool) {
        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    /*
     * @param item RLP encoded bytes
     */
    function toRlpItem(bytes memory item)
        internal
        pure
        returns (RLPItem memory)
    {
        uint memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    /*
     * @dev Create an iterator. Reverts if item is not a list.
     * @param self The RLP item.
     * @return An 'Iterator' over the item.
     */
    function iterator(RLPItem memory self)
        internal
        pure
        returns (Iterator memory)
    {
        require(isList(self), "RLPReader iterator not list");

        uint ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    /*
     * @param the RLP item.
     */
    function rlpLen(RLPItem memory item) internal pure returns (uint) {
        return item.len;
    }

    /*
     * @param the RLP item.
     * @return (memPtr, len) pair: location of the item's payload in memory.
     */
    function payloadLocation(RLPItem memory item)
        internal
        pure
        returns (uint, uint)
    {
        uint offset = _payloadOffset(item.memPtr);
        uint memPtr = item.memPtr + offset;
        uint len = item.len - offset; // data length
        return (memPtr, len);
    }

    /*
     * @param the RLP item.
     */
    function payloadLen(RLPItem memory item) internal pure returns (uint) {
        (, uint len) = payloadLocation(item);
        return len;
    }

    /*
     * @param the RLP item containing the encoded list.
     */
    function toList(RLPItem memory item)
        internal
        pure
        returns (RLPItem[] memory)
    {
        require(isList(item), "RLPReader not list");

        uint items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint dataLen;
        for (uint i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    // @return indicator whether encoded payload is a list. negate this function call for isData.
    function isList(RLPItem memory item) internal pure returns (bool) {
        if (item.len == 0) return false;

        uint8 byte0;
        uint memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }

    /*
     * @dev A cheaper version of keccak256(toRlpBytes(item)) that avoids copying memory.
     * @return keccak256 hash of RLP encoded bytes.
     */
    function rlpBytesKeccak256(RLPItem memory item)
        internal
        pure
        returns (bytes32)
    {
        uint256 ptr = item.memPtr;
        uint256 len = item.len;
        bytes32 result;
        assembly {
            result := keccak256(ptr, len)
        }
        return result;
    }

    /*
     * @dev A cheaper version of keccak256(toBytes(item)) that avoids copying memory.
     * @return keccak256 hash of the item payload.
     */
    function payloadKeccak256(RLPItem memory item)
        internal
        pure
        returns (bytes32)
    {
        (uint memPtr, uint len) = payloadLocation(item);
        bytes32 result;
        assembly {
            result := keccak256(memPtr, len)
        }
        return result;
    }

    /** RLPItem conversions into data types **/

    // @returns raw rlp encoding in bytes
    function toRlpBytes(RLPItem memory item)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;

        uint ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    // any non-zero byte except "0x80" is considered true
    function toBoolean(RLPItem memory item) internal pure returns (bool) {
        require(item.len == 1, "RLPReader item bool out of len");
        uint result;
        uint memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        // SEE Github Issue #5.
        // Summary: Most commonly used RLP libraries (i.e Geth) will encode
        // "0" as "0x80" instead of as "0". We handle this edge case explicitly
        // here.
        if (result == 0 || result == STRING_SHORT_START) {
            return false;
        } else {
            return true;
        }
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {
        // 1 byte for the length prefix
        require(item.len == 21, "RLPReader item address out of len");

        return address(uint160(toUint(item)));
    }

    function toUint(RLPItem memory item) internal pure returns (uint) {
        require(
            item.len > 0 && item.len <= 33,
            "RLPReader item uint out of len"
        );

        (uint memPtr, uint len) = payloadLocation(item);

        uint result;
        assembly {
            result := mload(memPtr)

            // shfit to the correct location if neccesary
            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    // enforces 32 byte length
    function toUintStrict(RLPItem memory item) internal pure returns (uint) {
        // one byte prefix
        require(item.len == 33, "RLPReader item uint strict out of len");

        uint result;
        uint memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0, "RLPReader item bytes out of len");

        (uint memPtr, uint len) = payloadLocation(item);
        bytes memory result = new bytes(len);

        uint destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(memPtr, destPtr, len);
        return result;
    }

    /*
     * Private Helpers
     */

    // @return number of payload items inside an encoded list.
    function numItems(RLPItem memory item) private pure returns (uint) {
        if (item.len == 0) return 0;

        uint count = 0;
        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            count++;
        }

        return count;
    }

    // @return entire rlp item byte length
    function _itemLength(uint memPtr) private pure returns (uint) {
        uint itemLen;
        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                /* 32 byte word size */
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint memPtr) private pure returns (uint) {
        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (
            byte0 < STRING_LONG_START ||
            (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)
        ) return 1;
        else if (byte0 < LIST_SHORT_START)
            // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }

    /*
     * @param src Pointer to source
     * @param dest Pointer to destination
     * @param len Amount of memory to copy from the source
     */
    function copy(
        uint src,
        uint dest,
        uint len
    ) private pure {
        if (len == 0) return;

        // copy as many word sizes as possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        if (len > 0) {
            // left over bytes. Mask is used to remove unwanted bytes from the word
            uint mask = 256**(WORD_SIZE - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask)) // zero out src
                let destpart := and(mload(dest), mask) // retrieve the bytes
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

library Utils {
    function compareBytes(bytes memory x, bytes memory y)
        internal
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(x)) == keccak256(abi.encodePacked(y));
    }

    function _bytes32ToString(bytes32 _bytes32)
        internal
        pure
        returns (string memory)
    {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function _amountErc20Token(address fromToken, uint256 totalAmount)
        internal
        view
        returns (uint256)
    {
        // lets pack ERC20 token meta data and scale amount to 18 decimals
        require(
            IERC20Metadata(fromToken).decimals() <= 18,
            "decimals overflow"
        );
        totalAmount *= (10**(18 - IERC20Metadata(fromToken).decimals()));
        return totalAmount;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

interface IValidatorChecker {
    function checkEpochBlock(
        uint256 chainId,
        address[] memory checkValidators,
        uint256 blockStart
    ) external view returns (bool);

    function checkValidatorsAndQuorumReached(
        uint256 chainId,
        address[] memory checkValidators,
        uint256 blockStart
    ) external view returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.6;

library RLP {
    uint8 public constant STRING_SHORT_START = 0x80;
    uint8 public constant STRING_LONG_START = 0xb8;
    uint8 public constant LIST_SHORT_START = 0xc0;
    uint8 public constant LIST_LONG_START = 0xf8;
    uint8 public constant WORD_SIZE = 32;

    function openRlp(bytes calldata rawRlp)
        internal
        pure
        returns (uint256 iter)
    {
        uint256 rawRlpOffset;
        assembly {
            rawRlpOffset := rawRlp.offset
        }
        return rawRlpOffset;
    }

    function beginRlp(bytes calldata rawRlp)
        internal
        pure
        returns (uint256 iter)
    {
        uint256 rawRlpOffset;
        assembly {
            rawRlpOffset := rawRlp.offset
        }
        return rawRlpOffset + _payloadOffset(rawRlpOffset);
    }

    function lengthRlp(bytes calldata rawRlp)
        internal
        pure
        returns (uint256 iter)
    {
        uint256 rawRlpOffset;
        assembly {
            rawRlpOffset := rawRlp.offset
        }
        return itemLength(rawRlpOffset);
    }

    function beginIteration(uint256 offset)
        internal
        pure
        returns (uint256 iter)
    {
        return offset + _payloadOffset(offset);
    }

    function next(uint256 iter) internal pure returns (uint256 nextIter) {
        return iter + itemLength(iter);
    }

    function payloadLen(uint256 ptr, uint256 len)
        internal
        pure
        returns (uint256)
    {
        return len - _payloadOffset(ptr);
    }

    function toAddress(uint256 ptr) internal pure returns (address) {
        return address(uint160(toUint(ptr, 21)));
    }

    function toBytes32(uint256 ptr) internal pure returns (bytes32) {
        return bytes32(toUint(ptr, 33));
    }

    function toRlpBytes(uint256 ptr) internal pure returns (bytes memory) {
        uint256 length = itemLength(ptr);
        bytes memory result = new bytes(length);
        if (result.length == 0) {
            return result;
        }
        ptr = beginIteration(ptr);
        assembly {
            calldatacopy(add(0x20, result), ptr, length)
        }
        return result;
    }

    function toRlpBytesKeccak256(uint256 ptr) internal pure returns (bytes32) {
        return keccak256(toRlpBytes(ptr));
    }

    function toBytes(uint256 ptr) internal pure returns (bytes memory) {
        uint256 offset = _payloadOffset(ptr);
        uint256 length = itemLength(ptr) - offset;
        bytes memory result = new bytes(length);
        if (result.length == 0) {
            return result;
        }
        ptr = beginIteration(ptr);
        assembly {
            calldatacopy(add(0x20, result), add(ptr, offset), length)
        }
        return result;
    }

    function toUint256(uint256 ptr, uint256 len)
        internal
        pure
        returns (uint256)
    {
        return toUint(ptr, len);
    }

    function uintToRlp(uint256 value)
        internal
        pure
        returns (bytes memory result)
    {
        // zero can be encoded as zero or empty array, go-ethereum's encodes as empty array
        if (value == 0) {
            result = new bytes(1);
            result[0] = 0x80;
            return result;
        }
        // encode value
        if (value <= 0x7f) {
            result = new bytes(1);
            result[0] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 8)) {
            result = new bytes(2);
            result[0] = 0x81;
            result[1] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 16)) {
            result = new bytes(3);
            result[0] = 0x82;
            result[1] = bytes1(uint8(value >> 8));
            result[2] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 24)) {
            result = new bytes(4);
            result[0] = 0x83;
            result[1] = bytes1(uint8(value >> 16));
            result[2] = bytes1(uint8(value >> 8));
            result[3] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 32)) {
            result = new bytes(5);
            result[0] = 0x84;
            result[1] = bytes1(uint8(value >> 24));
            result[2] = bytes1(uint8(value >> 16));
            result[3] = bytes1(uint8(value >> 8));
            result[4] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 40)) {
            result = new bytes(6);
            result[0] = 0x85;
            result[1] = bytes1(uint8(value >> 32));
            result[2] = bytes1(uint8(value >> 24));
            result[3] = bytes1(uint8(value >> 16));
            result[4] = bytes1(uint8(value >> 8));
            result[5] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 48)) {
            result = new bytes(7);
            result[0] = 0x86;
            result[1] = bytes1(uint8(value >> 40));
            result[2] = bytes1(uint8(value >> 32));
            result[3] = bytes1(uint8(value >> 24));
            result[4] = bytes1(uint8(value >> 16));
            result[5] = bytes1(uint8(value >> 8));
            result[6] = bytes1(uint8(value));
            return result;
        } else if (value < (1 << 56)) {
            result = new bytes(8);
            result[0] = 0x87;
            result[1] = bytes1(uint8(value >> 48));
            result[2] = bytes1(uint8(value >> 40));
            result[3] = bytes1(uint8(value >> 32));
            result[4] = bytes1(uint8(value >> 24));
            result[5] = bytes1(uint8(value >> 16));
            result[6] = bytes1(uint8(value >> 8));
            result[7] = bytes1(uint8(value));
            return result;
        } else {
            result = new bytes(9);
            result[0] = 0x88;
            result[1] = bytes1(uint8(value >> 56));
            result[2] = bytes1(uint8(value >> 48));
            result[3] = bytes1(uint8(value >> 40));
            result[4] = bytes1(uint8(value >> 32));
            result[5] = bytes1(uint8(value >> 24));
            result[6] = bytes1(uint8(value >> 16));
            result[7] = bytes1(uint8(value >> 8));
            result[8] = bytes1(uint8(value));
            return result;
        }
    }

    function uintRlpPrefixLength(uint256 value)
        internal
        pure
        returns (uint256 len)
    {
        if (value < (1 << 8)) {
            return 1;
        } else if (value < (1 << 16)) {
            return 2;
        } else if (value < (1 << 24)) {
            return 3;
        } else if (value < (1 << 32)) {
            return 4;
        } else if (value < (1 << 40)) {
            return 5;
        } else if (value < (1 << 48)) {
            return 6;
        } else if (value < (1 << 56)) {
            return 7;
        } else {
            return 8;
        }
    }

    function toUint(uint256 ptr, uint256 len) internal pure returns (uint256) {
        require(len > 0 && len <= 33, "RLP out of len");
        uint256 offset = _payloadOffset(ptr);
        uint256 result;
        assembly {
            result := calldataload(add(ptr, offset))
            // cut off redundant bytes
            result := shr(mul(8, sub(32, sub(len, offset))), result)
        }
        return result;
    }

    function toUintStrict(uint256 ptr) internal pure returns (uint256) {
        // one byte prefix
        uint256 result;
        assembly {
            result := calldataload(add(ptr, 1))
        }
        return result;
    }

    function rawDataPtr(uint256 ptr) internal pure returns (uint256) {
        return ptr + _payloadOffset(ptr);
    }

    // @return entire rlp item byte length
    function itemLength(uint ptr) internal pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, calldataload(ptr))
        }

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                ptr := add(ptr, 1) // skip over the first byte
                let dataLen := shr(mul(8, sub(32, byteLen)), calldataload(ptr))
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                ptr := add(ptr, 1)

                let dataLen := shr(mul(8, sub(32, byteLen)), calldataload(ptr))
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    function prefixLength(uint256 ptr) internal pure returns (uint256) {
        return _payloadOffset(ptr);
    }

    function estimatePrefixLength(uint256 length)
        internal
        pure
        returns (uint256)
    {
        if (length == 0) return 1;
        if (length == 1) return 1;
        if (length < 0x38) {
            return 1;
        }
        return 0;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint256 ptr) private pure returns (uint256) {
        uint256 byte0;
        assembly {
            byte0 := byte(0, calldataload(ptr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (
            byte0 < STRING_LONG_START ||
            (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)
        ) return 1;
        else if (byte0 < LIST_SHORT_START)
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
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