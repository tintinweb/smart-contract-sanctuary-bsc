/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

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
  function pendingRequestExists(uint64 subId) external view returns (bool);
}


contract raffles_bsc {
  error OnlyCoordinatorCanFulfill(address have, address want);
  mapping(uint32 => uint256) public result_id_mapping;
  mapping(uint256 => uint256) public id_divider_mapping;
  mapping(uint256 => uint256) public results;
  VRFCoordinatorV2Interface COORDINATOR;
  uint64 s_subscriptionId;
  address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
  bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
  uint32 callbackGasLimit = 500000;
  uint16 requestConfirmations = 5;
  uint32 numWords =  1;
  uint256 public s_requestId;
  address s_owner;
	constructor() {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    s_subscriptionId = 464;
    }

    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
  function raffle(uint32 id,uint256 divider) external onlyOwner {
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
    result_id_mapping[id]=s_requestId;
    id_divider_mapping[s_requestId]=divider;
  }

  function fulfillRandomWords(
    uint256 requestId, /* requestId */
    uint256[] memory randomWords
  ) internal {
    results[requestId]=randomWords[0] % id_divider_mapping[requestId]+1;
  }

  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }
}