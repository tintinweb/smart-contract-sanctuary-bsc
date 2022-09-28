/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT
// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol


pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol


pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// File: docs.chain.link/samples/VRF/LuckyPlace.sol





pragma solidity ^0.8.7;





contract LuckyPlace is VRFConsumerBaseV2 {

  VRFCoordinatorV2Interface COORDINATOR;



  uint64 SubscriptionId;

  // see https://docs.chain.link/docs/vrf-contracts/#configurations

  address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;

  bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;



  uint32 callbackGasLimit = 500000;

  uint32 numWords =  10;

  uint16 requestConfirmations = 3;



  uint256[] rawRandomWords;

  uint256 requestId;



  uint256 public transferOwnershipAllowed = 0;

  uint256 transferOwnershipAllowDay;



  address Owner;

  mapping (address => uint256) Managers;



  uint256 public Fee = 15;

  uint256 constant MaxFee = 30;

  uint256 constant MaxReferralFee = 10;

  mapping (address => uint8) public referralsFee; // takes from general Fee

  mapping (uint8 => uint256) public referralFeeLevels; // referralFee => roundParticipated

  uint256 feeMoney = 0;



  uint256 totalReferralRewards;

  mapping (address => uint256) public referralsCount;

  mapping (address => uint256) referralsRewards;

  

  mapping (address => uint256) public betsCount;

  mapping (address => uint256) rewards;



  bool public isPaused;

  Round[] rounds;

  uint256[] currentRounds;

  uint256 currentRoundId;



  event RandomWordsRequested();

  event RandomWordsRecieved();

  event NeedToRequestRandomWords();



  event GameStarted();

  event GamePaused();



  event RoundStarted(uint256 roundId);

  event RoundFinished(uint256 roundId);

  event RoundBet(uint256 roundId,address better,uint256 yourNumber);



  event Claimed(address claimer);

  event ReferralWithdrawed(address withdrawer);



  struct Round {

    uint256 id;

    address[] betters;

    uint256 betSize;

    uint32 membersMax;

    uint32 winnersNum;

    uint32[] randomNums;

    bool isFinished;

    bool repeat;

  }



  constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {

    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);

    Owner = msg.sender;

    SubscriptionId = subscriptionId;



    referralFeeLevels[1] = 0;

    referralFeeLevels[2] = 3;

    referralFeeLevels[3] = 5;

    referralFeeLevels[4] = 10;

    referralFeeLevels[5] = 15;

  }



  function addManager(address manager) external onlyOwner { 

    Managers[manager] = 1;

  }



  function removeManager(address manager) external onlyOwner { 

    Managers[manager] = 0;

  }



  function setSubscriptionId(uint64 subscriptionId) external onlyOwner { 

    SubscriptionId = subscriptionId;

  }



  function requestRandomWords() public onlyManagers {

    requestId = COORDINATOR.requestRandomWords(

      keyHash,

      SubscriptionId,

      requestConfirmations,

      callbackGasLimit,

      numWords

    );

    emit RandomWordsRequested();

  }



  function fulfillRandomWords(

    uint256, //requestId

    uint256[] memory randomWords

  ) internal override {

    for(uint256 i =0;i<randomWords.length;i++){

      rawRandomWords.push(randomWords[i]);

    }

    emit RandomWordsRecieved();

  }



  function getRequestId() external onlyOwner view returns(uint256){

    return requestId;

  }



  function setChainlinkParameters(uint32 wordsLimit,uint32 gasLimit,uint16 confirmations,bytes32 KeyHash) external onlyOwner {

    numWords = wordsLimit;

    callbackGasLimit = gasLimit;

    requestConfirmations = confirmations;

    keyHash = KeyHash;

  }



  function play() external onlyOwner{

    isPaused = false;

    emit GameStarted();

  }



  function pause() external onlyOwner{

    isPaused = true;

    emit GamePaused();

  }



  function startNewRound(uint256 BetSize,uint32 MembersMax,uint32 WinnersNum, bool Repeat) public onlyManagers {

    if(rawRandomWords.length == 0){

      emit NeedToRequestRandomWords();

      revert("Need to request random numbers");

    }

    address[] memory bettersArr;

    uint32[] memory RandomNums = new uint32[](WinnersNum);

    

    for(uint i = 0;i<WinnersNum;i++){

      if(rawRandomWords[rawRandomWords.length-1] / MembersMax == 0 && rawRandomWords[rawRandomWords.length-1] % MembersMax == 0){

        rawRandomWords.pop();

      }

      RandomNums[i] = (uint32) (rawRandomWords[rawRandomWords.length-1] % MembersMax);

      rawRandomWords[rawRandomWords.length-1] /= MembersMax;

    }

    

    if(rawRandomWords.length < numWords){

      emit NeedToRequestRandomWords();

    }



    Round memory round = Round({

      id: currentRoundId,

      betters: bettersArr,

      betSize: BetSize,

      membersMax: MembersMax,

      winnersNum: WinnersNum,

      randomNums: RandomNums,

      isFinished: false,

      repeat: Repeat    

    });



    currentRounds.push(currentRoundId);

    rounds.push(round);

    emit RoundStarted(currentRoundId);

    currentRoundId++;

  }



  function betRound(uint256 roundId, address referral) external payable{

    require(msg.value == rounds[roundId].betSize,"Value must equal bet size");

    require(!rounds[roundId].isFinished,"Round is Finished");

    require(!isPaused,"Game is paused");



    rounds[roundId].betters.push(msg.sender);



    uint256 betsCnt = betsCount[msg.sender] + 1;

    betsCount[msg.sender] = betsCnt;

    uint8 refFee = referralsFee[msg.sender]; 

    if(refFee == 0)

    {

      refFee = 1;

      referralsFee[msg.sender] = refFee;

    }

    uint256 betsForNextFeeLevel = referralFeeLevels[refFee+1];

    if(betsCnt >= betsForNextFeeLevel && betsForNextFeeLevel != 0 && refFee+1 <= MaxReferralFee)

    {

      refFee = refFee+1;

      referralsFee[msg.sender] = refFee;

    }





    if(referral != address(0) && referral != msg.sender){

      refFee = referralsFee[referral];

      if(refFee == 0)

        refFee = 1;

      uint256 reward = rounds[roundId].betSize / 100 * refFee;

      referralsRewards[referral] += reward;

      totalReferralRewards += reward; 

      feeMoney -= reward;

      referralsCount[referral] += 1;

    }



    emit RoundBet(roundId,msg.sender,rounds[roundId].betters.length-1);

    

    if(rounds[roundId].betters.length == rounds[roundId].membersMax)

      finishRound(roundId);

  }



  function finishRound(uint256 roundId) internal{

    uint256 deleteIndex = 0;

    for(uint256 i =0;i<currentRounds.length;i++){

      if(currentRounds[i] == roundId)

        deleteIndex = i;

    }

    currentRounds[deleteIndex] = currentRounds[currentRounds.length-1];

    currentRounds.pop();

    rounds[roundId].isFinished = true;

    feeMoney += rounds[roundId].membersMax * rounds[roundId].betSize / 100 * Fee; 

    rewardDistribute(roundId);

    emit RoundFinished(roundId);

  }



  function rewardDistribute(uint256 roundId) internal {

    uint32[] memory winNumbers = rounds[roundId].randomNums;

    uint256 reward = rounds[roundId].membersMax * rounds[roundId].betSize / 100 * (100-Fee) / rounds[roundId].winnersNum; 



    for(uint256 i = 0;i< winNumbers.length;i++){

      rewards[rounds[roundId].betters[winNumbers[i]]] += reward;

    }

  }



  function claim() external{

    require(rewards[msg.sender] != 0,"Nothing to claim!");

    uint256 reward = rewards[msg.sender];

    rewards[msg.sender] = 0; 

    (bool success, ) = msg.sender.call{value: reward}("");

    require(success, "Transfer failed.");

    emit Claimed(msg.sender);

  }



  function amountToClaim() external view returns(uint256){

    return rewards[msg.sender];

  }



  function withdrawReferralReward() external{

    require(referralsRewards[msg.sender] != 0,"Nothing to withdraw!");

    uint256 reward = referralsRewards[msg.sender];

    referralsRewards[msg.sender] = 0; 

    (bool success, ) = msg.sender.call{value: reward}("");

    require(success, "Transfer failed.");

    emit ReferralWithdrawed(msg.sender);

  }



  function amountReferralReward() external view returns(uint256){

    return referralsRewards[msg.sender];

  }



  function changeFee(uint256 fee) external onlyOwner {

    require(fee <= MaxFee,"Fee is higher than possible");

    Fee = fee;

  }



  function changeReferralFee(address addr,uint8 fee) external onlyOwner {

    require(fee <= MaxReferralFee,"Fee is higher than possible");

    referralsFee[addr] = fee;

  }



  function changeRoundRepeat(uint256 roundId,bool isNeedToRepeat) external onlyOwner{

    rounds[roundId].repeat = isNeedToRepeat;

  }



  function getCurrentRounds() external view returns(uint256[] memory){

    return currentRounds;

  }



//hiding random numbers while round not finished

  function getRound(uint256 roundId) external view returns(Round memory){

    uint32[] memory randomNums;

    Round memory round = rounds[roundId];

    if(!round.isFinished)

      round.randomNums = randomNums;

    return round;

  }



  function getLengthRawRandomWords() external onlyManagers view returns(uint256){

    return rawRandomWords.length;

  }



function withdraw(uint256 amount) external onlyOwner{

  require(feeMoney >= amount,"Amount more than possible");

  feeMoney -= amount;

  (bool success, ) = Owner.call{value: amount}("");

  require(success, "Transfer failed.");

}



function addFeeMoney() external onlyOwner payable{

  feeMoney += msg.value;  

}



function getFeeMoney() external view onlyOwner returns(uint256){

  return feeMoney;

}



function getTotalReferralRewards() external view onlyOwner returns(uint256){

  return totalReferralRewards;

}



function transferOwnership(address to) external onlyOwner{

  require(transferOwnershipAllowed == 1,"Allow transferOwnership");

  require(transferOwnershipAllowDay < block.timestamp,"Wait when transfer ownership become allowed");

  transferOwnershipAllowed = 0;

  transferOwnershipAllowDay = 0;

  Owner = to;

}



function transferOwnershipAllow() external onlyOwner{

  transferOwnershipAllowDay = block.timestamp + 3 days;

  transferOwnershipAllowed = 1;

}



function transferOwnershipDisallow() external onlyOwner{

  transferOwnershipAllowed = 0;

}



  modifier onlyOwner() {

    require(msg.sender == Owner);

    _;

  }



  modifier onlyManagers() {

    require(msg.sender == Owner || Managers[msg.sender] == 1);

    _;

  }

  

}