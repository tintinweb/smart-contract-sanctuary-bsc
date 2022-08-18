// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./RLPReader.sol";
import "./interface/IEthash.sol";

contract ETHBlockUpdater is Ownable {
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;

    event BlockRecorded(uint256 blockNumber);

    struct BlockHeaderFull {
        bytes32 parentHash;     // 0
        bytes32 uncleHash;      // 1
        //bytes32 coinbase;     // 2
        //bytes32 stateRoot;    // 3
        //bytes32 txRoot;       // 4
        //bytes32 receiptRoot;  // 5
        //bytes bloom;          // 6
        uint difficulty;        // 7
        uint blockNumber;       // 8
        uint64 gasLimit;        // 9
        uint64 gasUsed;         // 10
        uint time;              // 11
        bytes extra;            // 12
        bytes32 mixDigest;      // 13
        uint nonce;             // 14
        //uint64 baseFeePerGas; //15
    }

    struct BlockHeader {
        bytes32 uncleHash;
        uint difficulty;
        uint blockNumber;
        uint time;
        uint confirmTime;
    }

    mapping(bytes32 => BlockHeader) public blocks;

    bytes32 public genesisBlockHash;
    uint genesisBlockNumber;
    uint highestBlockNumber;
    // TODO 后面改成15个区块的时间，大概4分钟
    uint blockLockTime = 0 minutes;

    IEthash ethash;


    //--------------------------verify header param ---------------------------//
    int big1 = 1;
    int big2 = 2;
    int big9 = 9;
    int bigMinus99 = - 99;
    int DifficultyBoundDivisor = 2048;
    int MinimumDifficulty = 131072;
    uint MaxBig256 = 2 ** 256 - 1;
    uint maxGasLimit = 2 ** 63 - 1;
    uint bombDelay = 11400000; //GrayGlacier
    uint bombDelayFromParent = bombDelay - uint(big1);
    uint expDiffPeriod = 100000;
    bytes32 EmptyUncleHash = 0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347;

    constructor(address ethashAddress) {
        ethash = IEthash(ethashAddress);
    }

    function submitBlock(
        bytes32 blockHash,
        bytes memory rlpHeader,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[7] memory input) external {

        // Verify BlockHash with RLP encoded data
        require(blockHash == keccak256(rlpHeader));

        BlockHeaderFull memory headerFull;
        bytes32 hashNoNonce;
        (headerFull, hashNoNonce) = parseBlockHeader(rlpHeader);
        if (genesisBlockNumber == 0) {
            setGenesisBlock(blockHash, headerFull);
            return;
        }

        assert(verifyHeader(blockHash, headerFull, true, hashNoNonce, a, b, c, input));

        uint confirmTime = headerFull.time + blockLockTime;

        BlockHeader memory header = BlockHeader(headerFull.uncleHash, headerFull.difficulty, headerFull.blockNumber, headerFull.time, confirmTime);
        // Set highestBlockNumber
        blocks[blockHash] = header;
        if (highestBlockNumber < header.blockNumber) {
            highestBlockNumber = header.blockNumber;
        }
        emit BlockRecorded(header.blockNumber);
    }

    function getGenesisBlockNumber() external view returns (uint) {
        return genesisBlockNumber;
    }

    function getHighestBlockNumber() external view returns (uint) {
        return highestBlockNumber;
    }

    function getBombDelay() external view returns (uint) {
        return bombDelay;
    }

    function checkBlockHash(bytes32 blockHash, bytes32[] calldata merkleProof) external view returns (bool) {
        //merkleProof compatible bsc block update
        return blocks[blockHash].blockNumber != 0 && blocks[blockHash].confirmTime < block.timestamp;
    }

    function setBombDelay(uint newBombDelay) external onlyOwner {
        bombDelay = newBombDelay;
    }

    function setGenesisBlock(bytes32 blockHash, BlockHeaderFull memory headerFull) internal {
        BlockHeader memory header = BlockHeader(headerFull.uncleHash, headerFull.difficulty, headerFull.blockNumber, headerFull.time, headerFull.time);
        blocks[blockHash] = header;
        genesisBlockHash = blockHash;
        genesisBlockNumber = header.blockNumber;
        highestBlockNumber = genesisBlockNumber;
    }

    function parseBlockHeader(bytes memory rlpHeader) internal pure returns (BlockHeaderFull memory, bytes32) {
        RLPReader.RLPItem[] memory ls = rlpHeader.toRlpItem().toList();

        BlockHeaderFull memory header;
        header.parentHash = ls[0].toBytes32();
        header.uncleHash = ls[1].toBytes32();
        //header.coinbase = ls[2].toBytes32();
        //header.stateRoot = ls[3].toBytes32();
        //header.txRoot = ls[4].toBytes32();
        //header.receiptRoot = ls[5].toBytes32();
        //header.bloom = ls[6].toBytes();
        header.difficulty = ls[7].toUint();
        header.blockNumber = ls[8].toUint();
        header.gasLimit = uint64(ls[9].toUint());
        header.gasUsed = uint64(ls[10].toUint());
        header.time = ls[11].toUint();
        header.extra = ls[12].toBytes();
        header.mixDigest = ls[13].toBytes32();
        header.nonce = ls[14].toUint();
        //header.baseFeePerGas = ls[15].toUint();
        bytes32 hashNoNonce = getHashNoNonce(rlpHeader);
        return (header, hashNoNonce);
    }

    function getHashNoNonce(bytes memory rlpHeader) internal pure returns (bytes32) {
        // 48: length of none+mixHash+baseGas  6:length of baseGas
        bytes memory rlpWithoutNonce = copy(rlpHeader, rlpHeader.length - 48, 6);
        // rlpHeaderLength - 3 prefix bytes (0xf9 + length) - length of nonce and mixHash
        uint16 rlpHeaderWithoutNonceLength = uint16(rlpHeader.length - 3 - 42);
        bytes2 headerLengthBytes = bytes2(rlpHeaderWithoutNonceLength);
        rlpWithoutNonce[1] = headerLengthBytes[0];
        rlpWithoutNonce[2] = headerLengthBytes[1];
        bytes32 rlpHeaderHashWithoutNonce = keccak256(rlpWithoutNonce);
        return rlpHeaderHashWithoutNonce;
    }

    function copy(bytes memory sourceArray, uint newLength, uint appendLength) internal pure returns (bytes memory) {
        uint newArraySize = newLength + appendLength;
        if (newArraySize > sourceArray.length) {
            newArraySize = sourceArray.length;
        }

        bytes memory newArray = new bytes(newArraySize);
        uint256 sourceArrayIndex = 0;
        for (uint i = 0; i < newArraySize; i++) {
            newArray[i] = sourceArray[sourceArrayIndex];
            sourceArrayIndex++;
            if (i == newLength - 1) {
                sourceArrayIndex = sourceArray.length - appendLength;
            }
        }
        return newArray;
    }

    function verifyHeader(bytes32 blockHash, BlockHeaderFull
    memory header,
        bool seal,
        bytes32 hashNoNonce,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[7] memory input) internal view returns (bool) {
        //Verify basic features of block header.
        if (blocks[blockHash].time != 0) {
            revert();
        }
        BlockHeader memory parent = blocks[header.parentHash];
        if (parent.time == 0) {
            revert("consensus.ErrUnknownAncestor");
        }

        return verifyHeaderDetails(header, parent, false, seal, hashNoNonce, a, b, c, input);
    }

    function verifyHeaderDetails(BlockHeaderFull memory header,
        BlockHeader memory parent,
        bool uncle,
        bool seal,
        bytes32 hashNoNonce,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[7] memory input) internal view returns (bool) {

        if (header.extra.length > 32) {
            revert("extra-data too long");
        }

        // Verify the header's timestamp
        if (uncle) {
            if (header.time > MaxBig256) {
                revert("errLargeBlockTime");
            }
        } else {
            // Skip consensus.ErrFutureBlock test
            // because relayer can upload past block header.
        }

        if (header.time <= parent.time) {
            revert("errZeroBlockTime");
        }

        // Verify the block's difficulty based in it's timestamp and parent's difficulty
        int expected = CalcDifficulty(header.time, parent);
        if (expected != int(header.difficulty)) {
            revert("invalid difficulty");
        }

        if (header.gasLimit > maxGasLimit) {
            revert("invalid gasLimit");
        }

        if (header.gasUsed > header.gasLimit) {
            revert("invalid gasUsed");
        }

        // Verify that the block number is parent's +1
        int diff = int(header.blockNumber - parent.blockNumber);
        if (diff != 1) {
            revert("consensus.ErrInvalidNumber");
        }

        if (seal) {
            if (!VerifySeal(header, hashNoNonce, a, b, c, input)) {
                revert();
            }
        }

        return true;
    }

    function CalcDifficulty(
        uint time,
        BlockHeader memory parent
    ) internal view returns (int) {
        // calc Difficulty GrayGlacier
        int bigTime = int(time);
        int bigParentTime = int(parent.time);


        int x = bigTime - bigParentTime;
        x = x / big9;

        if (parent.uncleHash == EmptyUncleHash) {
            x = big1 - x;
        }
        else {
            x = big2 - x;
        }

        if (x < bigMinus99) {
            x = bigMinus99;
        }

        int y = int(parent.difficulty) / DifficultyBoundDivisor;
        x = y * x;
        x = int(parent.difficulty) + x;

        if (x < MinimumDifficulty) {
            x = MinimumDifficulty;
        }

        uint fakeBlockNumber;
        if (parent.blockNumber >= bombDelayFromParent) {
            fakeBlockNumber = parent.blockNumber - bombDelayFromParent;
        }

        uint periodCount = fakeBlockNumber;
        periodCount = periodCount / expDiffPeriod;

        if (periodCount > uint(big1)) {
            uint t = periodCount - uint(big2);
            y = int(2 ** t);
            x = x + y;
        }

        return x;
    }

    function VerifySeal(BlockHeaderFull memory header,
        bytes32 hashNoNonce,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[7] memory input) internal view returns (bool) {
        // Ensure that we have a valid difficulty for the block
        if (header.difficulty <= 0) {
            revert("errInvalidDifficulty");
        }

        (uint returnCode,) = ethash.verifyPoW(header.blockNumber, hashNoNonce,
            header.nonce, header.difficulty, a, b, c, input);
        if (returnCode == 1) {
            revert("epoch data not set");
        }
        else if (returnCode == 2) {
            revert("circuit input not match");
        }
        else if (returnCode == 3) {
            revert("circuit verification failed");
        }
        return true;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: Apache-2.0

/*
* @author Hamdi Allam [email protected]
*         Changes: Markus Levonyak
* Please reach out with any questions or concerns
*/
pragma solidity >=0.5.0 <0.9.0;

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
        RLPItem item;   // Item that's being iterated over.
        uint nextPtr;   // Position of the next item in the list.
    }

    /*
    * @dev Returns the next element in the iteration. Reverts if it has not next element.
    * @param self The iterator.
    * @return The next element in the iteration.
    */
    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self));

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
    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {
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
    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {
        require(isList(self));

        uint ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    /*
    * @param item RLP encoded bytes
    */
    function rlpLen(RLPItem memory item) internal pure returns (uint) {
        return item.len;
    }

    /*
    * @param item RLP encoded bytes
    */
    function payloadLen(RLPItem memory item) internal pure returns (uint) {
        return item.len - _payloadOffset(item.memPtr);
    }

    /*
    * @param item RLP encoded list in bytes
    */
    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {
        require(isList(item));

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

        if (byte0 < LIST_SHORT_START)
            return false;
        return true;
    }

    /** RLPItem conversions into data types **/

    // @returns raw rlp encoding in bytes
    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {
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
        require(item.len == 1);
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
        require(item.len == 21);

        return address(uint160(toUint(item)));
    }

    function toUint(RLPItem memory item) internal pure returns (uint) {
        require(item.len > 0 && item.len <= 33);

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset;

        uint result;
        uint memPtr = item.memPtr + offset;
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
        require(item.len == 33);

        uint result;
        uint memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0);

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset;
        // data length
        bytes memory result = new bytes(len);

        uint destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
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
            currPtr = currPtr + _itemLength(currPtr);
            // skip over an item
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

        if (byte0 < STRING_SHORT_START)
            itemLen = 1;

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
        }

        else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        }

        else {
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

        if (byte0 < STRING_SHORT_START)
            return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START))
            return 1;
        else if (byte0 < LIST_SHORT_START)  // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else
            return byte0 - (LIST_LONG_START - 1) + 1;
    }

    /*
    * @param src Pointer to source
    * @param dest Pointer to destination
    * @param len Amount of memory to copy from the source
    */
    function copy(uint src, uint dest, uint len) private pure {
        if (len == 0) return;

        // copy as many word sizes as possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        // left over bytes. Mask is used to remove unwanted bytes from the word
        uint mask = 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }

    function toBytes32(RLPItem memory self) internal pure returns (bytes32 data) {
        return bytes32(toUint(self));
    }

}

pragma solidity ^0.8.14;

interface IEthash {
    function verifyPoW(uint blockNumber,
        bytes32 rlpHeaderHashWithoutNonce,
        uint nonce,
        uint difficulty,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[7] memory input) external view returns (uint, uint);
}

// SPDX-License-Identifier: MIT
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