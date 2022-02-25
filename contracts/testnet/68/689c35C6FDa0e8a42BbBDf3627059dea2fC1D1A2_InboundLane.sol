/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// Verified by Darwinia Network

// hevm: flattened sources of src/common/message/InboundLane.sol
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

////// src/common/message/InboundLaneVerifier.sol

/* pragma solidity ^0.8.0; */
/* pragma abicoder v2; */

/* import "../../interfaces/ILightClient.sol"; */

contract InboundLaneVerifier {
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

    function verify_messages_proof(
        bytes32 outlane_data_hash,
        bytes memory encoded_proof
    ) internal view {
        require(
            lightClient.verify_messages_proof(outlane_data_hash, thisChainPosition, bridgedLanePosition, encoded_proof),
            "Verifer: InvalidProof"
        );
    }

    function getLaneInfo() external view returns (uint32,uint32,uint32,uint32) {
        return (thisChainPosition,thisLanePosition,bridgedChainPosition,bridgedLanePosition);
    }

    // 32 bytes to identify an unique message from source chain
    // MessageKey encoding:
    // BridgedChainPosition | BridgedLanePosition | ThisChainPosition | ThisLanePosition | Nonce
    // [0..8)   bytes ---- Reserved
    // [8..12)  bytes ---- BridgedChainPosition
    // [16..20) bytes ---- BridgedLanePosition
    // [12..16) bytes ---- ThisChainPosition
    // [20..24) bytes ---- ThisLanePosition
    // [24..32) bytes ---- Nonce, max of nonce is `uint64(-1)`
    function encodeMessageKey(uint64 nonce) public view returns (uint256) {
        return (uint256(bridgedChainPosition) << 160) + (uint256(bridgedLanePosition) << 128) + (uint256(thisChainPosition) << 96) + (uint256(thisLanePosition) << 64) + uint256(nonce);
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

////// src/interfaces/ICrossChainFilter.sol

/* pragma solidity ^0.8.0; */

/**
 * @title A interface for message layer to filter unsafe message
 * @author echo
 * @notice The app layer must implement the interface `ICrossChainFilter`
 */
interface ICrossChainFilter {
    /**
     * @notice Verify the source sender and payload of source chain messages,
     * Generally, app layer cross-chain messages require validation of sourceAccount
     * @param bridgedChainPosition The source chain position which send the message
     * @param bridgedLanePosition The source lane position which send the message
     * @param sourceAccount The source contract address which send the message
     * @param payload The calldata which encoded by ABI Encoding
     * @return Can call target contract if returns true
     */
    function crossChainFilter(uint32 bridgedChainPosition, uint32 bridgedLanePosition, address sourceAccount, bytes calldata payload) external view returns (bool);
}

////// src/common/message/InboundLane.sol
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

/* import "../../interfaces/ICrossChainFilter.sol"; */
/* import "./InboundLaneVerifier.sol"; */
/* import "../spec/SourceChain.sol"; */
/* import "../spec/TargetChain.sol"; */

/**
 * @title Everything about incoming messages receival
 * @author echo
 * @notice The inbound lane is the message layer of the bridge
 * @dev See https://itering.notion.site/Basic-Message-Channel-c41f0c9e453c478abb68e93f6a067c52
 */
contract InboundLane is InboundLaneVerifier, SourceChain, TargetChain {
    /**
     * @notice Notifies an observer that the message has dispatched
     * @param thisChainPosition The thisChainPosition of the message
     * @param thisLanePosition The thisLanePosition of the message
     * @param bridgedChainPosition The bridgedChainPosition of the message
     * @param bridgedLanePosition The bridgedLanePosition of the message
     * @param nonce The message nonce
     * @param result The message result
     * @param returndata The return data of message call, when return false, it's the reason of the error
     */
    event MessageDispatched(uint32 thisChainPosition, uint32 thisLanePosition, uint32 bridgedChainPosition, uint32 bridgedLanePosition, uint64 nonce, bool result, bytes returndata);

    /* Constants */

    /**
     * @dev Gas used per message needs to be less than 100000 wei
     */
    uint256 public constant MAX_GAS_PER_MESSAGE = 100000;
    /**
     * @dev Gas buffer for executing `send_message` tx
     */
    uint256 public constant GAS_BUFFER = 3000;
    /**
     * @notice This parameter must lesser than 256
     * Maximal number of unconfirmed messages at inbound lane. Unconfirmed means that the
     * message has been delivered, but either confirmations haven't been delivered back to the
     * source chain, or we haven't received reward confirmations for these messages yet.
     *
     * This constant limits difference between last message from last entry of the
     * `InboundLaneData::relayers` and first message at the first entry.
     *
     * This value also represents maximal number of messages in single delivery transaction.
     * Transaction that is declaring more messages than this value, will be rejected. Even if
     * these messages are from different lanes.
     */
    uint256 public constant MAX_UNCONFIRMED_MESSAGES = 30;

    /* State */

    /**
     * @dev ID of the next message, which is incremented in strict order
     * @notice When upgrading the lane, this value must be synchronized
     */
    struct InboundLaneNonce {
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

        // Range of UnrewardedRelayers
        // Front index of the UnrewardedRelayers (inclusive).
        uint64 relayer_range_front;
        // Back index of the UnrewardedRelayers (inclusive).
        uint64 relayer_range_back;
    }

    // slot 1
    InboundLaneNonce public inboundLaneNonce;

    // slot 2
    // index => UnrewardedRelayer
    // indexes to relayers and messages that they have delivered to this lane (ordered by
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
    mapping(uint64 => UnrewardedRelayer) public relayers;

    uint256 internal locked;
    // --- Synchronization ---
    modifier nonReentrant {
        require(locked == 0, "Lane: locked");
        locked = 1;
        _;
        locked = 0;
    }

    /**
     * @notice Deploys the InboundLane contract
     * @param _lightClientBridge The contract address of on-chain light client
     * @param _thisChainPosition The thisChainPosition of inbound lane
     * @param _thisLanePosition The lanePosition of this inbound lane
     * @param _bridgedChainPosition The bridgedChainPosition of inbound lane
     * @param _bridgedLanePosition The lanePosition of target outbound lane
     * @param _last_confirmed_nonce The last_confirmed_nonce of inbound lane
     * @param _last_delivered_nonce The last_delivered_nonce of inbound lane
     */
    constructor(
        address _lightClientBridge,
        uint32 _thisChainPosition,
        uint32 _thisLanePosition,
        uint32 _bridgedChainPosition,
        uint32 _bridgedLanePosition,
        uint64 _last_confirmed_nonce,
        uint64 _last_delivered_nonce
    ) InboundLaneVerifier(_lightClientBridge, _thisChainPosition, _thisLanePosition, _bridgedChainPosition, _bridgedLanePosition) {
        inboundLaneNonce = InboundLaneNonce(_last_confirmed_nonce, _last_delivered_nonce, 1, 0);
    }

    /* Public Functions */

    // Receive messages proof from bridged chain.
    //
    // The weight of the call assumes that the transaction always brings outbound lane
    // state update. Because of that, the submitter (relayer) has no benefit of not including
    // this data in the transaction, so reward confirmations lags should be minimal.
    function receive_messages_proof(
        OutboundLaneData memory outboundLaneData,
        bytes[] memory messagesCallData,
        bytes memory messagesProof
    ) public nonReentrant {
        verify_messages_proof(hash(outboundLaneData), messagesProof);
        // Require there is enough gas to play all messages
        require(
            gasleft() >= outboundLaneData.messages.length * (MAX_GAS_PER_MESSAGE + GAS_BUFFER),
            "Lane: InsufficientGas"
        );
        receive_state_update(outboundLaneData.latest_received_nonce);
        receive_message(outboundLaneData.messages, messagesCallData);
    }

    function relayers_size() public view returns (uint64 size) {
        if (inboundLaneNonce.relayer_range_back >= inboundLaneNonce.relayer_range_front) {
            size = inboundLaneNonce.relayer_range_back - inboundLaneNonce.relayer_range_front + 1;
        }
    }

    function relayers_back() public view returns (address pre_relayer) {
        if (relayers_size() > 0) {
            uint64 back = inboundLaneNonce.relayer_range_back;
            pre_relayer = relayers[back].relayer;
        }
    }

	// Get lane data from the storage.
    function data() public view returns (InboundLaneData memory lane_data) {
        uint64 size = relayers_size();
        if (size > 0) {
            lane_data.relayers = new UnrewardedRelayer[](size);
            uint64 front = inboundLaneNonce.relayer_range_front;
            for (uint64 index = 0; index < size; index++) {
                lane_data.relayers[index] = relayers[front + index];
            }
        }
        lane_data.last_confirmed_nonce = inboundLaneNonce.last_confirmed_nonce;
        lane_data.last_delivered_nonce = inboundLaneNonce.last_delivered_nonce;
    }

    // commit lane data to the `commitment` storage.
    function commitment() external view returns (bytes32) {
        return hash(data());
    }

    /* Private Functions */

    // Receive state of the corresponding outbound lane.
    // Syncing state from SourceChain::OutboundLane, deal with nonce and relayers.
    function receive_state_update(uint64 latest_received_nonce) internal returns (uint64) {
        uint64 last_delivered_nonce = inboundLaneNonce.last_delivered_nonce;
        uint64 last_confirmed_nonce = inboundLaneNonce.last_confirmed_nonce;
        // SourceChain::OutboundLane::latest_received_nonce must less than or equal to TargetChain::InboundLane::last_delivered_nonce, otherwise it will receive the future nonce which has not delivery.
        // This should never happen if proofs are correct
        require(latest_received_nonce <= last_delivered_nonce, "Lane: InvalidReceivedNonce");
        if (latest_received_nonce > last_confirmed_nonce) {
            uint64 new_confirmed_nonce = latest_received_nonce;
            uint64 front = inboundLaneNonce.relayer_range_front;
            uint64 back = inboundLaneNonce.relayer_range_back;
            for (uint64 index = front; index <= back; index++) {
                UnrewardedRelayer storage entry = relayers[index];
                if (entry.messages.end <= new_confirmed_nonce) {
                    // Firstly, remove all of the records where higher nonce <= new confirmed nonce
                    delete relayers[index];
                    inboundLaneNonce.relayer_range_front = index + 1;
                } else if (entry.messages.begin <= new_confirmed_nonce) {
                    // Secondly, update the next record with lower nonce equal to new confirmed nonce if needed.
                    // Note: There will be max. 1 record to update as we don't allow messages from relayers to
                    // overlap.
                    entry.messages.dispatch_results >>= (new_confirmed_nonce + 1 - entry.messages.begin);
                    entry.messages.begin = new_confirmed_nonce + 1;
                }
            }
            inboundLaneNonce.last_confirmed_nonce = new_confirmed_nonce;
        }
        return latest_received_nonce;
    }

    // Receive new message.
    function receive_message(Message[] memory messages, bytes[] memory messagesCallData) internal returns (uint256 dispatch_results) {
        require(messages.length == messagesCallData.length, "Lane: InvalidLength");
        address relayer = msg.sender;
        uint64 begin = inboundLaneNonce.last_delivered_nonce + 1;
        uint64 next = begin;
        for (uint256 i = 0; i < messages.length; i++) {
            Message memory message = messages[i];
            MessageKey memory key = decodeMessageKey(message.encoded_key);
            MessagePayload memory message_payload = message.data;
            if (key.nonce < next) {
                continue;
            }
            // check message nonce is correct and increment nonce for replay protection
            require(key.nonce == next, "Lane: InvalidNonce");
            // check message is from the correct source chain position
            require(key.this_chain_id == bridgedChainPosition, "Lane: InvalidSourceChainId");
            // check message is from the correct source lane position
            require(key.this_lane_id == bridgedLanePosition, "Lane: InvalidSourceLaneId");
            // check message delivery to the correct target chain position
            require(key.bridged_chain_id == thisChainPosition, "Lane: InvalidTargetChainId");
            // check message delivery to the correct target lane position
            require(key.bridged_lane_id == thisLanePosition, "Lane: InvalidTargetLaneId");
            // if there are more unconfirmed messages than we may accept, reject this message
            require(next - inboundLaneNonce.last_confirmed_nonce <= MAX_UNCONFIRMED_MESSAGES, "Lane: TooManyUnconfirmedMessages");
            // check message call data is correct
            require(message_payload.encodedHash == keccak256(messagesCallData[i]));

            // update inbound lane nonce storage
            inboundLaneNonce.last_delivered_nonce = next;

            // then, dispatch message
            (bool dispatch_result, bytes memory returndata) = dispatch(message_payload, messagesCallData[i]);

            emit MessageDispatched(key.this_chain_id, key.this_lane_id, key.bridged_chain_id, key.bridged_lane_id, key.nonce, dispatch_result, returndata);
            dispatch_results |= (dispatch_result ? uint256(1) << (next - begin) : uint256(0));

            next += 1;
        }
        if (inboundLaneNonce.last_delivered_nonce >= begin) {
            uint64 end = inboundLaneNonce.last_delivered_nonce;
            // now let's update inbound lane storage
            address pre_relayer = relayers_back();
            if (pre_relayer == relayer) {
                UnrewardedRelayer storage r = relayers[inboundLaneNonce.relayer_range_back];
                r.messages.dispatch_results |= dispatch_results << (r.messages.end - r.messages.begin + 1);
                r.messages.end = end;
            } else {
                inboundLaneNonce.relayer_range_back += 1;
                relayers[inboundLaneNonce.relayer_range_back] = UnrewardedRelayer(relayer, DeliveredMessages(begin, end, dispatch_results));
            }
        }
    }

    function dispatch(MessagePayload memory payload, bytes memory encoded) internal returns (bool dispatch_result, bytes memory returndata) {
        bytes memory filterCallData = abi.encodeWithSelector(
            ICrossChainFilter.crossChainFilter.selector,
            bridgedChainPosition,
            bridgedLanePosition,
            payload.sourceAccount,
            encoded
        );
        bool canCall = filter(payload.targetContract, filterCallData);
        if (canCall) {
            // Deliver the message to the target
            (dispatch_result, returndata) = payload.targetContract.call{value: 0, gas: MAX_GAS_PER_MESSAGE}(encoded);
        } else {
            dispatch_result = false;
            returndata = "Lane: MessageCallRejected";
        }
    }

    function filter(address target, bytes memory encoded) internal view returns (bool canCall) {
        /**
         * @notice The app layer must implement the interface `ICrossChainFilter`
         */
        (bool ok, bytes memory result) = target.staticcall{gas: GAS_BUFFER}(encoded);
        if (ok) {
            if (result.length == 32) {
                canCall = abi.decode(result, (bool));
            }
        }
    }
}