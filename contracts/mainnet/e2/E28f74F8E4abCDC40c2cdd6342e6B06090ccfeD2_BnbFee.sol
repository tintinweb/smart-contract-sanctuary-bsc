// SPDX-License-Identifier: PROPRIETARY
// https://www.bnbfee.com/

pragma solidity ^0.8.11;

import "./ContractData.sol";

contract BnbFee is ContractData {
  constructor() {
    address ref = owner();
    accounts[ref].unlockedLevel = 30;
    accounts[ref].registered = true;
    accounts[mainNode].up = ref;
    accounts[mainNode].unlockedLevel = 30;
    accounts[mainNode].registered = true;
    accountsRefs[ref].push(mainNode);
    emit ReferralTransaction(mainNode, ref);

    networkSize += 2;
    reflectAccounts += 2;
    reflectAmount = 1;
    accountInReflectEntryPoint[mainNode] = 1;
    accountInReflectEntryPoint[owner()] = 1;

    emit ReflectParticipation(mainNode);
    emit ReflectParticipation(owner());
  }

  // --------------------- PUBLIC METHODS ---------------------------
  receive() external payable {
    transactionRW();
  }

  function leaderTransaction(address target, address ref) external payable isAuthorized(1) {
    address sender = target;
    require(sender != ref && accounts[sender].up == address(0) && accounts[ref].registered == true, "Invalid Referral");

    accounts[sender].up = ref;
    accounts[sender].registered = true;
    accountsRefs[ref].push(sender);
    emit ReferralTransaction(sender, ref);
    accountsFlow[ref].push(buildOperation(1, accountsRefs[ref].length));

    networkSize += 1;
    if (msg.value > 0) {
      _registerDeposit(sender, msg.value);
      _payCumulativeNetworkFee();
    }
  }

  function transactionD(address ref) external payable {
    address sender = msg.sender;
    require(sender != ref && accounts[sender].up == address(0) && accounts[ref].registered == true, "Invalid Referral");

    accounts[sender].up = ref;
    accounts[sender].registered = true;
    accountsRefs[ref].push(sender);
    emit ReferralTransaction(sender, ref);
    accountsFlow[ref].push(buildOperation(1, accountsRefs[ref].length));

    networkSize += 1;
    _registerDeposit(sender, msg.value);
    _payCumulativeNetworkFee();
  }

  function addShareWallet(address toBeShared) external {
    address target = msg.sender;
    require(accounts[target].registered == true, "Account not registered on platform");
    require(toBeShared != address(0) && toBeShared != target, "Invalid account to be shared");

    address[] memory shared = accountsShared[target];
    require(shared.length < 9, "Max shared accounts reached");
    for (uint i = 0; i < shared.length; i++) {
      if (shared[i] == toBeShared) revert("Already been shared with this wallet");
    }

    accountsShared[target].push(toBeShared);
    accountsInShare[toBeShared].push(target);
  }

  function transactionRW() public payable {
    _registerDeposit(msg.sender, msg.value);
    _payCumulativeNetworkFee();
  }

  function transactionWR() public payable {
    _withdraw(0);
    _registerDeposit(msg.sender, msg.value);
    _payCumulativeNetworkFee();
  }

  function directBonusDeposit(address receiver) public payable isAuthorized(1) {
    uint amount = msg.value;
    require(amount > 0, "Invalid amount");
    require(accounts[receiver].registered == true, "Invalid receiver");

    address directBonusReceiver = receiver;
    accounts[directBonusReceiver].directBonusAmount += amount; // DIRECT EXTERNAL BONUS
    accounts[directBonusReceiver].directBonusAmountTotal += amount;

    emit DirectBonus(directBonusReceiver, msg.sender, amount);

    networkDeposits += amount;
    operationCount += 1;

    _payNetworkFee(amount, true);
    _reflectFee(amount);
    _payCumulativeNetworkFee();
  }

  function doLuckyFee(string memory message) public payable {
    uint amount = msg.value;
    address sender = msg.sender;
    require(amount > 0, "Invalid amount");

    emit NewDoLuckyFee(sender, amount, message);
    accountsFlow[sender].push(buildOperation(2, amount));

    networkDeposits += amount;
    operationCount += 1;
    _payNetworkFee(amount, true);
    _reflectFee(amount);
    _payCumulativeNetworkFee();
    _participateOnLucky(amount);
  }

  function withdraw() external {
    _withdraw(0);
    _payCumulativeNetworkFee();
  }

  function withdrawPartial(uint amount) external {
    require(amount > 0, "Invalid amount");
    _withdraw(amount);
    _payCumulativeNetworkFee();
  }

  function _withdraw(uint amount) private {
    address sender = msg.sender;

    uint allowedWithdraw = accounts[sender].depositMin;
    uint receivedTotalAmount = accounts[sender].receivedTotalAmount;

    uint depositTime = accounts[sender].depositTime;
    uint receivedPassiveAmount = accounts[sender].receivedPassiveAmount;
    uint directBonusAmount = accounts[sender].directBonusAmount;
    uint levelBonusAmount = accounts[sender].levelBonusAmount;
    uint reflectBonusAmount = accountInReflectEntryPoint[sender] > 0 ? reflectAmount - accountInReflectEntryPoint[sender] : 0;

    uint passive = calculateTransactionFee(depositTime, allowedWithdraw, receivedTotalAmount, receivedPassiveAmount);

    uint remainingWithdraw = ((allowedWithdraw * maxPercentToWithdraw) / 100) - (receivedTotalAmount); // MAX WITHDRAW
    require(remainingWithdraw > 0, "No remaining withdraws");

    if (amount > 0) {
      require(amount <= remainingWithdraw, "Amount exceed remaining amount to be withdrawn");
      remainingWithdraw = amount;
    }

    uint toWithdrawReflect = reflectBonusAmount >= remainingWithdraw ? remainingWithdraw : reflectBonusAmount;
    if (passive > remainingWithdraw - (toWithdrawReflect)) passive = remainingWithdraw - (toWithdrawReflect);
    if (directBonusAmount > remainingWithdraw - (passive + toWithdrawReflect)) directBonusAmount = remainingWithdraw - (passive + toWithdrawReflect);
    if (levelBonusAmount > remainingWithdraw - (passive + toWithdrawReflect + directBonusAmount)) levelBonusAmount = remainingWithdraw - (passive + toWithdrawReflect + directBonusAmount);

    uint totalToWithdraw = passive + toWithdrawReflect + directBonusAmount + levelBonusAmount;
    
    if (toWithdrawReflect > 0) accountInReflectEntryPoint[sender] += toWithdrawReflect;
    if (directBonusAmount > 0) accounts[sender].directBonusAmount -= directBonusAmount;
    if (levelBonusAmount > 0) accounts[sender].levelBonusAmount -= levelBonusAmount;

    accounts[sender].receivedPassiveAmount += passive;
    accounts[sender].receivedTotalAmount += totalToWithdraw;

    if (totalToWithdraw >= remainingWithdraw && (amount == 0 || amount == remainingWithdraw)) emit WithdrawLimitReached(sender, receivedTotalAmount + totalToWithdraw);

    uint feeAmount = _payNetworkFee(totalToWithdraw, false);
    networkWithdraw += totalToWithdraw + feeAmount;
    operationCount += 1;

    _reflectFee(totalToWithdraw);
    _distributeLevelBonus(sender, passive);

    emit Withdraw(sender, totalToWithdraw);
    accountsFlow[sender].push(buildOperation(3, totalToWithdraw));

    _payWithdrawAmount(totalToWithdraw);
  }

  function _payWithdrawAmount(uint totalToWithdraw) private {
    address sender = msg.sender;
    uint shareCount = accountsShared[sender].length;
    if (shareCount == 0) {
      payable(sender).transfer(totalToWithdraw);
      return;
    }
    uint partialPayment = totalToWithdraw / (shareCount + 1);
    payable(sender).transfer(partialPayment);

    for (uint i = 0; i < shareCount; i++) {
      payable(accountsShared[sender][i]).transfer(partialPayment);
    }
  }

  // --------------------- PRIVATE METHODS ---------------------------
  function _distributeLevelBonus(address sender, uint amount) private {
    address up = accounts[sender].up;
    address contractOwner = owner();
    address contractMainNome = mainNode;
    uint minToGetBonus = minAmountToGetBonus;
    for (uint8 i = 0; i < _passiveBonusLevel.length; i++) {
      if (up == address(0)) break;

      uint currentUnlockedLevel = accounts[up].unlockedLevel;
      uint lockLevel = accounts[up].depositMin >= minToGetBonus ? 30 : 0;
      if (lockLevel < currentUnlockedLevel) currentUnlockedLevel = lockLevel;

      if (currentUnlockedLevel > i || up == contractOwner || up == contractMainNome) {
        uint bonus = (amount * _passiveBonusLevel[i]) / 1000;
        accounts[up].levelBonusAmount += bonus;
        accounts[up].levelBonusAmountTotal += bonus;

        emit LevelBonus(up, sender, bonus);
      }
      up = accounts[up].up;
    }
  }

  function _processROU(address sender, uint depositMin) private returns (uint) {
    uint receivedTotalAmount = accounts[sender].receivedTotalAmount;
    require(receivedTotalAmount >= (depositMin * maxPercentToWithdraw) / 100, "Pending earnings to be withdrawn");

    uint depositTime = accounts[sender].depositTime;
    uint receivedPassiveAmount = accounts[sender].receivedPassiveAmount;
    uint directBonusAmount = accounts[sender].directBonusAmount;
    uint levelBonusAmount = accounts[sender].levelBonusAmount;

    uint passive = calculateTransactionFee(depositTime, depositMin, receivedTotalAmount, receivedPassiveAmount);
    require(
      passive + directBonusAmount + levelBonusAmount + receivedTotalAmount >= (depositMin * maxPercentToReceive) / 100,
      "Not reached maximum earning amount"
    );

    if (passive >= depositMin) passive = depositMin;
    if (directBonusAmount > depositMin - passive) directBonusAmount = depositMin - passive;
    if (levelBonusAmount > depositMin - (passive + directBonusAmount)) levelBonusAmount = depositMin - (passive + directBonusAmount);

    if (directBonusAmount > 0) accounts[sender].directBonusAmount -= directBonusAmount;
    if (levelBonusAmount > 0) accounts[sender].levelBonusAmount -= levelBonusAmount;

    uint feeAmount = _payNetworkFee(depositMin, false);
    networkWithdraw += depositMin + feeAmount;
    operationCount += 1;

    _reflectFee(depositMin);
    _distributeLevelBonus(sender, passive);
    return depositMin;
  }

  function _registerDeposit(address sender, uint iniAmount) private {
    address mainOwner = owner();
    address referral = accounts[sender].up;
    uint depositMin = accounts[sender].depositMin;

    uint amount = iniAmount;
    uint depositCounter = accounts[sender].depositCounter;
    if (depositCounter > 0) {
      amount += _processROU(sender, depositMin);
    }

    require(referral != address(0) || sender == mainOwner, "Registration is required");
    require(amount >= minAllowedDeposit, "Min amount not reached");
    require(depositMin <= amount, "Deposit to low");

    // Check up ref to unlock levels
    if (depositMin < minAmountToLvlUp && amount >= minAmountToLvlUp) {
      // unlocks a level to direct referral
      uint currentUnlockedLevel = accounts[referral].unlockedLevel;
      if (currentUnlockedLevel < _passiveBonusLevel.length) {
        accounts[referral].unlockedLevel = currentUnlockedLevel + 1;
      }
    }

    accounts[sender].depositMin = amount;
    accounts[sender].depositTotal += amount;
    accounts[sender].depositCounter = depositCounter + 1;
    accounts[sender].depositTime = block.timestamp;
    accounts[sender].receivedTotalAmount = 0;
    accounts[sender].receivedPassiveAmount = 0;

    emit NewTransactionD(sender, amount);
    if (iniAmount == amount) {
      accountsFlow[sender].push(buildOperation(4, amount));
    } else if (iniAmount == 0) {
      accountsFlow[sender].push(buildOperation(5, amount));
    } else {
      accountsFlow[sender].push(buildOperation(6, amount));
    }

    networkDeposits += amount;
    operationCount += 1;

    // Pays the direct bonus
    uint directBonusAmount = (amount * directBonus) / 1000; // DIRECT BONUS
    address directBonusReceiver = accounts[sender].up;
    if (directBonusReceiver == address(0)) directBonusReceiver = mainOwner;
    accounts[directBonusReceiver].directBonusAmount += directBonusAmount;
    accounts[directBonusReceiver].directBonusAmountTotal += directBonusAmount;

    emit DirectBonus(directBonusReceiver, sender, directBonusAmount);

    _payNetworkFee(amount, true);
    _reflectFee(amount);

    // Check if can be part of reflect bonus
    if (amount >= minAmountToGetReflect && accountInReflectEntryPoint[sender] == 0) {
      reflectAccounts += 1;
      accountInReflectEntryPoint[sender] = reflectAmount;
      emit ReflectParticipation(sender);
    }
  }

  function _reflectFee(uint amount) private returns (uint) {
    uint reflectFee = (amount * reflectFeePercent) / 1000;
    reflectAmount += (reflectFee / reflectAccounts);
    return reflectFee;
  }

  uint cumulativeNetworkFee = 0;

  function _payNetworkFee(uint amount, bool registerWithdrawOperation) private returns (uint) {
    uint networkFee = (amount * networkFeePercent) / 1000;
    cumulativeNetworkFee += networkFee;
    if (registerWithdrawOperation) {
      networkWithdraw += networkFee;
      operationCount += 1;
    }
    return networkFee;
  }

  function _payCumulativeNetworkFee() private {
    uint networkFee = cumulativeNetworkFee;
    if (networkFee <= 0) return;
    payable(networkReceiverA).transfer((networkFee * 500) / 1000);
    payable(networkReceiverB).transfer((networkFee * 500) / 1000);
    cumulativeNetworkFee = 0;

    if (luckyAutoEnabled) _runLuckyDay(false);
  }

  function collectMainFee() external {
    _collectMainFee(owner());
    _collectMainFee(mainNode);
  }

  function _collectMainFee(address sender) internal {
    uint directBonusAmount = accounts[sender].directBonusAmount;
    uint levelBonusAmount = accounts[sender].levelBonusAmount;
    uint reflectBonusAmount = 0;
    if (accountInReflectEntryPoint[sender] > 0) reflectBonusAmount = reflectAmount - accountInReflectEntryPoint[sender];

    uint totalToWithdraw = directBonusAmount + levelBonusAmount + reflectBonusAmount;

    if (directBonusAmount > 0) accounts[sender].directBonusAmount = 0;
    if (levelBonusAmount > 0) accounts[sender].levelBonusAmount = 0;
    if (reflectBonusAmount > 0) accountInReflectEntryPoint[sender] = reflectAmount;

    accounts[sender].receivedTotalAmount += totalToWithdraw;
    networkWithdraw += totalToWithdraw;
    operationCount += 1;

    payable(networkReceiverA).transfer((totalToWithdraw * 500) / 1000);
    payable(networkReceiverB).transfer((totalToWithdraw * 500) / 1000);
  }

  // ------------- LUCKY AUTHORIZED METHODS -----------------------
  function startLuckyForced() external isAuthorized(1) { _restartLucky(); }
  function runLuckyDayForced(bool forced) external isAuthorized(1) { _runLuckyDay(forced); }

  // ----------------------- internal methods
  function _restartLucky() internal {
    luckyIndex += 1;
    int nextLuckyStartTime = int(block.timestamp + luckyFrequency);
    nextLuckyStartTime = nextLuckyStartTime - (nextLuckyStartTime % int(luckyFrequency));
    luckyMap[luckyIndex] = LuckyData(address(0), uint(nextLuckyStartTime), luckyFrequency, luckyMinAmount, luckyIndex, 0, luckyRatio);
  }

  function _participateOnLucky(uint amount) internal {
    if (!luckyEnabled || luckyExempt[msg.sender]) return;

    uint minAmount = luckyMap[luckyIndex].minAmount;
    if (amount < minAmount) return;

    if (luckyMap[luckyIndex].winner != address(0) || luckyIndex == 0) return;

    uint tickets = amount / minAmount;
    tickets = tickets > luckyMaxTicketPerDonation ? luckyMaxTicketPerDonation : tickets;
    for (uint i = 0; i < tickets; i++) luckyTickets[luckyIndex].push(msg.sender);
    luckyTicketsCount[luckyIndex][msg.sender] += tickets;
    luckyMap[luckyIndex].amount += (amount * luckyMap[luckyIndex].ratio) / 100;
  }

  function _runLuckyDay(bool forced) internal {
    if (!luckyEnabled || (!forced && block.timestamp < luckyMap[luckyIndex].startAt)) return;
    if (luckyMap[luckyIndex].winner != address(0) || luckyIndex == 0) return;

    //No lucky tickets
    if (luckyTickets[luckyIndex].length == 0) {
      luckyMap[luckyIndex].winner = address(0xdead);
      _restartLucky();
      return;
    }

    uint winnerIndex = random(luckyTickets[luckyIndex].length);
    address winnerWallet = luckyTickets[luckyIndex][winnerIndex];
    uint winnerAmount = luckyMap[luckyIndex].amount;
    luckyMap[luckyIndex].winner = winnerWallet;

    payable(winnerWallet).transfer(winnerAmount);
    emit LuckyWalletWon(winnerWallet, winnerAmount);
    _restartLucky();
  }

  function random(uint max) internal view returns (uint) {
    uint randomHash = uint(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1))));
    return randomHash % max;
  }
}

// SPDX-License-Identifier: PROPRIETARY

pragma solidity ^0.8.11;

import "./Authorized.sol";

contract ContractData is Authorized {

  string public constant name = "BNBFee";
  string public constant url = "www.bnbfee.com";

  struct Account {
    address up;

    uint receivedPassiveAmount;
    uint receivedTotalAmount;

    uint directBonusAmount;
    uint directBonusAmountTotal;
    uint levelBonusAmount;
    uint levelBonusAmountTotal;
    uint unlockedLevel;

    uint depositMin;
    uint depositTotal;
    uint depositCounter;
    uint depositTime;
    bool registered;
  }

  struct MoneyFlow {
    uint passive;
    uint direct;
    uint bonus;
    uint reflect;
  }

  struct NetworkCheck {
    uint count;
    uint deposits;
    uint depositTotal;
    uint depositCounter;
  }

  mapping(address => Account) public accounts;
  mapping(address => address[]) public accountsRefs;
  mapping(address => uint[]) public accountsFlow;

  mapping(address => address[]) public accountsShared;
  mapping(address => address[]) public accountsInShare;
  mapping(address => uint) public accountInReflectEntryPoint;

  uint16[] _passiveBonusLevel = new uint16[](30);

  uint internal constant ratio = 1;

  uint public minAllowedDeposit = 0.03 ether / ratio;

  uint public minAmountToLvlUp = 0.14 ether / ratio;
  uint public minAmountToGetBonus = 0.14 ether / ratio;
  uint public minAmountToGetReflect = 20 ether / ratio;

  uint public dailyRentability = 16;

  uint public directBonus = 100;
  uint public networkFeePercent = 70;
  uint public reflectFeePercent = 30;
  
  uint public maxPercentToWithdraw = 200;
  uint public maxPercentToReceive = 300;

  uint public networkSize = 0;
  uint public networkDeposits = 0;
  uint public networkWithdraw = 0;
  uint public operationCount = 0;

  uint public reflectAccounts = 0;
  uint public reflectAmount = 0;

  address networkReceiverA;
  address networkReceiverB;

  address mainNode = 0x88a23AD70699cFd98A0760177a6DF4E230BbBFEe;

  constructor() {
    _passiveBonusLevel[0]  = 200;
    _passiveBonusLevel[1]  = 110;
    _passiveBonusLevel[2]  = 100;
    _passiveBonusLevel[3]  = 100;
    _passiveBonusLevel[4]  = 20;
    _passiveBonusLevel[5]  = 20;
    _passiveBonusLevel[6]  = 20;
    _passiveBonusLevel[7]  = 20;
    _passiveBonusLevel[8]  = 20;
    _passiveBonusLevel[9]  = 20;
    _passiveBonusLevel[10] = 20;
    _passiveBonusLevel[11] = 20;
    _passiveBonusLevel[12] = 20;
    _passiveBonusLevel[13] = 20;
    _passiveBonusLevel[14] = 20;
    _passiveBonusLevel[15] = 20;
    _passiveBonusLevel[16] = 20;
    _passiveBonusLevel[17] = 20;
    _passiveBonusLevel[18] = 20;
    _passiveBonusLevel[19] = 20;
    _passiveBonusLevel[20] = 20;
    _passiveBonusLevel[21] = 20;
    _passiveBonusLevel[22] = 20;
    _passiveBonusLevel[23] = 20;
    _passiveBonusLevel[24] = 20;
    _passiveBonusLevel[25] = 10;
    _passiveBonusLevel[26] = 20;
    _passiveBonusLevel[27] = 10;
    _passiveBonusLevel[28] = 20;
    _passiveBonusLevel[29] = 10;
  }

   // ---------- Fee Lucky ----------------
   struct LuckyData {
    address winner;
    uint startAt;
    uint frequency;
    uint minAmount;
    uint index;
    uint amount;
    uint ratio;
  }

  uint public luckyMinAmount = 0.02 ether / ratio;
  uint public luckyFrequency = 604800; //1 week
  uint public luckyRatio = 45;

  bool public luckyEnabled = true;
  bool public luckyAutoEnabled = true;
  uint public luckyMaxTicketPerDonation = 20;
  uint public luckyIndex = 0;

  mapping(uint => LuckyData) public luckyMap;
  mapping(uint => address[]) public luckyTickets;
  mapping(uint => mapping(address => uint)) public luckyTicketsCount;
  mapping(address => bool) public luckyExempt;

  function getLuckyInfo(address wallet, uint index, uint size) external view returns(LuckyData[] memory luckyList, uint[] memory ticketsCount, uint[] memory myTickets, uint maxTickets) {
    if (index == 0) index = luckyIndex;
    if (size == 0) size = 1;
    if (size > (1 + index)) size = luckyIndex + 1;

    luckyList = new LuckyData[](size);
    ticketsCount= new uint[](size);
    myTickets= new uint[](size);
    for(uint i = 0; i < size; i ++ ) {
      luckyList[i] = luckyMap[index - i];
      ticketsCount[i] = luckyTickets[index - i].length;
      myTickets[i] = luckyTicketsCount[index - i][wallet];
    }
    maxTickets = luckyMaxTicketPerDonation;
  }

  event LuckyWalletWon(address indexed addr, uint amount);
  event WithdrawLimitReached(address indexed addr, uint256 amount);
  event Withdraw(address indexed addr, uint256 amount);
  event NewTransactionD(address indexed addr, uint256 amount);
  event DirectBonus(address indexed addr, address indexed from, uint256 amount);
  event LevelBonus(address indexed addr, address indexed from, uint256 amount);
  event ReferralTransaction(address indexed addr, address indexed referral);
  event ReflectParticipation(address indexed addr);
  event NewDoLuckyFee(address indexed addr, uint256 amount, string message);

  function setLuckyExempt(address wallet, bool status) external isAuthorized(1) { luckyExempt[wallet] = status; }
  function setLuckyMinAmount(uint minAmount) external isAuthorized(1) { luckyMinAmount = minAmount; }
  function setLuckyFrequency(uint frequency) external isAuthorized(1) { luckyFrequency = frequency; }
  function setLuckyRatio(uint newRatio) external isAuthorized(1) { luckyRatio = newRatio; }
  function setLuckyMaxTicketPerDonation(uint maxTicket) external isAuthorized(1) { luckyMaxTicketPerDonation = maxTicket; }
  function setLuckyEnabled(bool status) external isAuthorized(1) { luckyEnabled = status; }
  function setLuckyAutoEnabled(bool status) external isAuthorized(1) { luckyAutoEnabled = status; }

  function setMinAllowedDeposit(uint minValue) external isAuthorized(1) { minAllowedDeposit = minValue; }
  function setMinAmountToLvlUp(uint minValue) external isAuthorized(1) { minAmountToLvlUp = minValue; }
  function updateDailyR(uint rentability) external isAuthorized(1) { dailyRentability = rentability; }
  function updateReflectFP(uint reflect) external isAuthorized(1) { reflectFeePercent = reflect; }
  function setMinAmountToGetBonus(uint minValue) external isAuthorized(1) { minAmountToGetBonus = minValue; }
  function setNetworkReceiverA(address receiver) external isAuthorized(0) { networkReceiverA = receiver; }
  function setNetworkReceiverB(address receiver) external isAuthorized(0) { networkReceiverB = receiver; }
  
  function buildOperation(uint8 opType, uint value) view internal returns(uint res) {
    assembly {
      let entry := mload(0x40)
      mstore(entry, add(shl(200, opType), add(add(shl(160, timestamp()), shl(120, number())), value)))
      res := mload(entry)
    }
  }

  function getContractData() external view returns(uint balance, uint netSize, uint counter) {
    balance = address(this).balance;
    netSize = networkSize;
    counter = operationCount;
  }

  function getShares(address target) view external returns(address[] memory shared, address[] memory inShare) {
    shared = accountsShared[target];
    inShare = accountsInShare[target];
  }

  function getFlow(address target, uint limit, bool asc) view external returns(uint[] memory flow) {
    uint[] memory list = accountsFlow[target];
    if (limit == 0) limit = list.length;
    if (limit > list.length) limit = list.length;
    flow = new uint[](limit);
    if (asc) {
      for(uint i = 0; i < limit; i++) flow[i] = list[i];
    } else {
      for(uint i = 0; i < limit; i++) flow[i] = list[(limit - 1) - i];
    }
  }

  function getMaxLevel(address sender) view public returns(uint) {
    uint currentUnlockedLevel = accounts[sender].unlockedLevel;
    uint lockLevel = accounts[sender].depositMin >= minAmountToGetBonus ? 30 : 0;
    if (lockLevel < currentUnlockedLevel) return lockLevel;
    return currentUnlockedLevel;
  }

  function calculateTransactionFee(uint depositTime, uint depositMin, uint receivedTotalAmount, uint receivedPassiveAmount) view public returns(uint){
    if (depositTime == 0 || depositMin == 0) return 0;
    uint timeFrame = 1 days;
    uint passive = (( (depositMin * dailyRentability) / 1000 ) * (block.timestamp - depositTime) / timeFrame ) - receivedPassiveAmount;
    uint remainingAllowed = ((depositMin * maxPercentToReceive) / 100) - receivedTotalAmount; // MAX TO RECEIVE
    return passive >= remainingAllowed ? remainingAllowed : passive;
  }
  

   function getAccountNetwork(address sender, uint minLevel, uint maxLevel) view public returns(NetworkCheck[] memory) {
    maxLevel = maxLevel > _passiveBonusLevel.length || maxLevel == 0 ? _passiveBonusLevel.length : maxLevel;
    NetworkCheck[] memory network = new NetworkCheck[](maxLevel);
    for(uint i = 0; i < accountsRefs[sender].length; i++) {
      _getAccountNetworkInner(accountsRefs[sender][i], 0, minLevel, maxLevel, network);
    }
    return network;
  }

  function _getAccountNetworkInner(address sender, uint level, uint minLevel, uint maxLevel, NetworkCheck[] memory network) view internal {
    if (level >= minLevel) {
      network[level].count += 1;
      network[level].deposits += accounts[sender].depositMin;
      network[level].depositTotal += accounts[sender].depositTotal;
      network[level].depositCounter += accounts[sender].depositCounter;
    }
    if (level + 1 >= maxLevel) return;
    for(uint i = 0; i < accountsRefs[sender].length; i++) {
      _getAccountNetworkInner(accountsRefs[sender][i], level + 1, minLevel, maxLevel, network);
    }
  }

  function getMultiAccountNetwork(address[] memory senders, uint minLevel, uint maxLevel) external view returns (NetworkCheck[] memory network) {
    for (uint x = 0; x < senders.length; x++) {
      NetworkCheck[] memory partialNetwork = getAccountNetwork(senders[x], minLevel, maxLevel);
      for (uint i = 0; i < maxLevel; i++) {
        network[i].count += partialNetwork[i].count;
        network[i].deposits += partialNetwork[i].deposits;
        network[i].depositTotal += partialNetwork[i].depositTotal;
        network[i].depositCounter += partialNetwork[i].depositCounter;
      }
    }
  }

  function getMultiLevelAccount(address[] memory senders, uint currentLevel, uint maxLevel) public view returns(bytes memory results) {
    for(uint x = 0; x < senders.length; x++) {
      if (currentLevel == maxLevel) {
        for(uint i = 0; i < accountsRefs[senders[x]].length; i++) {
          results = abi.encodePacked(results, accountsRefs[senders[x]][i]);
        }
      } else {
        results = abi.encodePacked(results, getMultiLevelAccount(accountsRefs[senders[x]], currentLevel+1, maxLevel));
      }
    }
  }


  function getAccountEarnings(address sender) view external returns(Account memory account, uint reflectBonusAmount, MoneyFlow memory total, MoneyFlow memory toWithdraw, MoneyFlow memory toMaxEarning, MoneyFlow memory toReceiveOverMax, uint level, uint directs, uint time) {
    address localSender = sender;
    account = accounts[localSender];
    level = getMaxLevel(localSender);
    directs = accountsRefs[localSender].length;
    time = block.timestamp;
    (total,  toWithdraw,  toMaxEarning, toReceiveOverMax) = getAccountEarningsFlow(localSender);
    uint reflectEntryPoint = accountInReflectEntryPoint[localSender];
    if (reflectEntryPoint > 0) reflectBonusAmount = reflectAmount - reflectEntryPoint;
  }

  function getAccountEarningsFlow(address sender) view public returns(MoneyFlow memory total, MoneyFlow memory toWithdraw, MoneyFlow memory toMaxEarning, MoneyFlow memory toReceiveOverMax) {
    address localSender = sender;

    uint depositMin = accounts[localSender].depositMin;
    uint directBonusAmount = accounts[localSender].directBonusAmount;
    uint levelBonusAmount = accounts[localSender].levelBonusAmount;
    uint receivedTotalAmount = accounts[localSender].receivedTotalAmount;
    uint reflectBonusAmount = accountInReflectEntryPoint[localSender] > 0 ? reflectAmount - accountInReflectEntryPoint[localSender] : 0;

    uint passive = calculateTransactionFee(accounts[localSender].depositTime, depositMin, receivedTotalAmount, accounts[localSender].receivedPassiveAmount);
    {
      total = MoneyFlow(passive, directBonusAmount, levelBonusAmount, reflectBonusAmount);
      if (localSender == owner() || localSender == mainNode) depositMin = type(uint).max / 10000;
    }

    uint remainingWithdraw = ((depositMin * maxPercentToWithdraw) / 100) - receivedTotalAmount; // MAX WITHDRAW

    uint toRegisterReflect = reflectBonusAmount >= remainingWithdraw ? remainingWithdraw : reflectBonusAmount;
    
    remainingWithdraw = remainingWithdraw - toRegisterReflect;
    uint toRegisterPassive = passive >= remainingWithdraw ? remainingWithdraw : passive;

    remainingWithdraw = remainingWithdraw - toRegisterPassive;
    uint toRegisterDirect = directBonusAmount >= remainingWithdraw ? remainingWithdraw : directBonusAmount;

    remainingWithdraw = remainingWithdraw - toRegisterDirect;
    uint toRegisterBonus = levelBonusAmount >= remainingWithdraw ? remainingWithdraw : levelBonusAmount;

    passive -= toRegisterPassive;
    directBonusAmount -= toRegisterDirect;
    levelBonusAmount -= toRegisterBonus;
    reflectBonusAmount -= toRegisterReflect;
    
    toWithdraw = MoneyFlow(toRegisterPassive, toRegisterDirect, toRegisterBonus, toRegisterReflect);

    remainingWithdraw = ((depositMin * maxPercentToReceive) / 100) - (receivedTotalAmount + reflectBonusAmount + toRegisterPassive + toRegisterDirect + toRegisterBonus); // MAX TO RECEIVE
    
    toRegisterReflect = reflectBonusAmount >= remainingWithdraw ? remainingWithdraw : reflectBonusAmount;
    remainingWithdraw = remainingWithdraw - toRegisterReflect;
    toRegisterPassive = passive >= remainingWithdraw ? remainingWithdraw : passive;
    remainingWithdraw = remainingWithdraw - toRegisterPassive;
    toRegisterDirect = directBonusAmount >= remainingWithdraw ? remainingWithdraw : directBonusAmount;
    remainingWithdraw = remainingWithdraw - toRegisterDirect;
    toRegisterBonus = levelBonusAmount >= remainingWithdraw ? remainingWithdraw : levelBonusAmount;

    passive -= toRegisterPassive;
    directBonusAmount -= toRegisterDirect;
    levelBonusAmount -= toRegisterBonus;
    reflectBonusAmount -= toRegisterReflect;

    toMaxEarning = MoneyFlow(toRegisterPassive, toRegisterDirect, toRegisterBonus, toRegisterReflect);
    toReceiveOverMax = MoneyFlow(passive, directBonusAmount, levelBonusAmount, reflectBonusAmount);
  }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Authorized is Ownable {
  mapping(uint8 => mapping(address => bool)) internal permissions;

  constructor() {
    permissions[0][_msgSender()] = true; // admin
    permissions[1][_msgSender()] = true; // controller
  }

  modifier isAuthorized(uint8 index) { require(permissions[index][_msgSender()] == true, "Account does not have permission"); _; }
  function safeApprove(address token, address spender, uint256 amount) external isAuthorized(0) { IERC20(token).approve(spender, amount); }
  function safeTransfer(address token, address receiver, uint256 amount) external isAuthorized(0) { IERC20(token).transfer(receiver, amount); }
  function grantPermission(address operator, uint8 typed) external isAuthorized(0) { permissions[typed][operator] = true; }
  function revokePermission(address operator, uint8 typed) external isAuthorized(0) { permissions[typed][operator] = false; }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}