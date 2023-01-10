// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;
import "./interfaces/IBTSPeriphery.sol";
import "./interfaces/IBTSCore.sol";
import "./interfaces/IBMCPeriphery.sol";
import "./libraries/Types.sol";
import "./libraries/RLPEncodeStruct.sol";
import "./libraries/RLPDecodeStruct.sol";
import "./libraries/ParseAddress.sol";
import "./libraries/String.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
   @title BTSPeriphery contract
   @dev This contract is used to handle communications among BMCService and BTSCore contract
   @dev OwnerUpgradeable has been removed. This contract does not have its own Owners
        Instead, BTSCore manages ownership roles.
        Thus, BTSPeriphery should call btsCore.isOwner() and pass an address for verification
        in case of implementing restrictions, if needed, in the future. 
*/
contract BTSPeriphery is Initializable, IBTSPeriphery {
    using RLPEncodeStruct for Types.TransferCoin;
    using RLPEncodeStruct for Types.ServiceMessage;
    using RLPEncodeStruct for Types.Response;
    using RLPDecodeStruct for bytes;
    using SafeMathUpgradeable for uint256;
    using ParseAddress for address;
    using ParseAddress for string;
    using String for string;
    using String for uint256;

    /**   @notice Sends a receipt to user
        The `_from` sender
        The `_to` receiver.
        The `_sn` sequence number of service message.
        The `_assetDetails` a list of `_coinName` and `_value`  
    */
    event TransferStart(
        address indexed _from,
        string _to,
        uint256 _sn,
        Types.AssetTransferDetail[] _assetDetails
    );

    /**   @notice Sends a final notification to a user
        The `_from` sender
        The `_sn` sequence number of service message.
        The `_code` response code, i.e. RC_OK = 0, RC_ERR = 1
        The `_response` message of response if error  
    */
    event TransferEnd(
        address indexed _from,
        uint256 _sn,
        uint256 _code,
        string _response
    );

    /**
        Used to log the state of successful incoming transaction
    */
    event TransferReceived(
        string indexed _from,
        address indexed _to,
        uint256 _sn,
        Types.Asset[] _assetDetails
    );

    /**   @notice Notify that BSH contract has received unknown response
        The `_from` sender
        The `_sn` sequence number of service message
    */
    event UnknownResponse(string _from, uint256 _sn);

    IBMCPeriphery private bmc;
    IBTSCore internal btsCore;
    mapping(uint256 => Types.PendingTransferCoin) public requests; // a list of transferring requests
    string public constant serviceName = "bts"; //    BSH Service Name

    uint256 private constant RC_OK = 0;
    uint256 private constant RC_ERR = 1;
    uint256 private serialNo; //  a counter of sequence number of service message
    uint256 private numOfPendingRequests;

    mapping(address => bool) public blacklist;
    mapping(string => uint) public tokenLimit;
    uint256 private constant MAX_BATCH_SIZE = 15;

    modifier onlyBMC() {
        require(msg.sender == address(bmc), "Unauthorized");
        _;
    }

    modifier onlyBTSCore() {
        require(msg.sender == address(btsCore), "Unauthorized");
        _;
    }

    function initialize(address _bmc, address _btsCore) public initializer {
        bmc = IBMCPeriphery(_bmc);
        btsCore = IBTSCore(_btsCore);
        tokenLimit[btsCore.getNativeCoinName()] = type(uint256).max;
    }

    /**
     @notice Check whether BTSPeriphery has any pending transferring requests
     @return true or false
    */
    function hasPendingRequest() external view override returns (bool) {
        return numOfPendingRequests != 0;
    }

    /**
        @notice Add users to blacklist
        @param _address Address to blacklist
    */
    function addToBlacklist(string[] memory _address) external {
        require(msg.sender == address(this), "Unauthorized");
        require(_address.length <= MAX_BATCH_SIZE, "BatchMaxSizeExceed");
        for (uint i = 0; i < _address.length; i++) {
            try this.checkParseAddress(_address[i]) {
                blacklist[_address[i].parseAddress()] = true;
            } catch {
                revert("InvalidAddress");
            }
        }
    }

    /**
        @notice Remove users from blacklist
        @param _address Address to blacklist
    */
    function removeFromBlacklist(string[] memory _address) external {
        require(msg.sender == address(this), "Unauthorized");
        require(_address.length <= MAX_BATCH_SIZE, "BatchMaxSizeExceed");
        for (uint i = 0; i < _address.length; i++) {
            try this.checkParseAddress(_address[i]) {
                address addr = _address[i].parseAddress();
                require(blacklist[addr], "UserNotBlacklisted");
                delete blacklist[addr];
            } catch {
                revert("InvalidAddress");
            }
        }
    }

    /**
        @notice Set token limit
        @param _coinNames    Array of names of the coin
        @param _tokenLimits  Token limit for coins
    */
    function setTokenLimit(
        string[] memory _coinNames,
        uint256[] memory _tokenLimits
    ) external override {
        require(msg.sender == address(this) || msg.sender == address(btsCore), "Unauthorized");
        require(_coinNames.length == _tokenLimits.length,"InvalidParams");
        require(_coinNames.length <= MAX_BATCH_SIZE, "BatchMaxSizeExceed");
        for(uint i = 0; i < _coinNames.length; i++) {
            tokenLimit[_coinNames[i]] = _tokenLimits[i];
        }
    }

    function sendServiceMessage(
        address _from,
        string memory _to,
        string[] memory _coinNames,
        uint256[] memory _values,
        uint256[] memory _fees
    ) external override onlyBTSCore {
        //  Send Service Message to BMC
        //  If '_to' address is an invalid BTP Address format
        //  VM throws an error and revert(). Thus, it does not need
        //  a try_catch at this point
        (string memory _toNetwork, string memory _toAddress) = _to
            .splitBTPAddress();
        Types.Asset[] memory _assets = new Types.Asset[](_coinNames.length);
        Types.AssetTransferDetail[]
            memory _assetDetails = new Types.AssetTransferDetail[](
                _coinNames.length
            );
        for (uint256 i = 0; i < _coinNames.length; i++) {
            _assets[i] = Types.Asset(_coinNames[i], _values[i]);
            _assetDetails[i] = Types.AssetTransferDetail(
                _coinNames[i],
                _values[i],
                _fees[i]
            );
        }

        serialNo++;

        //  Because `stack is too deep`, must create `_strFrom` to waive this error
        //  `_strFrom` is a string type of an address `_from`
        string memory _strFrom = _from.toString();
        bmc.sendMessage(
            _toNetwork,
            serviceName,
            serialNo,
            Types
                .ServiceMessage(
                    Types.ServiceType.REQUEST_COIN_TRANSFER,
                    Types
                        .TransferCoin(_strFrom, _toAddress, _assets)
                        .encodeTransferCoinMsg()
                )
                .encodeServiceMessage()
        );
        //  Push pending tx into Record list
        requests[serialNo] = Types.PendingTransferCoin(
            _strFrom,
            _to,
            _coinNames,
            _values,
            _fees
        );
        numOfPendingRequests++;
        emit TransferStart(_from, _to, serialNo, _assetDetails);
    }

    /**
     @notice BSH handle BTP Message from BMC contract
     @dev Caller must be BMC contract only
     @param _from    An originated network address of a request
     @param _svc     A service name of BSH contract     
     @param _sn      A serial number of a service request 
     @param _msg     An RLP message of a service request/service response
    */
    function handleBTPMessage(
        string calldata _from,
        string calldata _svc,
        uint256 _sn,
        bytes calldata _msg
    ) external override onlyBMC {
        require(_svc.compareTo(serviceName) == true, "InvalidSvc");
        Types.ServiceMessage memory _sm = _msg.decodeServiceMessage();
        string memory errMsg;

        if (_sm.serviceType == Types.ServiceType.REQUEST_COIN_TRANSFER) {
            Types.TransferCoin memory _tc = _sm.data.decodeTransferCoinMsg();
            //  checking receiving address whether is a valid address
            //  revert() if not a valid one
            try this.checkParseAddress(_tc.to) {
                try this.handleRequestService(_tc.to, _tc.assets) {
                    sendResponseMessage(
                        Types.ServiceType.REPONSE_HANDLE_SERVICE,
                        _from,
                        _sn,
                        "",
                        RC_OK
                    );
                    emit TransferReceived(
                        _from,
                        _tc.to.parseAddress(),
                        _sn,
                        _tc.assets
                    );
                    return;
                } catch Error(string memory _err) {
                    errMsg = _err;
                }
            } catch {
                errMsg = "InvalidAddress";
            }
            sendResponseMessage(
                Types.ServiceType.REPONSE_HANDLE_SERVICE,
                _from,
                _sn,
                errMsg,
                RC_ERR
            );
        } else if (_sm.serviceType == Types.ServiceType.BLACKLIST_MESSAGE) {
            Types.BlacklistMessage memory _bm = _sm.data.decodeBlackListMsg();
            string[] memory addresses = _bm.addrs;

            if (_bm.serviceType == Types.BlacklistService.ADD_TO_BLACKLIST ) {
                try this.addToBlacklist(addresses) {
                    // send message to bmc
                    sendResponseMessage(
                        Types.ServiceType.BLACKLIST_MESSAGE,
                        _from,
                        _sn,
                        "AddedToBlacklist",
                        RC_OK
                    );
                    return;
                } catch {
                    errMsg = "ErrorAddToBlackList";
                }
            } else if (_bm.serviceType == Types.BlacklistService.REMOVE_FROM_BLACKLIST) {
                try this.removeFromBlacklist(addresses) {
                    // send message to bmc
                    sendResponseMessage(
                        Types.ServiceType.BLACKLIST_MESSAGE,
                        _from,
                        _sn,
                        "RemovedFromBlacklist",
                        RC_OK
                    );
                    return;
                } catch {
                    errMsg = "ErrorRemoveFromBlackList";
                }
            } else {
                errMsg = "BlacklistServiceTypeErr";
            }

            sendResponseMessage(
                Types.ServiceType.BLACKLIST_MESSAGE,
                _from,
                _sn,
                errMsg,
                RC_ERR
            );

        } else if (_sm.serviceType == Types.ServiceType.CHANGE_TOKEN_LIMIT) {
            Types.TokenLimitMessage memory _tl = _sm.data.decodeTokenLimitMsg();
            string[] memory coinNames = _tl.coinName;
            uint256[] memory tokenLimits = _tl.tokenLimit;

            try this.setTokenLimit(coinNames, tokenLimits) {
                sendResponseMessage(
                    Types.ServiceType.CHANGE_TOKEN_LIMIT,
                    _from,
                    _sn,
                    "ChangeTokenLimit",
                    RC_OK
                );
                return;
            } catch {
                errMsg = "ErrorChangeTokenLimit";
                sendResponseMessage(
                    Types.ServiceType.CHANGE_TOKEN_LIMIT,
                    _from,
                    _sn,
                    errMsg,
                    RC_ERR
                );
            }

        } else if (
            _sm.serviceType == Types.ServiceType.REPONSE_HANDLE_SERVICE
        ) {
            //  Check whether '_sn' is pending state
            require(bytes(requests[_sn].from).length != 0, "InvalidSN");
            Types.Response memory response = _sm.data.decodeResponse();
            //  @dev Not implement try_catch at this point
            //  + If RESPONSE_REQUEST_SERVICE:
            //      If RC_ERR, BTSCore proceeds a refund. If a refund is failed, BTSCore issues refundable Balance
            //      If RC_OK:
            //      - requested coin = native -> update aggregation fee (likely no issue)
            //      - requested coin = wrapped coin -> BTSCore calls itself to burn its tokens and update aggregation fee (likely no issue)
            //  The only issue, which might happen, is BTSCore's token balance lower than burning amount
            //  If so, there might be something went wrong before
            //  + If RESPONSE_FEE_GATHERING
            //      If RC_ERR, BTSCore saves charged fees back to `aggregationFee` state mapping variable
            //      If RC_OK: do nothing
            handleResponseService(_sn, response.code, response.message);
        } else if (_sm.serviceType == Types.ServiceType.UNKNOWN_TYPE) {
            emit UnknownResponse(_from, _sn);
        } else {
            //  If none of those types above, BSH responds a message of RES_UNKNOWN_TYPE
            sendResponseMessage(
                Types.ServiceType.UNKNOWN_TYPE,
                _from,
                _sn,
                "Unknown",
                RC_ERR
            );
        }
    }

    /**
     @notice BSH handle BTP Error from BMC contract
     @dev Caller must be BMC contract only 
     @param _svc     A service name of BSH contract     
     @param _sn      A serial number of a service request 
     @param _code    A response code of a message (RC_OK / RC_ERR)
     @param _msg     A response message
    */
    function handleBTPError(
        string calldata, /* _src */
        string calldata _svc,
        uint256 _sn,
        uint256 _code,
        string calldata _msg
    ) external override onlyBMC {
        require(_svc.compareTo(serviceName) == true, "InvalidSvc");
        require(bytes(requests[_sn].from).length != 0, "InvalidSN");
        string memory _emitMsg = string("errCode: ")
            .concat(", errMsg: ")
            .concat(_code.toString())
            .concat(_msg);
        handleResponseService(_sn, RC_ERR, _emitMsg);
    }

    function handleResponseService(
        uint256 _sn,
        uint256 _code,
        string memory _msg
    ) private {
        address _caller = requests[_sn].from.parseAddress();
        uint256 loop = requests[_sn].coinNames.length;
        require(loop <= MAX_BATCH_SIZE, "BatchNaxSizeExceed");
        for (uint256 i = 0; i < loop; i++) {
            btsCore.handleResponseService(
                _caller,
                requests[_sn].coinNames[i],
                requests[_sn].amounts[i],
                requests[_sn].fees[i],
                _code
            );
        }
        delete requests[_sn];
        numOfPendingRequests--;
        emit TransferEnd(_caller, _sn, _code, _msg);
    }

    /**
     @notice Handle a list of minting/transferring coins/tokens
     @dev Caller must be BMC contract only 
     @param _to          An address to receive coins/tokens    
     @param _assets      A list of requested coin respectively with an amount
    */
    function handleRequestService(
        string memory _to,
        Types.Asset[] memory _assets
    ) external {
        require(msg.sender == address(this), "Unauthorized");
        require(_assets.length <= MAX_BATCH_SIZE, "BatchMaxSizeExceed");
        for (uint256 i = 0; i < _assets.length; i++) {
            require(
                btsCore.isValidCoin(_assets[i].coinName) == true,
                "UnregisteredCoin"
            );
            checkTransferRestrictions(
                    _assets[i].coinName,
                    _to.parseAddress(),
                    _assets[i].value)
            ;
            //  @dev There might be many errors generating by BTSCore contract
            //  which includes also low-level error
            //  Thus, must use try_catch at this point so that it can return an expected response
            try
                btsCore.mint(
                    _to.parseAddress(),
                    _assets[i].coinName,
                    _assets[i].value
                )
            {} catch {
                revert("TransferFailed");
            }
        }
    }

    function sendResponseMessage(
        Types.ServiceType _serviceType,
        string memory _to,
        uint256 _sn,
        string memory _msg,
        uint256 _code
    ) private {
        bmc.sendMessage(
            _to,
            serviceName,
            _sn,
            Types
                .ServiceMessage(
                    _serviceType,
                    Types.Response(_code, _msg).encodeResponse()
                )
                .encodeServiceMessage()
        );
    }

    /**
     @notice BSH handle Gather Fee Message request from BMC contract
     @dev Caller must be BMC contract only
     @param _fa     A BTP address of fee aggregator
     @param _svc    A name of the service
    */
    function handleFeeGathering(string calldata _fa, string calldata _svc)
        external
        override
        onlyBMC
    {
        require(_svc.compareTo(serviceName) == true, "InvalidSvc");
        //  If adress of Fee Aggregator (_fa) is invalid BTP address format
        //  revert(). Then, BMC will catch this error
        //  @dev this part simply check whether `_fa` is splittable (`prefix` + `_net` + `dstAddr`)
        //  checking validity of `_net` and `dstAddr` does not belong to BTSPeriphery's scope
        _fa.splitBTPAddress();
        btsCore.transferFees(_fa);
    }

    //  @dev Solidity does not allow to use try_catch with internal function
    //  Thus, this is a work-around solution
    //  Since this function is basically checking whether a string address
    //  can be parsed to address type. Hence, it would not have any restrictions
    function checkParseAddress(string calldata _to) external pure {
        _to.parseAddress();
    }

    function checkTransferRestrictions(
        string memory _coinName,
        address _user,
        uint256 _value
    ) public view override {
        require(!blacklist[_user],"Blacklisted");
        require(tokenLimit[_coinName] >= _value ,"LimitExceed");
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

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
        bool isSPREmpty; //  add to check whether SPR is an empty struct
        //  It will not be included in serializing thereafter
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
        bytes[] txReceipts;
        EventProof[] ep;
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
        BLACKLIST_MESSAGE,
        CHANGE_TOKEN_LIMIT,
        UNKNOWN_TYPE
    }

    enum BlacklistService {
        ADD_TO_BLACKLIST,
        REMOVE_FROM_BLACKLIST
    }

    struct PendingTransferCoin {
        string from;
        string to;
        string[] coinNames;
        uint256[] amounts;
        uint256[] fees;
    }

    struct TransferCoin {
        string from;
        string to;
        Asset[] assets;
    }

    struct BlacklistMessage {
        BlacklistService serviceType;
        string[] addrs;
        string net;
    }

    struct TokenLimitMessage {
        string[] coinName;
        uint256[] tokenLimit;
        string net;
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
        bytes message; //  serializef Service Message from BSH
    }

    struct Connection {
        string from;
        string to;
    }

    struct EventMessage {
        string eventType;
        Connection conn;
    }

    struct BMCService {
        string serviceType;
        bytes payload;
    }

    struct GatherFeeMessage {
        string fa; //  BTP address of Fee Aggregator
        string[] svcs; //  a list of services
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

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

    function toString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint256 len;
        for (uint256 j = _i; j != 0; j /= 10) {
            len++;
        }
        bytes memory bstr = new bytes(len);
        for (uint256 k = len; k > 0; k--) {
            bstr[k - 1] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;

import "./RLPEncode.sol";
import "./Types.sol";

library RLPEncodeStruct {
    using RLPEncode for bytes;
    using RLPEncode for string;
    using RLPEncode for uint256;
    using RLPEncode for address;
    using RLPEncode for int256;

    using RLPEncodeStruct for Types.BlockHeader;
    using RLPEncodeStruct for Types.BlockWitness;
    using RLPEncodeStruct for Types.BlockUpdate;
    using RLPEncodeStruct for Types.BlockProof;
    using RLPEncodeStruct for Types.EventProof;
    using RLPEncodeStruct for Types.ReceiptProof;
    using RLPEncodeStruct for Types.Votes;
    using RLPEncodeStruct for Types.RelayMessage;

    uint8 private constant LIST_SHORT_START = 0xc0;
    uint8 private constant LIST_LONG_START = 0xf7;

    function encodeBMCService(Types.BMCService memory _bs)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp = abi.encodePacked(
            _bs.serviceType.encodeString(),
            _bs.payload.encodeBytes()
        );
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
            temp = abi.encodePacked(_gfm.svcs[i].encodeString());
            _rlp = abi.encodePacked(_rlp, temp);
        }
        _rlp = abi.encodePacked(
            _gfm.fa.encodeString(),
            addLength(_rlp.length, false),
            _rlp
        );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeEventMessage(Types.EventMessage memory _em)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp = abi.encodePacked(
            _em.conn.from.encodeString(),
            _em.conn.to.encodeString()
        );
        _rlp = abi.encodePacked(
            _em.eventType.encodeString(),
            addLength(_rlp.length, false),
            _rlp
        );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeCoinRegister(string[] memory _coins)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp;
        bytes memory temp;
        for (uint256 i = 0; i < _coins.length; i++) {
            temp = abi.encodePacked(_coins[i].encodeString());
            _rlp = abi.encodePacked(_rlp, temp);
        }
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeBMCMessage(Types.BMCMessage memory _bm)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp = abi.encodePacked(
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
        bytes memory _rlp = abi.encodePacked(
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
        bytes memory _rlp = abi.encodePacked(
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
        bytes memory _rlp = abi.encodePacked(
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

    function encodeReceiptProof(Types.ReceiptProof memory _rp)
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
    }

    function encodeBlockProof(Types.BlockProof memory _bp)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory _rlp = abi.encodePacked(
            _bp.bh.encodeBlockHeader().encodeBytes(),
            _bp.bw.encodeBlockWitness().encodeBytes()
        );
        return abi.encodePacked(addLength(_rlp.length, false), _rlp);
    }

    function encodeRelayMessage(Types.RelayMessage memory _rm)
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
    }

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
pragma solidity >=0.8.0;

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
        uint256 nBytes = bitLength(self) / 8 + 1;
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
        require(
            -MAX_INT128 - 1 <= n && n <= MAX_INT128,
            "outOfBounds: [-2^128-1, 2^128]"
        );
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
        require(
            length >= MAX_UINT120 && length < MAX_UINT128,
            "outOfBounds: [0, 2^128]"
        );
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
pragma solidity >=0.8.0;
pragma abicoder v2;

import "./RLPDecode.sol";
import "./Types.sol";

//import "./RLPEncode.sol";

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

    function decodeEventMessage(bytes memory _rlp)
        internal
        pure
        returns (Types.EventMessage memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        return
            Types.EventMessage(
                string(ls[0].toBytes()),
                Types.Connection(
                    string(ls[1].toList()[0].toBytes()),
                    string(ls[1].toList()[1].toBytes())
                )
            );
    }

    function decodeCoinRegister(bytes memory _rlp)
        internal
        pure
        returns (string[] memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        string[] memory _coins = new string[](ls.length);
        for (uint256 i = 0; i < ls.length; i++) {
            _coins[i] = string(ls[i].toBytes());
        }
        return _coins;
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

    function decodeBlackListMsg(bytes memory _rlp)
        internal
        pure
        returns(Types.BlacklistMessage memory) 
    {

        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();

        RLPDecode.RLPItem[] memory subList = ls[1].toList();
        string[] memory _addrs = new string[](subList.length);
        for (uint256 i = 0; i < subList.length; i++) {
            _addrs[i] = string(subList[i].toBytes());
        }
        return
            Types.BlacklistMessage(
                Types.BlacklistService(ls[0].toUint()),
                _addrs,
                string(ls[2].toBytes())
            );
    }

    function decodeTokenLimitMsg(bytes memory _rlp)
        internal
        pure
        returns(Types.TokenLimitMessage memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();

        RLPDecode.RLPItem[] memory subList1 = ls[0].toList();
        string[] memory _names = new string[](subList1.length);
        for (uint256 i = 0; i < subList1.length; i++) {
            _names[i] = string(subList1[i].toBytes());
        }

        RLPDecode.RLPItem[] memory subList2 = ls[1].toList();
        uint256[] memory _limits = new uint256[](subList2.length);
        for (uint256 i = 0; i < subList2.length; i++) {
            _limits[i] = uint256(subList2[i].toUint());
        }

        return 
            Types.TokenLimitMessage(
                _names,
                _limits,
                string(ls[2].toBytes())
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
        RLPDecode.RLPItem[] memory subList = ls[10]
            .toBytes()
            .toRlpItem()
            .toList();
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

    function decodeReceiptProof(bytes memory _rlp)
        internal
        pure
        returns (Types.ReceiptProof memory)
    {
        RLPDecode.RLPItem[] memory ls = _rlp.toRlpItem().toList();
        RLPDecode.RLPItem[] memory receiptList = ls[1]
            .toBytes()
            .toRlpItem()
            .toList();

        bytes[] memory txReceipts = new bytes[](receiptList.length);
        for (uint256 i = 0; i < receiptList.length; i++) {
            txReceipts[i] = receiptList[i].toBytes();
        }

        Types.EventProof[] memory _ep = new Types.EventProof[](
            ls[2].toList().length
        );
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
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

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
            return int256(toUint(item)) - int256(2**(toBytes(item).length * 8));
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
        if (len > 0) {
            // left over bytes. Mask is used to remove unwanted bytes from the word
            uint256 mask = 256**(WORD_SIZE - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask)) // zero out src
                let destpart := and(mload(dest), mask) // retrieve the bytes
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

/*
 * Utility library of inline functions on addresses
 */
library ParseAddress {
    function parseAddress(string memory account)
        internal
        pure
        returns (address accountAddress)
    {
        bytes memory accountBytes = bytes(account);
        require(
            accountBytes.length == 42 &&
                accountBytes[0] == bytes1("0") &&
                accountBytes[1] == bytes1("x"),
            "Invalid address format"
        );

        // create a new fixed-size byte array for the ascii bytes of the address.
        bytes memory accountAddressBytes = new bytes(20);

        // declare variable types.
        uint8 b;
        uint8 nibble;
        uint8 asciiOffset;

        for (uint256 i = 0; i < 40; i++) {
            // get the byte in question.
            b = uint8(accountBytes[i + 2]);

            bool isValidASCII = true;
            // ensure that the byte is a valid ascii character (0-9, A-F, a-f)
            if (b < 48) isValidASCII = false;
            if (57 < b && b < 65) isValidASCII = false;
            if (70 < b && b < 97) isValidASCII = false;
            if (102 < b) isValidASCII = false; //bytes(hex"");

            // If string contains invalid ASCII characters, revert()
            if (!isValidASCII) revert("Invalid address");

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
                    bytes1(16 * nibble + (b - asciiOffset))
                );
            }
        }

        // pack up the fixed-size byte array and cast it to accountAddress.
        bytes memory packed = abi.encodePacked(accountAddressBytes);
        assembly {
            accountAddress := mload(add(packed, 20))
        }

        // return false in the event the account conversion returned null address.
        if (accountAddress == address(0)) {
            // ensure that provided address is not also the null address first.
            for (uint256 i = 2; i < accountBytes.length; i++)
                require(accountBytes[i] == hex"30", "Invalid address");
        }

        // get the capitalized characters in the actual checksum.
        //string memory actual = _toChecksumString(accountAddress);

        // compare provided string to actual checksum string to test for validity.
        //TODO: check with ICONDAO team, this fails due to the capitalization of the actual address
        /* require(
            keccak256(abi.encodePacked(actual)) ==
                keccak256(abi.encodePacked(account)),
            "Invalid checksum"
        ); */
    }

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
            asciiBytes[2 * i] = bytes1(leftNibble + asciiOffset);

            // get the offset from nibble value to ascii character for right nibble.
            asciiOffset = _getAsciiOffset(rightNibble, rightCaps);

            // add the converted character to the byte array.
            asciiBytes[2 * i + 1] = bytes1(rightNibble + asciiOffset);
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
                        bytes1(16 * nibble + (b - asciiOffset))
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
            asciiBytes[2 * i] = bytes1(
                leftNibble + (leftNibble < 10 ? 48 : 87)
            );
            asciiBytes[2 * i + 1] = bytes1(
                rightNibble + (rightNibble < 10 ? 48 : 87)
            );
        }

        return string(asciiBytes);
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;

import "./IBSH.sol";

/**
   @title Interface of BTSPeriphery contract
   @dev This contract is used to handle communications among BMCService and BTSCore contract
*/
interface IBTSPeriphery is IBSH {
    /**
     @notice Check whether BTSPeriphery has any pending transferring requests
     @return true or false
    */
    function hasPendingRequest() external view returns (bool);

    /**
     @notice Send Service Message from BTSCore contract to BMCService contract
     @dev Caller must be BTSCore only
     @param _to             A network address of destination chain
     @param _coinNames      A list of coin name that are requested to transfer  
     @param _values         A list of an amount to receive at destination chain respectively with its coin name
     @param _fees           A list of an amount of charging fee respectively with its coin name 
    */
    function sendServiceMessage(
        address _from,
        string calldata _to,
        string[] memory _coinNames,
        uint256[] memory _values,
        uint256[] memory _fees
    ) external;

    /** */
    function setTokenLimit(
        string[] memory _coinNames,
        uint256[] memory _tokenLimits
    ) external;
    /**
     @notice BSH handle BTP Message from BMC contract
     @dev Caller must be BMC contract only
     @param _from    An originated network address of a request
     @param _svc     A service name of BTSPeriphery contract     
     @param _sn      A serial number of a service request 
     @param _msg     An RLP message of a service request/service response
    */
    function handleBTPMessage(
        string calldata _from,
        string calldata _svc,
        uint256 _sn,
        bytes calldata _msg
    ) external override;

    /**
     @notice BSH handle BTP Error from BMC contract
     @dev Caller must be BMC contract only 
     @param _svc     A service name of BTSPeriphery contract     
     @param _sn      A serial number of a service request 
     @param _code    A response code of a message (RC_OK / RC_ERR)
     @param _msg     A response message
    */
    function handleBTPError(
        string calldata _src,
        string calldata _svc,
        uint256 _sn,
        uint256 _code,
        string calldata _msg
    ) external override;

    /**
     @notice BSH handle Gather Fee Message request from BMC contract
     @dev Caller must be BMC contract only
     @param _fa     A BTP address of fee aggregator
     @param _svc    A name of the service
    */
    function handleFeeGathering(string calldata _fa, string calldata _svc)
        external
        override;

    /**
        @notice Check if transfer is restricted
        @param _coinName    Name of the coin
        @param _user        Address to transfer from
        @param _value       Amount to transfer
    */
    function checkTransferRestrictions(
        string memory _coinName,
        address _user,
        uint256 _value
    ) external;

}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;

import "../libraries/Types.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/**
   @title Interface of BTSCore contract
   @dev This contract is used to handle coin transferring service
   Note: The coin of following interface can be:
   Native Coin : The native coin of this chain
   Wrapped Native Coin : A tokenized ERC20 version of another native coin like ICX
*/
interface IBTSCore {
    /**
       @notice Adding another Onwer.
       @dev Caller must be an Onwer of BTP network
       @param _owner    Address of a new Onwer.
    */
    function addOwner(address _owner) external;

    /**
        @notice Get name of nativecoin
        @dev caller can be any
        @return Name of nativecoin
    */
    function getNativeCoinName() external view returns (string memory);

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
       @notice Get a list of current Owners
       @dev Caller can be ANY
       @return      An array of addresses of current Owners
    */

    function getOwners() external view returns (address[] memory);

    /**
        @notice update BTS Periphery address.
        @dev Caller must be an Owner of this contract
        _btsPeriphery Must be different with the existing one.
        @param _btsPeriphery    BTSPeriphery contract address.
    */
    function updateBTSPeriphery(address _btsPeriphery) external;

    /**
        @notice set fee ratio.
        @dev Caller must be an Owner of this contract
        The transfer fee is calculated by feeNumerator/FEE_DEMONINATOR. 
        The feeNumetator should be less than FEE_DEMONINATOR
        _feeNumerator is set to `10` in construction by default, which means the default fee ratio is 0.1%.
        @param _feeNumerator    the fee numerator
    */
    function setFeeRatio(
        string calldata _name,
        uint256 _feeNumerator,
        uint256 _fixedFee
    ) external;

    /**
        @notice Registers a wrapped coin and id number of a supporting coin.
        @dev Caller must be an Owner of this contract
        _name Must be different with the native coin name.
        _symbol symbol name for wrapped coin.
        _decimals decimal number
        @param _name    Coin name. 
    */
    function register(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        uint256 _feeNumerator,
        uint256 _fixedFee,
        address _addr
    ) external;

    /**
       @notice Return all supported coins names
       @dev 
       @return _names   An array of strings.
    */
    function coinNames() external view returns (string[] memory _names);

    /**
       @notice  Return an _id number of Coin whose name is the same with given _coinName.
       @dev     Return nullempty if not found.
       @return  _coinId     An ID number of _coinName.
    */
    function coinId(string calldata _coinName)
        external
        view
        returns (address _coinId);

    /**
       @notice  Check Validity of a _coinName
       @dev     Call by BTSPeriphery contract to validate a requested _coinName
       @return  _valid     true of false
    */
    function isValidCoin(string calldata _coinName)
        external
        view
        returns (bool _valid);

    /**
        @notice Get fee numerator and fixed fee
        @dev caller can be any
        @param _coinName Coin name
        @return _feeNumerator Fee numerator for given coin
        @return _fixedFee Fixed fee for given coin
    */
    function feeRatio(string calldata _coinName)
        external
        view
        returns (uint _feeNumerator, uint _fixedFee);

    /**
        @notice Return a usable/locked/refundable balance of an account based on coinName.
        @return _usableBalance the balance that users are holding.
        @return _lockedBalance when users transfer the coin, 
                it will be locked until getting the Service Message Response.
        @return _refundableBalance refundable balance is the balance that will be refunded to users.
    */
    function balanceOf(address _owner, string memory _coinName)
        external
        view
        returns (
            uint256 _usableBalance,
            uint256 _lockedBalance,
            uint256 _refundableBalance,
            uint256 _userBalance
        );

    /**
        @notice Return a list Balance of an account.
        @dev The order of request's coinNames must be the same with the order of return balance
        Return 0 if not found.
        @return _usableBalances         An array of Usable Balances
        @return _lockedBalances         An array of Locked Balances
        @return _refundableBalances     An array of Refundable Balances
    */
    function balanceOfBatch(address _owner, string[] calldata _coinNames)
        external
        view
        returns (
            uint256[] memory _usableBalances,
            uint256[] memory _lockedBalances,
            uint256[] memory _refundableBalances,
            uint256[] memory _userBalances
        );

    /**
        @notice Return a list accumulated Fees.
        @dev only return the asset that has Asset's value greater than 0
        @return _accumulatedFees An array of Asset
    */
    function getAccumulatedFees()
        external
        view
        returns (Types.Asset[] memory _accumulatedFees);

    /**
       @notice Allow users to deposit `msg.value` native coin into a BTSCore contract.
       @dev MUST specify msg.value
       @param _to  An address that a user expects to receive an amount of tokens.
    */
    function transferNativeCoin(string calldata _to) external payable;

    /**
       @notice Allow users to deposit an amount of wrapped native coin `_coinName` from the `msg.sender` address into the BTSCore contract.
       @dev Caller must set to approve that the wrapped tokens can be transferred out of the `msg.sender` account by BTSCore contract.
       It MUST revert if the balance of the holder for token `_coinName` is lower than the `_value` sent.
       @param _coinName    A given name of a wrapped coin 
       @param _value       An amount request to transfer.
       @param _to          Target BTP address.
    */
    function transfer(
        string calldata _coinName,
        uint256 _value,
        string calldata _to
    ) external;

    /**
       @notice Allow users to transfer multiple coins/wrapped coins to another chain
       @dev Caller must set to approve that the wrapped tokens can be transferred out of the `msg.sender` account by BTSCore contract.
       It MUST revert if the balance of the holder for token `_coinName` is lower than the `_value` sent.
       In case of transferring a native coin, it also checks `msg.value` with `_values[i]`
       It MUST revert if `msg.value` is not equal to `_values[i]`
       The number of requested coins MUST be as the same as the number of requested values
       The requested coins and values MUST be matched respectively
       @param _coinNames    A list of requested transferring coins/wrapped coins
       @param _values       A list of requested transferring values respectively with its coin name
       @param _to          Target BTP address.
    */
    function transferBatch(
        string[] memory _coinNames,
        uint256[] memory _values,
        string calldata _to
    ) external payable;

    /**
        @notice Reclaim the token's refundable balance by an owner.
        @dev Caller must be an owner of coin
        The amount to claim must be smaller or equal than refundable balance
        @param _coinName   A given name of coin
        @param _value       An amount of re-claiming tokens
    */
    function reclaim(string calldata _coinName, uint256 _value) external;

    /**
        @notice mint the wrapped coin.
        @dev Caller must be an BTSPeriphery contract
        Invalid _coinName will have an _id = 0. However, _id = 0 is also dedicated to Native Coin
        Thus, BTSPeriphery will check a validity of a requested _coinName before calling
        for the _coinName indicates with id = 0, it should send the Native Coin (Example: PRA) to user account
        @param _to    the account receive the minted coin
        @param _coinName    coin name
        @param _value    the minted amount   
    */
    function mint(
        address _to,
        string calldata _coinName,
        uint256 _value
    ) external;

    /**
        @notice Handle a request of Fee Gathering
        @dev    Caller must be an BTSPeriphery contract
        @param  _fa    BTP Address of Fee Aggregator 
    */
    function transferFees(string calldata _fa) external;

    /**
        @notice Handle a response of a requested service
        @dev Caller must be an BTSPeriphery contract
        @param _requester   An address of originator of a requested service
        @param _coinName    A name of requested coin
        @param _value       An amount to receive on a destination chain
        @param _fee         An amount of charged fee
    */
    function handleResponseService(
        address _requester,
        string calldata _coinName,
        uint256 _value,
        uint256 _fee,
        uint256 _rspCode
    ) external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;

interface IBSH {
    /**
     @notice BSH handle BTP Message from BMC contract
     @dev Caller must be BMC contract only
     @param _from    An originated network address of a request
     @param _svc     A service name of BSH contract     
     @param _sn      A serial number of a service request 
     @param _msg     An RLP message of a service request/service response
    */
    function handleBTPMessage(
        string calldata _from,
        string calldata _svc,
        uint256 _sn,
        bytes calldata _msg
    ) external;

    /**
     @notice BSH handle BTP Error from BMC contract
     @dev Caller must be BMC contract only 
     @param _svc     A service name of BSH contract     
     @param _sn      A serial number of a service request 
     @param _code    A response code of a message (RC_OK / RC_ERR)
     @param _msg     A response message
    */
    function handleBTPError(
        string calldata _src,
        string calldata _svc,
        uint256 _sn,
        uint256 _code,
        string calldata _msg
    ) external;

    /**
     @notice BSH handle Gather Fee Message request from BMC contract
     @dev Caller must be BMC contract only
     @param _fa     A BTP address of fee aggregator
     @param _svc    A name of the service
    */
    function handleFeeGathering(string calldata _fa, string calldata _svc)
        external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}