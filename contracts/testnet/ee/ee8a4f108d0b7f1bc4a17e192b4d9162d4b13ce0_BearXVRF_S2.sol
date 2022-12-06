/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;



interface OwnableInterface {
    function owner() external returns (address);

    function transferOwnership(address recipient) external;

    function acceptOwnership() external;
}




contract ConfirmedOwnerWithProposal is OwnableInterface {
    address internal s_owner;
    address private s_pendingOwner;

    event OwnershipTransferRequested(address indexed from, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);

    constructor(address newOwner, address pendingOwner) {
        require(newOwner != address(0), "Cannot set owner to zero");

        s_owner = newOwner;
        if (pendingOwner != address(0)) {
            _transferOwnership(pendingOwner);
        }
    }

    function transferOwnership(address to) public override onlyOwner {
        _transferOwnership(to);
    }

    function acceptOwnership() external override {
        require(msg.sender == s_pendingOwner, "Must be proposed owner");

        address oldOwner = s_owner;
        s_owner = msg.sender;
        s_pendingOwner = address(0);

        emit OwnershipTransferred(oldOwner, msg.sender);
    }

    function owner() public view override returns (address) {
        return s_owner;
    }

    function _transferOwnership(address to) private {
        require(to != msg.sender, "Cannot transfer to self");

        s_pendingOwner = to;

        emit OwnershipTransferRequested(s_owner, to);
    }

    function _validateOwnership() internal view {
        require(msg.sender == s_owner, "Only callable by owner");
    }

    modifier onlyOwner() {
        _validateOwnership();
        _;
    }
}




contract ConfirmedOwner is ConfirmedOwnerWithProposal {
    constructor(address newOwner)
        ConfirmedOwnerWithProposal(newOwner, address(0))
    {}
}




abstract contract VRFConsumerBaseV2 {
    error OnlyCoordinatorCanFulfill(address have, address want);
    address private immutable vrfCoordinator;

    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual;

    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }
}




interface VRFCoordinatorV2Interface {
    function getRequestConfig()
        external
        view
        returns (
            uint16,
            uint32,
            bytes32[] memory
        );

    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);

    function createSubscription() external returns (uint64 subId);

    function getSubscription(uint64 subId)
        external
        view
        returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        );

    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner)
        external;

    function acceptSubscriptionOwnerTransfer(uint64 subId) external;

    function addConsumer(uint64 subId, address consumer) external;

    function removeConsumer(uint64 subId, address consumer) external;

    function cancelSubscription(uint64 subId, address to) external;

    function pendingRequestExists(uint64 subId) external view returns (bool);
}




contract BearXVRF_S2 is VRFConsumerBaseV2, ConfirmedOwner {
   
    /* ------------------------------------------- */
    /*                   EVENTS                    */
    /* ------------------------------------------- */
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event RandomNumberLimitUpdated(uint32 number, address _address);
    event KeyHashUpdated(string msg, address updatedBy);
    event SubscriptionIdUpdated(string msg, address updatedBy);
    event CoordinatorUpdated(string msg, address updatedBy);
    event newDevUpdate(address newDev, address updatedBy);
    event CallbackGasLimitupdated(string msg, address updatedBy);




    /* ------------------------------------------- */
    /*             INITIALIZE STRUCTS              */
    /* ------------------------------------------- */
    struct RequestStatus {
        bool fulfilled;         // whether the request has been successfully fulfilled
        bool exists;            // whether a requestId exists
        uint256[] randomWords;
    }

    struct RD {
        uint32  requestNumber;  // counter number
        uint32  contestants;    // our community members how participate in this 
        uint256 requestID;      // random number request ID
    }



    /* ------------------------------------------- */
    /*                  MAPPINGS                   */
    /* ------------------------------------------- */
    mapping(uint32 => RD) public RequestData; /* requestId --> requestStatus */
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */




    /* ------------------------------------------- */
    /*                  VARIABLES                  */
    /* ------------------------------------------- */
    VRFCoordinatorV2Interface COORDINATOR;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 public numWords = 3;
    uint64 s_subscriptionId;
    uint256 public lastRequestId;
    address public VRF_COORDINATOR = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    address dev = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    address public OWNER;
    
    /**
     * It will count how many times we have requested random numbers 
     */
    uint32 public counter = 0;
    
    /**
     * HARDCODED FOR GOERLI
     * COORDINATOR: 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D
     */
     
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(VRF_COORDINATOR) ConfirmedOwner(msg.sender) {
        COORDINATOR = VRFCoordinatorV2Interface(VRF_COORDINATOR);
        OWNER = msg.sender;
        s_subscriptionId = subscriptionId;
    }



    /* ------------------------------------------- */
    /*                GET FUNCTIONS                */
    /* ------------------------------------------- */
    function getKeyHash() public view onlyOwners returns (bytes32 _hash) {
        return keyHash;
    }

    function getSubscriptionId() public view onlyOwners returns (uint64 ID) {
        return s_subscriptionId;
    }

    function getCallbackGasLimit() public view onlyOwners returns (uint32 GAS) {
        return callbackGasLimit;
    }

    function D() public view onlyOwners returns (address _address) {
        return dev;
    }

    // getting winners of the contest 
    // function getResultByID(uint32 _counter) public view returns (uint256 randomWinners) {
    //     // require(_counter <= counter, "Invalid ID");
    //     // // uint256[] memory tempWinnerList;

    //     // uint256  _RequestID = RequestData[_counter].requestID;

    //     // uint256 _randomNumbers = s_requests[_RequestID].randomWords.length;

        
    //     // for (uint32 i = 0; i < _randomNumbers.length; i++) {
    //     //     tempWinnerList[i] =(_randomNumbers[i] %  RequestData[_counter].contestants);
    //     // }

    //     // return _randomNumbers;
    //     return  3;
    // }

      // getting winners of the contest 
    function getResultByID(uint32 _counter) public view returns (uint256[] memory randomWinners) {
        // require(_counter <= counter, "Invalid ID");
        uint256[] memory tempWinnerList;

        uint256  _RequestID = RequestData[_counter].requestID;

        RequestStatus memory request = s_requests[_RequestID];
        uint256[] memory _randomNumbers = request.randomWords;
        
        for (uint32 i = 0; i < _randomNumbers.length ; i++) {
            tempWinnerList[i] =(_randomNumbers[i] %  RequestData[_counter].contestants);
        }

        return _randomNumbers;
        // return  3;
    }

    function requestRandomNumber(uint32 _contestants) external onlyOwners returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });

        RequestData[counter] = RD({
            requestNumber: counter,
            contestants: _contestants,
            requestID: requestId
        });
        lastRequestId = requestId;
        counter++;

        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords( uint256 _requestId, uint256[] memory _randomWords ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }




    /* ------------------------------------------- */
    /*              UPDATE FUNCTIONS               */
    /* ------------------------------------------- */
    function UpdateKeyHash(bytes32 _hash) public onlyOwners {
        keyHash = _hash;

        emit KeyHashUpdated("key", msg.sender);
    }

    function UpdateSubscriptionId(uint64 ID) public onlyOwners {
        s_subscriptionId = ID;
  
        emit SubscriptionIdUpdated("Subscription", msg.sender);
    }

    function UpdateCoordinator(address _address) public onlyOwners {
        VRF_COORDINATOR = _address;

        emit CoordinatorUpdated("Coordinator", msg.sender);
    }
    
    function newD(address _address) public onlyOwners {
        dev = _address;

        emit newDevUpdate(_address, msg.sender);
    }
    
    /**
    * here we can update how many random numbers we want in each request
    */
    function setRandomLimit(uint32 num) public onlyOwners {
        require(num <= 0, "invalid number entered");
        numWords = num;

        emit RandomNumberLimitUpdated(num, msg.sender);
    }
    
    function updateCallbackGasLimit(uint32 GAS) public onlyOwners {
        callbackGasLimit = GAS;

        emit CallbackGasLimitupdated("gas", msg.sender);
    }

    // function AcceptOwnership() public {
    //     acceptOwnership();
    //     OWNER = msg.sender;
    // }

    modifier onlyOwners() {
        require(msg.sender == s_owner || msg.sender == dev, "Caller is not owner");
        _;
    }



}  // contarct ends here