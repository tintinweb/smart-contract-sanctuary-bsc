// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "./interfaces/ISocket.sol";
import "./interfaces/IAccumulator.sol";
import "./interfaces/IDeaccumulator.sol";
import "./interfaces/IVerifier.sol";
import "./interfaces/IPlug.sol";
import "./interfaces/IHasher.sol";
import "./utils/AccessControl.sol";

contract Socket is ISocket, AccessControl(msg.sender) {
    enum MessageStatus {
        NOT_EXECUTED,
        SUCCESS,
        FAILED
    }

    uint256 private immutable _chainId;

    bytes32 private constant EXECUTOR_ROLE = keccak256("EXECUTOR");

    // localPlug => remoteChainId => OutboundConfig
    mapping(address => mapping(uint256 => OutboundConfig))
        public outboundConfigs;

    // localPlug => remoteChainId => InboundConfig
    mapping(address => mapping(uint256 => InboundConfig)) public inboundConfigs;

    // localPlug => remoteChainId => nonce
    mapping(address => mapping(uint256 => uint256)) private _nonces;

    // msgId => executorAddress
    mapping(uint256 => address) private executor;

    // msgId => message status
    mapping(uint256 => MessageStatus) private _messagesStatus;

    IHasher public hasher;
    IVault public override vault;

    constructor(
        uint256 chainId_,
        address hasher_,
        address vault_
    ) {
        _setHasher(hasher_);
        _chainId = chainId_;
        vault = IVault(vault_);
    }

    function setHasher(address hasher_) external onlyOwner {
        _setHasher(hasher_);
    }

    /**
     * @notice registers a message
     * @dev Packs the message and includes it in a packet with accumulator
     * @param remoteChainId_ the destination chain id
     * @param msgGasLimit_ the gas limit needed to execute the payload on destination
     * @param payload_ the data which is needed by plug at inbound call on destination
     */
    function outbound(
        uint256 remoteChainId_,
        uint256 msgGasLimit_,
        bytes calldata payload_
    ) external payable override {
        OutboundConfig memory config = outboundConfigs[msg.sender][
            remoteChainId_
        ];
        uint256 nonce = _nonces[msg.sender][remoteChainId_]++;

        // Packs the src plug, src chain id, dest chain id and nonce
        // msgId(256) = srcPlug(160) + srcChainId(16) + destChainId(16) + nonce(64)
        uint256 msgId = (uint256(uint160(msg.sender)) << 96) |
            (_chainId << 80) |
            (remoteChainId_ << 64) |
            nonce;

        vault.deductFee{value: msg.value}(remoteChainId_, msgGasLimit_);

        bytes32 packedMessage = hasher.packMessage(
            _chainId,
            msg.sender,
            remoteChainId_,
            config.remotePlug,
            msgId,
            msgGasLimit_,
            payload_
        );

        IAccumulator(config.accum).addPackedMessage(packedMessage);
        emit MessageTransmitted(
            _chainId,
            msg.sender,
            remoteChainId_,
            config.remotePlug,
            msgId,
            msgGasLimit_,
            payload_
        );
    }

    /**
     * @notice executes a message
     * @param msgGasLimit gas limit needed to execute the inbound at destination
     * @param msgId message id packed with src plug, src chainId, dest chainId and nonce
     * @param localPlug dest plug address
     * @param payload the data which is needed by plug at inbound call on destination
     * @param verifyParams_ the details needed for message verification
     */
    function execute(
        uint256 msgGasLimit,
        uint256 msgId,
        address localPlug,
        bytes calldata payload,
        ISocket.VerificationParams calldata verifyParams_
    ) external override {
        if (!_hasRole(EXECUTOR_ROLE, msg.sender)) revert ExecutorNotFound();
        if (executor[msgId] != address(0)) revert MessageAlreadyExecuted();
        executor[msgId] = msg.sender;

        bytes32 packedMessage = hasher.packMessage(
            verifyParams_.remoteChainId,
            inboundConfigs[localPlug][verifyParams_.remoteChainId].remotePlug,
            _chainId,
            localPlug,
            msgId,
            msgGasLimit,
            payload
        );

        _verify(localPlug, packedMessage, verifyParams_);
        _execute(localPlug, msgGasLimit, msgId, payload);
    }

    function _verify(
        address localPlug,
        bytes32 packedMessage,
        ISocket.VerificationParams calldata verifyParams_
    ) internal view {
        InboundConfig memory config = inboundConfigs[localPlug][
            verifyParams_.remoteChainId
        ];

        (bool isVerified, bytes32 root) = IVerifier(config.verifier).verifyRoot(
            verifyParams_.remoteAccum,
            verifyParams_.remoteChainId,
            verifyParams_.packetId
        );

        if (!isVerified) revert VerificationFailed();

        if (
            !IDeaccumulator(config.deaccum).verifyMessageInclusion(
                root,
                packedMessage,
                verifyParams_.deaccumProof
            )
        ) revert InvalidProof();
    }

    function _execute(
        address localPlug,
        uint256 msgGasLimit,
        uint256 msgId,
        bytes calldata payload
    ) internal {
        try IPlug(localPlug).inbound{gas: msgGasLimit}(payload) {
            _messagesStatus[msgId] = MessageStatus.SUCCESS;
            emit ExecutionSuccess(msgId);
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            _messagesStatus[msgId] = MessageStatus.FAILED;
            emit ExecutionFailed(msgId, reason);
        } catch (bytes memory reason) {
            // catch failing assert()
            _messagesStatus[msgId] = MessageStatus.FAILED;
            emit ExecutionFailedBytes(msgId, reason);
        }
    }

    /// @inheritdoc ISocket
    function setInboundConfig(
        uint256 remoteChainId_,
        address remotePlug_,
        address deaccum_,
        address verifier_
    ) external override {
        InboundConfig storage config = inboundConfigs[msg.sender][
            remoteChainId_
        ];
        config.remotePlug = remotePlug_;
        config.deaccum = deaccum_;
        config.verifier = verifier_;

        // TODO: emit event
    }

    /// @inheritdoc ISocket
    function setOutboundConfig(
        uint256 remoteChainId_,
        address remotePlug_,
        address accum_
    ) external override {
        OutboundConfig storage config = outboundConfigs[msg.sender][
            remoteChainId_
        ];
        config.accum = accum_;
        config.remotePlug = remotePlug_;

        // TODO: emit event
    }

    /**
     * @notice adds an executor
     * @param executor_ executor address
     */
    function grantExecutorRole(address executor_) external onlyOwner {
        _grantRole(EXECUTOR_ROLE, executor_);
    }

    /**
     * @notice removes an executor from `remoteChainId_` chain list
     * @param executor_ executor address
     */
    function revokeExecutorRole(address executor_) external onlyOwner {
        _revokeRole(EXECUTOR_ROLE, executor_);
    }

    function _setHasher(address hasher_) private {
        hasher = IHasher(hasher_);
    }

    function chainId() external view returns (uint256) {
        return _chainId;
    }

    function getMessageStatus(uint256 msgId_)
        external
        view
        returns (MessageStatus)
    {
        return _messagesStatus[msgId_];
    }

    // TODO:
    // function updateSocket() external onlyOwner {
    //     // transfer ownership of connected contracts to new socket
    //     // update addresses everywhere
    // }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "./IVault.sol";

interface ISocket {
    // to handle stack too deep
    struct VerificationParams {
        uint256 remoteChainId;
        address remoteAccum;
        uint256 packetId;
        bytes deaccumProof;
    }

    /**
     * @notice emits the message details when a new message arrives at outbound
     * @param srcChainId src chain id
     * @param srcPlug src plug address
     * @param dstChainId dest chain id
     * @param dstPlug dest plug address
     * @param msgId message id packed with destChainId and nonce
     * @param msgGasLimit gas limit needed to execute the inbound at destination
     * @param payload the data which will be used by inbound at destination
     */
    event MessageTransmitted(
        uint256 srcChainId,
        address srcPlug,
        uint256 dstChainId,
        address dstPlug,
        uint256 msgId,
        uint256 msgGasLimit,
        bytes payload
    );

    /**
     * @notice emits the status of message after inbound call
     * @param msgId msg id which is executed
     */
    event ExecutionSuccess(uint256 msgId);

    /**
     * @notice emits the status of message after inbound call
     * @param msgId msg id which is executed
     * @param result if message reverts, returns the revert message
     */
    event ExecutionFailed(uint256 msgId, string result);

    /**
     * @notice emits the error message in bytes after inbound call
     * @param msgId msg id which is executed
     * @param result if message reverts, returns the revert message in bytes
     */
    event ExecutionFailedBytes(uint256 msgId, bytes result);

    error NotAttested();

    error InvalidRemotePlug();

    error InvalidProof();

    error VerificationFailed();

    error MessageAlreadyExecuted();

    error InsufficientGasLimit();

    error ExecutorNotFound();

    function vault() external view returns (IVault);

    /**
     * @notice registers a message
     * @dev Packs the message and includes it in a packet with accumulator
     * @param remoteChainId_ the destination chain id
     * @param msgGasLimit_ the gas limit needed to execute the payload on destination
     * @param payload_ the data which is needed by plug at inbound call on destination
     */
    function outbound(
        uint256 remoteChainId_,
        uint256 msgGasLimit_,
        bytes calldata payload_
    ) external payable;

    /**
     * @notice executes a message
     * @param msgGasLimit gas limit needed to execute the inbound at destination
     * @param msgId message id packed with destChainId and nonce
     * @param localPlug dest plug address
     * @param payload the data which is needed by plug at inbound call on destination
     * @param verifyParams_ the details needed for message verification
     */
    function execute(
        uint256 msgGasLimit,
        uint256 msgId,
        address localPlug,
        bytes calldata payload,
        ISocket.VerificationParams calldata verifyParams_
    ) external;

    // TODO: add confs and blocking/non-blocking
    struct InboundConfig {
        address remotePlug;
        address deaccum;
        address verifier;
    }

    struct OutboundConfig {
        address accum;
        address remotePlug;
    }

    /**
     * @notice sets the config specific to the plug
     * @param remoteChainId_ the destination chain id
     * @param remotePlug_ address of plug present at destination chain to call inbound
     * @param deaccum_ address of deaccum which is used to verify proof
     * @param verifier_ address of verifier responsible for final packet validity checks
     */
    function setInboundConfig(
        uint256 remoteChainId_,
        address remotePlug_,
        address deaccum_,
        address verifier_
    ) external;

    /**
     * @notice sets the config specific to the plug
     * @param remoteChainId_ the destination chain id
     * @param remotePlug_ address of plug present at destination chain to call inbound
     * @param accum_ address of accumulator which is used for collecting the messages and form packets
     */
    function setOutboundConfig(
        uint256 remoteChainId_,
        address remotePlug_,
        address accum_
    ) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface IAccumulator {
    /**
     * @notice emits the message details when it arrives
     * @param packedMessage the message packed with payload, fees and config
     * @param packetId an incremental id assigned to each new packet
     * @param newRootHash the packed message hash (to be replaced with the root hash of the merkle tree)
     */
    event MessageAdded(
        bytes32 packedMessage,
        uint256 packetId,
        bytes32 newRootHash
    );

    /**
     * @notice emits when the packet is sealed and indicates it can be send to destination
     * @param rootHash the packed message hash (to be replaced with the root hash of the merkle tree)
     * @param packetId an incremental id assigned to each new packet
     */
    event PacketComplete(bytes32 rootHash, uint256 packetId);

    /**
     * @notice adds the packed message to a packet
     * @dev this should be only executable by socket
     * @dev it will be later replaced with a function adding each message to a merkle tree
     * @param packedMessage the message packed with payload, fees and config
     */
    function addPackedMessage(bytes32 packedMessage) external;

    /**
     * @notice returns the latest packet details which needs to be sealed
     * @return root root hash of the latest packet which is not yet sealed
     * @return packetId latest packet id which is not yet sealed
     */
    function getNextPacketToBeSealed()
        external
        view
        returns (bytes32 root, uint256 packetId);

    /**
     * @notice returns the root of packet for given id
     * @param id the id assigned to packet
     * @return root root hash corresponding to given id
     */
    function getRootById(uint256 id) external view returns (bytes32 root);

    /**
     * @notice seals the packet
     * @dev also indicates the packet is ready to be shipped and no more messages can be added now.
     * @dev this should be executable by notary only
     * @return root root hash of the packet
     * @return packetId id of the packed sealed
     */
    function sealPacket() external returns (bytes32 root, uint256 packetId);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface IDeaccumulator {
    /**
     * @notice returns if the packed message is the part of a merkle tree or not
     * @param root_ root hash of the merkle tree
     * @param packedMessage_ packed message which needs to be verified
     * @param proof_ proof used to determine the inclusion
     */
    function verifyMessageInclusion(
        bytes32 root_,
        bytes32 packedMessage_,
        bytes calldata proof_
    ) external pure returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface IVerifier {
    /**
     * @notice verifies if the packet satisfies needed checks before execution
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ dest chain id
     * @param packetId_ packet id
     */
    function verifyRoot(
        address accumAddress_,
        uint256 remoteChainId_,
        uint256 packetId_
    ) external view returns (bool, bytes32);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

interface IPlug {
    /**
     * @notice executes the message received from source chain
     * @dev this should be only executable by socket
     * @param payload_ the data which is needed by plug at inbound call on destination
     */
    function inbound(bytes calldata payload_) external payable;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface IHasher {
    /**
     * @notice returns the bytes32 hash of the message packed
     * @param srcChainId src chain id
     * @param srcPlug address of plug at source
     * @param dstChainId destination chain id
     * @param dstPlug address of plug at destination
     * @param msgId message id assigned at outbound
     * @param msgGasLimit gas limit which is expected to be consumed by the inbound transaction on plug
     * @param payload the data packed which is used by inbound for execution
     */
    function packMessage(
        uint256 srcChainId,
        address srcPlug,
        uint256 dstChainId,
        address dstPlug,
        uint256 msgId,
        uint256 msgGasLimit,
        bytes calldata payload
    ) external returns (bytes32);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "./Ownable.sol";

abstract contract AccessControl is Ownable {
    // role => address => permit
    mapping(bytes32 => mapping(address => bool)) private _permits;

    event RoleGranted(bytes32 indexed role, address indexed grantee);

    event RoleRevoked(bytes32 indexed role, address indexed revokee);

    error NoPermit(bytes32 role);

    constructor(address owner_) Ownable(owner_) {}

    modifier onlyRole(bytes32 role) {
        if (!_permits[role][msg.sender]) revert NoPermit(role);
        _;
    }

    function grantRole(bytes32 role, address grantee)
        external
        virtual
        onlyOwner
    {
        _grantRole(role, grantee);
    }

    function revokeRole(bytes32 role, address revokee)
        external
        virtual
        onlyOwner
    {
        _revokeRole(role, revokee);
    }

    function _grantRole(bytes32 role, address grantee) internal {
        _permits[role][grantee] = true;
        emit RoleGranted(role, grantee);
    }

    function _revokeRole(bytes32 role, address revokee) internal {
        _permits[role][revokee] = false;
        emit RoleRevoked(role, revokee);
    }

    function hasRole(bytes32 role, address _address)
        external
        view
        returns (bool)
    {
        return _hasRole(role, _address);
    }

    function _hasRole(bytes32 role, address _address)
        internal
        view
        returns (bool)
    {
        return _permits[role][_address];
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

interface IVault {
    /**
     * @notice emits when fee is deducted at outbound
     * @param amount_ total fee amount
     */
    event FeeDeducted(uint256 amount_);

    error InsufficientFee();

    /**
     * @notice deducts the fee required to bridge the packet using msgGasLimit
     * @param remoteChainId_ dest chain id
     * @param msgGasLimit_ gas limit needed to execute inbound at remote plug
     */
    function deductFee(uint256 remoteChainId_, uint256 msgGasLimit_)
        external
        payable;

    /**
     * @notice transfers the `amount_` ETH to `account_`
     * @param account_ address to transfer ETH
     * @param amount_ amount to transfer
     */
    function claimFee(address account_, uint256 amount_) external;

    /**
     * @notice returns the fee required to bridge a message
     * @param remoteChainId_ dest chain id
     * @param msgGasLimit_ gas limit needed to execute inbound at remote plug
     */
    function getFees(uint256 remoteChainId_, uint256 msgGasLimit_)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

abstract contract Ownable {
    address private _owner;
    address private _nominee;

    event OwnerNominated(address indexed nominee);
    event OwnerClaimed(address indexed claimer);

    error OnlyOwner();
    error OnlyNominee();

    constructor(address owner_) {
        _claimOwner(owner_);
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) revert OnlyOwner();
        _;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function nominee() external view returns (address) {
        return _nominee;
    }

    function nominateOwner(address nominee_) external {
        if (msg.sender != _owner) revert OnlyOwner();
        _nominee = nominee_;
        emit OwnerNominated(_nominee);
    }

    function claimOwner() external {
        if (msg.sender != _nominee) revert OnlyNominee();
        _claimOwner(msg.sender);
    }

    function _claimOwner(address claimer_) internal {
        _owner = claimer_;
        _nominee = address(0);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IVerifier.sol";
import "../interfaces/INotary.sol";
import "../utils/Ownable.sol";

contract Verifier is IVerifier, Ownable {
    INotary public notary;
    uint256 public immutable timeoutInSeconds;

    event NotarySet(address notary_);

    constructor(
        address owner_,
        address _notary,
        uint256 timeoutInSeconds_
    ) Ownable(owner_) {
        notary = INotary(_notary);

        // TODO: restrict the timeout durations to a few select options
        timeoutInSeconds = timeoutInSeconds_;
    }

    /**
     * @notice updates notary
     * @param notary_ address of Notary
     */
    function setNotary(address notary_) external onlyOwner {
        notary = INotary(notary_);
        emit NotarySet(notary_);
    }

    /**
     * @notice verifies if the packet satisfies needed checks before execution
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ dest chain id
     * @param packetId_ packet id
     */
    function verifyRoot(
        address accumAddress_,
        uint256 remoteChainId_,
        uint256 packetId_
    ) external view override returns (bool, bytes32) {
        (bool isConfirmed, uint256 packetArrivedAt, bytes32 root) = notary
            .getPacketDetails(accumAddress_, remoteChainId_, packetId_);

        if (isConfirmed) return (true, root);
        if (packetArrivedAt == 0) return (false, root);

        // if timed out
        if (block.timestamp - packetArrivedAt > timeoutInSeconds)
            return (true, root);

        return (false, root);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

interface INotary {
    struct PacketDetails {
        bool isPaused;
        bytes32 remoteRoots;
        uint256 attestations;
        uint256 timeRecord;
    }

    enum PacketStatus {
        NOT_PROPOSED,
        PROPOSED,
        PAUSED,
        CONFIRMED
    }

    /**
     * @notice emits when a new signature verifier contract is set
     * @param signatureVerifier_ address of new verifier contract
     */
    event SignatureVerifierSet(address signatureVerifier_);

    /**
     * @notice emits the verification and seal confirmation of a packet
     * @param accumAddress address of accumulator at src
     * @param packetId packed id
     * @param signature signature of attester
     */
    event PacketVerifiedAndSealed(
        address indexed attester,
        address indexed accumAddress,
        uint256 indexed packetId,
        bytes signature
    );

    /**
     * @notice emits when a packet is challenged at src
     * @param attester address of packet attester
     * @param accumAddress address of accumulator at src
     * @param packetId packed id
     * @param challenger challenger address
     * @param rewardAmount amount slashed from attester is provided to challenger
     */
    event ChallengedSuccessfully(
        address indexed attester,
        address indexed accumAddress,
        uint256 indexed packetId,
        address challenger,
        uint256 rewardAmount
    );

    /**
     * @notice emits the packet details when proposed at destination
     * @param remoteChainId src chain id
     * @param accumAddress address of accumulator at src
     * @param packetId packed id
     */
    event Proposed(
        uint256 indexed remoteChainId,
        address indexed accumAddress,
        uint256 indexed packetId,
        bytes32 root
    );

    /**
     * @notice emits when a packet is unpaused by owner
     * @param accumAddress address of accumulator at src
     * @param packetId packed id
     */
    event PacketUnpaused(
        address indexed accumAddress,
        uint256 indexed packetId
    );

    /**
     * @notice emits when a packet is paused
     * @param accumAddress address of accumulator at src
     * @param packetId packed id
     * @param challenger challenger address
     */
    event PausedPacket(
        address indexed accumAddress,
        uint256 indexed packetId,
        address challenger
    );

    /**
     * @notice emits when a root is confirmed by attester at dest
     * @param attester address of packet attester
     * @param accumAddress address of accumulator at src
     * @param packetId packed id
     */
    event RootConfirmed(
        address indexed attester,
        address indexed accumAddress,
        uint256 indexed packetId,
        uint256 remoteChainId_
    );

    error InvalidAttester();

    error AlreadyProposed();

    error AttesterExists();

    error AttesterNotFound();

    error AccumAlreadyAdded();

    error AlreadyAttested();

    error NotFastPath();

    error PacketPaused();

    error PacketNotPaused();

    error ZeroAddress();

    error RootNotFound();

    /**
     * @notice verifies the attester and seals a packet
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ dest chain id
     * @param signature_ signature of attester
     */
    function verifyAndSeal(
        address accumAddress_,
        uint256 remoteChainId_,
        bytes calldata signature_
    ) external;

    /**
     * @notice challenges a packet at src if wrongly attested
     * @param accumAddress_ address of accumulator at src
     * @param root_ root hash of packet
     * @param packetId_ packed id
     * @param signature_ address of original attester
     */
    function challengeSignature(
        address accumAddress_,
        bytes32 root_,
        uint256 packetId_,
        bytes calldata signature_
    ) external;

    /**
     * @notice to propose a new packet
     * @param remoteChainId_ src chain id
     * @param accumAddress_ address of accumulator at src
     * @param packetId_ packed id
     * @param root_ root hash of packet
     * @param signature_ signature of proposer
     */
    function propose(
        uint256 remoteChainId_,
        address accumAddress_,
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external;

    /**
     * @notice to confirm a packet on destination
     * @dev depending on paths, it may be a requirement to have on-chain confirmations for a packet
     * @param remoteChainId_ src chain id
     * @param accumAddress_ address of accumulator at src
     * @param packetId_ packed id
     * @param root_ root hash of packet
     * @param signature_ signature of proposer
     */
    function confirmRoot(
        uint256 remoteChainId_,
        address accumAddress_,
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external;

    /**
     * @notice returns the root of given packet
     * @param remoteChainId_ dest chain id
     * @param accumAddress_ address of accumulator at src
     * @param packetId_ packed id
     * @return root_ root hash
     */
    function getRemoteRoot(
        uint256 remoteChainId_,
        address accumAddress_,
        uint256 packetId_
    ) external view returns (bytes32 root_);

    /**
     * @notice returns the packet status
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ src chain id
     * @param packetId_ packed id
     * @return status_ status as enum PacketStatus
     */
    function getPacketStatus(
        address accumAddress_,
        uint256 remoteChainId_,
        uint256 packetId_
    ) external view returns (PacketStatus status_);

    /**
     * @notice returns the packet details needed by verifier
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ src chain id
     * @param packetId_ packed id
     * @return isConfirmed true if has required confirmations
     * @return packetArrivedAt time at which packet was proposed
     * @return root root hash
     */
    function getPacketDetails(
        address accumAddress_,
        uint256 remoteChainId_,
        uint256 packetId_
    )
        external
        view
        returns (
            bool isConfirmed,
            uint256 packetArrivedAt,
            bytes32 root
        );
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

// deprecated
import "../interfaces/INotary.sol";
import "../utils/AccessControl.sol";
import "../interfaces/IAccumulator.sol";
import "../interfaces/ISignatureVerifier.sol";

// moved from interface
// function addBond() external payable;

//     function reduceBond(uint256 amount) external;

//     function unbondAttester() external;

//     function claimBond() external;

// contract BondedNotary is AccessControl(msg.sender) {
// event Unbonded(address indexed attester, uint256 amount, uint256 claimTime);

// event BondClaimed(address indexed attester, uint256 amount);

// event BondClaimDelaySet(uint256 delay);

// event MinBondAmountSet(uint256 amount);

//  error InvalidBondReduce();

// error UnbondInProgress();

// error ClaimTimeLeft();

// error InvalidBond();

//     uint256 private _minBondAmount;
//     uint256 private _bondClaimDelay;
//     uint256 private immutable _chainId;
//     ISignatureVerifier private _signatureVerifier;

//     // attester => bond amount
//     mapping(address => uint256) private _bonds;

//     struct UnbondData {
//         uint256 amount;
//         uint256 claimTime;
//     }
//     // attester => unbond data
//     mapping(address => UnbondData) private _unbonds;

//     // attester => accumAddress => packetId => sig hash
//     mapping(address => mapping(address => mapping(uint256 => bytes32)))
//         private _localSignatures;

//     // remoteChainId => accumAddress => packetId => root
//     mapping(uint256 => mapping(address => mapping(uint256 => bytes32)))
//         private _remoteRoots;

//     event BondAdded(
//          address indexed attester,
//          uint256 addAmount, // assuming native token
//          uint256 newBond
//     );

//     event BondReduced(
//          address indexed attester,
//          uint256 reduceAmount,
//          uint256 newBond
//     );

//     constructor(
//         uint256 minBondAmount_,
//         uint256 bondClaimDelay_,
//         uint256 chainId_,
//         address signatureVerifier_
//     ) {
//         _setMinBondAmount(minBondAmount_);
//         _setBondClaimDelay(bondClaimDelay_);
//         _setSignatureVerifier(signatureVerifier_);
//         _chainId = chainId_;
//     }

//     function addBond() external payable override {
//         _bonds[msg.sender] += msg.value;
//         emit BondAdded(msg.sender, msg.value, _bonds[msg.sender]);
//     }

//     function reduceBond(uint256 amount) external override {
//         uint256 newBond = _bonds[msg.sender] - amount;

//         if (newBond < _minBondAmount) revert InvalidBondReduce();

//         _bonds[msg.sender] = newBond;
//         emit BondReduced(msg.sender, amount, newBond);

//         payable(msg.sender).transfer(amount);
//     }

//     function unbondAttester() external override {
//         if (_unbonds[msg.sender].claimTime != 0) revert UnbondInProgress();

//         uint256 amount = _bonds[msg.sender];
//         uint256 claimTime = block.timestamp + _bondClaimDelay;

//         _bonds[msg.sender] = 0;
//         _unbonds[msg.sender] = UnbondData(amount, claimTime);

//         emit Unbonded(msg.sender, amount, claimTime);
//     }

//     function claimBond() external override {
//         if (_unbonds[msg.sender].claimTime > block.timestamp)
//             revert ClaimTimeLeft();

//         uint256 amount = _unbonds[msg.sender].amount;
//         _unbonds[msg.sender] = UnbondData(0, 0);
//         emit BondClaimed(msg.sender, amount);

//         payable(msg.sender).transfer(amount);
//     }

//     function minBondAmount() external view returns (uint256) {
//         return _minBondAmount;
//     }

//     function bondClaimDelay() external view returns (uint256) {
//         return _bondClaimDelay;
//     }

//     function signatureVerifier() external view returns (address) {
//         return address(_signatureVerifier);
//     }

//     function chainId() external view returns (uint256) {
//         return _chainId;
//     }

//     function getBond(address attester) external view returns (uint256) {
//         return _bonds[attester];
//     }

//     function isAttested(address, uint256) external view returns (bool) {
//         return true;
//     }

//     function getUnbondData(address attester)
//         external
//         view
//         returns (uint256, uint256)
//     {
//         return (_unbonds[attester].amount, _unbonds[attester].claimTime);
//     }

//     function setMinBondAmount(uint256 amount) external onlyOwner {
//         _setMinBondAmount(amount);
//     }

//     function setBondClaimDelay(uint256 delay) external onlyOwner {
//         _setBondClaimDelay(delay);
//     }

//     function setSignatureVerifier(address signatureVerifier_)
//         external
//         onlyOwner
//     {
//         _setSignatureVerifier(signatureVerifier_);
//     }

//     function verifyAndSeal(address accumAddress_, uint256 remoteChainId_, bytes calldata signature_)
//         external
//         override
//     {
//         (bytes32 root, uint256 packetId) = IAccumulator(accumAddress_)
//             .sealPacket();

//         bytes32 digest = keccak256(
//             abi.encode(_chainId, accumAddress_, packetId, root)
//         );
//         address attester = _signatureVerifier.recoverSigner(digest, signature_);

//         if (_bonds[attester] < _minBondAmount) revert InvalidBond();
//         _localSignatures[attester][accumAddress_][packetId] = keccak256(
//             signature_
//         );

//         emit PacketVerifiedAndSealed(attester, accumAddress_, packetId, signature_);
//     }

//     function challengeSignature(
//         address accumAddress_,
//         bytes32 root_,
//         uint256 packetId_,
//         bytes calldata signature_
//     ) external override {
//         bytes32 digest = keccak256(
//             abi.encode(_chainId, accumAddress_, packetId_, root_)
//         );
//         address attester = _signatureVerifier.recoverSigner(digest, signature_);
//         bytes32 oldSig = _localSignatures[attester][accumAddress_][packetId_];

//         if (oldSig != keccak256(signature_)) {
//             uint256 bond = _unbonds[attester].amount + _bonds[attester];
//             payable(msg.sender).transfer(bond);
//             emit ChallengedSuccessfully(
//                 attester,
//                 accumAddress_,
//                 packetId_,
//                 msg.sender,
//                 bond
//             );
//         }
//     }

//     function _setMinBondAmount(uint256 amount) private {
//         _minBondAmount = amount;
//         emit MinBondAmountSet(amount);
//     }

//     function _setBondClaimDelay(uint256 delay) private {
//         _bondClaimDelay = delay;
//         emit BondClaimDelaySet(delay);
//     }

//     function _setSignatureVerifier(address signatureVerifier_) private {
//         _signatureVerifier = ISignatureVerifier(signatureVerifier_);
//         emit SignatureVerifierSet(signatureVerifier_);
//     }

//     function propose(
//         uint256 remoteChainId_,
//         address accumAddress_,
//         uint256 packetId_,
//         bytes32 root_,
//         bytes calldata signature_
//     ) external override {
//         bytes32 digest = keccak256(
//             abi.encode(remoteChainId_, accumAddress_, packetId_, root_)
//         );
//         address attester = _signatureVerifier.recoverSigner(digest, signature_);

//         if (!_hasRole(_attesterRole(remoteChainId_), attester))
//             revert InvalidAttester();

//         if (_remoteRoots[remoteChainId_][accumAddress_][packetId_] != 0)
//             revert AlreadyProposed();

//         _remoteRoots[remoteChainId_][accumAddress_][packetId_] = root_;
//         emit Proposed(
//             remoteChainId_,
//             accumAddress_,
//             packetId_,
//             root_
//         );
//     }

//     function getRemoteRoot(
//         uint256 remoteChainId_,
//         address accumAddress_,
//         uint256 packetId_
//     ) external view override returns (bytes32) {
//         return _remoteRoots[remoteChainId_][accumAddress_][packetId_];
//     }

//     function grantAttesterRole(uint256 remoteChainId_, address attester_)
//         external
//         onlyOwner
//     {
//         _grantRole(_attesterRole(remoteChainId_), attester_);
//     }

//     function revokeAttesterRole(uint256 remoteChainId_, address attester_)
//         external
//         onlyOwner
//     {
//         _revokeRole(_attesterRole(remoteChainId_), attester_);
//     }

//     function _attesterRole(uint256 chainId_) internal pure returns (bytes32) {
//         return bytes32(chainId_);
//     }
// }

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface ISignatureVerifier {
    /**
     * @notice returns the address of signer recovered from input signature
     * @param remoteChainId_ destination chain id
     * @param accumAddress_ accumulator address
     * @param packetId_ packet id
     * @param root_ root hash of merkle tree
     * @param signature_ signature
     */
    function recoverSigner(
        uint256 remoteChainId_,
        address accumAddress_,
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external returns (address);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;
import "../interfaces/ISignatureVerifier.sol";

contract SignatureVerifier is ISignatureVerifier {
    error InvalidSigLength();

    /// @inheritdoc ISignatureVerifier
    function recoverSigner(
        uint256 remoteChainId_,
        address accumAddress_,
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external pure override returns (address signer) {
        bytes32 digest = keccak256(
            abi.encode(remoteChainId_, accumAddress_, packetId_, root_)
        );
        digest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", digest)
        );
        signer = _recoverSigner(digest, signature_);
    }

    /**
     * @notice returns the address of signer recovered from input signature
     */
    function _recoverSigner(bytes32 hash_, bytes memory signature_)
        private
        pure
        returns (address signer)
    {
        (bytes32 sigR, bytes32 sigS, uint8 sigV) = _splitSignature(signature_);

        // recovered signer is checked for the valid roles later
        signer = ecrecover(hash_, sigV, sigR, sigS);
    }

    /**
     * @notice splits the signature into v, r and s.
     */
    function _splitSignature(bytes memory signature_)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        if (signature_.length != 65) revert InvalidSigLength();
        assembly {
            r := mload(add(signature_, 0x20))
            s := mload(add(signature_, 0x40))
            v := byte(0, mload(add(signature_, 0x60)))
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/INotary.sol";
import "../utils/AccessControl.sol";
import "../interfaces/IAccumulator.sol";
import "../interfaces/ISignatureVerifier.sol";

contract AdminNotary is INotary, AccessControl(msg.sender) {
    uint256 private immutable _chainId;
    uint256 public slowAccumWaitTime;
    ISignatureVerifier public signatureVerifier;

    // attester => accumAddr + chainId + packetId => is attested
    mapping(address => mapping(uint256 => bool)) public isAttested;

    // chainId => total attesters registered
    mapping(uint256 => uint256) public totalAttestors;

    // accumAddr + chainId
    mapping(uint256 => bool) public isFast;

    // accumAddr + chainId + packetId
    mapping(uint256 => PacketDetails) private _packetDetails;

    constructor(
        address signatureVerifier_,
        uint256 chainId_,
        uint256 slowAccumWaitTime_
    ) {
        _chainId = chainId_;
        //TODO: limits for wait time
        slowAccumWaitTime = slowAccumWaitTime_;
        signatureVerifier = ISignatureVerifier(signatureVerifier_);
    }

    /// @inheritdoc INotary
    function verifyAndSeal(
        address accumAddress_,
        uint256 remoteChainId_,
        bytes calldata signature_
    ) external override {
        (bytes32 root, uint256 packetId) = IAccumulator(accumAddress_)
            .sealPacket();

        address attester = signatureVerifier.recoverSigner(
            _chainId,
            accumAddress_,
            packetId,
            root,
            signature_
        );

        if (!_hasRole(_attesterRole(remoteChainId_), attester))
            revert InvalidAttester();
        emit PacketVerifiedAndSealed(
            attester,
            accumAddress_,
            packetId,
            signature_
        );
    }

    /// @inheritdoc INotary
    function challengeSignature(
        address accumAddress_,
        bytes32 root_,
        uint256 packetId_,
        bytes calldata signature_
    ) external override {
        address attester = signatureVerifier.recoverSigner(
            _chainId,
            accumAddress_,
            packetId_,
            root_,
            signature_
        );
        bytes32 root = IAccumulator(accumAddress_).getRootById(packetId_);

        if (root == root_ && root != bytes32(0)) {
            emit ChallengedSuccessfully(
                attester,
                accumAddress_,
                packetId_,
                msg.sender,
                0
            );
        }
    }

    /// @inheritdoc INotary
    function propose(
        uint256 remoteChainId_,
        address accumAddress_,
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external override {
        uint256 packedId = _packWithPacketId(
            accumAddress_,
            remoteChainId_,
            packetId_
        );

        PacketDetails storage packedDetails = _packetDetails[packedId];
        if (packedDetails.remoteRoots != 0) revert AlreadyProposed();

        packedDetails.remoteRoots = root_;
        packedDetails.timeRecord = block.timestamp;

        _verifyAndUpdateAttestations(
            remoteChainId_,
            accumAddress_,
            packetId_,
            root_,
            signature_
        );

        emit Proposed(remoteChainId_, accumAddress_, packetId_, root_);
    }

    /// @inheritdoc INotary
    function confirmRoot(
        uint256 remoteChainId_,
        address accumAddress_,
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external override {
        uint256 packedId = _packWithPacketId(
            accumAddress_,
            remoteChainId_,
            packetId_
        );

        if (_packetDetails[packedId].isPaused) revert PacketPaused();
        if (_packetDetails[packedId].remoteRoots != root_)
            revert RootNotFound();

        address attester = _verifyAndUpdateAttestations(
            remoteChainId_,
            accumAddress_,
            packetId_,
            root_,
            signature_
        );

        emit RootConfirmed(attester, accumAddress_, packetId_, remoteChainId_);
    }

    function _verifyAndUpdateAttestations(
        uint256 remoteChainId_,
        address accumAddress_,
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) private returns (address attester) {
        attester = signatureVerifier.recoverSigner(
            remoteChainId_,
            accumAddress_,
            packetId_,
            root_,
            signature_
        );

        if (!_hasRole(_attesterRole(remoteChainId_), attester))
            revert InvalidAttester();

        uint256 packedId = _packWithPacketId(
            accumAddress_,
            remoteChainId_,
            packetId_
        );
        PacketDetails storage packedDetails = _packetDetails[packedId];

        if (isAttested[attester][packedId]) revert AlreadyAttested();

        isAttested[attester][packedId] = true;
        packedDetails.attestations++;
    }

    /// @inheritdoc INotary
    function getPacketStatus(
        address accumAddress_,
        uint256 remoteChainId_,
        uint256 packetId_
    ) public view override returns (PacketStatus status) {
        uint256 packedId = _packWithPacketId(
            accumAddress_,
            remoteChainId_,
            packetId_
        );
        uint256 accumId = _pack(accumAddress_, remoteChainId_);

        PacketDetails memory packet = _packetDetails[packedId];
        uint256 packetArrivedAt = packet.timeRecord;

        if (packetArrivedAt == 0) return PacketStatus.NOT_PROPOSED;

        // if paused at dest
        if (packet.isPaused) return PacketStatus.PAUSED;

        if (isFast[accumId]) {
            if (packet.attestations != totalAttestors[remoteChainId_])
                return PacketStatus.PROPOSED;
        } else {
            if (block.timestamp - packet.timeRecord < slowAccumWaitTime)
                return PacketStatus.PROPOSED;
        }

        return PacketStatus.CONFIRMED;
    }

    /// @inheritdoc INotary
    function getPacketDetails(
        address accumAddress_,
        uint256 remoteChainId_,
        uint256 packetId_
    )
        external
        view
        override
        returns (
            bool isConfirmed,
            uint256 packetArrivedAt,
            bytes32 root
        )
    {
        uint256 packedId = _packWithPacketId(
            accumAddress_,
            remoteChainId_,
            packetId_
        );
        PacketStatus status = getPacketStatus(
            accumAddress_,
            remoteChainId_,
            packetId_
        );

        if (status == PacketStatus.CONFIRMED) isConfirmed = true;
        PacketDetails memory packet = _packetDetails[packedId];
        root = packet.remoteRoots;
        packetArrivedAt = packet.timeRecord;
    }

    /**
     * @notice pauses the packet on destination
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ src chain id
     * @param packetId_ packed id
     * @param root_ root hash
     */
    function pausePacketOnDest(
        address accumAddress_,
        uint256 remoteChainId_,
        uint256 packetId_,
        bytes32 root_
    ) external onlyOwner {
        uint256 packedId = _packWithPacketId(
            accumAddress_,
            remoteChainId_,
            packetId_
        );
        PacketDetails storage packedDetails = _packetDetails[packedId];

        if (packedDetails.remoteRoots != root_) revert RootNotFound();
        if (packedDetails.isPaused) revert PacketPaused();

        packedDetails.isPaused = true;
        emit PausedPacket(accumAddress_, packetId_, msg.sender);
    }

    /**
     * @notice unpause the packet on destination
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ src chain id
     * @param packetId_ packed id
     */
    function acceptPausedPacket(
        address accumAddress_,
        uint256 remoteChainId_,
        uint256 packetId_
    ) external onlyOwner {
        uint256 packedId = _packWithPacketId(
            accumAddress_,
            remoteChainId_,
            packetId_
        );
        PacketDetails storage packedDetails = _packetDetails[packedId];

        if (!packedDetails.isPaused) revert PacketNotPaused();
        packedDetails.isPaused = false;
        emit PacketUnpaused(accumAddress_, packetId_);
    }

    /**
     * @notice adds an attester for `remoteChainId_` chain
     * @param remoteChainId_ dest chain id
     * @param attester_ attester address
     */
    function grantAttesterRole(uint256 remoteChainId_, address attester_)
        external
        onlyOwner
    {
        if (_hasRole(_attesterRole(remoteChainId_), attester_))
            revert AttesterExists();
        _grantRole(_attesterRole(remoteChainId_), attester_);
        totalAttestors[remoteChainId_]++;
    }

    /**
     * @notice removes an attester from `remoteChainId_` chain list
     * @param remoteChainId_ dest chain id
     * @param attester_ attester address
     */
    function revokeAttesterRole(uint256 remoteChainId_, address attester_)
        external
        onlyOwner
    {
        if (!_hasRole(_attesterRole(remoteChainId_), attester_))
            revert AttesterNotFound();
        _revokeRole(_attesterRole(remoteChainId_), attester_);
        totalAttestors[remoteChainId_]--;
    }

    function _setSignatureVerifier(address signatureVerifier_) private {
        signatureVerifier = ISignatureVerifier(signatureVerifier_);
        emit SignatureVerifierSet(signatureVerifier_);
    }

    function _attesterRole(uint256 chainId_) internal pure returns (bytes32) {
        return bytes32(chainId_);
    }

    /**
     * @notice returns the confirmations received by a packet
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ src chain id
     * @param packetId_ packed id
     */
    function getConfirmations(
        address accumAddress_,
        uint256 remoteChainId_,
        uint256 packetId_
    ) external view returns (uint256) {
        uint256 packedId = _packWithPacketId(
            accumAddress_,
            remoteChainId_,
            packetId_
        );
        return _packetDetails[packedId].attestations;
    }

    /**
     * @notice returns the remote root for given `packetId_`
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ src chain id
     * @param packetId_ packed id
     */
    function getRemoteRoot(
        uint256 remoteChainId_,
        address accumAddress_,
        uint256 packetId_
    ) external view override returns (bytes32) {
        uint256 packedId = _packWithPacketId(
            accumAddress_,
            remoteChainId_,
            packetId_
        );
        return _packetDetails[packedId].remoteRoots;
    }

    /**
     * @notice returns the current chain id
     */
    function chainId() external view returns (uint256) {
        return _chainId;
    }

    /**
     * @notice adds the accumulator
     * @param accumAddress_ address of accumulator at src
     * @param remoteChainId_ src chain id
     * @param isFast_ indicates the path for accumulator
     */
    function addAccumulator(
        address accumAddress_,
        uint256 remoteChainId_,
        bool isFast_
    ) external onlyOwner {
        uint256 accumId = _pack(accumAddress_, remoteChainId_);
        isFast[accumId] = isFast_;
    }

    /**
     * @notice updates signatureVerifier_
     * @param signatureVerifier_ address of Signature Verifier
     */
    function setSignatureVerifier(address signatureVerifier_)
        external
        onlyOwner
    {
        _setSignatureVerifier(signatureVerifier_);
    }

    function _packWithPacketId(
        address accumAddr_,
        uint256 chainId_,
        uint256 packetId_
    ) internal pure returns (uint256 packed) {
        packed =
            (uint256(uint160(accumAddr_)) << 96) |
            (chainId_ << 64) |
            packetId_;
    }

    function _unpackWithPacketId(uint256 accumId_)
        internal
        pure
        returns (
            address accumAddr_,
            uint256 chainId_,
            uint256 packetId_
        )
    {
        accumAddr_ = address(uint160(accumId_ >> 96));
        packetId_ = uint64(accumId_);
        chainId_ = uint32(accumId_ >> 64);
    }

    function _pack(address accumAddr_, uint256 chainId_)
        internal
        pure
        returns (uint256 packed)
    {
        packed = (uint256(uint160(accumAddr_)) << 32) | chainId_;
    }

    function _unpack(uint256 accumId_)
        internal
        pure
        returns (address accumAddr_, uint256 chainId_)
    {
        accumAddr_ = address(uint160(accumId_ >> 32));
        chainId_ = uint32(accumId_);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IAccumulator.sol";
import "../utils/AccessControl.sol";

abstract contract BaseAccum is IAccumulator, AccessControl(msg.sender) {
    bytes32 public constant SOCKET_ROLE = keccak256("SOCKET_ROLE");
    bytes32 public constant NOTARY_ROLE = keccak256("NOTARY_ROLE");

    /// an incrementing id for each new packet created
    uint256 internal _packets;
    uint256 internal _sealedPackets;

    /// maps the packet id with the root hash generated while adding message
    mapping(uint256 => bytes32) internal _roots;

    error NoPendingPacket();

    /**
     * @notice initialises the contract with socket and notary addresses
     */
    constructor(address socket_, address notary_) {
        _setSocket(socket_);
        _setNotary(notary_);
    }

    /// @inheritdoc IAccumulator
    function sealPacket()
        external
        virtual
        override
        onlyRole(NOTARY_ROLE)
        returns (bytes32, uint256)
    {
        uint256 packetId = _sealedPackets;

        if (_roots[packetId] == bytes32(0)) revert NoPendingPacket();
        bytes32 root = _roots[packetId];
        _sealedPackets++;

        emit PacketComplete(root, packetId);
        return (root, packetId);
    }

    function setSocket(address socket_) external onlyOwner {
        _setSocket(socket_);
    }

    function setNotary(address notary_) external onlyOwner {
        _setNotary(notary_);
    }

    function _setSocket(address socket_) private {
        _grantRole(SOCKET_ROLE, socket_);
    }

    function _setNotary(address notary_) private {
        _grantRole(NOTARY_ROLE, notary_);
    }

    /// returns the latest packet details to be sealed
    /// @inheritdoc IAccumulator
    function getNextPacketToBeSealed()
        external
        view
        virtual
        override
        returns (bytes32, uint256)
    {
        uint256 toSeal = _sealedPackets;
        return (_roots[toSeal], toSeal);
    }

    /// returns the root of packet for given id
    /// @inheritdoc IAccumulator
    function getRootById(uint256 id)
        external
        view
        virtual
        override
        returns (bytes32)
    {
        return _roots[id];
    }

    function getLatestPacketId() external view returns (uint256) {
        return _packets == 0 ? 0 : _packets - 1;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "./BaseAccum.sol";

contract SingleAccum is BaseAccum {
    error PendingPacket();

    /**
     * @notice initialises the contract with socket and notary addresses
     */
    constructor(address socket_, address notary_) BaseAccum(socket_, notary_) {}

    /// adds the packed message to a packet
    /// @inheritdoc IAccumulator
    function addPackedMessage(bytes32 packedMessage)
        external
        override
        onlyRole(SOCKET_ROLE)
    {
        uint256 packetId = _packets;
        _roots[packetId] = packedMessage;
        _packets++;

        emit MessageAdded(packedMessage, packetId, packedMessage);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../utils/Ownable.sol";
import "../interfaces/IVault.sol";

contract Vault is IVault, Ownable {
    constructor(address owner_) Ownable(owner_) {}

    /// @inheritdoc IVault
    function deductFee(uint256, uint256) external payable override {
        emit FeeDeducted(msg.value);
    }

    /// @inheritdoc IVault
    function claimFee(address account_, uint256 amount_)
        external
        override
        onlyOwner
    {
        (bool success, ) = account_.call{value: amount_}("");
        require(success, "Transfer failed.");
    }

    /// @inheritdoc IVault
    function getFees(uint256, uint256)
        external
        pure
        override
        returns (uint256)
    {
        return 0;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IPlug.sol";
import "../interfaces/ISocket.sol";
import "../interfaces/IVault.sol";

contract Messenger is IPlug {
    // immutables
    address private immutable _socket;
    uint256 private immutable _chainId;

    address private _owner;
    bytes32 private _message;
    uint256 public msgGasLimit;

    bytes32 private constant _PING = keccak256("PING");
    bytes32 private constant _PONG = keccak256("PONG");

    constructor(
        address socket_,
        uint256 chainId_,
        uint256 msgGasLimit_
    ) {
        _socket = socket_;
        _chainId = chainId_;
        _owner = msg.sender;

        msgGasLimit = msgGasLimit_;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "can only be called by owner");
        _;
    }

    function sendLocalMessage(bytes32 message_) external {
        _updateMessage(message_);
    }

    function sendRemoteMessage(uint256 destChainId_, bytes32 message_)
        external
        payable
    {
        bytes memory payload = abi.encode(_chainId, message_);
        _outbound(destChainId_, payload);
    }

    function inbound(bytes calldata payload_) external payable override {
        require(msg.sender == _socket, "Counter: Invalid Socket");
        (uint256 srcChainId, bytes32 msgDecoded) = abi.decode(
            payload_,
            (uint256, bytes32)
        );

        _updateMessage(msgDecoded);

        bytes memory newPayload = abi.encode(
            _chainId,
            msgDecoded == _PING ? _PONG : _PING
        );
        _outbound(srcChainId, newPayload);
    }

    // settings
    function setSocketConfig(
        uint256 remoteChainId_,
        address remotePlug_,
        address accum_,
        address deaccum_,
        address verifier_
    ) external onlyOwner {
        ISocket(_socket).setInboundConfig(
            remoteChainId_,
            remotePlug_,
            deaccum_,
            verifier_
        );
        ISocket(_socket).setOutboundConfig(remoteChainId_, remotePlug_, accum_);
    }

    function message() external view returns (bytes32) {
        return _message;
    }

    function _updateMessage(bytes32 message_) private {
        _message = message_;
    }

    function _outbound(uint256 targetChain_, bytes memory payload_) private {
        ISocket(_socket).outbound{value: msg.value}(
            targetChain_,
            msgGasLimit,
            payload_
        );
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IPlug.sol";
import "../interfaces/ISocket.sol";
import "../interfaces/IVault.sol";

contract Counter is IPlug {
    // immutables
    address public immutable socket;

    address public owner;

    // application state
    uint256 public counter;

    // application ops
    bytes32 constant OP_ADD = keccak256("OP_ADD");
    bytes32 constant OP_SUB = keccak256("OP_SUB");

    constructor(address _socket) {
        socket = _socket;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by owner");
        _;
    }

    function localAddOperation(uint256 amount) external {
        _addOperation(amount);
    }

    function localSubOperation(uint256 amount) external {
        _subOperation(amount);
    }

    function remoteAddOperation(
        uint256 chainId,
        uint256 amount,
        uint256 msgGasLimit
    ) external payable {
        bytes memory payload = abi.encode(OP_ADD, amount);
        _outbound(chainId, msgGasLimit, payload);
    }

    function remoteSubOperation(
        uint256 chainId,
        uint256 amount,
        uint256 msgGasLimit
    ) external payable {
        bytes memory payload = abi.encode(OP_SUB, amount);
        _outbound(chainId, msgGasLimit, payload);
    }

    function inbound(bytes calldata payload) external payable override {
        require(msg.sender == socket, "Counter: Invalid Socket");
        (bytes32 operationType, uint256 amount) = abi.decode(
            payload,
            (bytes32, uint256)
        );

        if (operationType == OP_ADD) {
            _addOperation(amount);
        } else if (operationType == OP_SUB) {
            _subOperation(amount);
        } else {
            revert("CounterMock: Invalid Operation");
        }
    }

    function _outbound(
        uint256 targetChain,
        uint256 msgGasLimit,
        bytes memory payload
    ) private {
        ISocket(socket).outbound{value: msg.value}(
            targetChain,
            msgGasLimit,
            payload
        );
    }

    //
    // base ops
    //
    function _addOperation(uint256 amount) private {
        counter += amount;
    }

    function _subOperation(uint256 amount) private {
        counter -= amount;
    }

    // settings
    function setSocketConfig(
        uint256 remoteChainId,
        address remotePlug,
        address accum,
        address deaccum,
        address verifier
    ) external onlyOwner {
        ISocket(socket).setInboundConfig(
            remoteChainId,
            remotePlug,
            deaccum,
            verifier
        );
        ISocket(socket).setOutboundConfig(remoteChainId, remotePlug, accum);
    }

    function setupComplete() external {
        owner = address(0);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../utils/Ownable.sol";

contract MockOwnable is Ownable {
    constructor(address owner) Ownable(owner) {}

    function ownerFunction() external onlyOwner {}

    function publicFunction() external {}
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../utils/AccessControl.sol";

contract MockAccessControl is AccessControl {
    bytes32 public constant ROLE_GIRAFFE = keccak256("ROLE_GIRAFFE");
    bytes32 public constant ROLE_HIPPO = keccak256("ROLE_HIPPO");

    constructor(address owner) AccessControl(owner) {}

    function giraffe() external onlyRole(ROLE_GIRAFFE) {}

    function hippo() external onlyRole(ROLE_HIPPO) {}

    function animal() external {}
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IHasher.sol";

contract Hasher is IHasher {
    /// @inheritdoc IHasher
    function packMessage(
        uint256 srcChainId,
        address srcPlug,
        uint256 dstChainId,
        address dstPlug,
        uint256 msgId,
        uint256 msgGasLimit,
        bytes calldata payload
    ) external pure override returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    srcChainId,
                    srcPlug,
                    dstChainId,
                    dstPlug,
                    msgId,
                    msgGasLimit,
                    payload
                )
            );
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IDeaccumulator.sol";

contract SingleDeaccum is IDeaccumulator {
    /// returns if the packed message is the part of a merkle tree or not
    /// @inheritdoc IDeaccumulator
    function verifyMessageInclusion(
        bytes32 root_,
        bytes32 packedMessage_,
        bytes calldata
    ) external pure override returns (bool) {
        return root_ == packedMessage_;
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.7;

/**
 * @title Version0
 * @notice Version getter for contracts
 **/
contract Version0 {
    uint8 public constant VERSION = 0;
}