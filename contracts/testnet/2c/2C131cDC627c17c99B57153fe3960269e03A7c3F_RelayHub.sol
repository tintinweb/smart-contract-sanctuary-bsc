// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./common/Types.sol";

import "./interfaces/IRelayHub.sol";
import "./interfaces/ICrossChainBridge.sol";
import "./interfaces/IProofVerificationFunction.sol";
import "./interfaces/IValidatorChecker.sol";

import "./libraries/RLPReader.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

contract RelayHub is IRelayHub, IValidatorChecker {
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;
    using EnumerableSet for EnumerableSet.AddressSet;
    using BitMaps for BitMaps.BitMap;

    enum ChainStatus {
        NotFound,
        Verifying,
        Active
    }
    struct ChainData {
        ChainStatus chainStatus;
        IProofVerificationFunction verificationFunction;
        address bridgeAddress;
        uint32 epochLength;
    }

    struct ValidatorSet {
        // address[] validatorSet;
        // address[] preValidatorSet;
        EnumerableSet.AddressSet allValidators;
        mapping(uint256 => BitMaps.BitMap) activeValidators;
        mapping(uint256 => uint256) validatorCount;
        uint256 registeredEpoch;
        uint256 latestEpochNumber;
    }

    // default
    bytes32 internal constant ZERO_BLOCK_HASH = bytes32(0x00);
    address internal constant ZERO_ADDRESS = address(0x00);

    IProofVerificationFunction internal constant DEFAULT_VERIFICATION_FUNCTION =
        IProofVerificationFunction(ZERO_ADDRESS);

    IProofVerificationFunction internal _defaultVerificationFunction;

    // variable
    address _owner;
    mapping(address => bool) internal _operators;

    // chainid to validatorset
    mapping(uint256 => ValidatorSet) _validatorSet;

    // chainid to chaindata
    mapping(uint256 => ChainData) internal _registeredChains;

    // event
    event BridgeRegistered(
        uint256 indexed chainId,
        address indexed bridgeAddress
    );

    event BridgeUnregistered(uint256 indexed chainId);
    event ChainReseted(uint256 indexed chainId);

    event ValidatorSetUpdated(uint256 indexed chainId, address[] validatorSet);

    constructor(IProofVerificationFunction defaultVerificationFunction) {
        _owner = msg.sender;
        _operators[msg.sender] = true;

        _defaultVerificationFunction = defaultVerificationFunction;
    }

    modifier onlyOperator() {
        require(
            _operators[msg.sender] || (msg.sender == _owner),
            "RelayHub Only Operator"
        );
        _;
    }

    function setOperator(address operator_, bool status_)
        external
        onlyOperator
    {
        _operators[operator_] = status_;
    }

    function getLatestEpochNumber(uint256 chainId)
        external
        view
        returns (uint256)
    {
        return _validatorSet[chainId].latestEpochNumber;
    }

    function getBridgeAddress(uint256 chainId)
        external
        view
        override
        returns (address)
    {
        return _registeredChains[chainId].bridgeAddress;
    }

    function enableCrossChainBridge(uint256 chainId, address bridgeAddress)
        external
        override
        onlyOperator
    {
        _registeredChains[chainId].bridgeAddress = bridgeAddress;
        _registeredChains[chainId].chainStatus = ChainStatus.Active;
    }

    function registerBridge(
        uint256 chainId,
        IProofVerificationFunction verificationFunction,
        bytes calldata rawRegisterBlock,
        address bridgeAddress,
        uint32 epochLength
    ) external onlyOperator {
        ChainData memory chainData = _registeredChains[chainId];
        require(
            chainData.chainStatus == ChainStatus.NotFound ||
                chainData.chainStatus == ChainStatus.Verifying,
            "already registered"
        );
        (
            Types.BlockHeader memory blockHeader,
            address[] memory initialValidatorSet
        ) = _verificationFunction(verificationFunction)
                .verifyBlockWithoutQuorum(
                    chainId,
                    rawRegisterBlock,
                    epochLength
                );
        require(blockHeader.blockNumber % epochLength == 0, "not epoch block");

        chainData.chainStatus = ChainStatus.Verifying;
        chainData.verificationFunction = verificationFunction;
        chainData.bridgeAddress = bridgeAddress;
        chainData.epochLength = epochLength;

        ValidatorSet storage validatorSet = _validatorSet[chainId];
        _updateActiveValidatorSet(
            initialValidatorSet,
            validatorSet,
            blockHeader.blockNumber / epochLength
        );
        validatorSet.registeredEpoch = blockHeader.blockNumber / epochLength;
        chainData.chainStatus = ChainStatus.Active;
        _registeredChains[chainId] = chainData;
        emit BridgeRegistered(chainId, bridgeAddress);
    }

    function unregisterBridge(uint256 chainId) external onlyOperator {
        delete _registeredChains[chainId];
        emit BridgeUnregistered(chainId);
    }

    function resetChain(uint256 chainId) external onlyOperator {
        delete _registeredChains[chainId];
        delete _validatorSet[chainId];
        emit ChainReseted(chainId);
    }

    function updateValidatorSetUsingEpochBlocks(
        uint256 chainId,
        bytes[] calldata blockProofs
    ) external {
        ChainData memory chainData = _registeredChains[chainId];
        require(
            chainData.chainStatus == ChainStatus.Verifying ||
                chainData.chainStatus == ChainStatus.Active,
            "not registered"
        );
        IProofVerificationFunction pvf = _verificationFunction(
            chainData.verificationFunction
        );

        (
            Types.BlockHeader memory epochBlockHeader,
            address[] memory newValidatorSet
        ) = pvf.verifyBlockWithoutQuorum(
                chainId,
                blockProofs[0],
                chainData.epochLength
            );

        require(
            _verificationFunction(chainData.verificationFunction)
                .verifyEpochBlock(
                    chainId,
                    blockProofs,
                    chainData.epochLength,
                    this
                ),
            "invalid epoch block proofs"
        );

        require(
            epochBlockHeader.blockNumber % chainData.epochLength == 0,
            "not epoch block"
        );

        ValidatorSet storage validatorSet = _validatorSet[chainId];
        _updateActiveValidatorSet(
            newValidatorSet,
            validatorSet,
            epochBlockHeader.blockNumber / chainData.epochLength
        );

        _verificationFunction(chainData.verificationFunction)
            .verifyBlockAndReachedQuorum(
                chainId,
                blockProofs,
                chainData.epochLength,
                this
            );
        chainData.chainStatus = ChainStatus.Active;
        _registeredChains[chainId] = chainData;
        emit ValidatorSetUpdated(chainId, newValidatorSet);
    }

    function _updateActiveValidatorSet(
        address[] memory newValidatorSet,
        ValidatorSet storage validatorSet,
        uint256 newEpochNumber
    ) internal {
        if (validatorSet.latestEpochNumber > 0)
            require(
                newEpochNumber == validatorSet.latestEpochNumber + 1,
                "bad epoch transition"
            );
        require(newValidatorSet.length > 0, "bad validators set");

        uint256[] memory buckets = new uint256[](
            (validatorSet.allValidators.length() >> 8) + 1
        );
        // build set of buckets with new bits
        for (uint256 i = 0; i < newValidatorSet.length; i++) {
            // add validator to the set of all validators
            address validator = newValidatorSet[i];
            validatorSet.allValidators.add(validator);
            // get index of the validator in the set (-1 because 0 is not used)
            uint256 index = validatorSet.allValidators._inner._indexes[
                bytes32(uint256(uint160(validator)))
            ] - 1;
            buckets[index >> 8] |= 1 << (index & 0xff);
        }
        // copy buckets (its cheaper to keep buckets in memory)
        BitMaps.BitMap storage currentBitmap = validatorSet.activeValidators[
            newEpochNumber
        ];
        for (uint256 i = 0; i < buckets.length; i++) {
            currentBitmap._data[i] = buckets[i];
        }
        // remember total amount of validators and latest verified epoch
        validatorSet.validatorCount[newEpochNumber] = uint64(
            newValidatorSet.length
        );
        validatorSet.latestEpochNumber = newEpochNumber;
    }

    function checkEpochBlock(
        uint256 chainId,
        address[] memory checkValidators,
        uint256 blockStart
    ) public view override returns (bool) {
        uint256 epochLength = _registeredChains[chainId].epochLength;
        ValidatorSet storage validatorSet = _validatorSet[chainId];

        require(blockStart % epochLength == 0, "not epoch block");

        uint256 uniqueValidators = 0;
        uint256 epochNumber = blockStart / epochLength - 1;
        uint256 totalValidators = validatorSet.validatorCount[epochNumber];
        uint256[] memory markedValidators = new uint256[](
            (totalValidators + 0xff) >> 8
        );
        for (uint256 i = 0; i < totalValidators / 2; i++) {
            require(
                epochNumber <= validatorSet.latestEpochNumber,
                "bad epoch number"
            );

            // find validator's index and make sure it exists in the validator set
            uint256 index = validatorSet.allValidators._inner._indexes[
                bytes32(uint256(uint160(checkValidators[i])))
            ] - 1;
            if (
                index + 1 == 0 ||
                !validatorSet.activeValidators[epochNumber].get(index)
            ) {
                // its safe to skip because we might have produced block by validators from the next set
                continue;
            }
            // mark used validators to be sure quorum is well-calculated
            uint256 usedMask = 1 << (index & 0xff);
            if (markedValidators[index >> 8] & usedMask == 0) {
                uniqueValidators++;
            }
            markedValidators[index >> 8] |= usedMask;
        }
        return uniqueValidators == totalValidators / 2;
    }

    function checkValidatorsAndQuorumReached(
        uint256 chainId,
        address[] calldata checkValidators,
        uint256 blockStart
    ) external view override returns (bool) {
        uint256 epochLength = _registeredChains[chainId].epochLength;
        ValidatorSet storage validatorSet = _validatorSet[chainId];

        require(
            blockStart / epochLength >= validatorSet.registeredEpoch,
            "bad epoch started"
        );

        uint256 uniqueValidators = 0;
        uint256 epochNumber = blockStart / epochLength;
        uint256 totalValidators = validatorSet.validatorCount[epochNumber];
        uint256[] memory markedValidators = new uint256[](
            (totalValidators + 0xff) >> 8
        );
        for (uint256 i = 0; i < checkValidators.length; i++) {
            epochNumber = (blockStart + i) / epochLength;
            if (
                epochNumber > 1 &&
                (blockStart + i) % epochLength <=
                validatorSet.validatorCount[epochNumber - 1] / 2
            ) {
                epochNumber -= 1;
            }
            require(
                epochNumber <= validatorSet.latestEpochNumber,
                "bad epoch number"
            );

            // find validator's index and make sure it exists in the validator set
            uint256 index = validatorSet.allValidators._inner._indexes[
                bytes32(uint256(uint160(checkValidators[i])))
            ] - 1;
            if (
                index + 1 == 0 ||
                !validatorSet.activeValidators[epochNumber].get(index)
            ) {
                // its safe to skip because we might have produced block by validators from the next set
                continue;
            }
            // mark used validators to be sure quorum is well-calculated
            uint256 usedMask = 1 << (index & 0xff);
            if (markedValidators[index >> 8] & usedMask == 0) {
                uniqueValidators++;
            }
            markedValidators[index >> 8] |= usedMask;
        }
        totalValidators = validatorSet.validatorCount[epochNumber];
        return uniqueValidators >= (totalValidators * 2) / 3;
    }

    function _existsAddress(
        address[] memory addressArray,
        address checkAddress,
        uint256 toIndex
    ) internal pure returns (bool) {
        if (addressArray.length < toIndex) toIndex = addressArray.length;
        for (uint i = 0; i < toIndex; i++) {
            if (addressArray[i] == checkAddress) {
                return true;
            }
        }
        return false;
    }

    function checkReceiptProof(
        uint256 chainId,
        bytes[] calldata blockProofs,
        bytes calldata rawReceipt,
        bytes calldata proofSiblings,
        bytes calldata proofPath
    ) external view returns (bool) {
        // make sure chain is registered and active
        ChainData memory chainData = _registeredChains[chainId];
        require(chainData.chainStatus == ChainStatus.Active, "not active");

        // verify block transition
        // IProofVerificationFunction pvf = _verificationFunction(
        //     chainData.verificationFunction
        // );
        (Types.BlockHeader memory lastBlockHeader, ) = _verificationFunction(
            chainData.verificationFunction
        ).verifyBlockAndReachedQuorum(
                chainId,
                blockProofs,
                chainData.epochLength,
                this
            );
        // check receipt proof
        return
            _verificationFunction(chainData.verificationFunction)
                .checkReceiptProof(
                    rawReceipt,
                    lastBlockHeader.receiptsRoot,
                    proofSiblings,
                    proofPath
                );
    }

    function _verificationFunction(
        IProofVerificationFunction verificationFunction
    ) internal view returns (IProofVerificationFunction) {
        if (verificationFunction == DEFAULT_VERIFICATION_FUNCTION) {
            return _defaultVerificationFunction;
        } else {
            return verificationFunction;
        }
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRelayHub {
    function getBridgeAddress(uint256 chainId) external view returns (address);

    function enableCrossChainBridge(uint256 chainId, address bridgeAddress)
        external;

    function checkReceiptProof(
        uint256 chainId,
        bytes[] calldata blockProofs,
        bytes calldata rawReceipt,
        bytes calldata proofSiblings,
        bytes calldata proofPath
    ) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../common/Types.sol";

interface ICrossChainBridge {
    event DepositToken(
        uint256 fromChain,
        uint256 indexed toChain,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount,
        Types.TokenMetadata
    );

    event WithdrawToken(
        uint256 indexed fromChain,
        address indexed fromAddress,
        address indexed toAddress,
        address fromToken,
        address toToken,
        uint256 totalAmount,
        Types.TokenMetadata
    );

    function depositNative(uint256 toChain, address toAddress) external payable;

    function depositToken(
        address fromToken,
        uint256 toChain,
        address toAddress,
        uint256 totalAmount
    ) external;

    function withdraw(
        bytes[] calldata blockProofs,
        bytes calldata rawReceipt,
        bytes calldata proofPath,
        bytes calldata proofSiblings
    ) external;

    function getTokenImplementation() external view returns (address);
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
// OpenZeppelin Contracts v4.4.1 (utils/structs/BitMaps.sol)
pragma solidity ^0.8.0;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largelly inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}