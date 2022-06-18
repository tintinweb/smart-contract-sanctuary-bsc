// SPDX-License-Identifier: PROPRIETARY - Lameni

pragma solidity ^0.8.11;

import "./ContractData.sol";





interface ERC20 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

}



contract WinPerMinute is ContractData {

  ERC20 public token;
  constructor() {
    token=ERC20(0xCe5FCa35c0302F47DC05B3e943C9859648dc69a9);
    address ref = owner();
    accounts[ref].unlockedLevel = 20;
    accounts[ref].registered = true;
    accounts[owner()].up = ref;
    accounts[owner()].unlockedLevel = 20;
    accounts[owner()].registered = true;
    accountsRefs[ref].push(owner());
    emit ReferralRegistration(owner(), ref);

    networkSize += 1;
  }

  // --------------------- PUBLIC METHODS ---------------------------
  receive() external payable {
    // makeDeposit();
  }

  function leaderRegisterAcount(address target, address ref,uint256 amount) external  onlyOwner {
    address sender = target;
    require(sender != ref && accounts[sender].up == address(0) && accounts[ref].registered == true, "Invalid Referral");

    accounts[sender].up = ref;
    accounts[sender].registered = true;
    accountsRefs[ref].push(sender);
    emit ReferralRegistration(sender, ref);
    accountsFlow[ref].push(buildOperation(1, accountsRefs[ref].length));

    networkSize += 1;
    if (amount > 0) {
      _registerDeposit(sender, amount);
      _payCumulativeNetworkFee();
    }
  }

  function registerAccount(address ref, uint256 amount) external  {
    address sender = msg.sender;
    require(sender != ref && accounts[sender].up == address(0) && accounts[ref].registered == true, "Invalid Referral");
    require(token.allowance(msg.sender, address(this))>=amount,"allow less amount");
    accounts[sender].up = ref;
    accounts[sender].registered = true;
    accountsRefs[ref].push(sender);
    emit ReferralRegistration(sender, ref);
    accountsFlow[ref].push(buildOperation(1, accountsRefs[ref].length));
    networkSize += 1;
    _registerDeposit(sender, amount);
    _payCumulativeNetworkFee();

  }

  function addShareWallet(address toBeShared) external {
    address target = msg.sender;
    require(accounts[target].registered == true, "Account not registered on platform");
    require(toBeShared != address(0) && toBeShared != target, "Invalid account to be shared");

    address[] memory shared = accountsShared[target];
    require(shared.length < 9, "Max shared accounts reached");
    for(uint i = 0; i < shared.length; i++ ) {
      if (shared[i] == toBeShared) revert("Already been shared with this wallet");
    }

    accountsShared[target].push(toBeShared);
    accountsInShare[toBeShared].push(target);
  }

  function makeDeposit(uint256 amount) public  {
    _registerDeposit(msg.sender, amount);
    _payCumulativeNetworkFee();
  }

  function withdrawAndDeposit(uint256 amount) public payable {
    _withdraw(0);
    _registerDeposit(msg.sender, amount);
    _payCumulativeNetworkFeeForWithdraw();
  }

  function directBonusDeposit(address receiver, uint256 amount) public  onlyOwner {
    // uint amount = msg.value;
    require(amount > 0, "Invalid amount");
    require(accounts[receiver].registered == true, "Invalid receiver");

    address directBonusReceiver = receiver;
    accounts[directBonusReceiver].directBonusAmount += amount; // DIRECT EXTERNAL BONUS
    accounts[directBonusReceiver].directBonusAmountTotal += amount;

    emit DirectBonus(directBonusReceiver, msg.sender, amount);
    // networkDeposits += amount;
    _payNetworkFee(amount, true);
    _payCumulativeNetworkFee();
  }

  function makeDonation(string memory message) public payable {
    uint amount = msg.value;
    address sender = msg.sender;
    require(amount > 0, "Invalid amount");

    emit NewDonationDeposit(sender, amount, message);
    accountsFlow[sender].push(buildOperation(2, amount));

    networkDeposits += amount;
    _payNetworkFee(amount, true);
    _payCumulativeNetworkFee();
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

    uint passive = calculatePassive(depositTime, allowedWithdraw, receivedTotalAmount, receivedPassiveAmount);

    uint remainingWithdraw = ((allowedWithdraw * maxPercentToWithdraw) / 100) - receivedTotalAmount; // MAX WITHDRAW
    require(remainingWithdraw > 0, "No remaining withdraws");

    if (amount > 0) {
      require(amount <= remainingWithdraw, "Amount exceed remaining amount to be withdrawn");
      remainingWithdraw = amount;
    }

    uint toWithdrawPassive = passive >= remainingWithdraw ? remainingWithdraw : passive;

    if (directBonusAmount > remainingWithdraw - toWithdrawPassive) directBonusAmount = remainingWithdraw - toWithdrawPassive;
    if (levelBonusAmount > remainingWithdraw - (toWithdrawPassive + directBonusAmount)) levelBonusAmount = remainingWithdraw - (toWithdrawPassive + directBonusAmount);
    
    uint totalToWithdraw = toWithdrawPassive + directBonusAmount + levelBonusAmount;

    if (directBonusAmount > 0) accounts[sender].directBonusAmount -= directBonusAmount;
    if (levelBonusAmount > 0) accounts[sender].levelBonusAmount -= levelBonusAmount;

    accounts[sender].receivedPassiveAmount += toWithdrawPassive;
    accounts[sender].receivedTotalAmount += totalToWithdraw;

    if (totalToWithdraw >= remainingWithdraw && (amount == 0 || amount == remainingWithdraw)) emit WithdrawLimitReached(sender, receivedTotalAmount + totalToWithdraw);

    uint feeAmount = _payNetworkFeeForWithdraw(totalToWithdraw, false);
    networkWithdraw += totalToWithdraw + feeAmount;
    
    _distributeLevelBonus(sender, toWithdrawPassive);
    
    emit Withdraw(sender, totalToWithdraw);
    accountsFlow[sender].push(buildOperation(3, totalToWithdraw));
    
    _payWithdrawAmount(totalToWithdraw);
  }

  function _payWithdrawAmount(uint totalToWithdraw) private {
    address sender = msg.sender;
    uint shareCount = accountsShared[sender].length;
    if (shareCount == 0) {
      token.transfer(sender,totalToWithdraw);
      return;
    }
    uint parcial = totalToWithdraw / (shareCount + 1);
    token.transfer(sender,parcial);

    for(uint i = 0; i < shareCount; i++) {
      token.transfer(accountsShared[sender][i],parcial);
    }
  }

  // --------------------- PRIVATE METHODS ---------------------------
  function _distributeLevelBonus(address sender, uint amount) private {
    address up = accounts[sender].up;
    address contractOwner = owner();
    address contractMainNome = owner();
    uint minToGetBonus = minAmountToGetBonus;
    for(uint8 i = 0; i < _passiveBonusLevel.length; i++) {
      if(up == address(0)) break;

      uint currentUnlockedLevel = accounts[up].unlockedLevel;
      uint lockLevel = accounts[up].depositMin >= minToGetBonus ? 20 : 0;
      if (lockLevel < currentUnlockedLevel) currentUnlockedLevel = lockLevel;

      if (currentUnlockedLevel > i || up == contractOwner || up == contractMainNome) {
        uint256 bonus = (amount * _passiveBonusLevel[i]) / 1000;
        accounts[up].levelBonusAmount += bonus;
        accounts[up].levelBonusAmountTotal += bonus;

        emit LevelBonus(up, sender, bonus);
      }
      up = accounts[up].up;
    }
  }

  function _proccessRenewOrUpgrade(address sender, uint depositMin) private returns(uint) {
    uint receivedTotalAmount = accounts[sender].receivedTotalAmount;
    require(receivedTotalAmount >= (depositMin * maxPercentToWithdraw) / 100, "Pending earnings to be withdrawn");

    uint depositTime = accounts[sender].depositTime;
    uint receivedPassiveAmount = accounts[sender].receivedPassiveAmount;
    uint directBonusAmount = accounts[sender].directBonusAmount;
    uint levelBonusAmount = accounts[sender].levelBonusAmount;

    uint passive = calculatePassive(depositTime, depositMin, receivedTotalAmount, receivedPassiveAmount);
    require(passive + directBonusAmount + levelBonusAmount + receivedTotalAmount >= (depositMin * maxPercentToReceive) / 100, "Not reached maximum earning amount");

    if (passive >= depositMin) passive = depositMin;
    if (directBonusAmount > depositMin - passive) directBonusAmount = depositMin - passive;
    if (levelBonusAmount > depositMin - (passive + directBonusAmount)) levelBonusAmount = depositMin - (passive + directBonusAmount);
    
    if (directBonusAmount > 0) accounts[sender].directBonusAmount -= directBonusAmount;
    if (levelBonusAmount > 0) accounts[sender].levelBonusAmount -= levelBonusAmount;

    uint feeAmount = _payNetworkFeeForWithdraw(depositMin, false);
    networkWithdraw += depositMin + feeAmount;

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
      amount += _proccessRenewOrUpgrade(sender, depositMin);
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
    
    emit NewDeposit(sender, amount);
    if (iniAmount == amount) {
      accountsFlow[sender].push(buildOperation(4, amount));
    } else if (iniAmount == 0) {
      accountsFlow[sender].push(buildOperation(5, amount));
    } else {
      accountsFlow[sender].push(buildOperation(6, amount));
    }

    networkDeposits += amount;

    // Pays the direct bonus
    uint directBonusAmount = (amount * directBonus) / 1000; // DIRECT BONUS
    address directBonusReceiver = accounts[sender].up;
    if (directBonusReceiver == address(0)) directBonusReceiver = mainOwner;
    accounts[directBonusReceiver].directBonusAmount += directBonusAmount;
    accounts[directBonusReceiver].directBonusAmountTotal += directBonusAmount;
token.transferFrom(msg.sender,address(this),amount);
    emit DirectBonus(directBonusReceiver, sender, directBonusAmount);

    _payNetworkFee(amount, true);
  }

  uint cumulativeNetworkFee = 0;
    uint cumulativeNetworkFeeForWithdraw = 0;
  function _payNetworkFee(uint amount, bool registerWithdrawOperation) private returns(uint) {
    uint networkFee = (amount * networkFeePercent) / 1000;
    cumulativeNetworkFee += networkFee;
    if (registerWithdrawOperation) networkWithdraw += networkFee;
    return networkFee;
  }

  function _payNetworkFeeForWithdraw(uint amount, bool registerWithdrawOperation) private returns(uint) {
    uint networkFeeForWithdraw = (amount * WithdrawalFeePercent) / 1000;
    cumulativeNetworkFeeForWithdraw += networkFeeForWithdraw;
    if (registerWithdrawOperation) networkWithdraw += networkFeeForWithdraw;
    return networkFeeForWithdraw;
  }

  function _payCumulativeNetworkFee() private {
    uint networkFee = cumulativeNetworkFee;
    if (networkFee <= 0) return;
      token.transfer(networkReceiverA,(networkFee * 250) / 1000 );
      token.transfer(networkReceiverB,(networkFee * 250) / 1000 );
      token.transfer(networkReceiverC,(networkFee * 250) / 1000 );
      token.transfer(networkReceiverD,(networkFee * 250) / 1000 );
      cumulativeNetworkFee = 0;
  }

  function _payCumulativeNetworkFeeForWithdraw() private {
    uint networkFee = cumulativeNetworkFeeForWithdraw;
    if (networkFee <= 0) return;
      token.transfer(networkReceiverA,(networkFee * 250) / 1000 );
      token.transfer(networkReceiverB,(networkFee * 250) / 1000 );
      token.transfer(networkReceiverC,(networkFee * 250) / 1000 );
      token.transfer(networkReceiverD,(networkFee * 250) / 1000 );
      cumulativeNetworkFeeForWithdraw = 0;
  }

  function collectMainFee() external {
    address sender = owner();
    {
      uint directBonusAmount = accounts[sender].directBonusAmount;
      uint levelBonusAmount = accounts[sender].levelBonusAmount;

      uint totalToWithdraw = directBonusAmount + levelBonusAmount;

      if (directBonusAmount > 0) accounts[sender].directBonusAmount = 0;
      if (levelBonusAmount > 0) accounts[sender].levelBonusAmount = 0;

      accounts[sender].receivedTotalAmount += totalToWithdraw;
      networkWithdraw += totalToWithdraw;

      token.transfer(networkReceiverA,(totalToWithdraw * 250) / 1000 );
      token.transfer(networkReceiverB,(totalToWithdraw * 250) / 1000 );
      token.transfer(networkReceiverC,(totalToWithdraw * 250) / 1000 );
      token.transfer(networkReceiverD,(totalToWithdraw * 250) / 1000 );
    }
    sender = owner();
    // {
    //   uint directBonusAmount = accounts[sender].directBonusAmount;
    //   uint levelBonusAmount = accounts[sender].levelBonusAmount;

    //   uint totalToWithdraw = directBonusAmount + levelBonusAmount;

    //   accounts[sender].receivedTotalAmount += totalToWithdraw;
    //   networkWithdraw += totalToWithdraw;

    //   if (directBonusAmount > 0) accounts[sender].directBonusAmount = 0;
    //   if (levelBonusAmount > 0) accounts[sender].levelBonusAmount = 0;

    //   token.transfer(networkReceiverA,(totalToWithdraw * 500) / 1000 );
    // //   payable(networkReceiverB).transfer((totalToWithdraw * 500) / 1000 );
    // }
  }
}