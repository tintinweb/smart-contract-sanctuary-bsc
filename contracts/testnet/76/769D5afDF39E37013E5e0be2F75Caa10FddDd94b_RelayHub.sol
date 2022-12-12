// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

import "./BaseRelayHub.sol";

// RelayHub need to update only when validators set change
contract RelayHub is BaseRelayHub {
    using EnumerableSet for EnumerableSet.AddressSet;
    using BitMaps for BitMaps.BitMap;

    struct ValidatorSet {
        EnumerableSet.AddressSet allValidators;
        mapping(uint256 => BitMaps.BitMap) activeValidators;
        mapping(uint256 => uint256) validatorCount;
        uint256[] updatedEpochs;
    }

    // chainid to validatorset
    mapping(uint256 => ValidatorSet) _validatorSet;

    constructor(
        IProofVerificationFunction defaultVerificationFunction
    ) BaseRelayHub(defaultVerificationFunction) {}

    function getLatestEpochNumber(
        uint256 chainId
    ) public view override returns (uint256) {
        uint256 len = _validatorSet[chainId].updatedEpochs.length;
        if (len > 0) {
            return _validatorSet[chainId].updatedEpochs[len - 1];
        } else {
            return 0;
        }
    }

    function getLatestValidatorSet(
        uint256 chainId
    ) external view override returns (address[] memory) {
        return _getValidatorSetOfEpoch(chainId, getLatestEpochNumber(chainId));
    }

    function getValidatorSetForEpoch(
        uint256 chainId,
        uint256 epochNumber
    ) external view returns (address[] memory) {
        (uint256 validatorEpoch, ) = _getEpochNumber(
            epochNumber,
            _validatorSet[chainId].updatedEpochs
        );

        return _getValidatorSetOfEpoch(chainId, validatorEpoch);
    }

    function _getValidatorSetOfEpoch(
        uint256 chainId,
        uint256 epochNumber
    ) internal view returns (address[] memory) {
        ValidatorSet storage validatorSet = _validatorSet[chainId];
        uint256 validatorCount = validatorSet.validatorCount[epochNumber];
        address[] memory activeValidators = new address[](validatorCount);

        BitMaps.BitMap storage currentBitmap = validatorSet.activeValidators[
            epochNumber
        ];
        uint256 validatorIndex;
        for (uint256 i = 0; i < validatorSet.allValidators.length(); i++) {
            if (currentBitmap.get(i)) {
                address validator = validatorSet.allValidators.at(i);
                activeValidators[validatorIndex] = validator;
                ++validatorIndex;
                if (validatorIndex == validatorCount) {
                    break;
                }
            }
        }
        return activeValidators;
    }

    // BECAREFUL when using this function,
    // using this function may take A LOT OF GAS and lead to some unexpected SIDE EFFECTS,
    // not recommend for mainnet
    function resetChain(uint256 chainId) public override onlyOperator {
        ValidatorSet storage validatorSet = _validatorSet[chainId];

        // remove all map data
        {
            uint256 bucketNumber = (validatorSet.allValidators.length() >> 8) +
                1;
            for (uint256 i = 0; i < validatorSet.updatedEpochs.length; i++) {
                uint256 epoch = validatorSet.updatedEpochs[i];
                // reset validatorCount
                delete validatorSet.validatorCount[epoch];
                // reset all buckets
                for (uint256 bucket = 0; bucket < bucketNumber; bucket++) {
                    delete validatorSet.activeValidators[epoch]._data[bucket];
                }
            }
        }

        // remove all validator
        address[] memory validators = validatorSet.allValidators.values();
        for (uint256 i = 0; i < validators.length; i++) {
            // add validator to the set of all validators
            address validator = validators[i];
            validatorSet.allValidators.remove(validator);
        }

        // remove other data of validator set
        delete _validatorSet[chainId];
        super.resetChain(chainId);
    }

    function _updateActiveValidatorSet(
        uint256 chainId,
        address[] memory newValidatorSet,
        uint256 newEpochNumber
    ) internal override {
        ValidatorSet storage validatorSet = _validatorSet[chainId];
        {
            if (validatorSet.updatedEpochs.length > 0) {
                uint256 lastestUpdatedEpoch = validatorSet.updatedEpochs[
                    validatorSet.updatedEpochs.length - 1
                ];
                require(
                    newEpochNumber > lastestUpdatedEpoch,
                    "bad epoch transition"
                );
            }
        }
        require(newValidatorSet.length > 0, "bad validators set");

        {
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
            BitMaps.BitMap storage currentBitmap = validatorSet
                .activeValidators[newEpochNumber];
            for (uint256 i = 0; i < buckets.length; i++) {
                currentBitmap._data[i] = buckets[i];
            }
        }
        // remember total amount of validators and latest verified epoch
        validatorSet.validatorCount[newEpochNumber] = uint64(
            newValidatorSet.length
        );
        validatorSet.updatedEpochs.push(newEpochNumber);
    }

    function checkEpochBlock(
        uint256 chainId,
        address[] memory checkValidators,
        uint256 blockStart
    ) public view override returns (bool) {
        ValidatorSet storage validatorSet = _validatorSet[chainId];
        uint256 uniqueValidators;
        uint256 epochNumber;
        {
            uint256 epochLength = _registeredChains[chainId].epochLength;
            require(blockStart % epochLength == 0, "not epoch block");

            uint256 epochIndex;
            (epochNumber, epochIndex) = _getEpochNumber(
                blockStart / epochLength - 1,
                validatorSet.updatedEpochs
            );
            // epochIndex = 0 is for no match index
            require(
                epochIndex > 0,
                "checkEpochBlock: unsupported epoch number"
            );
        }

        uint256 totalValidators = validatorSet.validatorCount[epochNumber];
        uint256[] memory markedValidators = new uint256[](
            (totalValidators + 0xff) >> 8
        );

        // Validators set changes take place at the (epoch+N/2) blocks, reference from https://docs.bnbchain.org/docs/learn/consensus#light-client-security
        for (uint256 i = 0; i < totalValidators / 2; i++) {
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
        (uint256 epochNumber, uint256 epochIndex) = _getEpochNumber(
            blockStart / epochLength,
            validatorSet.updatedEpochs
        );
        require(
            epochIndex > 0,
            "checkValidatorsAndQuorumReached: unsupported epoch number"
        );
        // minus index by 1 because _getEpochNumber return (index+1) (0 for no index match)
        --epochIndex;

        // Validators set changes take place at the (epoch+N/2) blocks, reference from https://docs.bnbchain.org/docs/learn/consensus#light-client-security
        if (
            blockStart / epochLength == epochNumber &&
            epochIndex > 0 &&
            blockStart % epochLength <
            validatorSet.validatorCount[
                validatorSet.updatedEpochs[epochIndex - 1] / 2
            ]
        ) {
            --epochIndex;
            epochNumber = validatorSet.updatedEpochs[epochIndex];
        }
        uint256 uniqueValidators = 0;
        uint256 totalValidators = validatorSet.validatorCount[epochNumber];
        uint256[] memory markedValidators = new uint256[](
            (totalValidators + 0xff) >> 8
        );
        for (uint256 i = 0; i < checkValidators.length; i++) {
            // Validators set changes take place at the (epoch+N/2) blocks, reference from https://docs.bnbchain.org/docs/learn/consensus#light-client-security
            if (
                (blockStart + i) % epochLength ==
                validatorSet.validatorCount[epochNumber] / 2 &&
                epochIndex < validatorSet.updatedEpochs.length - 1 &&
                (blockStart + i) / epochLength >
                validatorSet.updatedEpochs[epochIndex + 1]
            ) {
                ++epochIndex;
                epochNumber = validatorSet.updatedEpochs[epochIndex];
            }

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

    // return (epochNumber, epochIndex), epochIndex != 0 is for (index+1) (0 for no index match)
    function _getEpochNumber(
        uint256 epochCheck,
        uint256[] storage updatedEpochs
    ) internal view returns (uint256, uint256) {
        for (uint256 i = updatedEpochs.length - 1; i >= 0; ) {
            if (epochCheck >= updatedEpochs[i]) {
                return (updatedEpochs[i], i + 1);
            }
            if (i > 0) --i;
            else break;
        }
        return (0, 0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../common/Types.sol";

import "../interfaces/IRelayHub.sol";
import "../interfaces/IProofVerificationFunction.sol";
import "../interfaces/IValidatorChecker.sol";

abstract contract BaseRelayHub is IRelayHub, IValidatorChecker {
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

    // default
    bytes32 internal constant ZERO_BLOCK_HASH = bytes32(0x00);
    address internal constant ZERO_ADDRESS = address(0x00);

    IProofVerificationFunction internal constant DEFAULT_VERIFICATION_FUNCTION =
        IProofVerificationFunction(ZERO_ADDRESS);

    IProofVerificationFunction internal _defaultVerificationFunction;

    // variable
    address _owner;
    mapping(address => bool) internal _operators;

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

    function setOperator(
        address operator_,
        bool status_
    ) external onlyOperator {
        _operators[operator_] = status_;
    }

    function getBridgeAddress(
        uint256 chainId
    ) external view override returns (address) {
        return _registeredChains[chainId].bridgeAddress;
    }

    function enableCrossChainBridge(
        uint256 chainId,
        address bridgeAddress
    ) external virtual override onlyOperator {
        _registeredChains[chainId].bridgeAddress = bridgeAddress;
        _registeredChains[chainId].chainStatus = ChainStatus.Active;
    }

    function registerBridge(
        uint256 chainId,
        IProofVerificationFunction verificationFunction,
        bytes calldata rawRegisterBlock,
        address bridgeAddress,
        uint32 epochLength
    )
        public
        virtual
        onlyOperator
        returns (
            Types.BlockHeader memory blockHeader,
            address[] memory initialValidatorSet
        )
    {
        ChainData memory chainData = _registeredChains[chainId];
        require(
            chainData.chainStatus == ChainStatus.NotFound ||
                chainData.chainStatus == ChainStatus.Verifying,
            "already registered"
        );
        (blockHeader, initialValidatorSet) = _verificationFunction(
            verificationFunction
        ).verifyBlockWithoutQuorum(chainId, rawRegisterBlock, epochLength);
        require(blockHeader.blockNumber % epochLength == 0, "not epoch block");

        chainData.chainStatus = ChainStatus.Verifying;
        chainData.verificationFunction = verificationFunction;
        chainData.bridgeAddress = bridgeAddress;
        chainData.epochLength = epochLength;

        _updateActiveValidatorSet(
            chainId,
            initialValidatorSet,
            blockHeader.blockNumber / epochLength
        );
        chainData.chainStatus = ChainStatus.Active;
        _registeredChains[chainId] = chainData;
        emit BridgeRegistered(chainId, bridgeAddress);
    }

    function unregisterBridge(uint256 chainId) public virtual onlyOperator {
        delete _registeredChains[chainId];
        emit BridgeUnregistered(chainId);
    }

    // becareful when using this function, this may lead to some unexpected side effects, not recommend for mainnet
    function resetChain(uint256 chainId) public virtual onlyOperator {
        delete _registeredChains[chainId];
        emit ChainReseted(chainId);
    }

    function updateValidatorSetUsingEpochBlocks(
        uint256 chainId,
        bytes[] calldata blockProofs
    ) external virtual {
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

        _updateActiveValidatorSet(
            chainId,
            newValidatorSet,
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
        uint256 chainId,
        address[] memory newValidatorSet,
        uint256 newEpochNumber
    ) internal virtual {}

    function checkReceiptProof(
        uint256 chainId,
        bytes[] calldata blockProofs,
        bytes calldata rawReceipt,
        bytes calldata proofSiblings,
        bytes calldata proofPath
    ) external view virtual returns (bool) {
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
    ) internal view virtual returns (IProofVerificationFunction) {
        if (verificationFunction == DEFAULT_VERIFICATION_FUNCTION) {
            return _defaultVerificationFunction;
        } else {
            return verificationFunction;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRelayHub {
    function getLatestEpochNumber(
        uint256 chainId
    ) external view returns (uint256);

    function getLatestValidatorSet(
        uint256 chainId
    ) external view returns (address[] memory);

    function getBridgeAddress(uint256 chainId) external view returns (address);

    function enableCrossChainBridge(
        uint256 chainId,
        address bridgeAddress
    ) external;

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