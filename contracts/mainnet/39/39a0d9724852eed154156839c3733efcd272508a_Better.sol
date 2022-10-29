// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import 'VRFCoordinatorV2Interface.sol';
import 'VRFConsumerBaseV2.sol';
import 'ConfirmedOwner.sol';

contract Better is VRFConsumerBaseV2, ConfirmedOwner {

  event RequestSent(uint256 requestId, uint32 numWords);
  event RequestFulfilled(uint256 requestId, uint256[] randomWords);

  VRFCoordinatorV2Interface COORDINATOR;

  // Your subscription ID.
  uint64 s_subscriptionId;

  // past requests Id.
  uint256 public lastRequestId;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
  bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;

  // Depends on the number of requested values that you want sent to the
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
  // so 100,000 is a safe default for this example contract. Test and adjust
  // this limit based on the network that you select, the size of the request,
  // and the processing of the callback request in the fulfillRandomWords()
  // function.
  uint32 callbackGasLimit = 250000;

  // The default is 3, but you can set this higher.
  uint16 requestConfirmations = 3;

  // For this example, retrieve 2 random values in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numWords = 1;

  uint256 public minWei = 0.01 ether;

  uint256 public multiplier = 200;
  uint256 public feePercent = 3;

  uint256 public randomResult;

  //declaring 50% chance, (0.5*(uint256+1))
  uint256 constant half = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  uint256 public gameId;
  uint256 public lastGameId;
  mapping(uint256 => Game) public games;

  struct Game {
    uint256 id;
    uint256 amount;
    uint256 prize;
    uint256 time;
    bool bet;
    address payable player;
  }

  event Withdraw(address admin, uint256 amount);
  event Received(address indexed sender, uint256 amount);
  event NewBet(uint256 gameId, address indexed player, uint256 amount);
  event GameWon(uint256 gameId, address indexed player, uint256 amount);
  event GameLost(uint256 gameId, address indexed player);

  constructor(uint64 subscriptionId, address coordinatorAddr)
  VRFConsumerBaseV2(coordinatorAddr)
  ConfirmedOwner(msg.sender)
  {
    COORDINATOR = VRFCoordinatorV2Interface(coordinatorAddr);
    s_subscriptionId = subscriptionId;
  }

  receive() external payable {
    emit Received(msg.sender, msg.value);
  }

  function getGamesList(uint256 page, uint256 limit) external view returns (Game[] memory) {
    if (limit > 50) {
      limit = 50;
    }
    uint256 start = limit * page;
    if (lastGameId == 0 || start > lastGameId - 1) {
      return new Game[](0);
    }
    start = lastGameId - 1 - start;
    if (limit > start + 1) {
      limit = start + 1;
    }
    Game[] memory result = new Game[](limit);
    uint256 end = start + 1 - limit;

    uint256 index = 0;
    for (uint256 i = start; i >= end; i = i > 0 ? i - 1 : 0) {
      result[index++] = games[i];
      if (i == 0) break;
    }

    return result;
  }

  function getGameById(uint256 id) external view returns (Game memory) {
    return games[id];
  }

  function getMultiplier() external view returns (uint256) {
    return multiplier - (multiplier * feePercent) / 100;
  }

  // Assumes the subscription is funded sufficiently.
  function requestRandomWords() internal returns (uint256 requestId) {
    // Will revert if subscription is not set and funded.
    requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
    lastRequestId = requestId;
    emit RequestSent(requestId, numWords);
    return requestId;
  }

  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
    randomResult = _randomWords[0];
    processResult(_randomWords[0]);
    emit RequestFulfilled(_requestId, _randomWords);
  }

  function tossCoin(bool bet) public payable {

    require(msg.value >= minWei, 'Error: msg.value must be >= minWei');

    require(msg.value * 4 <= address(this).balance, 'Error: insufficient vault balance');

    games[gameId] = Game(gameId, msg.value, 0, 0, bet, payable(msg.sender));

    emit NewBet(gameId, msg.sender, msg.value);

    gameId = gameId + 1;

    requestRandomWords();
  }

  function processResult(uint256 random) internal {
    uint256 balance = address(this).balance;

    for (uint256 i = lastGameId; i < gameId; i++) {
      uint256 winAmount = 0;
      if ((random >= half && games[i].bet == true) || (random < half && games[i].bet == false)) {
        winAmount = (games[i].amount * (multiplier - (multiplier * feePercent) / 100)) / 100;
        if (balance >= winAmount) {
          games[i].player.transfer(winAmount);
          balance -= winAmount;
        } else {
          winAmount = 0;
        }
      }
      if (winAmount > 0) {
        games[i].prize = winAmount;
        emit GameWon(gameId, games[i].player, winAmount);
      } else {
        emit GameLost(gameId, games[i].player);
      }
      games[i].time = block.timestamp;
    }
    lastGameId = gameId;
  }

  function withdrawEther(uint256 amount) external onlyOwner {
    require(address(this).balance >= amount, 'Error: contract has insufficient balance');
    if (amount == 0) amount = address(this).balance;
    payable(msg.sender).transfer(amount);
    emit Withdraw(msg.sender, amount);
  }

  function setMinWei(uint256 amount) external onlyOwner {
    minWei = amount;
  }

  function setMultiplier(uint256 amount) external onlyOwner {
    require(amount > 100 && amount <= 1000);
    multiplier = amount;
  }

  function setFeePercent(uint256 amount) external onlyOwner {
    require(amount <= 25);
    feePercent = amount;
  }
}