// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./interfaces/IBMCManagement.sol";
import "./interfaces/IBMCPeriphery.sol";
import "./libraries/ParseAddress.sol";
import "./libraries/RLPEncode.sol";
import "./libraries/RLPEncodeStruct.sol";
import "./libraries/String.sol";
import "./libraries/Types.sol";
import "./libraries/Utils.sol";

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract BMCManagement is IBMCManagement, Initializable {
    using ParseAddress for address;
    using ParseAddress for string;
    using RLPEncode for bytes;
    using RLPEncode for string;
    using RLPEncodeStruct for uint256;
    using RLPEncodeStruct for Types.BMCService;
    using String for string;
    using Utils for uint256;
    using Utils for string[];

    mapping(address => bool) private _owners;
    uint256 private numOfOwner;

    mapping(string => address) private bshServices;
    mapping(address => Types.RelayStats) private relayStats;
    mapping(string => string) private routes;
    mapping(string => Types.Link) internal links; // should be private, temporarily set internal for testing
    string[] private listBSHNames;
    string[] private listRouteKeys;
    string[] private listLinkNames;
    address private bmcPeriphery;

    uint256 public serialNo;

    address[] private addrs;

    // Use to search by substring
    mapping(string => string) private getRouteDstFromNet;
    mapping(string => string) private getLinkFromNet;
    mapping(string => Types.Tuple) private getLinkFromReachableNet;

    uint256 private constant BLOCK_INTERVAL_MSEC = 1000;

    modifier hasPermission {
        require(_owners[msg.sender] == true, "BMCRevertUnauthorized");
        _;
    }

    modifier onlyBMCPeriphery {
        require(msg.sender == bmcPeriphery, "BMCRevertUnauthorized");
        _;
    }

    function initialize() public initializer {
        _owners[msg.sender] = true;
        numOfOwner++;
    }

    function setBMCPeriphery(address _addr) external override hasPermission {
        require(_addr != address(0), "BMCRevertInvalidAddress");
        require(_addr != bmcPeriphery, "BMCRevertAlreadyExistsBMCPeriphery");
        bmcPeriphery = _addr;
    }

    /*****************************************************************************************
                                        Add Authorized Owner of Contract
        - addOwner(): register additional Owner of this Contract
        - removeOwner(): un-register existing Owner of this Contract. Unable to remove last
        - isOwner(): checking Ownership of an arbitrary address
    *****************************************************************************************/

    /**
       @notice Adding another Onwer.
       @dev Caller must be an Onwer of BTP network
       @param _owner    Address of a new Onwer.
   */
    function addOwner(address _owner) external override hasPermission {
        _owners[_owner] = true;
        numOfOwner++;
    }

    /**
       @notice Removing an existing Owner.
       @dev Caller must be an Owner of BTP network
       @dev If only one Owner left, unable to remove the last Owner
       @param _owner    Address of an Owner to be removed.
     */
    function removeOwner(address _owner) external override hasPermission {
        require(numOfOwner > 1, "BMCRevertLastOwner");
        require(_owners[_owner] == true, "BMCRevertNotExistsPermission");
        delete _owners[_owner];
        numOfOwner--;
    }

    /**
       @notice Checking whether one specific address has Owner role.
       @dev Caller can be ANY
       @param _owner    Address needs to verify.
    */
    function isOwner(address _owner) external view override returns (bool) {
        return _owners[_owner];
    }

    /**
       @notice Add the smart contract for the service.
       @dev Caller must be an operator of BTP network.
       @param _svc     Name of the service
       @param _addr    Service's contract address
     */
    function addService(string memory _svc, address _addr)
        external
        override
        hasPermission
    {
        require(_addr != address(0), "BMCRevertInvalidAddress");
        require(bshServices[_svc] == address(0), "BMCRevertAlreadyExistsBSH");
        bshServices[_svc] = _addr;
        listBSHNames.push(_svc);
    }

    /**
       @notice Unregisters the smart contract for the service.  
       @dev Caller must be an operator of BTP network.
       @param _svc     Name of the service
   */
    function removeService(string memory _svc) external override hasPermission {
        require(bshServices[_svc] != address(0), "BMCRevertNotExistsBSH");
        delete bshServices[_svc];
        listBSHNames.remove(_svc);
    }

    /**
       @notice Get registered services.
       @return _servicers   An array of Service.
    */
    function getServices()
        external
        view
        override
        returns (Types.Service[] memory)
    {
        Types.Service[] memory services =
            new Types.Service[](listBSHNames.length);
        for (uint256 i = 0; i < listBSHNames.length; i++) {
            services[i] = Types.Service(
                listBSHNames[i],
                bshServices[listBSHNames[i]]
            );
        }
        return services;
    }

    /**
       @notice Initializes status information for the link.
       @dev Caller must be an operator of BTP network.
       @param _link    BTP Address of connected BMC
   */
    function addLink(string calldata _link) external override hasPermission {
        (string memory _net, ) = _link.splitBTPAddress();
        require(
            links[_link].isConnected == false,
            "BMCRevertAlreadyExistsLink"
        );
        links[_link] = Types.Link(
            new address[](0),
            new string[](0),
            0,
            0,
            BLOCK_INTERVAL_MSEC,
            0,
            10,
            3,
            0,
            0,
            0,
            0,
            true
        );

        // propagate an event "LINK"
        propagateInternal("Link", _link);

        string[] memory _links = listLinkNames; 

        listLinkNames.push(_link);
        getLinkFromNet[_net] = _link;

        // init link
        sendInternal(_link, "Init", _links);
    }

    /**
       @notice Removes the link and status information. 
       @dev Caller must be an operator of BTP network.
       @param _link    BTP Address of connected BMC
   */
    function removeLink(string calldata _link) external override hasPermission {
        require(links[_link].isConnected == true, "BMCRevertNotExistsLink");
        delete links[_link];
        (string memory _net, ) = _link.splitBTPAddress();
        delete getLinkFromNet[_net];
        propagateInternal("Unlink", _link);
        listLinkNames.remove(_link);
    }

    /**
       @notice Get registered links.
       @return _links   An array of links ( BTP Addresses of the BMCs ).
    */
    function getLinks() external view override returns (string[] memory) {
        return listLinkNames;
    }

    function setLink(
        string memory _link,
        uint256 _blockInterval,
        uint256 _maxAggregation,
        uint256 _delayLimit
    ) external override hasPermission {
        require(links[_link].isConnected == true, "BMCRevertNotExistsLink");
        require(
            _maxAggregation >= 1 && _delayLimit >= 1,
            "BMCRevertInvalidParam"
        );
        Types.Link memory link = links[_link];
        uint256 _scale = link.blockIntervalSrc.getScale(link.blockIntervalDst);
        bool resetRotateHeight = false;
        if (link.maxAggregation.getRotateTerm(_scale) == 0) {
            resetRotateHeight = true;
        }
        link.blockIntervalDst = _blockInterval;
        link.maxAggregation = _maxAggregation;
        link.delayLimit = _delayLimit;

        _scale = link.blockIntervalSrc.getScale(_blockInterval);
        uint256 _rotateTerm = _maxAggregation.getRotateTerm(_scale);
        if (resetRotateHeight && _rotateTerm > 0) {
            link.rotateHeight = block.number + _rotateTerm;
            link.rxHeight = block.number;
            string memory _net;
            (_net, ) = _link.splitBTPAddress();
        }
        links[_link] = link;
    }

    function rotateRelay(
        string memory _link,
        uint256 _currentHeight,
        uint256 _relayMsgHeight,
        bool _hasMsg
    ) external override onlyBMCPeriphery returns (address) {
        /*
            @dev Solidity does not support calculate rational numbers/floating numbers
            thus, a division of _blockIntervalSrc and _blockIntervalDst should be
            scaled by 10^6 to minimize proportional error
        */
        Types.Link memory link = links[_link];
        uint256 _scale = link.blockIntervalSrc.getScale(link.blockIntervalDst);
        uint256 _rotateTerm = link.maxAggregation.getRotateTerm(_scale);
        uint256 _baseHeight;
        uint256 _rotateCount;
        if (_rotateTerm > 0) {
            if (_hasMsg) {
                //  Note that, Relay has to relay this event immediately to BMC
                //  upon receiving this event. However, Relay is allowed to hold
                //  no later than 'delay_limit'. Thus, guessHeight comes up
                //  Arrival time of BTP Message identified by a block height
                //  BMC starts guessing when an event of 'RelayMessage' was thrown by another BMC
                //  which is 'guessHeight' and the time BMC receiving this event is 'currentHeight'
                //  If there is any delay, 'guessHeight' is likely less than 'currentHeight'
                uint256 _guessHeight =
                    link.rxHeight +
                        uint256((_relayMsgHeight - link.rxHeightSrc) * 10**6)
                            .ceilDiv(_scale) -
                        1;

                if (_guessHeight > _currentHeight) {
                    _guessHeight = _currentHeight;
                }
                //  Python implementation as:
                //  rotate_count = math.ceil((guess_height - self.rotate_height)/rotate_term)
                //  the following code re-write it with using unsigned integer
                if (_guessHeight < link.rotateHeight) {
                    _rotateCount =
                        (link.rotateHeight - _guessHeight).ceilDiv(
                            _rotateTerm
                        ) -
                        1;
                } else {
                    _rotateCount = (_guessHeight - link.rotateHeight).ceilDiv(
                        _rotateTerm
                    );
                }
                //  No need to check this if using unsigned integer as above
                // if (_rotateCount < 0) {
                //     _rotateCount = 0;
                // }

                _baseHeight =
                    link.rotateHeight +
                    ((_rotateCount - 1) * _rotateTerm);
                /*  Python implementation as:
                //  skip_count = math.ceil((current_height - guess_height)/self.delay_limit) - 1
                //  In case that 'current_height' = 'guess_height'
                //  it might have an error calculation if using unsigned integer
                //  Thus, 'skipCount - 1' is moved into if_statement
                //  For example:
                //     + 'currentHeight' = 'guessHeight' 
                //        => skipCount = 0 
                //        => no delay
                //     + 'currentHeight' > 'guessHeight' and 'currentHeight' - 'guessHeight' <= 'delay_limit' 
                //        => ceil(('currentHeight' - 'guessHeight') / 'delay_limit') = 1
                //        => skipCount = skipCount - 1 = 0
                //        => not out of 'delay_limit'
                //        => accepted
                //     + 'currentHeight' > 'guessHeight' and 'currentHeight' - 'guessHeight' > 'delay_limit'
                //        => ceil(('currentHeight' - 'guessHeight') / 'delay_limit') = 2
                //        => skipCount = skipCount - 1 = 1
                //        => out of 'delay_limit'
                //        => rejected and move to next Relay
                */
                uint256 _skipCount =
                    (_currentHeight - _guessHeight).ceilDiv(link.delayLimit);

                if (_skipCount > 0) {
                    _skipCount = _skipCount - 1;
                    _rotateCount += _skipCount;
                    _baseHeight = _currentHeight;
                }
                link.rxHeight = _currentHeight;
                link.rxHeightSrc = _relayMsgHeight;
                links[_link] = link;
            } else {
                if (_currentHeight < link.rotateHeight) {
                    _rotateCount =
                        (link.rotateHeight - _currentHeight).ceilDiv(
                            _rotateTerm
                        ) -
                        1;
                } else {
                    _rotateCount = (_currentHeight - link.rotateHeight).ceilDiv(
                        _rotateTerm
                    );
                }
                _baseHeight =
                    link.rotateHeight +
                    ((_rotateCount - 1) * _rotateTerm);
            }
            return rotate(_link, _rotateTerm, _rotateCount, _baseHeight);
        }
        return address(0);
    }

    function rotate(
        string memory _link,
        uint256 _rotateTerm,
        uint256 _rotateCount,
        uint256 _baseHeight
    ) internal returns (address) {
        Types.Link memory link = links[_link];
        if (_rotateTerm > 0 && _rotateCount > 0) {
            link.rotateHeight = _baseHeight + _rotateTerm;
            link.relayIdx = link.relayIdx + _rotateCount;
            if (link.relayIdx >= link.relays.length) {
                link.relayIdx = link.relayIdx % link.relays.length;
            }
            links[_link] = link;
        }
        return link.relays[link.relayIdx];
    }

    function propagateInternal(
        string memory _serviceType,
        string calldata _link
    ) private {
        bytes memory _rlpBytes;
        _rlpBytes = abi.encodePacked(_rlpBytes, _link.encodeString());

        _rlpBytes = abi.encodePacked(
            _rlpBytes.length.addLength(false),
            _rlpBytes
        );

        // encode payload
        _rlpBytes = abi
            .encodePacked(_rlpBytes.length.addLength(false), _rlpBytes)
            .encodeBytes();

        for (uint256 i = 0; i < listLinkNames.length; i++) {
            if (links[listLinkNames[i]].isConnected) {
                (string memory _net, ) = listLinkNames[i].splitBTPAddress();
                IBMCPeriphery(bmcPeriphery).sendMessage(
                    _net,
                    "bmc",
                    0,
                    Types.BMCService(_serviceType, _rlpBytes).encodeBMCService()
                );
            }
        }
    }

    function sendInternal(
        string memory _target,
        string memory _serviceType,
        string[] memory _links
    ) private {
        bytes memory _rlpBytes;
        if (_links.length == 0) {
            _rlpBytes = abi.encodePacked(RLPEncodeStruct.LIST_SHORT_START);
        } else {
            for (uint256 i = 0; i < _links.length; i++)
                _rlpBytes = abi.encodePacked(_rlpBytes, _links[i].encodeString());
            // encode target's reachable list
            _rlpBytes = abi.encodePacked(
                _rlpBytes.length.addLength(false),
                _rlpBytes
            );
        }
        // encode payload
        _rlpBytes = abi
            .encodePacked(_rlpBytes.length.addLength(false), _rlpBytes)
            .encodeBytes();

        (string memory _net, ) = _target.splitBTPAddress();
        IBMCPeriphery(bmcPeriphery).sendMessage(
            _net,
            "bmc",
            0,
            Types.BMCService(_serviceType, _rlpBytes).encodeBMCService()
        );
    }

    /**
       @notice Add route to the BMC.
       @dev Caller must be an operator of BTP network.
       @param _dst     BTP Address of the destination BMC
       @param _link    BTP Address of the next BMC for the destination
   */
    function addRoute(string memory _dst, string memory _link)
        external
        override
        hasPermission
    {
        require(bytes(routes[_dst]).length == 0, "BTPRevertAlreadyExistRoute");
        //  Verify _dst and _link format address
        //  these two strings must follow BTP format address
        //  If one of these is failed, revert()
        (string memory _net, ) = _dst.splitBTPAddress();
        _link.splitBTPAddress();

        routes[_dst] = _link; //  map _dst to _link
        listRouteKeys.push(_dst); //  push _dst key into an array of route keys
        getRouteDstFromNet[_net] = _dst;
    }

    /**
       @notice Remove route to the BMC.
       @dev Caller must be an operator of BTP network.
       @param _dst     BTP Address of the destination BMC
    */
    function removeRoute(string memory _dst) external override hasPermission {
        //  @dev No need to check if _dst is a valid BTP format address
        //  since it was checked when adding route at the beginning
        //  If _dst does not match, revert()
        require(bytes(routes[_dst]).length != 0, "BTPRevertNotExistRoute");
        delete routes[_dst];
        (string memory _net, ) = _dst.splitBTPAddress();
        delete getRouteDstFromNet[_net];
        listRouteKeys.remove(_dst);
    }

    /**
       @notice Get routing information.
       @return _routes An array of Route.
    */
    function getRoutes() external view override returns (Types.Route[] memory) {
        Types.Route[] memory _routes = new Types.Route[](listRouteKeys.length);
        for (uint256 i = 0; i < listRouteKeys.length; i++) {
            _routes[i] = Types.Route(
                listRouteKeys[i],
                routes[listRouteKeys[i]]
            );
        }
        return _routes;
    }

    /**
       @notice Registers relay for the network.
       @dev Called by the Relay-Operator to manage the BTP network.
       @param _link     BTP Address of connected BMC
       @param _addr     the address of Relay
    */
    function addRelay(string memory _link, address[] memory _addr)
        external
        override
        hasPermission
    {
        require(links[_link].isConnected == true, "BMCRevertNotExistsLink");
        links[_link].relays = _addr;
        for (uint256 i = 0; i < _addr.length; i++)
            relayStats[_addr[i]] = Types.RelayStats(_addr[i], 0, 0);
    }

    /**
       @notice Unregisters Relay for the network.
       @dev Called by the Relay-Operator to manage the BTP network.
       @param _link     BTP Address of connected BMC
       @param _addr     the address of Relay
    */
    function removeRelay(string memory _link, address _addr)
        external
        override
        hasPermission
    {
        require(
            links[_link].isConnected == true && links[_link].relays.length != 0,
            "BMCRevertUnauthorized"
        );
        for (uint256 i = 0; i < links[_link].relays.length; i++) {
            if (links[_link].relays[i] != _addr) {
                addrs.push(links[_link].relays[i]);
            }
        }
        links[_link].relays = addrs;
        delete addrs;
    }

    /**
       @notice Get registered relays.
       @param _link        BTP Address of the connected BMC.
       @return _relayes A list of relays.
    */

    function getRelays(string memory _link)
        external
        view
        override
        returns (address[] memory)
    {
        return links[_link].relays;
    }

    /******************************* Use for BMC Service *************************************/
    function getBshServiceByName(string memory _serviceName)
        external
        view
        override
        returns (address)
    {
        return bshServices[_serviceName];
    }

    function getLink(string memory _to)
        external
        view
        override
        returns (Types.Link memory)
    {
        return links[_to];
    }

    function getLinkRxSeq(string calldata _prev)
        external
        view
        override
        returns (uint256)
    {
        return links[_prev].rxSeq;
    }

    function getLinkTxSeq(string calldata _prev)
        external
        view
        override
        returns (uint256)
    {
        return links[_prev].txSeq;
    }

    function getLinkRelays(string calldata _prev)
        external
        view
        override
        returns (address[] memory)
    {
        return links[_prev].relays;
    }

    function getRelayStatusByLink(string memory _prev)
        external
        view
        override
        returns (Types.RelayStats[] memory _relays)
    {
        _relays = new Types.RelayStats[](links[_prev].relays.length);
        for (uint256 i = 0; i < links[_prev].relays.length; i++) {
            _relays[i] = relayStats[links[_prev].relays[i]];
        }
    }

    //todo: commented temp         //onlyBMCPeriphery
    function updateLinkRxSeq(string calldata _prev, uint256 _val)
        external
        override
        onlyBMCPeriphery
    {
        links[_prev].rxSeq += _val;
    }

    function updateLinkTxSeq(string memory _prev)
        external
        override
        onlyBMCPeriphery
    {
        links[_prev].txSeq++;
    }

    function updateLinkReachable(string memory _prev, string[] memory _to)
        external
        override
        onlyBMCPeriphery
    {
        for (uint256 i = 0; i < _to.length; i++) {
            links[_prev].reachable.push(_to[i]);
            (string memory _net, ) = _to[i].splitBTPAddress();
            getLinkFromReachableNet[_net] = Types.Tuple(_prev, _to[i]);
        }
    }

    function deleteLinkReachable(string memory _prev, uint256 _index)
        external
        override
        onlyBMCPeriphery
    {
        (string memory _net, ) =
            links[_prev].reachable[_index].splitBTPAddress();
        delete getLinkFromReachableNet[_net];
        delete links[_prev].reachable[_index];
        links[_prev].reachable[_index] = links[_prev].reachable[
            links[_prev].reachable.length - 1
        ];
        links[_prev].reachable.pop();
    }

    function updateRelayStats(
        address relay,
        uint256 _blockCountVal,
        uint256 _msgCountVal
    ) external override onlyBMCPeriphery {
        relayStats[relay].blockCount += _blockCountVal;
        relayStats[relay].msgCount += _msgCountVal;
    }

    function resolveRoute(string memory _dstNet)
        external
        view
        override
        onlyBMCPeriphery
        returns (string memory, string memory)
    {
        // search in routes
        string memory _dst = getRouteDstFromNet[_dstNet];
        if (bytes(_dst).length != 0) return (routes[_dst], _dst);

        // search in links
        _dst = getLinkFromNet[_dstNet];
        if (bytes(_dst).length != 0) return (_dst, _dst);

        // search link by reachable net
        Types.Tuple memory res = getLinkFromReachableNet[_dstNet];

        require(
            bytes(res._to).length > 0,
            string("BMCRevertUnreachable: ").concat(_dstNet).concat(
                " is unreachable"
            )
        );
        return (res._prev, res._to);
    }
    /*******************************************************************************************/
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