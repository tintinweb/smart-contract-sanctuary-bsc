/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: None

pragma solidity 0.8.14;

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
    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;
    function acceptSubscriptionOwnerTransfer(uint64 subId) external;
    function addConsumer(uint64 subId, address consumer) external;
    function removeConsumer(uint64 subId, address consumer) external;
    function cancelSubscription(uint64 subId, address to) external;
}

contract ChainlinkTester {

    uint256 public winnerOne;
    uint256 public winnerTwo;

    address private CEO;

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}


    constructor() {
        CEO = msg.sender;
    }

    ////////////////////////////////ChainLink Section ///////////////////////////
    VRFCoordinatorV2Interface COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
    uint64 s_subscriptionId = 184;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  2;
    uint256[] public arrayOfRandomNumbers;
    uint256 public s_requestId;

    function requestRandomWords() internal {
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }   

    error OnlyCoordinatorCanFulfill(address have, address want);

    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        if (msg.sender != vrfCoordinator) revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        fulfillRandomWords(requestId, randomWords);
    }
  
    function fulfillRandomWords(uint256,uint256[] memory randomWords) internal {
        winnerOne = (randomWords[0] % 100) + 1;
        winnerTwo = (randomWords[1] % 100) + 1;
    }

    function ManuallyGetRandomness() external onlyOwner{
        requestRandomWords();
    }


    

    
    ////////////////////////////////ChainLink Section ///////////////////////////


}