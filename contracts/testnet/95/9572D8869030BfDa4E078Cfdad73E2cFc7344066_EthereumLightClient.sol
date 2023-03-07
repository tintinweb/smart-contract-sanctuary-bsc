// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

interface IEthereumLightClient {
    function finalizedExecutionStateRootAndSlot() external view returns (bytes32 root, uint64 slot);
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

// light client security params
uint256 constant MIN_SYNC_COMMITTEE_PARTICIPANTS = 1;
uint256 constant UPDATE_TIMEOUT = 86400;

// beacon chain constants
uint256 constant FINALIZED_ROOT_INDEX = 105;
uint256 constant NEXT_SYNC_COMMITTEE_INDEX = 55;
uint256 constant EXECUTION_STATE_ROOT_INDEX = 898;
// uint256 constant EXECUTION_STATE_ROOT_INDEX = 402;
uint256 constant SYNC_COMMITTEE_SIZE = 512;
uint64 constant SLOTS_PER_EPOCH = 32;
uint64 constant EPOCHS_PER_SYNC_COMMITTEE_PERIOD = 256;
bytes32 constant DOMAIN_SYNC_COMMITTEE = bytes32(uint256(0x07) << 248);
uint256 constant SLOT_LENGTH_SECONDS = 12;

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IEthereumLightClient.sol";

import "./IZkVerifier.sol";
import "./LightClientStore.sol";
import "./SSZ.sol";
import "./Constants.sol";
import "./Types.sol";

contract EthereumLightClient is IEthereumLightClient, LightClientStore, Ownable {
    event HeaderUpdated(uint256 slot, bytes32 stateRoot, bytes32 executionStateRoot, bool finalized);
    event SyncCommitteeUpdated(uint256 period, bytes32 sszRoot, bytes32 poseidonRoot);
    event ForkVersionUpdated(uint64 epoch, bytes4 forkVersion);

    constructor(
        uint256 genesisTime,
        bytes32 genesisValidatorsRoot,
        uint64[] memory _forkEpochs,
        bytes4[] memory _forkVersions,
        BeaconBlockHeader memory _finalizedHeader,
        bytes32 syncCommitteeRoot,
        bytes32 syncCommitteePoseidonRoot,
        address _zkVerifier
    )
        LightClientStore(
            genesisTime,
            genesisValidatorsRoot,
            _forkEpochs,
            _forkVersions,
            _finalizedHeader,
            syncCommitteeRoot,
            syncCommitteePoseidonRoot,
            _zkVerifier
        )
    {}

    function latestFinalizedSlotAndCommitteeRoots()
        external
        view
        returns (
            uint64 slot,
            bytes32 currentRoot,
            bytes32 nextRoot
        )
    {
        return (finalizedHeader.slot, currentSyncCommitteeRoot, nextSyncCommitteeRoot);
    }

    function finalizedExecutionStateRootAndSlot() external view returns (bytes32 root, uint64 slot) {
        return (finalizedExecutionStateRoot, finalizedExecutionStateRootSlot);
    }

    function updateForkVersion(uint64 epoch, bytes4 forkVersion) external onlyOwner {
        require(forkVersion != bytes4(0), "bad fork version");
        forkEpochs.push(epoch);
        forkVersions.push(forkVersion);
        emit ForkVersionUpdated(epoch, forkVersion);
    }

    function processLightClientForceUpdate() external onlyOwner {
        require(currentSlot() > finalizedHeader.slot + UPDATE_TIMEOUT, "timeout not passed");
        require(bestValidUpdate.attestedHeader.slot > 0, "no best valid update");

        // Forced best update when the update timeout has elapsed.
        // Because the apply logic waits for finalizedHeader.slot to indicate sync committee fin,
        // the attestedHeader may be treated as finalizedHeader in extended periods of non-fin
        // to guarantee progression into later sync committee periods according to isBetterUpdate().
        if (bestValidUpdate.finalizedHeader.slot <= finalizedHeader.slot) {
            bestValidUpdate.finalizedHeader = bestValidUpdate.attestedHeader;
        }
        applyLightClientUpdate(bestValidUpdate);
        delete bestValidUpdate;
    }

    function processLightClientUpdate(LightClientUpdate memory update) public {
        validateLightClientUpdate(update);

        // Update the best update in case we have to force-update to it if the timeout elapses
        if (isBetterUpdate(update, bestValidUpdate)) {
            bestValidUpdate = update;
        }

        // Apply fin update
        bool updateHasFinalizedNextSyncCommittee = hasNextSyncCommitteeProof(update) &&
            hasFinalityProof(update) &&
            computeSyncCommitteePeriodAtSlot(update.finalizedHeader.slot) ==
            computeSyncCommitteePeriodAtSlot(update.attestedHeader.slot) &&
            nextSyncCommitteeRoot == bytes32(0);
        if (
            hasSupermajority(update.syncAggregate.participation) &&
            (update.finalizedHeader.slot > finalizedHeader.slot || updateHasFinalizedNextSyncCommittee)
        ) {
            applyLightClientUpdate(update);
            delete bestValidUpdate;
        }
    }

    function validateLightClientUpdate(LightClientUpdate memory update) private view {
        // Verify sync committee has sufficient participants
        require(update.syncAggregate.participation > MIN_SYNC_COMMITTEE_PARTICIPANTS, "not enough participation");
        // Verify update does not skip a sync committee period
        require(
            currentSlot() > update.attestedHeader.slot && update.attestedHeader.slot > update.finalizedHeader.slot,
            "bad slot"
        );
        uint64 storePeriod = computeSyncCommitteePeriodAtSlot(finalizedHeader.slot);
        uint64 updatePeriod = computeSyncCommitteePeriodAtSlot(update.finalizedHeader.slot);
        require(updatePeriod == storePeriod || updatePeriod == storePeriod + 1);

        // Verify update is relavant
        uint64 updateAttestedPeriod = computeSyncCommitteePeriodAtSlot(update.attestedHeader.slot);
        bool updateHasNextSyncCommittee = nextSyncCommitteeRoot == bytes32(0) &&
            hasNextSyncCommitteeProof(update) &&
            updateAttestedPeriod == storePeriod;
        // since sync committee update prefers older header (see isBetterUpdate), an update either
        // needs to have a newer header or it should have sync committee update.
        require(update.attestedHeader.slot > finalizedHeader.slot || updateHasNextSyncCommittee);

        // Verify that the finalityBranch, if present, confirms finalizedHeader
        // to match the finalized checkpoint root saved in the state of attestedHeader.
        // Note that the genesis finalized checkpoint root is represented as a zero hash.
        if (!hasFinalityProof(update)) {
            require(isEmptyHeader(update.finalizedHeader), "no fin proof");
        } else {
            // genesis block header
            if (update.finalizedHeader.slot == 0) {
                require(isEmptyHeader(update.finalizedHeader), "genesis header should be empty");
            } else {
                bool isValidFinalityProof = SSZ.isValidMerkleBranch(
                    SSZ.hashTreeRoot(update.finalizedHeader),
                    update.finalityBranch,
                    FINALIZED_ROOT_INDEX,
                    update.attestedHeader.stateRoot
                );
                require(isValidFinalityProof, "bad fin proof");
            }
        }

        // Verify finalizedExecutionStateRoot
        if (!hasExecutionFinalityProof(update)) {
            require(update.finalizedExecutionStateRoot == bytes32(0), "no exec fin proof");
        } else {
            require(hasFinalityProof(update), "no exec fin proof");
            bool isValidFinalizedExecutionRootProof = SSZ.isValidMerkleBranch(
                update.finalizedExecutionStateRoot,
                update.finalizedExecutionStateRootBranch,
                EXECUTION_STATE_ROOT_INDEX,
                update.finalizedHeader.stateRoot
            );
            require(isValidFinalizedExecutionRootProof, "bad exec fin proof");
        }

        // Verify that the update's nextSyncCommittee, if present, actually is the next sync committee
        // saved in the state of the update's attested header
        if (!hasNextSyncCommitteeProof(update)) {
            require(
                update.nextSyncCommitteeRoot == bytes32(0) && update.nextSyncCommitteePoseidonRoot == bytes32(0),
                "no next sync committee proof"
            );
        } else {
            if (updateAttestedPeriod == storePeriod && nextSyncCommitteeRoot != bytes32(0)) {
                require(update.nextSyncCommitteeRoot == nextSyncCommitteeRoot, "bad next sync committee");
            }
            bool isValidSyncCommitteeProof = SSZ.isValidMerkleBranch(
                update.nextSyncCommitteeRoot,
                update.nextSyncCommitteeBranch,
                NEXT_SYNC_COMMITTEE_INDEX,
                update.attestedHeader.stateRoot
            );
            require(isValidSyncCommitteeProof, "bad next sync committee proof");
            bool isValidCommitteeRootMappingProof = zkVerifier.verifySyncCommitteeRootMappingProof(
                update.nextSyncCommitteeRoot,
                update.nextSyncCommitteePoseidonRoot,
                update.nextSyncCommitteeRootMappingProof
            );
            require(isValidCommitteeRootMappingProof, "bad next sync committee root mapping proof");
        }

        // Verify sync committee signature ZK proof
        bytes4 forkVersion = computeForkVersion(computeEpochAtSlot(update.signatureSlot));
        bytes32 domain = computeDomain(forkVersion);
        bytes32 signingRoot = computeSigningRoot(update.attestedHeader, domain);
        bytes32 activeSyncCommitteePoseidonRoot;
        if (updatePeriod == storePeriod) {
            require(currentSyncCommitteePoseidonRoot == update.syncAggregate.poseidonRoot, "bad poseidon root");
            activeSyncCommitteePoseidonRoot = currentSyncCommitteePoseidonRoot;
        } else if (updatePeriod == storePeriod + 1) {
            require(nextSyncCommitteePoseidonRoot == update.syncAggregate.poseidonRoot, "bad poseidon root");
            activeSyncCommitteePoseidonRoot = nextSyncCommitteePoseidonRoot;
        }
        require(
            zkVerifier.verifySignatureProof(
                signingRoot,
                activeSyncCommitteePoseidonRoot,
                update.syncAggregate.participation,
                update.syncAggregate.proof
            ),
            "bad bls sig proof"
        );
    }

    function applyLightClientUpdate(LightClientUpdate memory update) private {
        uint64 storePeriod = computeSyncCommitteePeriodAtSlot(finalizedHeader.slot);
        uint64 updateFinalizedPeriod = computeSyncCommitteePeriodAtSlot(update.finalizedHeader.slot);
        if (nextSyncCommitteeRoot == bytes32(0)) {
            require(updateFinalizedPeriod == storePeriod, "mismatch period");
            nextSyncCommitteeRoot = update.nextSyncCommitteeRoot;
            nextSyncCommitteePoseidonRoot = update.nextSyncCommitteePoseidonRoot;
            emit SyncCommitteeUpdated(updateFinalizedPeriod + 1, nextSyncCommitteeRoot, nextSyncCommitteePoseidonRoot);
        } else if (updateFinalizedPeriod == storePeriod + 1) {
            currentSyncCommitteeRoot = nextSyncCommitteeRoot;
            currentSyncCommitteePoseidonRoot = nextSyncCommitteePoseidonRoot;
            nextSyncCommitteeRoot = update.nextSyncCommitteeRoot;
            nextSyncCommitteePoseidonRoot = update.nextSyncCommitteePoseidonRoot;
            emit SyncCommitteeUpdated(updateFinalizedPeriod + 1, nextSyncCommitteeRoot, nextSyncCommitteePoseidonRoot);
        }
        if (update.finalizedHeader.slot > finalizedHeader.slot) {
            finalizedHeader = update.finalizedHeader;
            if (update.finalizedExecutionStateRoot != bytes32(0)) {
                finalizedExecutionStateRoot = update.finalizedExecutionStateRoot;
                finalizedExecutionStateRootSlot = update.finalizedHeader.slot;
            }
            emit HeaderUpdated(
                update.finalizedHeader.slot,
                update.finalizedHeader.stateRoot,
                update.finalizedExecutionStateRoot,
                true
            );
        }
    }

    /*
     * https://github.com/ethereum/consensus-specs/blob/dev/specs/altair/light-client/sync-protocol.md#is_better_update
     */
    function isBetterUpdate(LightClientUpdate memory newUpdate, LightClientUpdate memory oldUpdate)
        private
        pure
        returns (bool)
    {
        // Old update doesn't exist
        if (oldUpdate.syncAggregate.participation == 0) {
            return newUpdate.syncAggregate.participation > 0;
        }

        // Compare supermajority (> 2/3) sync committee participation
        bool newHasSupermajority = hasSupermajority(newUpdate.syncAggregate.participation);
        bool oldHasSupermajority = hasSupermajority(oldUpdate.syncAggregate.participation);
        if (newHasSupermajority != oldHasSupermajority) {
            // the new update is a better one if new has supermajority but old doesn't
            return newHasSupermajority && !oldHasSupermajority;
        }
        if (!newHasSupermajority && newUpdate.syncAggregate.participation != oldUpdate.syncAggregate.participation) {
            // a better update is the one with higher participation when both new and old doesn't have supermajority
            return newUpdate.syncAggregate.participation > oldUpdate.syncAggregate.participation;
        }

        // Compare presence of relevant sync committee
        bool newHasSyncCommittee = hasRelavantSyncCommittee(newUpdate);
        bool oldHasSyncCommittee = hasRelavantSyncCommittee(oldUpdate);
        if (newHasSyncCommittee != oldHasSyncCommittee) {
            return newHasSyncCommittee;
        }

        // Compare indication of any fin
        bool newHasFinality = hasFinalityProof(newUpdate);
        bool oldHasFinality = hasFinalityProof(oldUpdate);
        if (newHasFinality != oldHasFinality) {
            return newHasFinality;
        }

        // Compare sync committee fin
        if (newHasFinality) {
            bool newHasCommitteeFinality = computeSyncCommitteePeriodAtSlot(newUpdate.finalizedHeader.slot) ==
                computeSyncCommitteePeriodAtSlot(newUpdate.attestedHeader.slot);
            bool oldHasCommitteeFinality = computeSyncCommitteePeriodAtSlot(oldUpdate.finalizedHeader.slot) ==
                computeSyncCommitteePeriodAtSlot(oldUpdate.attestedHeader.slot);
            if (newHasCommitteeFinality != oldHasCommitteeFinality) {
                return newHasCommitteeFinality;
            }
        }

        // Tiebreaker 1: Sync committee participation beyond supermajority
        if (newUpdate.syncAggregate.participation != oldUpdate.syncAggregate.participation) {
            return newUpdate.syncAggregate.participation > oldUpdate.syncAggregate.participation;
        }

        // Tiebreaker 2: Prefer older data (fewer changes to best)
        if (newUpdate.attestedHeader.slot != oldUpdate.attestedHeader.slot) {
            return newUpdate.attestedHeader.slot < oldUpdate.attestedHeader.slot;
        }

        return newUpdate.signatureSlot < oldUpdate.signatureSlot;
    }

    function hasRelavantSyncCommittee(LightClientUpdate memory update) private pure returns (bool) {
        return
            hasNextSyncCommitteeProof(update) &&
            computeSyncCommitteePeriodAtSlot(update.attestedHeader.slot) ==
            computeSyncCommitteePeriodAtSlot(update.signatureSlot);
    }

    function hasNextSyncCommitteeProof(LightClientUpdate memory update) private pure returns (bool) {
        return update.nextSyncCommitteeBranch.length > 0;
    }

    function hasFinalityProof(LightClientUpdate memory update) private pure returns (bool) {
        return update.finalityBranch.length > 0;
    }

    function hasExecutionFinalityProof(LightClientUpdate memory update) private pure returns (bool) {
        return update.finalizedExecutionStateRootBranch.length > 0;
    }

    function hasSupermajority(uint64 participation) private pure returns (bool) {
        return participation * 3 >= SYNC_COMMITTEE_SIZE * 2;
    }

    function isEmptyHeader(BeaconBlockHeader memory header) private pure returns (bool) {
        return header.stateRoot == bytes32(0);
    }

    function currentSlot() private view returns (uint64) {
        return uint64((block.timestamp - GENESIS_TIME) / SLOT_LENGTH_SECONDS);
    }

    function computeForkVersion(uint64 epoch) private view returns (bytes4) {
        for (uint256 i = forkVersions.length - 1; i >= 0; i--) {
            if (epoch >= forkEpochs[i]) {
                return forkVersions[i];
            }
        }
        revert("fork versions not set");
    }

    function computeSyncCommitteePeriodAtSlot(uint64 slot) private pure returns (uint64) {
        return computeSyncCommitteePeriod(computeEpochAtSlot(slot));
    }

    function computeEpochAtSlot(uint64 slot) private pure returns (uint64) {
        return slot / SLOTS_PER_EPOCH;
    }

    function computeSyncCommitteePeriod(uint64 epoch) private pure returns (uint64) {
        return epoch / EPOCHS_PER_SYNC_COMMITTEE_PERIOD;
    }

    /**
     * https://github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#compute_domain
     */
    function computeDomain(bytes4 forkVersion) public view returns (bytes32) {
        return DOMAIN_SYNC_COMMITTEE | (sha256(abi.encode(forkVersion, GENESIS_VALIDATOR_ROOT)) >> 32);
    }

    // computeDomain(forkVersion, genesisValidatorsRoot)
    function computeSigningRoot(BeaconBlockHeader memory header, bytes32 domain) public pure returns (bytes32) {
        return sha256(bytes.concat(SSZ.hashTreeRoot(header), domain));
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

import "./Types.sol";

interface IZkVerifier {
    function verifySignatureProof(
        bytes32 signingRoot,
        bytes32 syncCommitteePoseidonRoot,
        uint256 participation,
        Proof memory p
    ) external view returns (bool);

    function verifySyncCommitteeRootMappingProof(
        bytes32 sszRoot,
        bytes32 poseidonRoot,
        Proof memory p
    ) external view returns (bool);
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

import "./Types.sol";
import "./IZkVerifier.sol";

abstract contract LightClientStore {
    // beacon chain genesis information
    uint256 immutable GENESIS_TIME;
    bytes32 immutable GENESIS_VALIDATOR_ROOT;

    // light client store
    BeaconBlockHeader public finalizedHeader;
    bytes32 public finalizedExecutionStateRoot;
    uint64 public finalizedExecutionStateRootSlot;

    bytes32 public currentSyncCommitteeRoot;
    bytes32 public currentSyncCommitteePoseidonRoot;
    bytes32 public nextSyncCommitteeRoot;
    bytes32 public nextSyncCommitteePoseidonRoot;

    LightClientUpdate public bestValidUpdate;

    // fork versions
    uint64[] public forkEpochs;
    bytes4[] public forkVersions;

    // zk verifier
    IZkVerifier public zkVerifier; // contract too big. need to move this one out

    constructor(
        uint256 genesisTime,
        bytes32 genesisValidatorsRoot,
        uint64[] memory _forkEpochs,
        bytes4[] memory _forkVersions,
        BeaconBlockHeader memory _finalizedHeader,
        bytes32 syncCommitteeRoot,
        bytes32 syncCommitteePoseidonRoot,
        address _zkVerifier
    ) {
        GENESIS_TIME = genesisTime;
        GENESIS_VALIDATOR_ROOT = genesisValidatorsRoot;
        forkEpochs = _forkEpochs;
        forkVersions = _forkVersions;
        finalizedHeader = _finalizedHeader;
        currentSyncCommitteeRoot = syncCommitteeRoot;
        currentSyncCommitteePoseidonRoot = syncCommitteePoseidonRoot;
        zkVerifier = IZkVerifier(_zkVerifier);
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

import "./Types.sol";

library SSZ {
    function isValidMerkleBranch(
        bytes32 leaf,
        bytes32[] memory branch,
        uint256 index,
        bytes32 root
    ) internal pure returns (bool) {
        bytes32 restoredMerkleRoot = restoreMerkleRoot(leaf, branch, index);
        return root == restoredMerkleRoot;
    }

    function restoreMerkleRoot(bytes32 leaf, bytes32[] memory branch, uint256 index) internal pure returns (bytes32) {
        bytes32 value = leaf;
        for (uint256 i = 0; i < branch.length; i++) {
            if ((index / (2 ** i)) % 2 == 1) {
                value = sha256(bytes.concat(branch[i], value));
            } else {
                value = sha256(bytes.concat(value, branch[i]));
            }
        }
        return value;
    }

    function hashTreeRoot(BeaconBlockHeader memory header) internal pure returns (bytes32) {
        bytes32 left = sha256(
            bytes.concat(
                sha256(bytes.concat(toLittleEndian(header.slot), toLittleEndian(header.proposerIndex))),
                sha256(bytes.concat(header.parentRoot, header.stateRoot))
            )
        );
        bytes32 right = sha256(
            bytes.concat(
                sha256(bytes.concat(header.bodyRoot, bytes32(0))),
                sha256(bytes.concat(bytes32(0), bytes32(0)))
            )
        );
        return sha256(bytes.concat(left, right));
    }

    function toLittleEndian(uint256 x) internal pure returns (bytes32) {
        bytes32 res;
        for (uint256 i = 0; i < 32; i++) {
            res = (res << 8) | bytes32(x & 0xff);
            x >>= 8;
        }
        return res;
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

struct BeaconBlockHeader {
    uint64 slot;
    uint64 proposerIndex;
    bytes32 parentRoot;
    bytes32 stateRoot;
    bytes32 bodyRoot;
}

struct LightClientUpdate {
    // Header attested to by the sync committee
    BeaconBlockHeader attestedHeader;
    // Finalized header corresponding to `attested_header.state_root`
    BeaconBlockHeader finalizedHeader;
    bytes32[] finalityBranch;
    bytes32 finalizedExecutionStateRoot;
    bytes32[] finalizedExecutionStateRootBranch;
    bytes32 optimisticExecutionStateRoot;
    bytes32[] optimisticExecutionStateRootBranch;
    bytes32 nextSyncCommitteeRoot;
    bytes32[] nextSyncCommitteeBranch;
    bytes32 nextSyncCommitteePoseidonRoot;
    Proof nextSyncCommitteeRootMappingProof;
    // Sync committee aggregate signature participation & zk proof
    SyncAggregate syncAggregate;
    // Slot at which the aggregate signature was created (untrusted)
    uint64 signatureSlot;
}

struct SyncAggregate {
    uint64 participation;
    bytes32 poseidonRoot;
    Proof proof;
}

struct Proof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
}