/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// Verified by Darwinia Network

// hevm: flattened sources of src/common/message/OutboundLane.sol
// SPDX-License-Identifier: MIT
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

////// src/common/message/OutboundLaneVerifier.sol

/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

/* import "../../interfaces/ILightClient.sol"; */

contract OutboundLaneVerifier {
    /**
     * @dev The contract address of on-chain light client
     */
    ILightClient public immutable lightClient;

    /* State */
    // indentify slot
    // slot 0 ------------------------------------------------------------
    // @dev bridged lane position of the leaf in the `lane_message_merkle_tree`, index starting with 0
    uint32 public bridgedLanePosition;
    // @dev Bridged chain position of the leaf in the `chain_message_merkle_tree`, index starting with 0
    uint32 public bridgedChainPosition;
    // @dev This lane position of the leaf in the `lane_message_merkle_tree`, index starting with 0
    uint32 public thisLanePosition;
    // @dev This chain position of the leaf in the `chain_message_merkle_tree`, index starting with 0
    uint32 public thisChainPosition;

    // ------------------------------------------------------------------

    constructor(
        address _lightClient,
        uint32 _thisChainPosition,
        uint32 _thisLanePosition,
        uint32 _bridgedChainPosition,
        uint32 _bridgedLanePosition
    ) {
        lightClient = ILightClient(_lightClient);
        thisChainPosition = _thisChainPosition;
        thisLanePosition = _thisLanePosition;
        bridgedChainPosition = _bridgedChainPosition;
        bridgedLanePosition = _bridgedLanePosition;
    }

    /* Private Functions */

    function verify_messages_delivery_proof(
        bytes32 inlane_data_hash,
        bytes memory encoded_proof
    ) internal view {
        require(
            lightClient.verify_messages_delivery_proof(inlane_data_hash, thisChainPosition, bridgedLanePosition, encoded_proof),
            "Verifer: InvalidProof"
        );
    }

    function getLaneInfo() external view returns (uint32,uint32,uint32,uint32) {
        return (thisChainPosition,thisLanePosition,bridgedChainPosition,bridgedLanePosition);
    }

    // 32 bytes to identify an unique message from source chain
    // MessageKey encoding:
    // ThisChainPosition | ThisLanePosition | BridgedChainPosition | BridgedLanePosition | Nonce
    // [0..8)   bytes ---- Reserved
    // [8..12)  bytes ---- ThisChainPosition
    // [16..20) bytes ---- ThisLanePosition
    // [12..16) bytes ---- BridgedChainPosition
    // [20..24) bytes ---- BridgedLanePosition
    // [24..32) bytes ---- Nonce, max of nonce is `uint64(-1)`
    function encodeMessageKey(uint64 nonce) public view returns (uint256) {
        return (uint256(thisChainPosition) << 160) + (uint256(thisLanePosition) << 128) + (uint256(bridgedChainPosition) << 96) + (uint256(bridgedLanePosition) << 64) + uint256(nonce);
    }
}


////// src/common/spec/SourceChain.sol

/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

contract SourceChain {
    /**
     * The MessagePayload is the structure of RPC which should be delivery to target chain
     * @param sourceAccount The source contract address which send the message
     * @param targetContract The targe contract address which receive the message
     * @param encoded The calldata hash which encoded by ABI Encoding
     */
    struct MessagePayload {
        address sourceAccount;
        address targetContract;
        bytes32 encodedHash; /*keccak256(abi.encodePacked(SELECTOR, PARAMS))*/
    }

    // Message key (unique message identifier) as it is stored in the storage.
    struct MessageKey {
        // This chain position
        uint32 this_chain_id;
        // Position of the message this lane.
        uint32 this_lane_id;
        // Bridged chain position
        uint32 bridged_chain_id;
        // Position of the message bridged lane.
        uint32 bridged_lane_id;
        /// Nonce of the message.
        uint64 nonce;
    }

    // Message as it is stored in the storage.
    struct Message {
        // Encoded message key.
        uint256 encoded_key;
        // Message data.
        MessagePayload data;
    }

    // Outbound lane data.
    struct OutboundLaneData {
        // Nonce of the latest message, received by bridged chain.
        uint64 latest_received_nonce;
        // Messages sent through this lane.
        Message[] messages;
    }

    /**
     * Hash of the OutboundLaneData Schema
     * keccak256(abi.encodePacked(
     *     "OutboundLaneData(uint256 latest_received_nonce,bytes32 messages)"
     *     ")"
     * )
     */
    bytes32 internal constant OUTBOUNDLANEDATA_TYPEHASH = 0x82446a31771d975201a71d0d87c46edcb4996361ca06e16208c5a001081dee55;


    /**
     * Hash of the Message Schema
     * keccak256(abi.encodePacked(
     *     "Message(uint256 encoded_key,MessagePayload data)",
     *     "MessagePayload(address sourceAccount,address targetContract,bytes32 encodedHash)"
     *     ")"
     * )
     */
    bytes32 internal constant MESSAGE_TYPEHASH = 0xca848e08f0288bb043640602cbacf8a9ac0a76c6dfe33cb660daa49c55f1d537;

    /**
     * Hash of the MessageKey Schema
     * keccak256(abi.encodePacked(
     *     "MessageKey(uint32 this_chain_id,uint32 this_lane_id,uint32 bridged_chain_id,uint32 bridged_lane_id,uint64 nonce)"
     *     ")"
     * )
     */
    bytes32 internal constant MESSAGEKEY_TYPEHASH = 0x585f05d88bd03c64597258f8336daadecf668cb7b708cb320742d432114d13ac;

    /**
     * Hash of the MessagePayload Schema
     * keccak256(abi.encodePacked(
     *     "MessagePayload(address sourceAccount,address targetContract,bytes32 encodedHash)"
     *     ")"
     * )
     */
    bytes32 internal constant MESSAGEPAYLOAD_TYPEHASH = 0x870c0499a698e69972afc2f00023f601b894f5731a45364e4d3ed7fd7304d9c7;

    function hash(OutboundLaneData memory landData)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                OUTBOUNDLANEDATA_TYPEHASH,
                landData.latest_received_nonce,
                hash(landData.messages)
            )
        );
    }

    function hash(Message[] memory msgs)
        internal
        pure
        returns (bytes32)
    {
        bytes memory encoded = abi.encode(msgs.length);
        for (uint256 i = 0; i < msgs.length; i ++) {
            Message memory message = msgs[i];
            encoded = abi.encodePacked(
                encoded,
                abi.encode(
                    MESSAGE_TYPEHASH,
                    message.encoded_key,
                    hash(message.data)
                )
            );
        }
        return keccak256(encoded);
    }

    function hash(MessageKey memory key)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                MESSAGEKEY_TYPEHASH,
                key.this_chain_id,
                key.this_lane_id,
                key.bridged_chain_id,
                key.bridged_lane_id,
                key.nonce
            )
        );
    }

    function hash(MessagePayload memory payload)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                MESSAGEPAYLOAD_TYPEHASH,
                payload.sourceAccount,
                payload.targetContract,
                payload.encodedHash
            )
        );
    }

    function decodeMessageKey(uint256 encoded) public pure returns (MessageKey memory key) {
        key.this_chain_id = uint32(encoded >> 160);
        key.this_lane_id = uint32(encoded >> 128);
        key.bridged_chain_id = uint32(encoded >> 96);
        key.bridged_lane_id = uint32(encoded >> 64);
        key.nonce = uint64(encoded);
    }
}

////// src/common/spec/TargetChain.sol

/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

contract TargetChain {
    // Delivered messages with their dispatch result.
    struct DeliveredMessages {
        // Nonce of the first message that has been delivered (inclusive).
        uint64 begin;
        // Nonce of the last message that has been delivered (inclusive).
        uint64 end;
        // Dispatch result (`false`/`true`), returned by the message dispatcher for every
        // message in the `[end; begin]` range.
        // The `MAX_UNCONFIRMED_MESSAGES` parameter must lesser than 256 for gas saving
        uint256 dispatch_results;
    }

    // Unrewarded relayer entry stored in the inbound lane data.
    //
    // This struct represents a continuous range of messages that have been delivered by the same
    // relayer and whose confirmations are still pending.
    struct UnrewardedRelayer {
        // Address of the relayer.
        address relayer;
        // Messages range, delivered by this relayer.
        DeliveredMessages messages;
    }

    // Inbound lane data
    struct InboundLaneData {
        // Identifiers of relayers and messages that they have delivered to this lane (ordered by
        // message nonce).
        //
        // This serves as a helper storage item, to allow the source chain to easily pay rewards
        // to the relayers who successfully delivered messages to the target chain (inbound lane).
        //
        // All nonces in this queue are in
        // range: `(self.last_confirmed_nonce; self.last_delivered_nonce()]`.
        //
        // When a relayer sends a single message, both of begin and end nonce are the same.
        // When relayer sends messages in a batch, the first arg is the lowest nonce, second arg the
        // highest nonce. Multiple dispatches from the same relayer are allowed.
        UnrewardedRelayer[] relayers;
        // Nonce of the last message that
        // a) has been delivered to the target (this) chain and
        // b) the delivery has been confirmed on the source chain
        //
        // that the target chain knows of.
        //
        // This value is updated indirectly when an `OutboundLane` state of the source
        // chain is received alongside with new messages delivery.
        uint64 last_confirmed_nonce;
        // Nonce of the latest received or has been delivered message to this inbound lane.
        uint64 last_delivered_nonce;
    }

    /**
     * Hash of the InboundLaneData Schema
     * keccak256(abi.encodePacked(
     *     "InboundLaneData(UnrewardedRelayer[] relayers,uint64 last_confirmed_nonce,uint64 last_delivered_nonce)",
     *     "UnrewardedRelayer(address relayer,DeliveredMessages messages)",
     *     "DeliveredMessages(uint64 begin,uint64 end,uint256 dispatch_results)"
     *     ")"
     * )
     */
    bytes32 internal constant INBOUNDLANEDATA_TYPEHASH = 0x921cbc4091014b23df7eb9bbd83d71accebac7afad7c1344d8b581e63b929a86;

    /**
     * Hash of the UnrewardedRelayer Schema
     * keccak256(abi.encodePacked(
     *     "UnrewardedRelayer(address relayer,DeliveredMessages messages)"
     *     ")"
     * )
     */
    bytes32 internal constant UNREWARDEDRELAYER_TYPETASH = 0x5a4aa0af73c7f5d93a664d3d678d10103a266e77779c6809ea90b94851216106;

    /**
     * Hash of the DeliveredMessages Schema
     * keccak256(abi.encodePacked(
     *     "DeliveredMessages(uint64 begin,uint64 end,uint256 dispatch_results)"
     *     ")"
     * )
     */
    bytes32 internal constant DELIVEREDMESSAGES_TYPETASH = 0xaa6637cd9a4d6b5008a62cb1bef3d0ade9f8d8284cc2d4bf4eb1e15260726513;

    function hash(InboundLaneData memory inboundLaneData)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                INBOUNDLANEDATA_TYPEHASH,
                hash(inboundLaneData.relayers),
                inboundLaneData.last_confirmed_nonce
            )
        );
    }

    function hash(UnrewardedRelayer[] memory relayers)
        internal
        pure
        returns (bytes32)
    {
        bytes memory encoded = abi.encode(relayers.length);
        for (uint256 i = 0; i < relayers.length; i ++) {
            UnrewardedRelayer memory r = relayers[i];
            encoded = abi.encodePacked(
                encoded,
                abi.encode(
                    UNREWARDEDRELAYER_TYPETASH,
                    r.relayer,
                    hash(r.messages)
                )
            );
        }
        return keccak256(encoded);
    }

    function hash(DeliveredMessages memory messages)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                DELIVEREDMESSAGES_TYPETASH,
                messages.begin,
                messages.end,
                messages.dispatch_results
            )
        );
    }

}

////// src/interfaces/IFeeMarket.sol

/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

interface IFeeMarket {
    //  Relayer which delivery the messages
    struct DeliveredRelayer {
        // relayer account
        address relayer;
        // encoded message key begin
        uint256 begin;
        // encoded message key end
        uint256 end;
    }
    function market_fee() external view returns (uint256 fee);

    function assign(uint256 nonce) external payable returns(bool);
    function settle(DeliveredRelayer[] calldata delivery_relayers, address confirm_relayer) external returns(bool);
}

////// src/interfaces/IOnMessageDelivered.sol

/* pragma solidity ^0.8.0; */

/**
 * @title A interface for app layer to get message dispatch result
 * @author echo
 * @notice The app layer could implement the interface `IOnMessageDelivered` to receive message dispatch result (optionally)
 */
interface IOnMessageDelivered {
    /**
     * @notice Message delivered callback
     * @param nonce Nonce of the callback message
     * @param dispatch_result Dispatch result of cross chain message
     */
    function on_messages_delivered(uint256 nonce, bool dispatch_result) external;
}

////// src/interfaces/IOutboundLane.sol

/* pragma solidity ^0.8.0; */

interface IOutboundLane {
    function send_message(address targetContract, bytes calldata encoded) external payable returns (uint256);
}

////// src/common/message/OutboundLane.sol
// Message module that allows sending and receiving messages using lane concept:
//
// 1) the message is sent using `send_message()` call;
// 2) every outbound message is assigned nonce;
// 3) the messages are stored in the storage;
// 4) external component (relay) delivers messages to bridged chain;
// 5) messages are processed in order (ordered by assigned nonce);
// 6) relay may send proof-of-delivery back to this chain.
//
// Once message is sent, its progress can be tracked by looking at lane contract events.
// The assigned nonce is reported using `MessageAccepted` event. When message is
// delivered to the the bridged chain, it is reported using `MessagesDelivered` event.

/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

/* import "../../interfaces/IOutboundLane.sol"; */
/* import "../../interfaces/IOnMessageDelivered.sol"; */
/* import "../../interfaces/IFeeMarket.sol"; */
/* import "./OutboundLaneVerifier.sol"; */
/* import "../spec/SourceChain.sol"; */
/* import "../spec/TargetChain.sol"; */

// Everything about outgoing messages sending.
contract OutboundLane is IOutboundLane, OutboundLaneVerifier, TargetChain, SourceChain {
    event MessageAccepted(uint64 indexed nonce, bytes encoded);
    event MessagesDelivered(uint64 indexed begin, uint64 indexed end, uint256 results);
    event MessagePruned(uint64 indexed oldest_unpruned_nonce);
    event MessageFeeIncreased(uint64 indexed nonce, uint256 fee);
    event CallbackMessageDelivered(uint64 indexed nonce, bool result);
    event Rely(address indexed usr);
    event Deny(address indexed usr);

    uint256 internal constant MAX_GAS_PER_MESSAGE = 100000;
    uint256 internal constant MAX_CALLDATA_LENGTH = 4096;
    uint64 internal constant MAX_PENDING_MESSAGES = 30;
    uint64 internal constant MAX_PRUNE_MESSAGES_ATONCE = 5;

    // Outbound lane nonce.
    struct OutboundLaneNonce {
        // Nonce of the latest message, received by bridged chain.
        uint64 latest_received_nonce;
        // Nonce of the latest message, generated by us.
        uint64 latest_generated_nonce;
        // Nonce of the oldest message that we haven't yet pruned. May point to not-yet-generated
        // message if all sent messages are already pruned.
        uint64 oldest_unpruned_nonce;
    }

    /* State */

    // slot 1
    OutboundLaneNonce public outboundLaneNonce;

    // slot 2
    // nonce => MessagePayload
    mapping(uint64 => MessagePayload) public messages;

    // white list who can send meesage over lane, will remove in the future
    mapping (address => uint256) public wards;
    address public fee_market;
    address public setter;

    uint256 internal locked;
    // --- Synchronization ---
    modifier nonReentrant {
        require(locked == 0, "Lane: locked");
        locked = 1;
        _;
        locked = 0;
    }

    modifier auth {
        require(wards[msg.sender] == 1, "Lane: NotAuthorized");
        _;
    }

    modifier onlySetter {
        require(msg.sender == setter, "Lane: NotAuthorized");
        _;
    }

    /**
     * @notice Deploys the OutboundLane contract
     * @param _lightClientBridge The contract address of on-chain light client
     * @param _thisChainPosition The thisChainPosition of outbound lane
     * @param _thisLanePosition The lanePosition of this outbound lane
     * @param _bridgedChainPosition The bridgedChainPosition of outbound lane
     * @param _bridgedLanePosition The lanePosition of target inbound lane
     * @param _oldest_unpruned_nonce The oldest_unpruned_nonce of outbound lane
     * @param _latest_received_nonce The latest_received_nonce of outbound lane
     * @param _latest_generated_nonce The latest_generated_nonce of outbound lane
     */
    constructor(
        address _lightClientBridge,
        uint32 _thisChainPosition,
        uint32 _thisLanePosition,
        uint32 _bridgedChainPosition,
        uint32 _bridgedLanePosition,
        uint64 _oldest_unpruned_nonce,
        uint64 _latest_received_nonce,
        uint64 _latest_generated_nonce
    ) OutboundLaneVerifier(_lightClientBridge, _thisChainPosition, _thisLanePosition, _bridgedChainPosition, _bridgedLanePosition) {
        outboundLaneNonce = OutboundLaneNonce(_latest_received_nonce, _latest_generated_nonce, _oldest_unpruned_nonce);
        setter = msg.sender;
    }

    function rely(address usr) external onlySetter nonReentrant { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external onlySetter nonReentrant { wards[usr] = 0; emit Deny(usr); }

    function setFeeMarket(address _fee_market) external onlySetter nonReentrant {
        fee_market = _fee_market;
    }

    function changeSetter(address _setter) external onlySetter nonReentrant {
        setter = _setter;
    }

    /**
     * @notice Send message over lane.
     * Submitter could be a contract or just an EOA address.
     * At the beginning of the launch, submmiter is permission, after the system is stable it will be permissionless.
     * @param targetContract The target contract address which you would send cross chain message to
     * @param encoded The calldata which encoded by ABI Encoding
     */
    function send_message(address targetContract, bytes calldata encoded) external payable override auth nonReentrant returns (uint256) {
        require(outboundLaneNonce.latest_generated_nonce - outboundLaneNonce.latest_received_nonce <= MAX_PENDING_MESSAGES, "Lane: TooManyPendingMessages");
        require(outboundLaneNonce.latest_generated_nonce < type(uint64).max, "Lane: Overflow");
        uint64 nonce = outboundLaneNonce.latest_generated_nonce + 1;
        uint256 fee = msg.value;
        // assign the message to top relayers
        require(IFeeMarket(fee_market).assign{value: fee}(encodeMessageKey(nonce)), "Lane: AssignRelayersFailed");
        require(encoded.length <= MAX_CALLDATA_LENGTH, "Lane: Calldata is too large");
        outboundLaneNonce.latest_generated_nonce = nonce;
        messages[nonce] = MessagePayload({
            sourceAccount: msg.sender,
            targetContract: targetContract,
            encodedHash: keccak256(encoded)
        });

        // message sender prune at most `MAX_PRUNE_MESSAGES_ATONCE` messages
        prune_messages(MAX_PRUNE_MESSAGES_ATONCE);
        emit MessageAccepted(nonce, encoded);
        return encodeMessageKey(nonce);
    }

    // Receive messages delivery proof from bridged chain.
    function receive_messages_delivery_proof(
        InboundLaneData memory inboundLaneData,
        bytes memory messagesProof
    ) public nonReentrant {
        verify_messages_delivery_proof(hash(inboundLaneData), messagesProof);
        DeliveredMessages memory confirmed_messages = confirm_delivery(inboundLaneData);
        on_messages_delivered(confirmed_messages);
        // settle the confirmed_messages at fee market
        settle_messages(inboundLaneData.relayers, confirmed_messages.begin, confirmed_messages.end);
    }

    function message_size() public view returns (uint64 size) {
        size = outboundLaneNonce.latest_generated_nonce - outboundLaneNonce.latest_received_nonce;
    }

	// Get lane data from the storage.
    function data() public view returns (OutboundLaneData memory lane_data) {
        uint64 size = message_size();
        if (size > 0) {
            lane_data.messages = new Message[](size);
            uint64 begin = outboundLaneNonce.latest_received_nonce + 1;
            for (uint64 index = 0; index < size; index++) {
                uint64 nonce = index + begin;
                lane_data.messages[index] = Message(encodeMessageKey(nonce), messages[nonce]);
            }
        }
        lane_data.latest_received_nonce = outboundLaneNonce.latest_received_nonce;
    }

    // commit lane data to the `commitment` storage.
    function commitment() external view returns (bytes32) {
        return hash(data());
    }

    /* Private Functions */

    function extract_inbound_lane_info(InboundLaneData memory lane_data) internal pure returns (uint64 total_unrewarded_messages, uint64 last_delivered_nonce) {
        total_unrewarded_messages = lane_data.last_delivered_nonce - lane_data.last_confirmed_nonce;
        last_delivered_nonce = lane_data.last_delivered_nonce;
    }

    // Confirm messages delivery.
    function confirm_delivery(InboundLaneData memory inboundLaneData) internal returns (DeliveredMessages memory confirmed_messages) {
        (uint64 total_messages, uint64 latest_delivered_nonce) = extract_inbound_lane_info(inboundLaneData);
        require(total_messages < 256, "Lane: InvalidNumberOfMessages");

        UnrewardedRelayer[] memory relayers = inboundLaneData.relayers;
        OutboundLaneNonce memory nonce = outboundLaneNonce;
        require(latest_delivered_nonce > nonce.latest_received_nonce, "Lane: NoNewConfirmations");
        require(latest_delivered_nonce <= nonce.latest_generated_nonce, "Lane: FailedToConfirmFutureMessages");
        // that the relayer has declared correct number of messages that the proof contains (it
        // is checked outside of the function). But it may happen (but only if this/bridged
        // chain storage is corrupted, though) that the actual number of confirmed messages if
        // larger than declared.
        require(latest_delivered_nonce - nonce.latest_received_nonce <= total_messages, "Lane: TryingToConfirmMoreMessagesThanExpected");
        uint256 dispatch_results = extract_dispatch_results(nonce.latest_received_nonce, latest_delivered_nonce, relayers);
        uint64 prev_latest_received_nonce = nonce.latest_received_nonce;
        outboundLaneNonce.latest_received_nonce = latest_delivered_nonce;
        confirmed_messages = DeliveredMessages({
            begin: prev_latest_received_nonce + 1,
            end: latest_delivered_nonce,
            dispatch_results: dispatch_results
        });
        // emit 'MessagesDelivered' event
        emit MessagesDelivered(confirmed_messages.begin, confirmed_messages.end, confirmed_messages.dispatch_results);
    }

    // Extract new dispatch results from the unrewarded relayers vec.
    //
    // Revert if unrewarded relayers vec contains invalid data, meaning that the bridged
    // chain has invalid runtime storage.
    function extract_dispatch_results(uint64 prev_latest_received_nonce, uint64 latest_received_nonce, UnrewardedRelayer[] memory relayers) internal pure returns(uint256 received_dispatch_result) {
        // the only caller of this functions checks that the
        // prev_latest_received_nonce..=latest_received_nonce is valid, so we're ready to accept
        // messages in this range => with_capacity call must succeed here or we'll be unable to receive
        // confirmations at all
        uint64 last_entry_end = 0;
        uint64 padding = 0;
        for (uint64 i = 0; i < relayers.length; i++) {
            UnrewardedRelayer memory entry = relayers[i];
            // unrewarded relayer entry must have at least 1 unconfirmed message
            // (guaranteed by the `InboundLane::receive_message()`)
            require(entry.messages.end >= entry.messages.begin, "Lane: EmptyUnrewardedRelayerEntry");
            if (last_entry_end > 0) {
                uint64 expected_entry_begin = last_entry_end + 1;
                // every entry must confirm range of messages that follows previous entry range
                // (guaranteed by the `InboundLane::receive_message()`)
                require(entry.messages.begin == expected_entry_begin, "Lane: NonConsecutiveUnrewardedRelayerEntries");
            }
            last_entry_end = entry.messages.end;
            // entry can't confirm messages larger than `inbound_lane_data.latest_received_nonce()`
            // (guaranteed by the `InboundLane::receive_message()`)
			// technically this will be detected in the next loop iteration as
			// `InvalidNumberOfDispatchResults` but to guarantee safety of loop operations below
			// this is detected now
            require(entry.messages.end <= latest_received_nonce, "Lane: FailedToConfirmFutureMessages");
            // now we know that the entry is valid
            // => let's check if it brings new confirmations
            uint64 new_messages_begin = max(entry.messages.begin, prev_latest_received_nonce + 1);
            uint64 new_messages_end = min(entry.messages.end, latest_received_nonce);
            if (new_messages_end < new_messages_begin) {
                continue;
            }
            uint64 extend_begin = new_messages_begin - entry.messages.begin;
            uint256 hight_bits_opp = 255 - (new_messages_end - entry.messages.begin);
            // entry must have single dispatch result for every message
            // (guaranteed by the `InboundLane::receive_message()`)
            uint256 dispatch_results = (entry.messages.dispatch_results << hight_bits_opp) >> hight_bits_opp;
            // now we know that entry brings new confirmations
            // => let's extract dispatch results
            received_dispatch_result |= ((dispatch_results >> extend_begin) << padding);
            padding += (new_messages_end - new_messages_begin + 1 - extend_begin);
        }
    }

    function on_messages_delivered(DeliveredMessages memory confirmed_messages) internal {
        for (uint64 nonce = confirmed_messages.begin; nonce <= confirmed_messages.end; nonce ++) {
            uint256 offset = nonce - confirmed_messages.begin;
            bool dispatch_result = ((confirmed_messages.dispatch_results >> offset) & 1) > 0;
            // Submitter could be a contract or just an EOA address.
            address submitter = messages[nonce].sourceAccount;
            bytes memory deliveredCallbackData = abi.encodeWithSelector(
                IOnMessageDelivered.on_messages_delivered.selector,
                encodeMessageKey(nonce),
                dispatch_result
            );
            (bool ok,) = submitter.call{value: 0, gas: MAX_GAS_PER_MESSAGE}(deliveredCallbackData);
            emit CallbackMessageDelivered(nonce, ok);
        }
    }

    // Prune at most `max_messages_to_prune` already received messages.
    //
    // Returns number of pruned messages.
    function prune_messages(uint64 max_messages_to_prune) internal returns (uint64) {
        uint64 pruned_messages = 0;
        bool anything_changed = false;
        OutboundLaneNonce memory nonce = outboundLaneNonce;
        while (pruned_messages < max_messages_to_prune &&
            nonce.oldest_unpruned_nonce <= nonce.latest_received_nonce)
        {
            delete messages[nonce.oldest_unpruned_nonce];
            anything_changed = true;
            pruned_messages += 1;
            nonce.oldest_unpruned_nonce += 1;
        }
        if (anything_changed) {
            outboundLaneNonce = nonce;
            emit MessagePruned(outboundLaneNonce.oldest_unpruned_nonce);
        }
        return pruned_messages;
    }

    function settle_messages(UnrewardedRelayer[] memory relayers, uint64 received_start, uint64 received_end) internal {
        IFeeMarket.DeliveredRelayer[] memory delivery_relayers = new IFeeMarket.DeliveredRelayer[](relayers.length);
        for (uint256 i = 0; i < relayers.length; i++) {
            UnrewardedRelayer memory r = relayers[i];
            uint64 nonce_begin = max(r.messages.begin, received_start);
            uint64 nonce_end = min(r.messages.end, received_end);
            delivery_relayers[i] = IFeeMarket.DeliveredRelayer(r.relayer, encodeMessageKey(nonce_begin), encodeMessageKey(nonce_end));
        }
        require(IFeeMarket(fee_market).settle(delivery_relayers, msg.sender), "Lane: SettleFailed");
    }

    // --- Math ---
    function min(uint64 x, uint64 y) internal pure returns (uint64 z) {
        return x <= y ? x : y;
    }

    function max(uint64 x, uint64 y) internal pure returns (uint64 z) {
        return x >= y ? x : y;
    }
}