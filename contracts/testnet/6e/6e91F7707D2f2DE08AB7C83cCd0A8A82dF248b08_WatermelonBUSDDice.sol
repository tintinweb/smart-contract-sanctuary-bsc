/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT
// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol
pragma solidity ^0.8.16;

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill (address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol
pragma solidity ^0.8.16;

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)
pragma solidity ^0.8.16;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// File: contracts/Betlify.sol
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.16;


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

interface VRFv2SubscriptionManager{
    function getSubscriptionDetails() external view returns(uint256, uint64, address,  address[] memory);
    function getSubscriptionBalance() external view returns(uint256);
    function topUpSubscription() external payable;
}

contract WatermelonBUSDDice is VRFConsumerBaseV2, ReentrancyGuard {
  
  VRFCoordinatorV2Interface COORDINATOR;
  uint64 s_subscriptionId;
  address vrfCoordinator = 	0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
  bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
  uint32 callbackGasLimit = 2500000;
  uint16 requestConfirmations = 3;
  uint32 numWords =  2;

  uint256[] public s_randomWords;
  uint256 public s_requestId;
  address s_owner;
  
  uint256 public totalBets;
  uint256 public totalBetsWon;
  uint256 public totalWinnings;
  uint256 public totalBetsLost;
  
  uint256 public maxBetPercentage;
  uint256 public minBetAmount = 0.001 ether; //1 BUSD
  uint256 public minChainlinkBalance = 5 ether;
  uint256 public minerFees;

  uint256 public minerWalletBalance;
  
  mapping (address => uint256) public userBet;
  mapping (uint256 => uint256) public betValue;
  mapping (address => uint256) public playerCurrentResult1;
  mapping (address => uint256) public playerCurrentResult2;
  mapping (address => uint256) public playerTotalBets;
  mapping (address => uint256) public playerTotalWinnings;
  mapping (address => uint256) public playerTotalLost;
 
  mapping (address => uint256) public unclaimedWinning;
  mapping (address => uint256) public userLostBalance;
 
  mapping (uint256 => address) public requesterAddress;
  mapping (address => bool) public roundStatus;

  struct Bet{
    uint256 requestId;
    uint256 amount;
    uint256 bet;
    uint256 dice1Result;
    uint256 dice2Result;
    bool isWon;
    uint256 createdTime;
  }

  Bet bet;
  mapping (address => Bet[]) public userBets;

  address public wmlnAddress;
  address public VRFv2SubscriptionManagerAddress;
 
  address public busdAddress;
  IERC20 busdToken;
  
  VRFv2SubscriptionManager VRFmanager;
  address public owner;
  bool public paused = false;

  constructor() VRFConsumerBaseV2(vrfCoordinator) {
    
    owner = msg.sender;
    VRFv2SubscriptionManagerAddress = 0x9bF951013034E3f690196Df8477450675d140b29;
    wmlnAddress = 0xEBFDF7A84eB1DD651663782802A818ce36F3e18A;
    busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    busdToken = IERC20(busdAddress);
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    setVRFv2SubscriptionManagerAddress(VRFv2SubscriptionManagerAddress);
    setSubscriptionId(441);
    setMinerFees(10);
    setMinBetValue(0.001 ether);
    setMaxBetPercentage(20);
  }

  function setSubscriptionId(uint64 _setSubscriptionId) public onlyOwner {
    s_subscriptionId = _setSubscriptionId;
  }

  function setVRFv2SubscriptionManagerAddress(address _VRFv2SubscriptionManagerAddress) public onlyOwner {
    VRFv2SubscriptionManagerAddress = _VRFv2SubscriptionManagerAddress;
    VRFmanager = VRFv2SubscriptionManager(VRFv2SubscriptionManagerAddress);
  }

  function setKeyHash(bytes32 _keyHash) external onlyOwner{
      keyHash = _keyHash;
  }

  function setCallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner{
      callbackGasLimit = _callbackGasLimit;
  }

  function getVRFsubscriptionBalance() public view returns(uint256) {
      return VRFmanager.getSubscriptionBalance();
  }

  function fundChainlinkSubscription() public {
      require(address(this).balance >= 0.001 ether, "Insufficient contract BNB balance");
      VRFmanager.topUpSubscription{value:0.001 ether}();
  }

  function setMinerFees(uint256 _minerFees) public onlyOwner {
    minerFees = _minerFees;
  }

  function setMinBetValue(uint256 _minBetAmount) public onlyOwner {
    minBetAmount = _minBetAmount;
  }

  function setMaxBetPercentage(uint256 _maxBetPercentage) public onlyOwner {
    maxBetPercentage = _maxBetPercentage;
  }

  function setMinChainlinkBalance(uint256 _minChainlinkBalance) public onlyOwner {
    minChainlinkBalance = _minChainlinkBalance;
  }

  function getMaxBetAmount() public view returns(uint256){
    return (busdToken.balanceOf(address(this)) * maxBetPercentage)/100;
  }

  function betUp(uint256 _amount) isUnpaused external {
    rollDice(1,_amount);
  }

  function betDown(uint256 _amount) isUnpaused external {
    rollDice(0,_amount);
  }

  // Assumes the subscription is funded sufficiently.
  function rollDice(uint16 _bet, uint256 _amount) internal {
    
    if(getVRFsubscriptionBalance() <= minChainlinkBalance){
      fundChainlinkSubscription();
    }
    // Will revert if subscription is not set and funded.
    require(getVRFsubscriptionBalance() >= minChainlinkBalance,"Insufficient Chainlink VRF subscription balance");
    require(_amount <= getMaxBetAmount(),"You can not bet more than maximum allowed limit");
    require(_amount >= minBetAmount,"Minimum bet amount is $5 BUSD");
    require(busdToken.allowance(msg.sender, address(this)) >= _amount,"Not enough allowance");
    require(busdToken.balanceOf(msg.sender) >= _amount,"Insufficient BUSD balance");    
    bool success = busdToken.transferFrom(msg.sender, address(this), _amount);
    require(success, "BUSD Transfer failed.");
    
    playerCurrentResult1[msg.sender] = 0;
    playerCurrentResult2[msg.sender] = 0;
    playerTotalBets[msg.sender]++;

    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
    
    userBet[msg.sender] = _bet;
    requesterAddress[s_requestId] = msg.sender;
    totalBets += _amount;
    betValue[s_requestId] = _amount;
    roundStatus[msg.sender] = true;
  }
  
  function getRoundStatus() public view returns (bool){
      return roundStatus[msg.sender];
  }

  function getRoundStatusByAddress(address _address) external view returns (bool){
      return roundStatus[_address];
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords ) internal override {
  
    address playerAddress = requesterAddress[requestId];
    bool isWon;

    playerCurrentResult1[playerAddress] = (randomWords[0] % 5) + 1;
    playerCurrentResult2[playerAddress] = (randomWords[1] % 5) + 1;

    roundStatus[playerAddress] = false;
    
    if(userBet[playerAddress] == 1){
      if((playerCurrentResult1[playerAddress]+playerCurrentResult2[playerAddress]) >= 7){
          addBets(playerAddress, requestId, userBet[playerAddress], betValue[requestId], playerCurrentResult1[playerAddress],playerCurrentResult2[playerAddress],true);
          isWon = true;
          totalBetsWon++;
      }else{
          addBets(playerAddress, requestId, userBet[playerAddress], betValue[requestId], playerCurrentResult1[playerAddress],playerCurrentResult2[playerAddress],false);
          userLostBalance[playerAddress] += betValue[requestId];
          totalBetsLost++;
      }
    }else {
      if((playerCurrentResult1[playerAddress]+playerCurrentResult2[playerAddress]) < 7){
        addBets(playerAddress, requestId, userBet[playerAddress], betValue[requestId], playerCurrentResult1[playerAddress],playerCurrentResult2[playerAddress],true);
        isWon = true;
        totalBetsWon++;
      }else{
        addBets(playerAddress, requestId, userBet[playerAddress], betValue[requestId], playerCurrentResult1[playerAddress],playerCurrentResult2[playerAddress],false);
        userLostBalance[playerAddress] += betValue[requestId];
        totalBetsLost++;
      }
    }
    
    processDistribution(playerAddress,betValue[requestId],isWon);
  }

  function processDistribution(address _playerAddress, uint256 _amount, bool _isWon) internal {
    minerWalletBalance = (_amount * minerFees)/100;
    bool success = busdToken.transfer(wmlnAddress, minerWalletBalance);
    require(success, "BUSD Transfer to miner contract failed.");
  
    if(_isWon){
      uint256 wonAmount = _amount + (_amount - (_amount * getTotalFees())/100);
      totalWinnings += wonAmount;
      unclaimedWinning[_playerAddress] += wonAmount;
      playerTotalWinnings[_playerAddress] += (_amount - (_amount * getTotalFees())/100);
    }else{
      playerTotalLost[_playerAddress] += _amount;
    }
  }

  function getTotalFees() public view returns(uint256){
    return (minerFees);
  }

  function addBets(address _playerAddress, uint256 _requestId, uint256 _bet, uint256 _amount, uint256 _dice1Result, uint256 _dice2Result, bool _isWon) internal {
    bet =  Bet(_requestId, _amount, _bet, _dice1Result, _dice2Result, _isWon, block.timestamp);
    userBets[_playerAddress].push(bet);
  }

  function getBets() external view returns (Bet[] memory){
      return userBets[msg.sender];
  }

  function getResult() external view returns (uint256, uint256, bool){
    bool isWon;
    if(userBet[msg.sender] == 1){
      if((playerCurrentResult1[msg.sender]+playerCurrentResult2[msg.sender]) >= 7){
        isWon = true;
      }
    }else {
      if((playerCurrentResult1[msg.sender]+playerCurrentResult2[msg.sender]) < 7){
        isWon = true;
      }
    }
    return(playerCurrentResult1[msg.sender],playerCurrentResult2[msg.sender],isWon);
  }

  function getResultByAddress(address _address) public view returns (uint256, uint256, bool){
    bool isWon;
    if(userBet[_address] == 1){
      if((playerCurrentResult1[_address]+playerCurrentResult2[_address]) >= 7){
        isWon = true;
      }
    }else {
      if((playerCurrentResult1[_address]+playerCurrentResult2[_address]) < 7){
        isWon = true;
      }
    }
    return(playerCurrentResult1[_address],playerCurrentResult2[_address],isWon);
  }

  function claimWinnings() external nonReentrant isUnpaused{
    uint256 claimableWinnings = unclaimedWinning[msg.sender];

    unclaimedWinning[msg.sender] = 0;
    require(busdToken.balanceOf(address(this)) >= claimableWinnings, "Insufficient contract BUSD balance");

    bool success = busdToken.transfer(msg.sender, claimableWinnings);
    require(success, "Token Transfer failed.");
  }

  function injectBNB() payable external {}

  function injectBUSD(uint256 _amount) external {
    require(busdToken.allowance(msg.sender, address(this)) >= _amount,"Not enough allowance");
    require(busdToken.balanceOf(msg.sender) >= _amount,"Insufficient BUSD balance");    
    bool success = busdToken.transferFrom(msg.sender, address(this), _amount);
    require(success, "BUSD Transfer failed.");
  }

  //Emergency withdrawal
  function withdrawBNB() onlyOwner isPaused external{ 
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
  }

  //Emergency withdrawal
  function withdrawBUSD() onlyOwner isPaused external{ 
    bool success = busdToken.transfer(msg.sender,busdToken.balanceOf(address(this)));
    require(success, "BUSD Transfer failed.");
  }

  function transferOwnership(address _newOwner) external onlyOwner{
    owner = _newOwner;
  }

  function renounceOwnership() external onlyOwner{
    owner = address(0);
  }

  function pauseContract() external onlyOwner{
    paused = true;
  }

  function unpauseContract() external onlyOwner{
    require(busdToken.balanceOf(address(this)) > 0,"Contract doesnt have any BUSD balance");
    require(address(this).balance > 0,"Contract doesnt have any BNB balance for LINK tokens purchase");
    paused = false;
  }

  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }

  modifier isUnpaused() {
    require(paused == false);
    _;
  }

  modifier isPaused() {
    require(paused == true);
    _;
  }

  receive() external payable {}
}