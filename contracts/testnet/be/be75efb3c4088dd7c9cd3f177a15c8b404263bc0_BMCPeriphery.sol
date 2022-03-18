// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./interfaces/IBSH.sol";
import "./interfaces/IBMCPeriphery.sol";
import "./interfaces/IBMCManagement.sol";
import "./libraries/ParseAddress.sol";
import "./libraries/RLPDecodeStruct.sol";
import "./libraries/RLPEncodeStruct.sol";
import "./libraries/String.sol";
import "./libraries/Types.sol";
import "./libraries/Utils.sol";
import "./libraries/DecodeBase64.sol";

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract BMCPeriphery is IBMCPeriphery, Initializable {
    using String for string;
    using DecodeBase64 for string;
    using ParseAddress for address;
    using RLPDecodeStruct for bytes;
    using RLPEncodeStruct for Types.BMCMessage;
    using RLPEncodeStruct for Types.Response;
    using Utils for uint256;

    uint256 internal constant UNKNOWN_ERR = 0;
    uint256 internal constant BMC_ERR = 10;
    uint256 internal constant BSH_ERR = 40;

    string private bmcBtpAddress; // a network address, i.e. btp://1234.pra/0xabcd
    address private bmcManagement;
    bytes[] internal msgs;

    function initialize(string memory _network, address _bmcManagementAddr)
        public
        initializer
    {
        bmcBtpAddress = string("btp://").concat(_network).concat("/").concat(
            address(this).toString()
        );
        bmcManagement = _bmcManagementAddr;
    }

    event Message(
        string _next, //  an address of the next BMC (it could be a destination BMC)
        uint256 _seq, //  a sequence number of BMC (NOT sequence number of BSH)
        bytes _msg
    );

    event ErrorMsg(
        string indexed _msg
    );

    // emit errors in BTP messages processing
    event ErrorOnBTPError(
        string _svc,
        int256 _sn,
        uint256 _code,
        string _errMsg,
        uint256 _svcErrCode,
        string _svcErrMsg
    );

    function getBmcBtpAddress() external view override returns (string memory) {
        return bmcBtpAddress;
    }

    /**
       @notice Verify and decode RelayMessage, and dispatch BTP Messages to registered BSHs
       @dev Caller must be a registered relayer.     
       @param _prev    BTP Address of the BMC generates the message
       @param _msg     base64 encoded string of serialized bytes of Relay Message refer RelayMessage structure
     */
    function handleRelayMessage(string calldata _prev, string calldata _msg)
        external
        override
    {
        bytes[] memory serializedMsgs = decodeMsgAndValidateRelay(_prev, _msg);

        // dispatch BTP Messages
        Types.BMCMessage memory _message;
        for (uint256 i = 0; i < serializedMsgs.length; i++) {
            try this.decodeBTPMessage(serializedMsgs[i]) returns (
                Types.BMCMessage memory _decoded
            ) {
                _message = _decoded;
            } catch {
                // ignore BTPMessage parse failure
                continue;
            }

            if (_message.dst.compareTo(bmcBtpAddress)) {
                handleMessage(_prev, _message);
            } else {
                (string memory _net, ) = _message.dst.splitBTPAddress();
                try IBMCManagement(bmcManagement).resolveRoute(_net) returns (
                    string memory _nextLink,
                    string memory
                ) {
                    _sendMessage(_nextLink, serializedMsgs[i]);
                } catch Error(string memory _error) {
                    _sendError(_prev, _message, BMC_ERR, _error);
                }
            }
        }
        IBMCManagement(bmcManagement).updateLinkRxSeq(
            _prev,
            serializedMsgs.length
        );
    }

    function decodeMsgAndValidateRelay(
        string calldata _prev,
        string calldata _msg
    ) internal returns (bytes[] memory) {
        // decode and verify relay message
        bytes[] memory serializedMsgs = handleRelayMessage(
            bmcBtpAddress,
            _prev,
            IBMCManagement(bmcManagement).getLinkRxSeq(_prev),
            _msg
        );

        // rotate and check valid relay
        /* address relay = IBMCManagement(bmcManagement).rotateRelay(
            _prev,
            block.number,
            block.number,
            serializedMsgs.length > 0
        ); */
        address relay = address(0);
        if (relay == address(0)) {
            address[] memory relays = IBMCManagement(bmcManagement)
                .getLinkRelays(_prev);
            bool check;
            for (uint256 i = 0; i < relays.length; i++)
                if (msg.sender == relays[i]) {
                    check = true;
                    break;
                }
            require(check, "BMCRevertUnauthorized: not registered relay");
            relay = msg.sender;
        } else if (relay != msg.sender)
            revert("BMCRevertUnauthorized: invalid relay");
        //TODO: change 0 to update latest block number by extending the relay message to include block number
        IBMCManagement(bmcManagement).updateRelayStats(
            relay,
            0,//TODO: change
            serializedMsgs.length
        );
        return serializedMsgs;
    }

    function handleRelayMessage(
        string memory _bmc,
        string memory _prev,
        uint256 _seq,
        string calldata _msg
    ) internal returns (bytes[] memory) {
        //bytes memory _serializedMsg = bytes(_msg);      
        bytes memory _serializedMsg = DecodeBase64.decode(_msg);
        bytes[] memory decodedMsgs = validateReceipt(_bmc, _prev, _seq, _serializedMsg);  // decode and verify relay message
        return decodedMsgs;
    }

     function validateReceipt(
        string memory _bmc,
        string memory _prev,
        uint256 _seq,
        bytes memory _serializedMsg
    ) internal returns (bytes[] memory) {
        uint256 nextSeq = _seq + 1;
        Types.MessageEvent memory messageEvent;
        Types.ReceiptProof[] memory receiptProofs = _serializedMsg
            .decodeReceiptProofs();
        if (msgs.length > 0) delete msgs;
        for (uint256 i = 0; i < receiptProofs.length; i++) {          
            for (uint256 j = 0; j < receiptProofs[i].events.length; j++) {
                messageEvent = receiptProofs[i].events[j];
                if (bytes(messageEvent.nextBmc).length != 0) {                    
                    if (messageEvent.seq > nextSeq) {
                        //string memory concat1 = string("RevertInvalidSequenceHigher, messageeventseq").concat(messageEvent.seq.toString()).concat(", nextseq").concat(nextSeq.toString());
                        revert("RevertInvalidSequenceHigher");
                    } else if (messageEvent.seq < nextSeq) {
                        //string memory concat1 = string("RevertInvalidSequence, messageeventseq").concat(messageEvent.seq.toString()).concat(", nextseq").concat(nextSeq.toString());
                        revert("RevertInvalidSequence");
                    } else if (messageEvent.nextBmc.compareTo(_bmc)) {
                        msgs.push(messageEvent.message);
                        nextSeq += 1;
                    } else {
                       emit ErrorMsg(string("RevertInvalidNextBmc:").concat(messageEvent.nextBmc).concat(" ,current bmc:").concat(_bmc));
                    }
                }
            }
        }
        return msgs;
    }

    //  @dev Despite this function was set as external, it should be called internally
    //  since Solidity does not allow using try_catch with internal function
    //  this solution can solve the issue
    function decodeBTPMessage(bytes memory _rlp)
        external
        pure
        returns (Types.BMCMessage memory)
    {
        return _rlp.decodeBMCMessage();
    }

    function handleMessage(string calldata _prev, Types.BMCMessage memory _msg)
        internal
    {
        address _bshAddr;
        if (_msg.svc.compareTo("bmc")) {
            Types.BMCService memory _sm;
            try this.tryDecodeBMCService(_msg.message) returns (
                Types.BMCService memory res
            ) {
                _sm = res;
            } catch {
                _sendError(_prev, _msg, BMC_ERR, "BMCRevertParseFailure");
                return;
            }

            if (_sm.serviceType.compareTo("FeeGathering")) {
                Types.GatherFeeMessage memory _gatherFee;
                try this.tryDecodeGatherFeeMessage(_sm.payload) returns (
                    Types.GatherFeeMessage memory res
                ) {
                    _gatherFee = res;
                } catch {
                    _sendError(_prev, _msg, BMC_ERR, "BMCRevertParseFailure");
                    return;
                }

                for (uint256 i = 0; i < _gatherFee.svcs.length; i++) {
                    _bshAddr = IBMCManagement(bmcManagement)
                        .getBshServiceByName(_gatherFee.svcs[i]);
                    //  If 'svc' not found, ignore
                    if (_bshAddr != address(0)) {
                        try
                            IBSH(_bshAddr).handleFeeGathering(
                                _gatherFee.fa,
                                _gatherFee.svcs[i]
                            )
                        {} catch {
                            //  If BSH contract throws a revert error, ignore and continue
                        }
                    }
                }
            } else if (_sm.serviceType.compareTo("Link")) {
                string memory _to = _sm.payload.decodePropagateMessage();
                Types.Link memory link = IBMCManagement(bmcManagement).getLink(
                    _prev
                );
                bool check;
                if (link.isConnected) {
                    for (uint256 i = 0; i < link.reachable.length; i++)
                        if (_to.compareTo(link.reachable[i])) {
                            check = true;
                            break;
                        }
                    if (!check) {
                        string[] memory _links = new string[](1);
                        _links[0] = _to;
                        IBMCManagement(bmcManagement).updateLinkReachable(
                            _prev,
                            _links
                        );
                    }
                }
            } else if (_sm.serviceType.compareTo("Unlink")) {
                string memory _to = _sm.payload.decodePropagateMessage();
                Types.Link memory link = IBMCManagement(bmcManagement).getLink(
                    _prev
                );
                if (link.isConnected) {
                    for (uint256 i = 0; i < link.reachable.length; i++) {
                        if (_to.compareTo(link.reachable[i]))
                            IBMCManagement(bmcManagement).deleteLinkReachable(
                                _prev,
                                i
                            );
                    }
                }
            } else if (_sm.serviceType.compareTo("Init")) {
                string[] memory _links = _sm.payload.decodeInitMessage();
                IBMCManagement(bmcManagement).updateLinkReachable(
                    _prev,
                    _links
                );
            } else if (_sm.serviceType.compareTo("Sack")) {
                // skip this case since it has been removed from internal services
            } else revert("BMCRevert: not exists internal handler");
        } else {
            _bshAddr = IBMCManagement(bmcManagement).getBshServiceByName(
                _msg.svc
            );
            if (_bshAddr == address(0)) {
                _sendError(_prev, _msg, BMC_ERR, "BMCRevertNotExistsBSH");
                return;
            }

            if (_msg.sn >= 0) {
                (string memory _net, ) = _msg.src.splitBTPAddress();
                try
                    IBSH(_bshAddr).handleBTPMessage(
                        _net,
                        _msg.svc,
                        uint256(_msg.sn),
                        _msg.message
                    )
                {} catch Error(string memory _error) {
                    /**
                     * @dev Uncomment revert to debug errors
                     */
                    //revert(_error);
                    _sendError(_prev, _msg, BSH_ERR, _error);
                }
            } else {
                Types.Response memory _errMsg = _msg.message.decodeResponse();
                try
                    IBSH(_bshAddr).handleBTPError(
                        _msg.src,
                        _msg.svc,
                        uint256(_msg.sn * -1),
                        _errMsg.code,
                        _errMsg.message
                    )
                {} catch Error(string memory _error) {
                    emit ErrorOnBTPError(
                        _msg.svc,
                        _msg.sn * -1,
                        _errMsg.code,
                        _errMsg.message,
                        BSH_ERR,
                        _error
                    );
                } catch (bytes memory _error) {
                    emit ErrorOnBTPError(
                        _msg.svc,
                        _msg.sn * -1,
                        _errMsg.code,
                        _errMsg.message,
                        UNKNOWN_ERR,
                        string(_error)
                    );
                }
            }
        }
    }

    //  @dev Solidity does not allow using try_catch with internal function
    //  Thus, work-around solution is the followings
    //  If there is any error throwing, BMC contract can catch it, then reply back a RC_ERR Response
    function tryDecodeBMCService(bytes calldata _msg)
        external
        pure
        returns (Types.BMCService memory)
    {
        return _msg.decodeBMCService();
    }

    function tryDecodeGatherFeeMessage(bytes calldata _msg)
        external
        pure
        returns (Types.GatherFeeMessage memory)
    {
        return _msg.decodeGatherFeeMessage();
    }

    function _sendMessage(string memory _to, bytes memory _serializedMsg)
        internal
    {
        IBMCManagement(bmcManagement).updateLinkTxSeq(_to);
        emit Message(
            _to,
            IBMCManagement(bmcManagement).getLinkTxSeq(_to),
            _serializedMsg
        );
    }

    function _sendError(
        string calldata _prev,
        Types.BMCMessage memory _message,
        uint256 _errCode,
        string memory _errMsg
    ) internal {
        if (_message.sn > 0) {
            bytes memory _serializedMsg = Types
                .BMCMessage(
                    bmcBtpAddress,
                    _message.src,
                    _message.svc,
                    _message.sn * -1,
                    Types.Response(_errCode, _errMsg).encodeResponse()
                )
                .encodeBMCMessage();
            _sendMessage(_prev, _serializedMsg);
        }
    }

    /**
       @notice Send the message to a specific network.
       @dev Caller must be an registered BSH.
       @param _to      Network Address of destination network
       @param _svc     Name of the service
       @param _sn      Serial number of the message, it should be positive
       @param _msg     Serialized bytes of Service Message
    */
    function sendMessage(
        string memory _to,
        string memory _svc,
        uint256 _sn,
        bytes memory _msg
    ) external override {
        require(
            msg.sender == bmcManagement ||
                IBMCManagement(bmcManagement).getBshServiceByName(_svc) ==
                msg.sender,
            "BMCRevertUnauthorized"
        );
        require(_sn >= 0, "BMCRevertInvalidSN");
        //  In case BSH sends a REQUEST_COIN_TRANSFER,
        //  but '_to' is a network which is not supported by BMC
        //  revert() therein
        (string memory _nextLink, string memory _dst) = IBMCManagement(
            bmcManagement
        ).resolveRoute(_to);
        bytes memory _rlp = Types
            .BMCMessage(bmcBtpAddress, _dst, _svc, int256(_sn), _msg)
            .encodeBMCMessage();
        _sendMessage(_nextLink, _rlp);
    }

    /*
       @notice Get status of BMC.
       @param _link        BTP Address of the connected BMC.
       @return tx_seq       Next sequence number of the next sending message.
       @return rx_seq       Next sequence number of the message to receive.
       @return verifier     VerifierStatus Object contains status information of the BMV.
    */
    function getStatus(string calldata _link)
        public
        view
        override
        returns (Types.LinkStats memory _linkStats)
    {
        Types.Link memory link = IBMCManagement(bmcManagement).getLink(_link);
        require(link.isConnected == true, "BMCRevertNotExistsLink");
        Types.RelayStats[] memory _relays = IBMCManagement(bmcManagement)
            .getRelayStatusByLink(_link);
        (string memory _net, ) = _link.splitBTPAddress();
        uint256 _rotateTerm = link.maxAggregation.getRotateTerm(
            link.blockIntervalSrc.getScale(link.blockIntervalDst)
        );
        return
            Types.LinkStats(
                link.rxSeq,
                link.txSeq,
                Types.VerifierStats(0, 0, 0, ""),//dummy
                _relays,
                link.relayIdx,
                link.rotateHeight,
                _rotateTerm,
                link.delayLimit,
                link.maxAggregation,
                link.rxHeightSrc,
                link.rxHeight,
                link.blockIntervalSrc,
                link.blockIntervalDst,
                block.number
            );
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;

import "./String.sol";

library Utils {
    using String for string;

    /**
    @notice this function return a ceiling value of division
    @dev No need to check validity of num2 (num2 != 0)
    @dev It is checked before calling this function
    */
    function ceilDiv(uint256 num1, uint256 num2)
        internal
        pure
        returns (uint256)
    {
        if (num1 % num2 == 0) {
            return num1 / num2;
        }
        return (num1 / num2) + 1;
    }

    function getScale(uint256 _blockIntervalSrc, uint256 _blockIntervalDst)
        internal
        pure
        returns (uint256)
    {
        if (_blockIntervalSrc < 1 || _blockIntervalDst < 1) {
            return 0;
        }
        return ceilDiv(_blockIntervalSrc * 10**6, _blockIntervalDst);
    }

    function getRotateTerm(uint256 _maxAggregation, uint256 _scale)
        internal
        pure
        returns (uint256)
    {
        if (_scale > 0) {
            return ceilDiv(_maxAggregation * 10**6, _scale);
        }
        return 0;
    }

    function remove(string[] storage arr, string memory _str) internal {
        for (uint256 i = 0; i < arr.length; i++)
            if (arr[i].compareTo(_str)) {
                arr[i] = arr[arr.length - 1];
                arr.pop();
                break;
            }
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;

library Types {
    /**
     * @Notice List of ALL Struct being used to Encode and Decode RLP Messages
     */

    //  SPR = State Hash + Pathch Receipt Hash + Receipt Hash
    struct SPR {
        bytes stateHash;
        bytes patchReceiptHash;
        bytes receiptHash;
    }

    struct BlockHeader {
        uint256 version;
        uint256 height;
        uint256 timestamp;
        bytes proposer;
        bytes prevHash;
        bytes voteHash;
        bytes nextValidators;
        bytes patchTxHash;
        bytes txHash;
        bytes logsBloom;
        SPR spr;
        bool isSPREmpty; //  add to check whether SPR is an empty struct, not include in RLP thereafter
    }

    //  TS = Timestamp + Signature
    struct TS {
        uint256 timestamp;
        bytes signature;
    }

    //  BPSI = blockPartSetID
    struct BPSI {
        uint256 n;
        bytes b;
    }

    struct Votes {
        uint256 round;
        BPSI blockPartSetID;
        TS[] ts;
    }

    struct BlockWitness {
        uint256 height;
        bytes[] witnesses;
    }

    struct EventProof {
        uint256 index;
        bytes[] eventMptNode;
    }

    struct BlockUpdate {
        BlockHeader bh;
        Votes votes;
        bytes[] validators;
    }

    struct ReceiptProof {
        uint256 index;
        MessageEvent[] events;
        uint256 height;
    }

    struct BlockProof {
        BlockHeader bh;
        BlockWitness bw;
    }

    struct RelayMessage {
        BlockUpdate[] buArray;
        BlockProof bp;
        bool isBPEmpty; //  add to check in a case BlockProof is an empty struct
        //  when RLP RelayMessage, this field will not be serialized
        ReceiptProof[] rp;
        bool isRPEmpty; //  add to check in a case ReceiptProof is an empty struct
        //  when RLP RelayMessage, this field will not be serialized
    }

    /**
     * @Notice List of ALL Structs being used by a BSH contract
     */
    enum ServiceType {
        REQUEST_COIN_TRANSFER,
        REQUEST_COIN_REGISTER,
        REPONSE_HANDLE_SERVICE,
        UNKNOWN_TYPE
    }

    struct PendingTransferCoin {
        string from;
        string to;
        string coinName;
        uint256 value;
        uint256 fee;
    }

    struct TransferCoin {
        string from;
        string to;
        Asset[] assets;
    }

    struct Asset {
        string coinName;
        uint256 value;
    }

    struct AssetTransferDetail {
        string coinName;
        uint256 value;
        uint256 fee;
    }

    struct RegisterCoin {
        string coinName;
        uint256 id;
        string symbol;
    }

    struct Response {
        uint256 code;
        string message;
    }

    struct ServiceMessage {
        ServiceType serviceType;
        bytes data;
    }

    struct Coin {
        uint256 id;
        string symbol;
        uint256 decimals;
    }

    struct Balance {
        uint256 lockedBalance;
        uint256 refundableBalance;
    }

    struct Request {
        string serviceName;
        address bsh;
    }

    /**
     * @Notice List of ALL Structs being used by a BMC contract
     */
    struct VerifierStats {
        uint256 heightMTA; // MTA = Merkle Trie Accumulator
        uint256 offsetMTA;
        uint256 lastHeight; // Block height of last verified message which is BTP-Message contained
        bytes extra;
    }

    struct Service {
        string svc;
        address addr;
    }

    struct Verifier {
        string net;
        address addr;
    }

    struct Route {
        string dst; //  BTP Address of destination BMC
        string next; //  BTP Address of a BMC before reaching dst BMC
    }

    struct Link {
        address[] relays; //  Address of multiple Relays handle for this link network
        string[] reachable; //  A BTP Address of the next BMC that can be reach using this link
        uint256 rxSeq;
        uint256 txSeq;
        uint256 blockIntervalSrc;
        uint256 blockIntervalDst;
        uint256 maxAggregation;
        uint256 delayLimit;
        uint256 relayIdx;
        uint256 rotateHeight;
        uint256 rxHeight;
        uint256 rxHeightSrc;
        bool isConnected;
    }

    struct LinkStats {
        uint256 rxSeq;
        uint256 txSeq;
        VerifierStats verifier;
        RelayStats[] relays;
        uint256 relayIdx;
        uint256 rotateHeight;
        uint256 rotateTerm;
        uint256 delayLimit;
        uint256 maxAggregation;
        uint256 rxHeightSrc;
        uint256 rxHeight;
        uint256 blockIntervalSrc;
        uint256 blockIntervalDst;
        uint256 currentHeight;
    }

    struct RelayStats {
        address addr;
        uint256 blockCount;
        uint256 msgCount;
    }

    struct BMCMessage {
        string src; //  an address of BMC (i.e. btp://1234.PARA/0x1234)
        string dst; //  an address of destination BMC
        string svc; //  service name of BSH
        int256 sn; //  sequence number of BMC
        bytes message; //  serialized Service Message from BSH
    }

    struct BMCService {
        string serviceType;
        bytes payload;
    }

    struct GatherFeeMessage {
        string fa; //  BTP address of Fee Aggregator
        string[] svcs; //  a list of services
    }

    struct Tuple {
        string _prev;
        string _to;
    }
    
    struct MessageEvent {
        string nextBmc;
        uint256 seq;
        bytes message;
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;

/**
 * String Library
 *
 * This is a simple library of string functions which try to simplify
 * string operations in solidity.
 *
 * Please be aware some of these functions can be quite gas heavy so use them only when necessary
 *
 * The original library was modified. If you want to know more about the original version
 * please check this link: https://github.com/willitscale/solidity-util.git
 */
library String {
    /**
     * splitBTPAddress
     *
     * Split the BTP Address format i.e. btp://1234.iconee/0x123456789
     * into Network_address (1234.iconee) and Server_address (0x123456789)
     *
     * @param _base String base BTP Address format to be split
     * @dev _base must follow a BTP Address format
     *
     * @return string, string   The resulting strings of Network_address and Server_address
     */
    function splitBTPAddress(string memory _base)
        internal
        pure
        returns (string memory, string memory)
    {
        string[] memory temp = split(_base, "/");
        return (temp[2], temp[3]);
    }

    /**
     * Concat
     *
     * Appends two strings together and returns a new value
     *
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string which will be the concatenated
     *              prefix
     * @param _value The value to be the concatenated suffix
     * @return string The resulting string from combinging the base and value
     */
    function concat(string memory _base, string memory _value)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(_base, _value));
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string
     *
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function indexOf(string memory _base, string memory _value)
        internal
        pure
        returns (int256)
    {
        return _indexOf(_base, _value, 0);
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string starting
     * from a defined offset
     *
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @param _offset The starting point to start searching from which can start
     *                from 0, but must not exceed the length of the string
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function _indexOf(
        string memory _base,
        string memory _value,
        uint256 _offset
    ) internal pure returns (int256) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for (uint256 i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int256(i);
            }
        }

        return -1;
    }

    /**
     * Length
     *
     * Returns the length of the specified string
     *
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string to be measured
     * @return uint The length of the passed string
     */
    function length(string memory _base) internal pure returns (uint256) {
        bytes memory _baseBytes = bytes(_base);
        return _baseBytes.length;
    }

    /*
     * String Split (Very high gas cost)
     *
     * Splits a string into an array of strings based off the delimiter value.
     * Please note this can be quite a gas expensive function due to the use of
     * storage so only use if really required.
     *
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string value to be split.
     * @param _value The delimiter to split the string on which must be a single
     *               character
     * @return string[] An array of values split based off the delimiter, but
     *                  do not container the delimiter.
     */
    function split(string memory _base, string memory _value)
        internal
        pure
        returns (string[] memory splitArr)
    {
        bytes memory _baseBytes = bytes(_base);

        uint256 _offset = 0;
        uint256 _splitsCount = 1;
        while (_offset < _baseBytes.length - 1) {
            int256 _limit = _indexOf(_base, _value, _offset);
            if (_limit == -1) break;
            else {
                _splitsCount++;
                _offset = uint256(_limit) + 1;
            }
        }

        splitArr = new string[](_splitsCount);

        _offset = 0;
        _splitsCount = 0;
        while (_offset < _baseBytes.length - 1) {
            int256 _limit = _indexOf(_base, _value, _offset);
            if (_limit == -1) {
                _limit = int256(_baseBytes.length);
            }

            string memory _tmp = new string(uint256(_limit) - _offset);
            bytes memory _tmpBytes = bytes(_tmp);

            uint256 j = 0;
            for (uint256 i = _offset; i < uint256(_limit); i++) {
                _tmpBytes[j++] = _baseBytes[i];
            }
            _offset = uint256(_limit) + 1;
            splitArr[_splitsCount++] = string(_tmpBytes);
        }
        return splitArr;
    }

    /**
     * Compare To
     *
     * Compares the characters of two strings, to ensure that they have an
     * identical footprint
     *
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string base to compare against
     * @param _value The string the base is being compared to
     * @return bool Simply notates if the two string have an equivalent
     */
    function compareTo(string memory _base, string memory _value)
        internal
        pure
        returns (bool)
    {
        if (
            keccak256(abi.encodePacked(_base)) ==
            keccak256(abi.encodePacked(_value))
        ) {
            return true;
        }
        return false;
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./RLPEncode.sol";
import "./Types.sol";

library RLPEncodeStruct {
    using RLPEncode for bytes;
    using RLPEncode for string;
    using RLPEncode for uint256;
    using RLPEncode for int256;
    using RLPEncode for address;

    using RLPEncodeStruct for Types.BlockHeader;
    using RLPEncodeStruct for Types.BlockWitness;
    using RLPEncodeStruct for Types.BlockUpdate;
    using RLPEncodeStruct for Types.BlockProof;
    using RLPEncodeStruct for Types.EventProof;
    using RLPEncodeStruct for Types.ReceiptProof;
    using RLPEncodeStruct for Types.Votes;
    using RLPEncodeStruct for Types.RelayMessage;

    uint8 internal constant LIST_SHORT_START = 0xc0;
    uint8 internal constant LIST_LONG_START = 0xf7;

    function encodeBMCService(Types.BMCService memory _bs)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp =
            abi.encodePacked(_bs.serviceType.encodeString(), _bs.payload);
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeGatherFeeMessage(Types.GatherFeeMessage memory _gfm)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp;
        bytes memory temp;
        for (uint256 i = 0; i < _gfm.svcs.length; i++) {
            temp = _gfm.svcs[i].encodeString();
            _rlp = abi.encodePacked(_rlp, temp);
        }
        _rlp = abi.encodePacked(
            _gfm.fa.encodeString(),
            addLength(_rlp.length, false),
            _rlp
        );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeRegisterCoin(Types.RegisterCoin memory _rc)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp =
            abi.encodePacked(
                _rc.coinName.encodeString(),
                _rc.id.encodeUint(),
                _rc.symbol.encodeString()
            );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeBMCMessage(Types.BMCMessage memory _bm)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp =
            abi.encodePacked(
                _bm.src.encodeString(),
                _bm.dst.encodeString(),
                _bm.svc.encodeString(),
                _bm.sn.encodeInt(),
                _bm.message.encodeBytes()
            );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeServiceMessage(Types.ServiceMessage memory _sm)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp =
            abi.encodePacked(
                uint256(_sm.serviceType).encodeUint(),
                _sm.data.encodeBytes()
            );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeTransferCoinMsg(Types.TransferCoin memory _data)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp;
        bytes memory temp;
        for (uint256 i = 0; i < _data.assets.length; i++) {
            temp = abi.encodePacked(
                _data.assets[i].coinName.encodeString(),
                _data.assets[i].value.encodeUint()
            );
            _rlp = abi.encodePacked(_rlp, addLength(temp.length, false), temp);
        }
        _rlp = abi.encodePacked(
            _data.from.encodeString(),
            _data.to.encodeString(),
            addLength(_rlp.length, false),
            _rlp
        );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeResponse(Types.Response memory _res)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp =
            abi.encodePacked(
                _res.code.encodeUint(),
                _res.message.encodeString()
            );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeBlockHeader(Types.BlockHeader memory _bh)
        internal
        pure
        returns (bytes memory)
    {
        // Serialize the first 10 items in the BlockHeader
        //  patchTxHash and txHash might be empty.
        //  In that case, encoding these two items gives the result as 0xF800
        //  Similarly, logsBloom might be also empty
        //  But, encoding this item gives the result as 0x80
        bytes memory _rlp =
            abi.encodePacked(
                _bh.version.encodeUint(),
                _bh.height.encodeUint(),
                _bh.timestamp.encodeUint(),
                _bh.proposer.encodeBytes(),
                _bh.prevHash.encodeBytes(),
                _bh.voteHash.encodeBytes(),
                _bh.nextValidators.encodeBytes()
            );
        bytes memory temp1;
        if (_bh.patchTxHash.length != 0) {
            temp1 = _bh.patchTxHash.encodeBytes();
        } else {
            temp1 = emptyListHeadStart();
        }
        _rlp = abi.encodePacked(_rlp, temp1);

        if (_bh.txHash.length != 0) {
            temp1 = _bh.txHash.encodeBytes();
        } else {
            temp1 = emptyListHeadStart();
        }
        _rlp = abi.encodePacked(_rlp, temp1, _bh.logsBloom.encodeBytes());
        bytes memory temp2;
        //  SPR struct could be an empty struct
        //  In that case, serialize(SPR) = 0xF800
        if (_bh.isSPREmpty) {
            temp2 = emptyListHeadStart();
        } else {
            //  patchReceiptHash and receiptHash might be empty
            //  In that case, encoding these two items gives the result as 0xF800
            if (_bh.spr.patchReceiptHash.length != 0) {
                temp1 = _bh.spr.patchReceiptHash.encodeBytes();
            } else {
                temp1 = emptyListHeadStart();
            }
            temp2 = abi.encodePacked(_bh.spr.stateHash.encodeBytes(), temp1);

            if (_bh.spr.receiptHash.length != 0) {
                temp1 = _bh.spr.receiptHash.encodeBytes();
            } else {
                temp1 = emptyListHeadStart();
            }
            temp2 = abi.encodePacked(temp2, temp1);
            temp2 = abi
                .encodePacked(addLength(temp2.length, false), temp2)
                .encodeBytes();
        }
        _rlp = abi.encodePacked(_rlp, temp2);

        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeVotes(Types.Votes memory _vote)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp;
        bytes memory temp;

        //  First, serialize an array of TS
        for (uint256 i = 0; i < _vote.ts.length; i++) {
            temp = abi.encodePacked(
                _vote.ts[i].timestamp.encodeUint(),
                _vote.ts[i].signature.encodeBytes()
            );
            _rlp = abi.encodePacked(_rlp, addLength(temp.length, false), temp);
        }

        //  Next, serialize the blockPartSetID
        temp = abi.encodePacked(
            _vote.blockPartSetID.n.encodeUint(),
            _vote.blockPartSetID.b.encodeBytes()
        );
        //  Combine all of them
        _rlp = abi.encodePacked(
            _vote.round.encodeUint(),
            addLength(temp.length, false),
            temp,
            addLength(_rlp.length, false),
            _rlp
        );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeBlockWitness(Types.BlockWitness memory _bw)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp;
        bytes memory temp;
        for (uint256 i = 0; i < _bw.witnesses.length; i++) {
            temp = _bw.witnesses[i].encodeBytes();
            _rlp = abi.encodePacked(_rlp, temp);
        }
        _rlp = abi.encodePacked(
            _bw.height.encodeUint(),
            addLength(_rlp.length, false),
            _rlp
        );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeEventProof(Types.EventProof memory _ep)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp;
        bytes memory temp;
        for (uint256 i = 0; i < _ep.eventMptNode.length; i++) {
            temp = _ep.eventMptNode[i].encodeBytes();
            _rlp = abi.encodePacked(_rlp, temp);
        }
        _rlp = abi
            .encodePacked(addLength(_rlp.length, false), _rlp)
            .encodeBytes();

        _rlp = abi.encodePacked(_ep.index.encodeUint(), _rlp);
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeBlockUpdate(Types.BlockUpdate memory _bu)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory temp;
        bytes memory _rlp;
        //  In the case that _validators[] is an empty array, loop will be skipped
        //  and RLP_ENCODE([bytes]) == EMPTY_LIST_HEAD_START (0xF800) instead
        if (_bu.validators.length != 0) {
            for (uint256 i = 0; i < _bu.validators.length; i++) {
                temp = _bu.validators[i].encodeBytes();
                _rlp = abi.encodePacked(_rlp, temp);
            }
            _rlp = abi
                .encodePacked(addLength(_rlp.length, false), _rlp)
                .encodeBytes();
        } else {
            _rlp = emptyListHeadStart();
        }

        _rlp = abi.encodePacked(
            _bu.bh.encodeBlockHeader().encodeBytes(),
            _bu.votes.encodeVotes().encodeBytes(),
            _rlp
        );

        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

   /*  function encodeReceiptProof(Types.ReceiptProof memory _rp)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory temp;
        bytes memory _rlp;
        //  Serialize [bytes] which are transaction receipts
        for (uint256 i = 0; i < _rp.txReceipts.length; i++) {
            temp = _rp.txReceipts[i].encodeBytes();
            _rlp = abi.encodePacked(_rlp, temp);
        }
        _rlp = abi
            .encodePacked(addLength(_rlp.length, false), _rlp)
            .encodeBytes();

        bytes memory eventProof;
        for (uint256 i = 0; i < _rp.ep.length; i++) {
            temp = _rp.ep[i].encodeEventProof();
            eventProof = abi.encodePacked(eventProof, temp);
        }
        _rlp = abi.encodePacked(
            _rp.index.encodeUint(),
            _rlp,
            addLength(eventProof.length, false),
            eventProof
        );

        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    } */

    function encodeBlockProof(Types.BlockProof memory _bp)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp =
            abi.encodePacked(
                _bp.bh.encodeBlockHeader().encodeBytes(),
                _bp.bw.encodeBlockWitness().encodeBytes()
            );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

   /*  function encodeRelayMessage(Types.RelayMessage memory _rm)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory temp;
        bytes memory _rlp;
        if (_rm.buArray.length != 0) {
            for (uint256 i = 0; i < _rm.buArray.length; i++) {
                temp = _rm.buArray[i].encodeBlockUpdate().encodeBytes();
                _rlp = abi.encodePacked(_rlp, temp);
            }
            _rlp = abi.encodePacked(addLength(_rlp.length, false), _rlp);
        } else {
            _rlp = emptyListShortStart();
        }

        if (_rm.isBPEmpty == false) {
            temp = _rm.bp.encodeBlockProof();
        } else {
            temp = emptyListHeadStart();
        }
        _rlp = abi.encodePacked(_rlp, temp);

        bytes memory receiptProof;
        if (_rm.isRPEmpty == false) {
            for (uint256 i = 0; i < _rm.rp.length; i++) {
                temp = _rm.rp[i].encodeReceiptProof().encodeBytes();
                receiptProof = abi.encodePacked(receiptProof, temp);
            }
            receiptProof = abi.encodePacked(
                addLength(receiptProof.length, false),
                receiptProof
            );
        } else {
            receiptProof = emptyListShortStart();
        }
        _rlp = abi.encodePacked(_rlp, receiptProof);

        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    } */

    //  Adding LIST_HEAD_START by length
    //  There are two cases:
    //  1. List contains less than or equal 55 elements (total payload of the RLP) -> LIST_HEAD_START = LIST_SHORT_START + [0-55] = [0xC0 - 0xF7]
    //  2. List contains more than 55 elements:
    //  - Total Payload = 512 elements = 0x0200
    //  - Length of Total Payload = 2
    //  => LIST_HEAD_START = \x (LIST_LONG_START + length of Total Payload) \x (Total Payload) = \x(F7 + 2) \x(0200) = \xF9 \x0200 = 0xF90200
    function addLength(uint256 length, bool isLongList)
        internal
        pure
        returns (bytes memory)
    {
        if (length > 55 && !isLongList) {
            bytes memory payLoadSize = RLPEncode.encodeUintByLength(length);
            return
                abi.encodePacked(
                    addLength(payLoadSize.length, true),
                    payLoadSize
                );
        } else if (length <= 55 && !isLongList) {
            return abi.encodePacked(uint8(LIST_SHORT_START + length));
        }
        return abi.encodePacked(uint8(LIST_LONG_START + length));
    }

    function emptyListHeadStart() internal pure returns (bytes memory) {
        bytes memory payLoadSize = RLPEncode.encodeUintByLength(0);
        return
            abi.encodePacked(
                abi.encodePacked(uint8(LIST_LONG_START + payLoadSize.length)),
                payLoadSize
            );
    }

    function emptyListShortStart() internal pure returns (bytes memory) {
        return abi.encodePacked(LIST_SHORT_START);
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;

/**
 * @title RLPEncode
 * @dev A simple RLP encoding library.
 * @author Bakaoh
 * The original code was modified. For more info, please check the link:
 * https://github.com/bakaoh/solidity-rlp-encode.git
 */
library RLPEncode {
    int8 internal constant MAX_INT8 = type(int8).max;
    int16 internal constant MAX_INT16 = type(int16).max;
    int24 internal constant MAX_INT24 = type(int24).max;
    int32 internal constant MAX_INT32 = type(int32).max;
    int40 internal constant MAX_INT40 = type(int40).max;
    int48 internal constant MAX_INT48 = type(int48).max;
    int56 internal constant MAX_INT56 = type(int56).max;
    int64 internal constant MAX_INT64 = type(int64).max;
    int72 internal constant MAX_INT72 = type(int72).max;
    int80 internal constant MAX_INT80 = type(int80).max;
    int88 internal constant MAX_INT88 = type(int88).max;
    int96 internal constant MAX_INT96 = type(int96).max;
    int104 internal constant MAX_INT104 = type(int104).max;
    int112 internal constant MAX_INT112 = type(int112).max;
    int120 internal constant MAX_INT120 = type(int120).max;
    int128 internal constant MAX_INT128 = type(int128).max;

    uint8 internal constant MAX_UINT8 = type(uint8).max;
    uint16 internal constant MAX_UINT16 = type(uint16).max;
    uint24 internal constant MAX_UINT24 = type(uint24).max;
    uint32 internal constant MAX_UINT32 = type(uint32).max;
    uint40 internal constant MAX_UINT40 = type(uint40).max;
    uint48 internal constant MAX_UINT48 = type(uint48).max;
    uint56 internal constant MAX_UINT56 = type(uint56).max;
    uint64 internal constant MAX_UINT64 = type(uint64).max;
    uint72 internal constant MAX_UINT72 = type(uint72).max;
    uint80 internal constant MAX_UINT80 = type(uint80).max;
    uint88 internal constant MAX_UINT88 = type(uint88).max;
    uint96 internal constant MAX_UINT96 = type(uint96).max;
    uint104 internal constant MAX_UINT104 = type(uint104).max;
    uint112 internal constant MAX_UINT112 = type(uint112).max;
    uint120 internal constant MAX_UINT120 = type(uint120).max;
    uint128 internal constant MAX_UINT128 = type(uint128).max;

    /*
     * Internal functions
     */

    /**
     * @dev RLP encodes a byte string.
     * @param self The byte string to encode.
     * @return The RLP encoded string in bytes.
     */
    function encodeBytes(bytes memory self)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory encoded;
        if (self.length == 1 && uint8(self[0]) <= 128) {
            encoded = self;
        } else {
            encoded = concat(encodeLength(self.length, 128), self);
        }
        return encoded;
    }

    /**
     * @dev RLP encodes a list of RLP encoded byte byte strings.
     * @param self The list of RLP encoded byte strings.
     * @return The RLP encoded list of items in bytes.
     */
    function encodeList(bytes[] memory self)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory list = flatten(self);
        return concat(encodeLength(list.length, 192), list);
    }

    /**
     * @dev RLP encodes a string.
     * @param self The string to encode.
     * @return The RLP encoded string in bytes.
     */
    function encodeString(string memory self)
        internal
        pure
        returns (bytes memory)
    {
        return encodeBytes(bytes(self));
    }

    /**
     * @dev RLP encodes an address.
     * @param self The address to encode.
     * @return The RLP encoded address in bytes.
     */
    function encodeAddress(address self) internal pure returns (bytes memory) {
        bytes memory inputBytes;
        assembly {
            let m := mload(0x40)
            mstore(
                add(m, 20),
                xor(0x140000000000000000000000000000000000000000, self)
            )
            mstore(0x40, add(m, 52))
            inputBytes := m
        }
        return encodeBytes(inputBytes);
    }

    /**
     * @dev RLP encodes a uint.
     * @param self The uint to encode.
     * @return The RLP encoded uint in bytes.
     */
    function encodeUint(uint256 self) internal pure returns (bytes memory) {
        uint nBytes = bitLength(self)/8 + 1;
        bytes memory uintBytes = encodeUintByLength(self);
        if (nBytes - uintBytes.length > 0) {
            uintBytes = abi.encodePacked(bytes1(0), uintBytes);
        }
        return encodeBytes(uintBytes);
    }

    /**
     * @dev convert int to strict bytes.
     * @notice only handle to int128 due to contract code size limit
     * @param n The int to convert.
     * @return The int in strict bytes without padding.
     */
    function intToStrictBytes(int256 n) internal pure returns (bytes memory) {
        if (-MAX_INT8 - 1 <= n && n <= MAX_INT8) {
            return abi.encodePacked(int8(n));
        } else if (-MAX_INT16 - 1 <= n && n <= MAX_INT16) {
            return abi.encodePacked(int16(n));
        } else if (-MAX_INT24 - 1 <= n && n <= MAX_INT24) {
            return abi.encodePacked(int24(n));
        } else if (-MAX_INT32 - 1 <= n && n <= MAX_INT32) {
            return abi.encodePacked(int32(n));
        } else if (-MAX_INT40 - 1 <= n && n <= MAX_INT40) {
            return abi.encodePacked(int40(n));
        } else if (-MAX_INT48 - 1 <= n && n <= MAX_INT48) {
            return abi.encodePacked(int48(n));
        } else if (-MAX_INT56 - 1 <= n && n <= MAX_INT56) {
            return abi.encodePacked(int56(n));
        } else if (-MAX_INT64 - 1 <= n && n <= MAX_INT64) {
            return abi.encodePacked(int64(n));
        } else if (-MAX_INT72 - 1 <= n && n <= MAX_INT72) {
            return abi.encodePacked(int72(n));
        } else if (-MAX_INT80 - 1 <= n && n <= MAX_INT80) {
            return abi.encodePacked(int80(n));
        } else if (-MAX_INT88 - 1 <= n && n <= MAX_INT88) {
            return abi.encodePacked(int88(n));
        } else if (-MAX_INT96 - 1 <= n && n <= MAX_INT96) {
            return abi.encodePacked(int96(n));
        } else if (-MAX_INT104 - 1 <= n && n <= MAX_INT104) {
            return abi.encodePacked(int104(n));
        } else if (-MAX_INT112 - 1 <= n && n <= MAX_INT112) {
            return abi.encodePacked(int112(n));
        } else if (-MAX_INT120 - 1 <= n && n <= MAX_INT120) {
            return abi.encodePacked(int120(n));
        }
        require(-MAX_INT128 - 1 <= n && n <= MAX_INT128, "outOfBounds: [-2^128-1, 2^128]");
        return abi.encodePacked(int128(n));
    }

    /**
     * @dev RLP encodes an int.
     * @param self The int to encode.
     * @return The RLP encoded int in bytes.
     */
    function encodeInt(int256 self) internal pure returns (bytes memory) {
        return encodeBytes(intToStrictBytes(self));
    }

    /**
     * @dev RLP encodes a bool.
     * @param self The bool to encode.
     * @return The RLP encoded bool in bytes.
     */
    function encodeBool(bool self) internal pure returns (bytes memory) {
        bytes memory encoded = new bytes(1);
        encoded[0] = (self ? bytes1(0x01) : bytes1(0x00));
        return encoded;
    }

    /*
     * Private functions
     */

    /**
     * @dev Encode the first byte, followed by the `len` in binary form if `length` is more than 55.
     * @param len The length of the string or the payload.
     * @param offset 128 if item is string, 192 if item is list.
     * @return RLP encoded bytes.
     */
    function encodeLength(uint256 len, uint256 offset)
        private
        pure
        returns (bytes memory)
    {
        bytes memory encoded;
        if (len < 56) {
            encoded = new bytes(1);
            encoded[0] = bytes32(len + offset)[31];
        } else {
            uint256 lenLen;
            uint256 i = 1;
            while (len / i != 0) {
                lenLen++;
                i *= 256;
            }

            encoded = new bytes(lenLen + 1);
            encoded[0] = bytes32(lenLen + offset + 55)[31];
            for (i = 1; i <= lenLen; i++) {
                encoded[i] = bytes32((len / (256**(lenLen - i))) % 256)[31];
            }
        }
        return encoded;
    }

    /**
     * @dev Encode integer in big endian binary form with no leading zeroes.
     * @notice TODO: This should be optimized with assembly to save gas costs.
     * @param _x The integer to encode.
     * @return RLP encoded bytes.
     */
    function toBinary(uint256 _x) private pure returns (bytes memory) {
        //  Modify library to make it work properly when _x = 0
        if (_x == 0) {
            return abi.encodePacked(uint8(_x));
        }
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), _x)
        }
        uint256 i;
        for (i = 0; i < 32; i++) {
            if (b[i] != 0) {
                break;
            }
        }
        bytes memory res = new bytes(32 - i);
        for (uint256 j = 0; j < res.length; j++) {
            res[j] = b[i++];
        }
        return res;
    }

    /**
     * @dev Copies a piece of memory to another location.
     * @notice From: https://github.com/Arachnid/solidity-stringutils/blob/master/src/strings.sol.
     * @param _dest Destination location.
     * @param _src Source location.
     * @param _len Length of memory to copy.
     */
    function memcpy(
        uint256 _dest,
        uint256 _src,
        uint256 _len
    ) private pure {
        uint256 dest = _dest;
        uint256 src = _src;
        uint256 len = _len;

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint256 mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /**
     * @dev Flattens a list of byte strings into one byte string.
     * @notice From: https://github.com/sammayo/solidity-rlp-encoder/blob/master/RLPEncode.sol.
     * @param _list List of byte strings to flatten.
     * @return The flattened byte string.
     */
    function flatten(bytes[] memory _list) private pure returns (bytes memory) {
        if (_list.length == 0) {
            return new bytes(0);
        }

        uint256 len;
        uint256 i;
        for (i = 0; i < _list.length; i++) {
            len += _list[i].length;
        }

        bytes memory flattened = new bytes(len);
        uint256 flattenedPtr;
        assembly {
            flattenedPtr := add(flattened, 0x20)
        }

        for (i = 0; i < _list.length; i++) {
            bytes memory item = _list[i];

            uint256 listPtr;
            assembly {
                listPtr := add(item, 0x20)
            }

            memcpy(flattenedPtr, listPtr, item.length);
            flattenedPtr += _list[i].length;
        }

        return flattened;
    }

    /**
     * @dev Concatenates two bytes.
     * @notice From: https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol.
     * @param _preBytes First byte string.
     * @param _postBytes Second byte string.
     * @return Both byte string combined.
     */
    function concat(bytes memory _preBytes, bytes memory _postBytes)
        private
        pure
        returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(
                0x40,
                and(
                    add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                    not(31)
                )
            )
        }

        return tempBytes;
    }

    /**
     * @dev convert uint to strict bytes.
     * @notice only handle to uint128 due to contract code size limit
     * @param length The uint to convert.
     * @return The uint in strict bytes without padding.
     */
    function encodeUintByLength(uint256 length)
        internal
        pure
        returns (bytes memory)
    {
        if (length < MAX_UINT8) {
            return abi.encodePacked(uint8(length));
        } else if (length >= MAX_UINT8 && length < MAX_UINT16) {
            return abi.encodePacked(uint16(length));
        } else if (length >= MAX_UINT16 && length < MAX_UINT24) {
            return abi.encodePacked(uint24(length));
        } else if (length >= MAX_UINT24 && length < MAX_UINT32) {
            return abi.encodePacked(uint32(length));
        } else if (length >= MAX_UINT32 && length < MAX_UINT40) {
            return abi.encodePacked(uint40(length));
        } else if (length >= MAX_UINT40 && length < MAX_UINT48) {
            return abi.encodePacked(uint48(length));
        } else if (length >= MAX_UINT48 && length < MAX_UINT56) {
            return abi.encodePacked(uint56(length));
        } else if (length >= MAX_UINT56 && length < MAX_UINT64) {
            return abi.encodePacked(uint64(length));
        } else if (length >= MAX_UINT64 && length < MAX_UINT72) {
            return abi.encodePacked(uint72(length));
        } else if (length >= MAX_UINT72 && length < MAX_UINT80) {
            return abi.encodePacked(uint80(length));
        } else if (length >= MAX_UINT80 && length < MAX_UINT88) {
            return abi.encodePacked(uint88(length));
        } else if (length >= MAX_UINT88 && length < MAX_UINT96) {
            return abi.encodePacked(uint96(length));
        } else if (length >= MAX_UINT96 && length < MAX_UINT104) {
            return abi.encodePacked(uint104(length));
        } else if (length >= MAX_UINT104 && length < MAX_UINT112) {
            return abi.encodePacked(uint112(length));
        } else if (length >= MAX_UINT112 && length < MAX_UINT120) {
            return abi.encodePacked(uint120(length));
        }
        require(length >= MAX_UINT120 && length < MAX_UINT128, "outOfBounds: [0, 2^128]");
        return abi.encodePacked(uint128(length));
    }

    function bitLength(uint256 n) internal pure returns (uint256) {
        uint256 count;
        while (n != 0) {
            count += 1;
            n >>= 1;
        }
        return count;
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./RLPDecode.sol";
import "./Types.sol";

library RLPDecodeStruct {
    using RLPDecode for RLPDecode.RLPItem;
    using RLPDecode for RLPDecode.Iterator;
    using RLPDecode for bytes;

    using RLPDecodeStruct for bytes;

    uint8 private constant LIST_SHORT_START = 0xc0;
    uint8 private constant LIST_LONG_START = 0xf7;

    function decodeBMCService(bytes memory _rlp)
        internal
        pure
        returns (Types.BMCService memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        return
            Types.BMCService(
                string(ls[0].toBytes()),
                ls[1].toBytes() //  bytes array of RLPEncode(Data)
            );
    }

    function decodeGatherFeeMessage(bytes memory _rlp)
        internal
        pure
        returns (Types.GatherFeeMessage memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        RLPDecode.RLPItem[] memory subList = ls[1].toList();
        string[] memory _svcs = new string[](subList.length);
        for (uint256 i = 0; i < subList.length; i++) {
            _svcs[i] = string(subList[i].toBytes());
        }
        return Types.GatherFeeMessage(string(ls[0].toBytes()), _svcs);
    }

    function decodePropagateMessage(bytes memory _rlp)
        internal
        pure
        returns (string memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        return string(ls[0].toBytes());
    }

    function decodeInitMessage(bytes memory _rlp)
        internal
        pure
        returns (string[] memory _links)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        RLPDecode.RLPItem[] memory rlpLinks = ls[0].toList();
        _links = new string[](rlpLinks.length);
        for (uint256 i = 0; i < rlpLinks.length; i++)
            _links[i] = string(rlpLinks[i].toBytes());
    }

    function decodeRegisterCoin(bytes memory _rlp)
        internal
        pure
        returns (Types.RegisterCoin memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        return
            Types.RegisterCoin(
                string(ls[0].toBytes()),
                ls[1].toUint(),
                string(ls[2].toBytes())
            );
    }

    function decodeBMCMessage(bytes memory _rlp)
        internal
        pure
        returns (Types.BMCMessage memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        return
            Types.BMCMessage(
                string(ls[0].toBytes()),
                string(ls[1].toBytes()),
                string(ls[2].toBytes()),
                ls[3].toInt(),
                ls[4].toBytes() //  bytes array of RLPEncode(ServiceMessage)
            );
    }

    function decodeServiceMessage(bytes memory _rlp)
        internal
        pure
        returns (Types.ServiceMessage memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        return
            Types.ServiceMessage(
                Types.ServiceType(ls[0].toUint()),
                ls[1].toBytes() //  bytes array of RLPEncode(Data)
            );
    }

    function decodeTransferCoinMsg(bytes memory _rlp)
        internal
        pure
        returns (Types.TransferCoin memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        Types.Asset[] memory assets = new Types.Asset[](ls[2].toList().length);
        RLPDecode.RLPItem[] memory rlpAssets = ls[2].toList();
        for (uint256 i = 0; i < ls[2].toList().length; i++) {
            assets[i] = Types.Asset(
                string(rlpAssets[i].toList()[0].toBytes()),
                rlpAssets[i].toList()[1].toUint()
            );
        }
        return
            Types.TransferCoin(
                string(ls[0].toBytes()),
                string(ls[1].toBytes()),
                assets
            );
    }

    function decodeResponse(bytes memory _rlp)
        internal
        pure
        returns (Types.Response memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        return Types.Response(ls[0].toUint(), string(ls[1].toBytes()));
    }

    function decodeBlockHeader(bytes memory _rlp)
        internal
        pure
        returns (Types.BlockHeader memory)
    {
        //  Decode RLP bytes into a list of items
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        bool isSPREmpty = true;
        if (ls[10].toBytes().length == 0) {
            return
                Types.BlockHeader(
                    ls[0].toUint(),
                    ls[1].toUint(),
                    ls[2].toUint(),
                    ls[3].toBytes(),
                    ls[4].toBytes(),
                    ls[5].toBytes(),
                    ls[6].toBytes(),
                    ls[7].toBytes(),
                    ls[8].toBytes(),
                    ls[9].toBytes(),
                    Types.SPR("", "", ""),
                    isSPREmpty
                );
        }
        RLPDecode.RLPItem[] memory subList =
            ls[10].toBytes().toRlpItem().toList();
        isSPREmpty = false;
        return
            Types.BlockHeader(
                ls[0].toUint(),
                ls[1].toUint(),
                ls[2].toUint(),
                ls[3].toBytes(),
                ls[4].toBytes(),
                ls[5].toBytes(),
                ls[6].toBytes(),
                ls[7].toBytes(),
                ls[8].toBytes(),
                ls[9].toBytes(),
                Types.SPR(
                    subList[0].toBytes(),
                    subList[1].toBytes(),
                    subList[2].toBytes()
                ),
                isSPREmpty
            );
    }

    //  Votes item consists of:
    //  round as integer
    //  blockPartSetID is a list that consists of two items - integer and bytes
    //  and TS[] ts_list (an array of list)
    function decodeVotes(bytes memory _rlp)
        internal
        pure
        returns (Types.Votes memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();

        Types.TS[] memory tsList = new Types.TS[](ls[2].toList().length);
        RLPDecode.RLPItem[] memory rlpTs = ls[2].toList();
        for (uint256 i = 0; i < ls[2].toList().length; i++) {
            tsList[i] = Types.TS(
                rlpTs[i].toList()[0].toUint(),
                rlpTs[i].toList()[1].toBytes()
            );
        }
        return
            Types.Votes(
                ls[0].toUint(),
                Types.BPSI(
                    ls[1].toList()[0].toUint(),
                    ls[1].toList()[1].toBytes()
                ),
                tsList
            );
    }

    //  Wait for confirmation
    function decodeBlockWitness(bytes memory _rlp)
        internal
        pure
        returns (Types.BlockWitness memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();

        bytes[] memory witnesses = new bytes[](ls[1].toList().length);
        //  witnesses is an array of hash of leaf node
        //  The array size may also vary, thus loop is needed therein
        for (uint256 i = 0; i < ls[1].toList().length; i++) {
            witnesses[i] = ls[1].toList()[i].toBytes();
        }
        return Types.BlockWitness(ls[0].toUint(), witnesses);
    }

    function decodeEventProof(bytes memory _rlp)
        internal
        pure
        returns (Types.EventProof memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        RLPDecode.RLPItem[] memory data = ls[1].toBytes().toRlpItem().toList();

        bytes[] memory eventMptNode = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            eventMptNode[i] = data[i].toBytes();
        }
        return Types.EventProof(ls[0].toUint(), eventMptNode);
    }

    function decodeBlockUpdate(bytes memory _rlp)
        internal
        pure
        returns (Types.BlockUpdate memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();

        // Types.BlockHeader memory _bh;
        Types.BlockHeader memory _bh = ls[0].toBytes().decodeBlockHeader();
        Types.Votes memory _v = ls[1].toBytes().decodeVotes();
        // Types.Votes memory _v;

        //  BlockUpdate may or may not include the RLP of addresses of validators
        //  In that case, RLP_ENCODE([bytes]) == EMPTY_LIST_HEAD_START == 0xF800
        //  Thus, length of data will be 0. Therein, loop will be skipped
        //  and the _validators[] will be empty
        //  Otherwise, executing normally to read and assign value into the array _validators[]
        bytes[] memory _validators;
        if (ls[2].toBytes().length != 0) {
            _validators = new bytes[](ls[2].toList().length);
            for (uint256 i = 0; i < ls[2].toList().length; i++) {
                _validators[i] = ls[2].toList()[i].toBytes();
            }
        }
        return Types.BlockUpdate(_bh, _v, _validators);
    }

    /* function decodeReceiptProof(bytes memory _rlp)
        internal
        pure
        returns (Types.ReceiptProof memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        RLPDecode.RLPItem[] memory receiptList =
            ls[1].toBytes().toRlpItem().toList();

        bytes[] memory txReceipts = new bytes[](receiptList.length);
        for (uint256 i = 0; i < receiptList.length; i++) {
            txReceipts[i] = receiptList[i].toBytes();
        }

        Types.EventProof[] memory _ep =
            new Types.EventProof[](ls[2].toList().length);
        for (uint256 i = 0; i < ls[2].toList().length; i++) {
            _ep[i] = Types.EventProof(
                ls[2].toList()[i].toList()[0].toUint(),
                ls[2].toList()[i].toList()[1].toBytes().decodeEventLog()
            );
        }

        return Types.ReceiptProof(ls[0].toUint(), txReceipts, _ep);
    } 

    function decodeEventLog(bytes memory _rlp)
        internal
        pure
        returns (bytes[] memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        bytes[] memory eventMptNode = new bytes[](ls.length);
        for (uint256 i = 0; i < ls.length; i++) {
            eventMptNode[i] = ls[i].toBytes();
        }
        return eventMptNode;
    }
    */

    function decodeBlockProof(bytes memory _rlp)
        internal
        pure
        returns (Types.BlockProof memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();

        Types.BlockHeader memory _bh = ls[0].toBytes().decodeBlockHeader();
        Types.BlockWitness memory _bw = ls[1].toBytes().decodeBlockWitness();

        return Types.BlockProof(_bh, _bw);
    }

    function decodeRelayMessage(bytes memory _rlp)
        internal
        pure
        returns (Types.RelayMessage memory)
    {
        //  _rlp.toRlpItem() removes the LIST_HEAD_START of RelayMessage
        //  then .toList() to itemize all fields in the RelayMessage
        //  which are [RLP_ENCODE(BlockUpdate)], RLP_ENCODE(BlockProof), and
        //  the RLP_ENCODE(ReceiptProof)
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        // return (
        //     ls[0].toList()[0].toBytes().toRlpItem().toList()[1].toBytes().toRlpItem().toList()[2].toList()[0].toList()[1].toBytes()
        // );

        //  If [RLP_ENCODE(BlockUpdate)] was empty, it should be started by 0xF800
        //  therein, ls[0].toBytes() will be null (length = 0)
        //  Otherwise, create an array of BlockUpdate struct to decode
        Types.BlockUpdate[] memory _buArray;
        if (ls[0].toBytes().length != 0) {
            _buArray = new Types.BlockUpdate[](ls[0].toList().length);
            for (uint256 i = 0; i < ls[0].toList().length; i++) {
                //  Each of items inside an array [RLP_ENCODE(BlockUpdate)]
                //  is a string which defines RLP_ENCODE(BlockUpdate)
                //  that contains a LIST_HEAD_START and multiple RLP of data
                //  ls[0].toList()[i].toBytes() returns bytes presentation of
                //  RLP_ENCODE(BlockUpdate)
                _buArray[i] = ls[0].toList()[i].toBytes().decodeBlockUpdate();
            }
        }
        bool isBPEmpty = true;
        Types.BlockProof memory _bp;
        //  If RLP_ENCODE(BlockProof) is omitted,
        //  ls[1].toBytes() should be null (length = 0)
        if (ls[1].toBytes().length != 0) {
            _bp = ls[1].toBytes().decodeBlockProof();
            isBPEmpty = false; //  add this field into RelayMessage
            //  to specify whether BlockProof is omitted
            //  to make it easy on encoding
            //  it will not be serialized thereafter
        }

        bool isRPEmpty = true;
        Types.ReceiptProof[] memory _rp;
        //  If [RLP_ENCODE(ReceiptProof)] is omitted,
        //  ls[2].toBytes() should be null (length = 0)
        if (ls[2].toBytes().length != 0) {
            _rp = new Types.ReceiptProof[](ls[2].toList().length);
            for (uint256 i = 0; i < ls[2].toList().length; i++) {
                _rp[i] = ls[2].toList()[i].toBytes().decodeReceiptProof();
            }
            isRPEmpty = false; //  add this field into RelayMessage
            //  to specify whether ReceiptProof is omitted
            //  to make it easy on encoding
            //  it will not be serialized thereafter
        }
        return Types.RelayMessage(_buArray, _bp, isBPEmpty, _rp, isRPEmpty);
    }

    
    function decodeReceiptProofs(bytes memory _rlp)
        internal        
        pure
        returns (Types.ReceiptProof[] memory _rp)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        if (ls[0].toBytes().length != 0) {
            _rp = new Types.ReceiptProof[](ls[0].toList().length);
            for (uint256 i = 0; i < ls[0].toList().length; i++) {
                _rp[i] = ls[0].toList()[i].toBytes().decodeReceiptProof();
            }
        }
    }


    
    function decodeReceiptProof(bytes memory _rlp)
        internal        
        pure
        returns (Types.ReceiptProof memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();

        Types.MessageEvent[] memory events =
            new Types.MessageEvent[](ls[1].toBytes().toRlpItem().toList().length);

        for (uint256 i = 0; i < ls[1].toBytes().toRlpItem().toList().length; i++) {
            events[i] =ls[1].toBytes().toRlpItem().toList()[i].toRlpBytes().toMessageEvent();
        }
        
        return
            Types.ReceiptProof(
                ls[0].toUint(),
                events,
                ls[2].toUint()
            );
    }

      function toMessageEvent(bytes memory _rlp)
        internal
        pure
        returns (Types.MessageEvent memory)
    {
         RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
            return
                Types.MessageEvent(
                    string(ls[0].toBytes()),
                    ls[1].toUint(),
                    ls[2].toBytes()
                );
    }

}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;

/*
 *  Change supporting solidity compiler version
 *  The original code can be found via this link: https://github.com/hamdiallam/Solidity-RLP.git
 */

library RLPDecode {
    uint8 private constant STRING_SHORT_START = 0x80;
    uint8 private constant STRING_LONG_START = 0xb8;
    uint8 private constant LIST_SHORT_START = 0xc0;
    uint8 private constant LIST_LONG_START = 0xf8;
    uint8 private constant WORD_SIZE = 32;

    struct RLPItem {
        uint256 len;
        uint256 memPtr;
    }

    struct Iterator {
        RLPItem item; // Item that's being iterated over.
        uint256 nextPtr; // Position of the next item in the list.
    }

    /*
     * @dev Returns the next element in the iteration. Reverts if it has not next element.
     * @param self The iterator.
     * @return The next element in the iteration.
     */
    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self), "Must have next elements");

        uint256 ptr = self.nextPtr;
        uint256 itemLength = _itemLength(ptr);
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
        uint256 memPtr;
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
        require(isList(self), "Must be a list");

        uint256 ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    /*
     * @param item RLP encoded bytes
     */
    function rlpLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len;
    }

    /*
     * @param item RLP encoded bytes
     */
    function payloadLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len - _payloadOffset(item.memPtr);
    }

    /*
     * @param item RLP encoded list in bytes
     */
    function toList(RLPItem memory item)
        internal
        pure
        returns (RLPItem[] memory)
    {
        require(isList(item), "Must be a list");

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint256 memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 dataLen;
        for (uint256 i = 0; i < items; i++) {
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
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
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

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    // any non-zero byte except "0x80" is considered true
    function toBoolean(RLPItem memory item) internal pure returns (bool) {
        require(item.len == 1, "Must have length 1");
        uint256 result;
        uint256 memPtr = item.memPtr;
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
        require(item.len == 21, "Must have length 21");

        return address(uint160(toUint(item)));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {
        require(item.len > 0 && item.len <= 33, "Invalid uint number");

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset;

        uint256 result;
        uint256 memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

            // shfit to the correct location if neccesary
            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    function toInt(RLPItem memory item) internal pure returns (int256) {
        if ((toBytes(item)[0] & 0x80) == 0x80) {
            return int256(toUint(item) - 2**(toBytes(item).length * 8));
        }

        return int256(toUint(item));
    }

    // enforces 32 byte length
    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {
        // one byte prefix
        require(item.len == 33, "Must have length 33");

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0, "Invalid length");

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint256 destPtr;
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
    function numItems(RLPItem memory item) private pure returns (uint256) {
        if (item.len == 0) return 0;

        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            count++;
        }

        return count;
    }

    // @return entire rlp item byte length
    function _itemLength(uint256 memPtr) private pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
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
    function _payloadOffset(uint256 memPtr) private pure returns (uint256) {
        uint256 byte0;
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
        uint256 src,
        uint256 dest,
        uint256 len
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

        // left over bytes. Mask is used to remove unwanted bytes from the word
        uint256 mask = 256**(WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;

/*
 * Utility library of inline functions on addresses
 */
library ParseAddress {
    /**
     * @dev Get a checksummed string hex representation of an account address.
     * @param account address The account to get the checksum for.
     * @return The checksummed account string in ASCII format. Note that leading
     * "0x" is not included.
     */
    function toString(address account) internal pure returns (string memory) {
        // call internal function for converting an account to a checksummed string.
        return _toChecksumString(account);
    }

    /**
     * @dev Get a fixed-size array of whether or not each character in an account
     * will be capitalized in the checksum.
     * @param account address The account to get the checksum capitalization
     * information for.
     * @return A fixed-size array of booleans that signify if each character or
     * "nibble" of the hex encoding of the address will be capitalized by the
     * checksum.
     */
    function getChecksumCapitalizedCharacters(address account)
        internal
        pure
        returns (bool[40] memory)
    {
        // call internal function for computing characters capitalized in checksum.
        return _toChecksumCapsFlags(account);
    }

    /**
     * @dev Determine whether a string hex representation of an account address
     * matches the ERC-55 checksum of that address.
     * @param accountChecksum string The checksummed account string in ASCII
     * format. Note that a leading "0x" MUST NOT be included.
     * @return A boolean signifying whether or not the checksum is valid.
     */
    function isChecksumValid(string calldata accountChecksum)
        internal
        pure
        returns (bool)
    {
        // call internal function for validating checksum strings.
        return _isChecksumValid(accountChecksum);
    }

    function _toChecksumString(address account)
        internal
        pure
        returns (string memory asciiString)
    {
        // convert the account argument from address to bytes.
        bytes20 data = bytes20(account);

        // create an in-memory fixed-size bytes array.
        bytes memory asciiBytes = new bytes(40);

        // declare variable types.
        uint8 b;
        uint8 leftNibble;
        uint8 rightNibble;
        bool leftCaps;
        bool rightCaps;
        uint8 asciiOffset;

        // get the capitalized characters in the actual checksum.
        bool[40] memory caps = _toChecksumCapsFlags(account);

        // iterate over bytes, processing left and right nibble in each iteration.
        for (uint256 i = 0; i < data.length; i++) {
            // locate the byte and extract each nibble.
            b = uint8(uint160(data) / (2**(8 * (19 - i))));
            leftNibble = b / 16;
            rightNibble = b - 16 * leftNibble;

            // locate and extract each capitalization status.
            leftCaps = caps[2 * i];
            rightCaps = caps[2 * i + 1];

            // get the offset from nibble value to ascii character for left nibble.
            asciiOffset = _getAsciiOffset(leftNibble, leftCaps);

            // add the converted character to the byte array.
            asciiBytes[2 * i] = byte(leftNibble + asciiOffset);

            // get the offset from nibble value to ascii character for right nibble.
            asciiOffset = _getAsciiOffset(rightNibble, rightCaps);

            // add the converted character to the byte array.
            asciiBytes[2 * i + 1] = byte(rightNibble + asciiOffset);
        }

        return string(abi.encodePacked("0x", string(asciiBytes)));
    }

    function _toChecksumCapsFlags(address account)
        internal
        pure
        returns (bool[40] memory characterCapitalized)
    {
        // convert the address to bytes.
        bytes20 a = bytes20(account);

        // hash the address (used to calculate checksum).
        bytes32 b = keccak256(abi.encodePacked(_toAsciiString(a)));

        // declare variable types.
        uint8 leftNibbleAddress;
        uint8 rightNibbleAddress;
        uint8 leftNibbleHash;
        uint8 rightNibbleHash;

        // iterate over bytes, processing left and right nibble in each iteration.
        for (uint256 i; i < a.length; i++) {
            // locate the byte and extract each nibble for the address and the hash.
            rightNibbleAddress = uint8(a[i]) % 16;
            leftNibbleAddress = (uint8(a[i]) - rightNibbleAddress) / 16;
            rightNibbleHash = uint8(b[i]) % 16;
            leftNibbleHash = (uint8(b[i]) - rightNibbleHash) / 16;

            characterCapitalized[2 * i] = (leftNibbleAddress > 9 &&
                leftNibbleHash > 7);
            characterCapitalized[2 * i + 1] = (rightNibbleAddress > 9 &&
                rightNibbleHash > 7);
        }
    }

    function _isChecksumValid(string memory provided)
        internal
        pure
        returns (bool ok)
    {
        // convert the provided string into account type.
        address account = _toAddress(provided);

        // return false in the event the account conversion returned null address.
        if (account == address(0)) {
            // ensure that provided address is not also the null address first.
            bytes memory b = bytes(provided);
            for (uint256 i; i < b.length; i++) {
                if (b[i] != hex"30") {
                    return false;
                }
            }
        }

        // get the capitalized characters in the actual checksum.
        string memory actual = _toChecksumString(account);

        // compare provided string to actual checksum string to test for validity.
        return (keccak256(abi.encodePacked(actual)) ==
            keccak256(abi.encodePacked(provided)));
    }

    function _getAsciiOffset(uint8 nibble, bool caps)
        internal
        pure
        returns (uint8 offset)
    {
        // to convert to ascii characters, add 48 to 0-9, 55 to A-F, & 87 to a-f.
        if (nibble < 10) {
            offset = 48;
        } else if (caps) {
            offset = 55;
        } else {
            offset = 87;
        }
    }

    function _toAddress(string memory account)
        internal
        pure
        returns (address accountAddress)
    {
        // convert the account argument from address to bytes.
        bytes memory accountBytes = bytes(account);

        // create a new fixed-size byte array for the ascii bytes of the address.
        bytes memory accountAddressBytes = new bytes(20);

        // declare variable types.
        uint8 b;
        uint8 nibble;
        uint8 asciiOffset;

        // only proceed if the provided string has a length of 40.
        if (accountBytes.length == 40) {
            for (uint256 i; i < 40; i++) {
                // get the byte in question.
                b = uint8(accountBytes[i]);

                // ensure that the byte is a valid ascii character (0-9, A-F, a-f)
                if (b < 48) return address(0);
                if (57 < b && b < 65) return address(0);
                if (70 < b && b < 97) return address(0);
                if (102 < b) return address(0); //bytes(hex"");

                // find the offset from ascii encoding to the nibble representation.
                if (b < 65) {
                    // 0-9
                    asciiOffset = 48;
                } else if (70 < b) {
                    // a-f
                    asciiOffset = 87;
                } else {
                    // A-F
                    asciiOffset = 55;
                }

                // store left nibble on even iterations, then store byte on odd ones.
                if (i % 2 == 0) {
                    nibble = b - asciiOffset;
                } else {
                    accountAddressBytes[(i - 1) / 2] = (
                        byte(16 * nibble + (b - asciiOffset))
                    );
                }
            }

            // pack up the fixed-size byte array and cast it to accountAddress.
            bytes memory packed = abi.encodePacked(accountAddressBytes);
            assembly {
                accountAddress := mload(add(packed, 20))
            }
        }
    }

    // based on https://ethereum.stackexchange.com/a/56499/48410
    function _toAsciiString(bytes20 data)
        internal
        pure
        returns (string memory asciiString)
    {
        // create an in-memory fixed-size bytes array.
        bytes memory asciiBytes = new bytes(40);

        // declare variable types.
        uint8 b;
        uint8 leftNibble;
        uint8 rightNibble;

        // iterate over bytes, processing left and right nibble in each iteration.
        for (uint256 i = 0; i < data.length; i++) {
            // locate the byte and extract each nibble.
            b = uint8(uint160(data) / (2**(8 * (19 - i))));
            leftNibble = b / 16;
            rightNibble = b - 16 * leftNibble;

            // to convert to ascii characters, add 48 to 0-9 and 87 to a-f.
            asciiBytes[2 * i] = byte(leftNibble + (leftNibble < 10 ? 48 : 87));
            asciiBytes[2 * i + 1] = byte(
                rightNibble + (rightNibble < 10 ? 48 : 87)
            );
        }

        return string(asciiBytes);
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;

/**
 * @title DecodeBase64
 * @dev A simple Base64 decoding library.
 * @author Quang Tran
 */

library DecodeBase64 {
    function decode(string memory _str) internal pure returns (bytes memory) {
        bytes memory _bs = bytes(_str);
        uint256 remove = 0;
        if (_bs[_bs.length - 1] == "=" && _bs[_bs.length - 2] == "=") {
            remove += 2;
        } else if (_bs[_bs.length - 1] == "=") {
            remove++;
        }
        uint256 resultLength = (_bs.length / 4) * 3 - remove;
        bytes memory result = new bytes(resultLength);

        uint256 i = 0;
        uint256 j = 0;
        for (; i + 4 < _bs.length; i += 4) {
            (result[j], result[j + 1], result[j + 2]) = decode4(
                mapBase64Char(_bs[i]),
                mapBase64Char(_bs[i + 1]),
                mapBase64Char(_bs[i + 2]),
                mapBase64Char(_bs[i + 3])
            );
            j += 3;
        }
        if (remove == 1) {
            (result[j], result[j + 1], ) = decode4(
                mapBase64Char(_bs[_bs.length - 4]),
                mapBase64Char(_bs[_bs.length - 3]),
                mapBase64Char(_bs[_bs.length - 2]),
                0
            );
        } else if (remove == 2) {
            (result[j], , ) = decode4(
                mapBase64Char(_bs[_bs.length - 4]),
                mapBase64Char(_bs[_bs.length - 3]),
                0,
                0
            );
        } else {
            (result[j], result[j + 1], result[j + 2]) = decode4(
                mapBase64Char(_bs[_bs.length - 4]),
                mapBase64Char(_bs[_bs.length - 3]),
                mapBase64Char(_bs[_bs.length - 2]),
                mapBase64Char(_bs[_bs.length - 1])
            );
        }
        return result;
    }

    function mapBase64Char(bytes1 _char) private pure returns (uint8) {
        // solhint-disable-next-line
        uint8 A = 0;
        uint8 a = 26;
        uint8 zero = 52;
        if (uint8(_char) == 45) {
            return 62;
        } else if (uint8(_char) == 95) {
            return 63;
        } else if (uint8(_char) >= 48 && uint8(_char) <= 57) {
            return zero + (uint8(_char) - 48);
        } else if (uint8(_char) >= 65 && uint8(_char) <= 90) {
            return A + (uint8(_char) - 65);
        } else if (uint8(_char) >= 97 && uint8(_char) <= 122) {
            return a + (uint8(_char) - 97);
        }
        return 0;
    }

    function decode4(
        uint256 a0,
        uint256 a1,
        uint256 a2,
        uint256 a3
    )
        private
        pure
        returns (
            bytes1,
            bytes1,
            bytes1
        )
    {
        uint256 n =
            ((a0 & 63) << 18) |
                ((a1 & 63) << 12) |
                ((a2 & 63) << 6) |
                (a3 & 63);
        uint256 b0 = (n >> 16) & 255;
        uint256 b1 = (n >> 8) & 255;
        uint256 b2 = (n) & 255;
        return (bytes1(uint8(b0)), bytes1(uint8(b1)), bytes1(uint8(b2)));
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;

interface IBSH {
    /**
       @notice Handle BTP Message from other blockchain.
       @dev Accept the message only from the BMC. 
       Every BSH must implement this function
       @param _from    Network Address of source network
       @param _svc     Name of the service
       @param _sn      Serial number of the message
       @param _msg     Serialized bytes of ServiceMessage
   */

    function handleBTPMessage(
        string calldata _from,
        string calldata _svc,
        uint256 _sn,
        bytes calldata _msg
    ) external;

    /**
       @notice Handle the error on delivering the message.
       @dev Accept the error only from the BMC.
       Every BSH must implement this function
       @param _src     BTP Address of BMC generates the error
       @param _svc     Name of the service
       @param _sn      Serial number of the original message
       @param _code    Code of the error
       @param _msg     Message of the error  
   */
    function handleBTPError(
        string calldata _src,
        string calldata _svc,
        uint256 _sn,
        uint256 _code,
        string calldata _msg
    ) external;

    /**
       @notice Handle Gather Fee Request from ICON.
       @dev Every BSH must implement this function
       @param _fa    BTP Address of Fee Aggregator in ICON
       @param _svc   Name of the service
   */
    function handleFeeGathering(string calldata _fa, string calldata _svc)
        external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "../libraries/Types.sol";

interface IBMCPeriphery {
    /**
        @notice Get BMC BTP address
     */
    function getBmcBtpAddress() external view returns (string memory);

    /**
        @notice Verify and decode RelayMessage with BMV, and dispatch BTP Messages to registered BSHs
        @dev Caller must be a registered relayer.     
        @param _prev    BTP Address of the BMC generates the message
        @param _msg     base64 encoded string of serialized bytes of Relay Message refer RelayMessage structure
     */
    function handleRelayMessage(string calldata _prev, string calldata _msg)
        external;

    /**
        @notice Send the message to a specific network.
        @dev Caller must be an registered BSH.
        @param _to      Network Address of destination network
        @param _svc     Name of the service
        @param _sn      Serial number of the message, it should be positive
        @param _msg     Serialized bytes of Service Message
     */
    function sendMessage(
        string calldata _to,
        string calldata _svc,
        uint256 _sn,
        bytes calldata _msg
    ) external;

    /*
        @notice Get status of BMC.
        @param _link        BTP Address of the connected BMC
        @return _linkStats  The link status
     */
    function getStatus(string calldata _link)
        external
        view
        returns (Types.LinkStats memory _linkStats);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "../libraries/Types.sol";

interface IBMCManagement {
    /**
       @notice Update BMC periphery.
       @dev Caller must be an Onwer of BTP network
       @param _addr    Address of a new periphery.
     */
    function setBMCPeriphery(address _addr) external;

    /**
       @notice Adding another Onwer.
       @dev Caller must be an Onwer of BTP network
       @param _owner    Address of a new Onwer.
     */
    function addOwner(address _owner) external;

    /**
       @notice Removing an existing Owner.
       @dev Caller must be an Owner of BTP network
       @dev If only one Owner left, unable to remove the last Owner
       @param _owner    Address of an Owner to be removed.
     */
    function removeOwner(address _owner) external;

    /**
       @notice Checking whether one specific address has Owner role.
       @dev Caller can be ANY
       @param _owner    Address needs to verify.
     */
    function isOwner(address _owner) external view returns (bool);

    /**
       @notice Add the smart contract for the service.
       @dev Caller must be an operator of BTP network.
       @param _svc     Name of the service
       @param _addr    Service's contract address
     */
    function addService(string memory _svc, address _addr) external;

    /**
       @notice De-registers the smart contract for the service.  
       @dev Caller must be an operator of BTP network.
       @param _svc     Name of the service
     */
    function removeService(string calldata _svc) external;

    /**
       @notice Initializes status information for the link.
       @dev Caller must be an operator of BTP network.
       @param _link    BTP Address of connected BMC
     */
    function addLink(string calldata _link) external;

    /**
       @notice Set the link and status information. 
       @dev Caller must be an operator of BTP network.
       @param _link    BTP Address of connected BMC
       @param _blockInterval    Block interval of a connected link 
       @param _maxAggregation   Set max aggreation of a connected link
       @param _delayLimit       Set delay limit of a connected link
     */
    function setLink(
        string calldata _link,
        uint256 _blockInterval,
        uint256 _maxAggregation,
        uint256 _delayLimit
    ) external;

    /**
       @notice Removes the link and status information. 
       @dev Caller must be an operator of BTP network.
       @param _link    BTP Address of connected BMC
     */
    function removeLink(string calldata _link) external;

    /**
       @notice Add route to the BMC.
       @dev Caller must be an operator of BTP network.
       @param _dst     BTP Address of the destination BMC
       @param _link    BTP Address of the next BMC for the destination
     */
    function addRoute(string calldata _dst, string calldata _link) external;

    /**
       @notice Remove route to the BMC.
       @dev Caller must be an operator of BTP network.
       @param _dst     BTP Address of the destination BMC
     */
    function removeRoute(string calldata _dst) external;

    /**
       @notice Registers relay for the network.
       @dev Caller must be an operator of BTP network.
       @param _link     BTP Address of connected BMC
       @param _addrs     A list of Relays
     */
    function addRelay(string calldata _link, address[] memory _addrs) external;

    /**
       @notice Unregisters Relay for the network.
       @dev Caller must be an operator of BTP network.
       @param _link     BTP Address of connected BMC
       @param _addrs     A list of Relays
     */
    function removeRelay(string calldata _link, address _addrs) external;

    /**
       @notice Get registered services.
       @return _servicers   An array of Service.
     */
    function getServices()
        external
        view
        returns (Types.Service[] memory _servicers);

    /**
       @notice Get registered links.
       @return _links   An array of links ( BTP Addresses of the BMCs ).
     */
    function getLinks() external view returns (string[] memory _links);

    /**
       @notice Get routing information.
       @return _routes An array of Route.
     */
    function getRoutes() external view returns (Types.Route[] memory _routes);

    /**
       @notice Get registered relays.
       @param _link        BTP Address of the connected BMC.
       @return _relayes A list of relays.
     */
    function getRelays(string calldata _link)
        external
        view
        returns (address[] memory _relayes);

    /**
        @notice Get BSH services by name. Only called by BMC periphery.
        @param _serviceName BSH service name
        @return BSH service address
     */
    function getBshServiceByName(string memory _serviceName)
        external
        view
        returns (address);

    /**
        @notice Get link info. Only called by BMC periphery.
        @param _to link's BTP address
        @return Link info
     */
    function getLink(string memory _to)
        external
        view
        returns (Types.Link memory);

    /**
        @notice Get rotation sequence by link. Only called by BMC periphery.
        @param _prev BTP Address of the previous BMC
        @return Rotation sequence
     */
    function getLinkRxSeq(string calldata _prev)
        external
        view
        returns (uint256);

    /**
        @notice Get transaction sequence by link. Only called by BMC periphery.
        @param _prev BTP Address of the previous BMC
        @return Transaction sequence
     */
    function getLinkTxSeq(string calldata _prev)
        external
        view
        returns (uint256);

    /**
        @notice Get relays by link. Only called by BMC periphery.
        @param _prev BTP Address of the previous BMC
        @return List of relays' addresses
     */
    function getLinkRelays(string calldata _prev)
        external
        view
        returns (address[] memory);

    /**
        @notice Get relays status by link. Only called by BMC periphery.
        @param _prev BTP Address of the previous BMC
        @return Relay status of all relays
     */
    function getRelayStatusByLink(string memory _prev)
        external
        view
        returns (Types.RelayStats[] memory);

    /**
        @notice Update rotation sequence by link. Only called by BMC periphery.
        @param _prev BTP Address of the previous BMC
        @param _val increment value
     */
    function updateLinkRxSeq(string calldata _prev, uint256 _val) external;

    /**
        @notice Increase transaction sequence by 1.
        @param _prev BTP Address of the previous BMC
     */
    function updateLinkTxSeq(string memory _prev) external;

    /**
        @notice Add a reachable BTP address to link. Only called by BMC periphery.
        @param _prev BTP Address of the previous BMC
        @param _to BTP Address of the reachable
     */
    function updateLinkReachable(string memory _prev, string[] memory _to)
        external;

    /**
        @notice Remove a reachable BTP address. Only called by BMC periphery.
        @param _index reachable index to remove
     */
    function deleteLinkReachable(string memory _prev, uint256 _index) external;

    /**
        @notice Update relay status. Only called by BMC periphery.
        @param _relay relay address
        @param _blockCountVal increment value for block counter
        @param _msgCountVal increment value for message counter
     */
    function updateRelayStats(
        address _relay,
        uint256 _blockCountVal,
        uint256 _msgCountVal
    ) external;

    /**
        @notice resolve next BMC. Only called by BMC periphery.
        @param _dstNet net of BTP network address
        @return BTP address of next BMC and destinated BMC
     */
    function resolveRoute(string memory _dstNet)
        external
        view
        returns (string memory, string memory);

    /**
        @notice rotate relay for relay address. Only called by BMC periphery.
        @param _link BTP network address of connected BMC
        @param _currentHeight current block height of MTA from BMV
        @param _relayMsgHeight  block height of last relayed BTP Message
        @param _hasMsg check if message exists
        @return relay address
     */
    function rotateRelay(
        string memory _link,
        uint256 _currentHeight,
        uint256 _relayMsgHeight,
        bool _hasMsg
    ) external returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}