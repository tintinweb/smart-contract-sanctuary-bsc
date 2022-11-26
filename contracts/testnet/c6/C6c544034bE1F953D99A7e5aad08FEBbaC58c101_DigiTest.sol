//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./ContractData.sol";

contract DigiTest is ContractData {
  constructor() {
    accountsInfo[mainNode].up = owner();
    accountsInfo[mainNode].unlockedLevel = 15;
    accountsInfo[mainNode].registered = true;
    accountsRefs[owner()].push(mainNode);
    emit ReferralRegistration(mainNode, owner());

    networkSize += 1;
  }

  // --------------------- PUBLIC METHODS ---------------------------
  receive() external payable {
    makeDeposit();
  }

  function marketingPumpUp() external {}

  function registerAccount(address ref) external payable {
    address sender = msg.sender;
    require(sender != ref && accountsInfo[sender].up == address(0) && accountsInfo[ref].registered == true, "Invalid Referral");

    accountsInfo[sender].up = ref;
    accountsInfo[sender].registered = true;
    accountsRefs[ref].push(sender);
    emit ReferralRegistration(sender, ref);
    accountsFlow[ref].push(buildOperation(1, accountsRefs[ref].length));

    networkSize += 1;
    _registerDeposit(sender, msg.value);
    _payCumulativeFee();
  }

  function addShareWallet(address toBeShared) external {
    address target = msg.sender;
    require(accountsInfo[target].registered == true, "Account not registered on platform");
    require(toBeShared != address(0) && toBeShared != target, "Invalid account to be shared");

    address[] memory shared = accountsShared[target];
    require(shared.length < 9, "Max shared accounts reached");
    for (uint i = 0; i < shared.length; i++) {
      if (shared[i] == toBeShared) revert("Already been shared with this wallet");
    }

    accountsShared[target].push(toBeShared);
    accountsInShare[toBeShared].push(target);
  }

  function makeDeposit() public payable {
    _registerDeposit(msg.sender, msg.value);
    _payCumulativeFee();
  }

  function withdrawAndDeposit(uint amount) public payable {
    require(amount >= 0, "Invalid amount");
    composeDeposit = amount;
    _withdraw(0);
    _registerDeposit(msg.sender, msg.value + composeDeposit);
    _payCumulativeFee();
    composeDeposit = 0;
  }

  function directBonusDeposit(address receiver) public payable isAuthorized(1) {
    uint amount = msg.value;
    
    require(amount > 0, "Invalid amount");
    require(accountsInfo[receiver].registered == true, "Invalid receiver");
  /*
    address directBonusReceiver = receiver;
    accountsEarnings[directBonusReceiver].directBonusAmount += amount; // DIRECT EXTERNAL BONUS
    accountsEarnings[directBonusReceiver].directBonusAmountTotal += amount;

    emit DirectBonus(directBonusReceiver, msg.sender, amount);
  */
    networkDeposits += amount;
    _payNetworkFee(amount, true, false);
    _payCumulativeFee();

    address up = accountsInfo[receiver].up;
    address contractMainNome = mainNode;
    uint minToGetBonus = minAmountToGetBonus;
    for (uint8 i = 0; i < _passiveBonusLevel.length; i++) {
      if (up == address(0)) break;

      uint currentUnlockedLevel = accountsInfo[up].unlockedLevel;
      uint lockLevel = accountsInfo[up].depositMin >= minToGetBonus ? 15 : 0;
      if (lockLevel < currentUnlockedLevel) currentUnlockedLevel = lockLevel;

      if (currentUnlockedLevel > i || up == contractMainNome) {
        uint bonus = (amount * _passiveBonusLevel[i]) / 1000;
        accountsEarnings[up].levelBonusAmount += bonus;
        accountsEarnings[up].levelBonusAmountTotal += bonus;

        emit LevelBonus(up, receiver, bonus);
      }
      up = accountsInfo[up].up;
    }
  }

  function makeDonation(string memory message) public payable {
    uint amount = msg.value;
    address sender = msg.sender;
    require(amount > 0, "Invalid amount");

    emit NewDonationDeposit(sender, amount, message);
    accountsFlow[sender].push(buildOperation(2, amount));

    networkDeposits += amount;
    _payNetworkFee(amount, true, false);
    _payCumulativeFee();
  }

  function withdraw() external {
    _withdraw(0);
    _payCumulativeFee();
  }

  function withdrawPartial(uint amount) external {
    require(amount > 0, "Invalid amount");
    _withdraw(amount);
    _payCumulativeFee();
  }

  // --------------------- PRIVATE METHODS ---------------------------

  function _withdraw(uint amountOut) private {
    address sender = msg.sender;
    uint amount = amountOut;

    uint depositMin = accountsInfo[sender].depositMin;
    uint receivedTotalAmount = accountsEarnings[sender].receivedTotalAmount;

    uint depositTime = accountsInfo[sender].depositTime;
    uint receivedPassiveAmount = accountsEarnings[sender].receivedPassiveAmount;
    uint directBonusAmount = accountsEarnings[sender].directBonusAmount;
    uint levelBonusAmount = accountsEarnings[sender].levelBonusAmount;

    uint passive = calculatePassive(depositTime, depositMin, receivedTotalAmount, receivedPassiveAmount);

    uint remainingWithdraw = ((depositMin * maxPercentToWithdraw) / 100) - receivedTotalAmount; // MAX WITHDRAW
    uint withdrawAmount = remainingWithdraw;

    require(withdrawAmount > 0, "No remaining withdraws");
    require(accountsInfo[sender].lastWithdraw <= (block.timestamp - timeToWithdraw), "Only 1 withdraw each 24h is possible");

    if (amount > 0) {
      require(amount <= remainingWithdraw, "Amount exceed remaining amount to be withdrawn");
      withdrawAmount = amount;
    } else if (directBonusAmount + levelBonusAmount + passive < remainingWithdraw) {
      if (composeDeposit > 0) {
        withdrawAmount = composeDeposit;
      } else {
        withdrawAmount = ((directBonusAmount + levelBonusAmount + passive) * maxWithdrawPercentPerTime) / 100;
      }
    }
    _withdrawCalculations(sender, withdrawAmount, passive, directBonusAmount, levelBonusAmount, amount, receivedTotalAmount, remainingWithdraw);
  }

  function _withdrawCalculations(
    address sender,
    uint withdrawAmount,
    uint passive,
    uint directBonusAmount,
    uint levelBonusAmount,
    uint amount,
    uint receivedTotalAmount,
    uint remainingWithdraw
  ) private {
    uint summedBonus = directBonusAmount + levelBonusAmount;
    uint toWithdrawPassive = passive >= withdrawAmount ? withdrawAmount : passive;

    if (directBonusAmount > withdrawAmount - toWithdrawPassive) directBonusAmount = withdrawAmount - toWithdrawPassive;
    if (levelBonusAmount > withdrawAmount - (toWithdrawPassive + directBonusAmount))
      levelBonusAmount = withdrawAmount - (toWithdrawPassive + directBonusAmount);

    uint totalToWithdraw = toWithdrawPassive + directBonusAmount + levelBonusAmount;

    if (directBonusAmount > 0) accountsEarnings[sender].directBonusAmount -= directBonusAmount;
    if (levelBonusAmount > 0) accountsEarnings[sender].levelBonusAmount -= levelBonusAmount;

    accountsEarnings[sender].receivedPassiveAmount += toWithdrawPassive;
    accountsEarnings[sender].receivedTotalAmount += totalToWithdraw;
    accountsInfo[sender].lastWithdraw = block.timestamp;

    if (totalToWithdraw >= remainingWithdraw) {
      emit WithdrawLimitReached(sender, receivedTotalAmount + totalToWithdraw);
    } else {
      uint maxWithdraw = passive + summedBonus;
      if (amount > 0 && maxWithdraw < remainingWithdraw) {
        require(amount <= (maxWithdraw * maxWithdrawPercentPerTime) / 100, "Max withdraw allowed per time is 30% of remaining available");
      }
    }

    uint feeAmount = _payNetworkFee(totalToWithdraw, false, true);
    networkWithdraw += totalToWithdraw;

    //if (distributePassiveNetwork) _distributeLevelBonus(sender, toWithdrawPassive);

    emit Withdraw(sender, totalToWithdraw);
    accountsFlow[sender].push(buildOperation(3, totalToWithdraw));

    uint totalToPay = totalToWithdraw - feeAmount;
    if (composeDeposit > 0) {
      if (totalToPay >= composeDeposit) {
        totalToPay -= composeDeposit;
      } else {
        composeDeposit = totalToPay;
        totalToPay = 0;
      }
    }
    if (totalToPay > 0) _payWithdrawAmount(totalToPay);

    if (address(this).balance < ((maxBalance * holdPassiveOnDrop) / 100) && distributePassiveNetwork == true) {
      distributePassiveNetwork = false;
    }
  }

  function _payWithdrawAmount(uint totalToWithdraw) private {
    address sender = msg.sender;
    uint shareCount = accountsShared[sender].length;
    if (shareCount == 0) {
      payable(sender).transfer(totalToWithdraw);
      return;
    }
    uint partialValue = totalToWithdraw / (shareCount + 1);
    payable(sender).transfer(partialValue);

    for (uint i = 0; i < shareCount; i++) {
      payable(accountsShared[sender][i]).transfer(partialValue);
    }
  }




/*
   function _distributeLevelBonus(address sender, uint amount) private {
    address up = accountsInfo[sender].up;
    address contractMainNome = mainNode;
    uint minToGetBonus = minAmountToGetBonus;
    for (uint8 i = 0; i < _passiveBonusLevel.length; i++) {
      if (up == address(0)) break;

      uint currentUnlockedLevel = accountsInfo[up].unlockedLevel;
      uint lockLevel = accountsInfo[up].depositMin >= minToGetBonus ? 15 : 0;
      if (lockLevel < currentUnlockedLevel) currentUnlockedLevel = lockLevel;

      if (currentUnlockedLevel > i || up == contractMainNome) {
        uint bonus = (amount * _passiveBonusLevel[i]) / 1000;
        accountsEarnings[up].levelBonusAmount += bonus;
        accountsEarnings[up].levelBonusAmountTotal += bonus;

        emit LevelBonus(up, sender, bonus);
      }
      up = accountsInfo[up].up;
    }
  }

*/

  function _registerDeposit(address sender, uint amount) private {
    uint depositMin = accountsInfo[sender].depositMin;
    uint depositCounter = accountsInfo[sender].depositCounter;

    uint currentBalance = address(this).balance;
    if (maxBalance < currentBalance) {
      maxBalance = currentBalance;
      if (distributePassiveNetwork == false) distributePassiveNetwork = true;
    }

    if (depositCounter == 0) {
      accountsFlow[sender].push(buildOperation(4, amount));
    } else {
      uint receivedTotalAmount = accountsEarnings[sender].receivedTotalAmount;
      uint maxToReceive = (depositMin * maxPercentToWithdraw) / 100;
      if (receivedTotalAmount < maxToReceive) {
        if (composeDeposit > 0) {
          accountsFlow[sender].push(buildOperation(8, amount));
        } else {
          accountsFlow[sender].push(buildOperation(7, amount));
        }
        return _registerLiveUpgrade(sender, amount, depositMin, receivedTotalAmount, maxToReceive);
      } else {
        if (depositMin == amount) {
          accountsFlow[sender].push(buildOperation(5, amount));
        } else {
          accountsFlow[sender].push(buildOperation(6, amount));
        }
      }
    }

    address referral = accountsInfo[sender].up;
    require(referral != address(0), "Registration is required");
    require(amount >= minAllowedDeposit, "Min amount not reached");
    require(depositMin <= amount, "Deposit lower than account value");

    // Check up ref to unlock levels
    if (depositMin < minAmountToLvlUp && amount >= minAmountToLvlUp) {
      // unlocks a level to direct referral
      uint currentUnlockedLevel = accountsInfo[referral].unlockedLevel;
      if (currentUnlockedLevel < _passiveBonusLevel.length) {
        accountsInfo[referral].unlockedLevel = currentUnlockedLevel + 1;
      }
    }

    accountsInfo[sender].depositMin = amount;
    accountsInfo[sender].depositTotal += amount;
    accountsInfo[sender].depositCounter = depositCounter + 1;
    accountsInfo[sender].depositTime = block.timestamp;
    accountsEarnings[sender].receivedTotalAmount = 0;
    accountsEarnings[sender].receivedPassiveAmount = 0;
    accountsEarnings[sender].directBonusAmount = 0;
    accountsEarnings[sender].levelBonusAmount = 0;

    emit NewDeposit(sender, amount);
    networkDeposits += amount;

    // Pays the direct bonus
    /*
    uint directBonusAmount = (amount * directBonus) / 1000; // DIRECT BONUS
    if (referral != address(0)) {
      accountsEarnings[referral].directBonusAmount += directBonusAmount;
      accountsEarnings[referral].directBonusAmountTotal += directBonusAmount;
      emit DirectBonus(referral, sender, directBonusAmount);
    }
    */
    
    //PAGAMENTO UNILEVEL
    address up = accountsInfo[sender].up;
    address contractMainNome = mainNode;
    uint minToGetBonus = minAmountToGetBonus;

        for (uint8 i = 0; i < _passiveBonusLevel.length; i++) {
      if (up == address(0)) break;

      uint currentUnlockedLevel = accountsInfo[up].unlockedLevel;
      uint lockLevel = accountsInfo[up].depositMin >= minToGetBonus ? 15 : 0;
      if (lockLevel < currentUnlockedLevel) currentUnlockedLevel = lockLevel;

      if (currentUnlockedLevel > i || up == contractMainNome) {
        uint bonus = (amount * _passiveBonusLevel[i]) / 1000;
        accountsEarnings[up].levelBonusAmount += bonus;
        accountsEarnings[up].levelBonusAmountTotal += bonus;

        emit LevelBonus(up, sender, bonus);
      }
      up = accountsInfo[up].up;
    }


    _payNetworkFee(amount, true, false);
  }


  function _registerLiveUpgrade(
    address sender,
    uint amount,
    uint depositMin,
    uint receivedTotalAmount,
    uint maxToReceive
  ) private {
    uint depositTime = accountsInfo[sender].depositTime;
    uint receivedPassiveAmount = accountsEarnings[sender].receivedPassiveAmount;
    uint directBonusAmount = accountsEarnings[sender].directBonusAmount;
    uint levelBonusAmount = accountsEarnings[sender].levelBonusAmount;
    uint passive = calculatePassive(depositTime, depositMin, receivedTotalAmount, receivedPassiveAmount);

    require(passive + directBonusAmount + levelBonusAmount < maxToReceive, "Cannot live upgrade after reach 200% earnings");

    if (depositMin < minAmountToLvlUp && (amount + depositMin) >= minAmountToLvlUp) {
      // unlocks a level to direct referral
      address referral = accountsInfo[sender].up;
      uint currentUnlockedLevel = accountsInfo[referral].unlockedLevel;
      if (currentUnlockedLevel < _passiveBonusLevel.length) {
        accountsInfo[referral].unlockedLevel = currentUnlockedLevel + 1;
      }
    }

    uint passedTime;
    {
      uint precision = 1e12;
      uint percentage = (((passive + receivedPassiveAmount) * precision) / (((amount + depositMin) * maxPercentToWithdraw) / 100));
      uint totalSeconds = (maxPercentToWithdraw * timeFrame * 10) / dailyRentability;
      passedTime = (totalSeconds * percentage) / precision;
    }

    accountsInfo[sender].depositMin += amount;
    accountsInfo[sender].depositTotal += amount;
    accountsInfo[sender].depositCounter += 1;
    accountsInfo[sender].depositTime = block.timestamp - passedTime;

    emit NewUpgrade(sender, amount);
    networkDeposits += amount;

    // Pays the direct bonus
    address directBonusReceiver = accountsInfo[sender].up;
    if (directBonusReceiver != address(0)) {
      uint directBonusAmountPayment = (amount * directBonus) / 1000;
      accountsEarnings[directBonusReceiver].directBonusAmount += directBonusAmountPayment;
      accountsEarnings[directBonusReceiver].directBonusAmountTotal += directBonusAmountPayment;
      emit DirectBonus(directBonusReceiver, sender, directBonusAmountPayment);
    }

    _payNetworkFee(amount, true, false);
  }

  function _payNetworkFee(
    uint amount,
    bool registerWithdrawOperation,
    bool isWithdraw
  ) private returns (uint) {
    uint networkFee = (amount * networkFeePercent) / 1000;
    cumulativeNetworkFee += networkFee;

    uint wpmFee;
    if (isWithdraw) {
      wpmFee = (amount * wpmFeePercent) / 1000;
      cumulativeWPMFee += wpmFee;
    }

    if (registerWithdrawOperation) networkWithdraw += networkFee + wpmFee;
    return networkFee + wpmFee;
  }

  function _payCumulativeFee() private {
    uint networkFee = cumulativeNetworkFee;
    uint wpmFee = cumulativeWPMFee;
    if (networkFee > 0) {
      payable(networkReceiver).transfer(networkFee);
      cumulativeNetworkFee = 0;
    }
    if (wpmFee > 0 && wpmReceiver != address(0)) {
      payable(wpmReceiver).transfer(wpmFee);
      cumulativeWPMFee = 0;
    }
  }

  function collectMotherNode() external {
    if (wpmReceiver == address(0)) return;

    address sender = mainNode;
    {
      uint directBonusAmount = accountsEarnings[sender].directBonusAmount;
      uint levelBonusAmount = accountsEarnings[sender].levelBonusAmount;

      uint totalToWithdraw = directBonusAmount + levelBonusAmount;

      accountsEarnings[sender].receivedTotalAmount += totalToWithdraw;

      if (directBonusAmount > 0) accountsEarnings[sender].directBonusAmount = 0;
      if (levelBonusAmount > 0) accountsEarnings[sender].levelBonusAmount = 0;

      payable(wpmReceiver).transfer(totalToWithdraw);

      uint networkFee = _payNetworkFee(totalToWithdraw, false, false);
      networkWithdraw += totalToWithdraw + networkFee;
    }
  }
}