// SPDX-License-Identifier: Private
// Developed by Lameni - @lamencrypto
// Architected by GLHC - glhc.eth
// SmartContract License. This SmartContract is protected by copyright laws and international copyright treaties,
// as well as other intellectual property laws and treaties. This SmartContract is licensed for Drive Crypto without expiration.

pragma solidity 0.8.13;

import "./ERC20.sol";
import "./IPancake.sol";
import "./GasHelper.sol";
import "./SwapHelper.sol";


contract DriveCrypto is GasHelper, ERC20 {
  address constant private DEAD = 0x000000000000000000000000000000000000dEaD;
  address constant private ZERO = 0x0000000000000000000000000000000000000000;
  address constant private WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // BSC WBNB
  address constant private BUSD = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // BSC BUSD
  // address constant private WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // BSC WBNB TESTET

  string constant private _nameToken = "Drive Crypto";
  string constant private _symbolToken = "$DRIVECRYPTO";
  string constant public author = "Lameni";

  // Token Details
  uint8 constant private decimal = 18;
  uint256 constant private maxSupply = 1_000_000_000 * (10 ** decimal);

  // Wallets limits
  uint256 public _maxTxAmount = (maxSupply * 1) / 100;
  uint256 public _maxAccountAmount = (maxSupply * 5) / 100;
  uint256 public _minAmountToAutoSwap =  1000 * (10 ** decimal); // min amount stored before swap to collect fee

  // Fees
  uint256 public feeAdministrativeWallet; // 3%
  uint256 public feeInternalFundWallet; // 3%
  uint256 public feeReward; // 0%
  uint256 public feeBurn; // 0%

  uint constant private maxTotalFee = 1600; // fee will never ever be higher than 16
  mapping(address => uint) public specialFeesByWallet;
  mapping(address => uint) public specialFeesByWalletReceiver;

  // Helpers
  bool internal pausedToken;
  bool private _noReentrance;

  bool public pausedSwapFee;
  bool public disabledReward;

  // Counters
  uint256 public accumulatedToSwapFeeAdministrative;
  uint256 public accumulatedToSwapFeeInternalFund;
  uint256 public accumulatedToSwapFeeReward;
  uint256 public accumulatedToReward;

  // Liquidity Pair
  address public liquidityPool;
  address public secondaryPair;

  // Wallets
  address public administrativeWallet;
  address public internalFundWallet;

  address public swapHelperAddress;

  // Reward calculations
  mapping(address => HolderShare) public holderMap;
  address[] public _holders;

  uint256 public minTokenHoldToStake = 100 * (10 ** decimal); // min amount holder must have to be able to receive rewards
  uint256 public totalTokens;
  uint256 private stakePerShare;
  uint256 public rewardWithdrawWaitTime = 86400; // 24 hours
  uint256 constant private stakePrecision = 10 ** 18;

  struct Receivers { address wallet; uint256 amount; }

  struct HolderShare { uint256 amountToken; uint256 totalReceived; uint256 pendingReceive; uint256 entryPointMarkup; uint256 arrayIndex; uint256 receivedAt; }

  event RewardWithdraw( address indexed wallet, uint amount);

  receive() external payable { }

  constructor()ERC20(_nameToken, _symbolToken) {
    PancakeRouter router = PancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // BSC
    // PancakeRouter router = PancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // BSC TESTNET
    address factory = router.factory();
    liquidityPool = address(PancakeFactory(factory).createPair(WBNB, address(this)));
    secondaryPair = address(PancakeFactory(factory).getPair(WBNB, BUSD));

    administrativeWallet = 0x63332bA32ba8884B3523CE9c2Ad52E6C83A38e8f;
    _permissions[administrativeWallet] = 15; // exempt fee, fee receiver, tx limit and wallet limit
    internalFundWallet = 0x63332bA32ba8884B3523CE9c2Ad52E6C83A38e8f;
    _permissions[internalFundWallet] = 15; // exempt fee, fee receiver, tx limit and wallet limit

    uint baseAttributes = 0;
    baseAttributes = setExemptAmountLimit(baseAttributes, true);
    baseAttributes = setSpecialFeeWallet(baseAttributes, true);
    baseAttributes = setSpecialFeeWalletReceiver(baseAttributes, true);
    baseAttributes = setExemptReward(baseAttributes, true);

    _attributeMap[liquidityPool] = baseAttributes;

    setSpecialWalletFeeOnSend(liquidityPool, 200, 300, 100, 100);
    setSpecialWalletFeeOnReceive(liquidityPool, 200, 300, 100, 400);

    baseAttributes = setSpecialFeeWallet(baseAttributes, false);
    baseAttributes = setSpecialFeeWalletReceiver(baseAttributes, false);

    baseAttributes = setExemptTxLimit(baseAttributes, true);
    _attributeMap[DEAD] = baseAttributes;
    _attributeMap[ZERO] = baseAttributes;

    baseAttributes = setExemptFee(baseAttributes, true);
    baseAttributes = setExemptSwapMaker(baseAttributes, true);
    _attributeMap[address(this)] = baseAttributes;

    baseAttributes = setExemptOperatePausedToken(baseAttributes, true);
    _attributeMap[_msgSender()] = baseAttributes;

    SwapHelper swapHelper = new SwapHelper();
    swapHelper.safeApprove(WBNB, address(this), type(uint256).max);
    swapHelper.safeApprove(BUSD, address(this), type(uint256).max);
    swapHelper.transferOwnership(_msgSender());
    swapHelperAddress = address(swapHelper);

    baseAttributes = setExemptOperatePausedToken(baseAttributes, false);
    _attributeMap[swapHelperAddress] = baseAttributes;

    _mint(_msgSender(), maxSupply);

    pausedToken = true;
  }

  // ----------------- Public Views -----------------
  function name() public pure override returns (string memory) { return _nameToken; }
  function symbol() public pure override returns (string memory) { return _symbolToken; }
  function getOwner() external view returns (address) { return owner(); }
  function decimals() public pure override returns (uint8) { return decimal; }
  function getFeeTotal() public view returns(uint256) { return feeAdministrativeWallet + feeInternalFundWallet + feeReward + feeBurn; }
  function getSpecialWalletFeeOnSend(address target) public view returns(uint administrativeFee, uint internalFundFee, uint rewardFee, uint burnFee ) { return getSpecialWalletFee(target, true); }
  function getSpecialWalletFeeOnReceive(address target) public view returns(uint administrativeFee, uint internalFundFee, uint rewardFee, uint burnFee ) { return getSpecialWalletFee(target, false); }
  function getStakeHoldersSize() public view returns (uint) { return _holders.length; }
  function getCalculatedWithdraw(address holder) external view returns (uint) {
    uint256 entryPointMarkup = holderMap[holder].entryPointMarkup;
    uint256 totalToBePaid = (holderMap[holder].amountToken * stakePerShare) / stakePrecision;
    if (totalToBePaid <= entryPointMarkup) return holderMap[holder].pendingReceive;
    return holderMap[holder].pendingReceive + (totalToBePaid - entryPointMarkup);
  }
  function isReadyToWithdraw(address holder) external view returns(bool) { return holderMap[holder].receivedAt + rewardWithdrawWaitTime < block.timestamp; }
  function getWithdrawTimeout(address holder) external view returns(uint) {
    if (holderMap[holder].receivedAt + rewardWithdrawWaitTime <= block.timestamp) return 0;
    return (holderMap[holder].receivedAt + rewardWithdrawWaitTime) - block.timestamp;
  }

  // ----------------- Authorized Methods -----------------

  function enableToken() external isAdmin { pausedToken = false; }
  function setLiquidityPool(address newPair) external isAdmin { require(newPair != address(0), "invalid new pair address"); liquidityPool = newPair; }
  function setSecondaryPair(address newPair) external isAdmin { require(newPair != address(0), "invalid new pair address"); secondaryPair = newPair; }
  function setPausedSwapFee(bool state) external isAdmin { pausedSwapFee = state; }
  function setDisabledReward(bool state) external isAdmin { disabledReward = state; }
  function setRewardWithdrawWaitTime(uint valueInSeconds) external isAdmin { rewardWithdrawWaitTime = valueInSeconds; }

  // ----------------- Wallets Settings -----------------
  function setAdministrativeWallet(address account) public isAdmin {
    require(account != address(0), "administrativeWallet cannot be Zero");
    administrativeWallet = account;
  }

  function setInternalFundWallet(address account) public isAdmin {
    require(account != address(0), "internalFundWallet cannot be Zero");
    internalFundWallet = account;
  }

  // ----------------- Fee Settings -----------------
  function setContractFees(uint administrative, uint internalFund, uint rewardFee, uint burnFee) public isFinancial {
    feeAdministrativeWallet = administrative;
    feeInternalFundWallet = internalFund;
    feeReward = rewardFee;
    feeBurn = burnFee;
    require(getFeeTotal() <= maxTotalFee, "All rates and fee together must be equal or lower than 16%");
  }

  function setSpecialWallet(address target, bool isSender, uint administrative, uint internalFund, uint reward, uint burnFee) internal isFinancial {
    require(administrative + internalFund + reward + burnFee <= maxTotalFee, "All rates and fee together must be equal or lower than 16%");
    uint composedValue = administrative + (internalFund * 1e4) + (reward * 1e8) + (burnFee * 1e12);
    if (isSender) {
      specialFeesByWallet[target] = composedValue;
    } else {
      specialFeesByWalletReceiver[target] = composedValue;
    }
  }

  function setSpecialWalletFeeOnSend(address target, uint administrative, uint internalFund, uint reward, uint burnFee) public isFinancial { return setSpecialWallet(target, true, administrative, internalFund, reward, burnFee); }
  function setSpecialWalletFeeOnReceive(address target, uint administrative, uint internalFund, uint reward, uint burnFee) public isFinancial { return setSpecialWallet(target, false, administrative, internalFund, reward, burnFee); }

  // ----------------- Token Flow Settings -----------------
  function setMaxTxAmount(uint256 maxTxAmount) public isFinancial {
    require(maxTxAmount >= maxSupply / 10000, "Amount must be bigger then 0.01% tokens"); // 10000 tokens
    _maxTxAmount = maxTxAmount;
  }

  function setMaxAccountAmount(uint256 maxAccountAmount) public isFinancial {
    require(maxAccountAmount >= maxSupply / 10000, "Amount must be bigger then 0.01% tokens"); // 10000 tokens
    _maxAccountAmount = maxAccountAmount;
  }
  function setMinAmountToAutoSwap(uint256 amount) public isFinancial {
    _minAmountToAutoSwap = amount;
  }

  // ----------------- Special Authorized Operations -----------------
  function buyBackAndHoldWithDecimals(uint256 decimalAmount, address receiver) public isController { buyBackWithDecimals(decimalAmount, receiver); }
  function buyBackAndBurnWithDecimals(uint256 decimalAmount) public isController { buyBackWithDecimals(decimalAmount, address(0)); }

  // ----------------- External Methods -----------------
  function burn(uint256 amount) external { _burn(_msgSender(), amount); }

  function withdraw(address wallet) external {
    require(holderMap[wallet].receivedAt + rewardWithdrawWaitTime < block.timestamp);
    calculateDistribution(wallet, holderMap[wallet].amountToken, stakePerShare, stakePrecision);
    uint amountToTransfer = holderMap[wallet].pendingReceive;
    holderMap[wallet].pendingReceive = 0;
    holderMap[wallet].totalReceived += amountToTransfer;
    holderMap[wallet].receivedAt = block.timestamp;
    tokenTransfer(BUSD, wallet, amountToTransfer);
    emit RewardWithdraw(wallet, amountToTransfer);
  }

  function multiTransfer(Receivers[] memory users) external {
    for ( uint i = 0; i < users.length; i++ ) transfer(users[i].wallet, users[i].amount);
  }

  // ----------------- Internal CORE -----------------
  function _transfer( address sender, address receiver,uint256 amount) internal override {
    require(amount > 0, "Invalid Amount");
    require(!_noReentrance, "ReentranceGuard Alert");
    _noReentrance = true;

    uint senderAttributes = _attributeMap[sender];
    uint receiverAttributes = _attributeMap[receiver];
    // Initial Checks
    require(sender != address(0) && receiver != address(0), "transfer from the zero address");
    require(!pausedToken || isExemptOperatePausedToken(senderAttributes), "Token is paused");
    require(amount <= _maxTxAmount || isExemptTxLimit(senderAttributes), "Exceeded the maximum transaction limit");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "Transfer amount exceeds your balance");
    uint256 newSenderBalance = senderBalance - amount;
    _balances[sender] = newSenderBalance;


    uint administrativeFee = feeAdministrativeWallet;
    uint internalFundFee = feeInternalFundWallet;
    uint rewardFee = feeReward;
    uint burnFee = feeBurn;

    // Calculate Fees
    uint256 feeAmount = 0;
    if(!isExemptFee(senderAttributes) && !isExemptFeeReceiver(receiverAttributes)) {
      if(isSpecialFeeWallet(senderAttributes)) { // Check special wallet fee on sender
        (administrativeFee, internalFundFee, rewardFee, burnFee) = getSpecialWalletFee(sender, true);
      } else if(isSpecialFeeWalletReceiver(receiverAttributes)) { // Check special wallet fee on receiver
        (administrativeFee, internalFundFee, rewardFee, burnFee) = getSpecialWalletFee(receiver, false);
      }
      feeAmount = ((administrativeFee + internalFundFee + rewardFee + burnFee) * amount) / 10000;
    }

    if (feeAmount != 0) splitFee(feeAmount, sender, administrativeFee, internalFundFee, rewardFee, burnFee);
    if ((!pausedSwapFee) && !isExemptSwapMaker(senderAttributes)) autoSwap(sender);

    // Update Recipient Balance
    uint256 newRecipientBalance = _balances[receiver] + (amount - feeAmount);
    _balances[receiver] = newRecipientBalance;
    require(newRecipientBalance <= _maxAccountAmount || isExemptAmountLimit(receiverAttributes), "Exceeded the maximum tokens an wallet can hold");

    if (!disabledReward) executeRewardOperations(sender, receiver, newSenderBalance, newRecipientBalance, senderAttributes, receiverAttributes);

    _noReentrance = false;
    emit Transfer(sender, receiver, amount);
  }

  function autoSwap(address sender) private {
    // --------------------- Execute Auto Swap -------------------------
    address liquidityPair = liquidityPool;
    address secondaryPairLocal = secondaryPair;

    if (sender == liquidityPair) return;
    uint accumulatedAdministrative = accumulatedToSwapFeeAdministrative;
    uint accumulatedInternalFund = accumulatedToSwapFeeInternalFund;
    uint accumulatedReward = accumulatedToSwapFeeReward;

    uint totalAmount = accumulatedAdministrative + accumulatedInternalFund + accumulatedReward;
    if (totalAmount < _minAmountToAutoSwap) return;

    // Execute auto swap
    address busdAddress = BUSD;
    address swapHelper = swapHelperAddress;
    uint256 amountOut = executeSwap(totalAmount, liquidityPair, secondaryPairLocal, swapHelper, busdAddress);

    // --------------------- Transfer Swapped Amount -------------------------
    uint totalFee = accumulatedAdministrative + accumulatedInternalFund + accumulatedReward;
    if (accumulatedAdministrative > 0) { // Cost 2 cents
      uint amountToSend = (amountOut * accumulatedAdministrative) / (totalFee);
      tokenTransferFrom(busdAddress, swapHelper, administrativeWallet, amountToSend);
      accumulatedToSwapFeeAdministrative = 0;
    }
    if (accumulatedInternalFund > 0) { // Cost 2 cents
      uint amountToSend = (amountOut * accumulatedInternalFund) / (totalFee);
      tokenTransferFrom(busdAddress, swapHelper, internalFundWallet, amountToSend);
      accumulatedToSwapFeeInternalFund = 0;
    }
    if (accumulatedReward > 0) { // Cost 2 cents
      uint amountToSend = (amountOut * accumulatedReward) / (totalFee);
      tokenTransferFrom(busdAddress, swapHelper, address(this), amountToSend);
      accumulatedToReward += amountToSend;
      accumulatedToSwapFeeReward = 0;
    }
  }

  function executeSwap(uint totalAmount, address liquidityPair, address secondaryPairLocal, address swapHelper, address busdAddress) private returns (uint amountOut) {
    {
      address wbnbAddress = WBNB;
      (uint112 reserve0, uint112 reserve1) = getTokenReserves(liquidityPair);
      bool reversed = isReversed(liquidityPair, wbnbAddress);
      if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }
      _balances[liquidityPair] += totalAmount;

      uint256 wbnbBalanceBefore = getTokenBalanceOf(wbnbAddress, secondaryPairLocal);
      uint256 wbnbAmount = getAmountOut(totalAmount, reserve1, reserve0);
      swapToken(liquidityPair, reversed ? 0 : wbnbAmount, reversed ? wbnbAmount : 0, secondaryPairLocal);
      uint256 wbnbBalanceNew = getTokenBalanceOf(wbnbAddress, secondaryPairLocal);
      require(wbnbBalanceNew == wbnbBalanceBefore + wbnbAmount, "Wrong amount of swapped on WBNB");
      amountOut = wbnbAmount;
    }
    {
      (uint112 reserve0, uint112 reserve1) = getTokenReserves(secondaryPairLocal);
      bool reversed = isReversed(secondaryPairLocal, busdAddress);
      if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

      uint256 busdBalanceBefore = getTokenBalanceOf(busdAddress, swapHelper);
      uint256 busdAmount = getAmountOut(amountOut, reserve1, reserve0);
      swapToken(secondaryPairLocal, reversed ? 0 : busdAmount, reversed ? busdAmount : 0, swapHelper);
      uint256 busdBalanceNew = getTokenBalanceOf(busdAddress, swapHelper);
      require(busdBalanceNew == busdBalanceBefore + busdAmount, "Wrong amount of swapped on BUSD");
      amountOut = busdAmount;
    }
  }

  function splitFee(uint256 incomingFeeTokenAmount, address sender, uint administrativeFee, uint internalFundFee, uint rewardFee, uint burnFee) private {
    uint256 totalFee = administrativeFee + internalFundFee + rewardFee + burnFee;

    //Burn
    if (burnFee > 0) {
      uint256 burnAmount = (incomingFeeTokenAmount * burnFee) / totalFee;
      _balances[address(this)] += burnAmount;
      _burn(address(this), burnAmount);
    }

    accumulatedToSwapFeeAdministrative =  (incomingFeeTokenAmount * administrativeFee) / totalFee;
    accumulatedToSwapFeeInternalFund =  (incomingFeeTokenAmount * internalFundFee) / totalFee;
    accumulatedToSwapFeeReward =  (incomingFeeTokenAmount * rewardFee) / totalFee;
    if (pausedSwapFee) {
      if (administrativeFee > 0) {
        address wallet = administrativeWallet;
        uint accumulated = accumulatedToSwapFeeAdministrative;
        uint256 walletBalance = _balances[wallet] + accumulated;
        _balances[wallet] = walletBalance;
        emit Transfer(sender, wallet, accumulated);
        accumulatedToSwapFeeAdministrative = 0;
        if(!isExemptReward(_attributeMap[wallet])) _updateHolder(wallet, walletBalance, minTokenHoldToStake, stakePerShare, stakePrecision);
      }
      if (internalFundFee > 0) {
        address wallet = internalFundWallet;
        uint accumulated = accumulatedToSwapFeeInternalFund;
        uint256 walletBalance = _balances[wallet] + accumulated;
        _balances[wallet] = walletBalance;
        emit Transfer(sender, wallet, accumulated);
        accumulatedToSwapFeeInternalFund = 0;
        if(!isExemptReward(_attributeMap[wallet])) _updateHolder(wallet, walletBalance, minTokenHoldToStake, stakePerShare, stakePrecision);
      }
      if (rewardFee > 0) {
        address wallet = address(this);
        uint accumulated = accumulatedToSwapFeeReward;
        uint256 walletBalance = _balances[wallet] + accumulated;
        _balances[wallet] = walletBalance;
        emit Transfer(sender, wallet, accumulated);
        accumulatedToSwapFeeReward = 0;
      }
    }
  }

  function getSpecialWalletFee(address target, bool isSender) internal view returns(uint administrativeFee, uint internalFundFee, uint rewardFee, uint burnFee ) {
    uint composedValue = isSender ? specialFeesByWallet[target] : specialFeesByWalletReceiver[target];
    administrativeFee = composedValue % 1e4;
    composedValue = composedValue / 1e4;
    internalFundFee = composedValue % 1e4;
    composedValue = composedValue / 1e4;
    rewardFee = composedValue % 1e4;
    composedValue = composedValue / 1e4;
    burnFee = composedValue % 1e4;
  }

  // --------------------- Stake Internal Methods -------------------------
  function setMinTokenHoldToStake(uint amount) external isFinancial { minTokenHoldToStake = amount; }

  function executeRewardOperations(address sender, address receiver, uint senderAmount, uint receiverAmount, uint senderAttributes, uint receiverAttributes) private {
    uint minTokenHolder = minTokenHoldToStake;
    uint stakePerShareValue = stakePerShare;
    uint stakePrecisionValue = stakePrecision;

    if(!isExemptReward(senderAttributes)) _updateHolder(sender, senderAmount, minTokenHolder, stakePerShareValue, stakePrecisionValue);

    // Calculate new stake per share value
    uint accumulated = accumulatedToReward;
    if (accumulated > 0) {
      uint considerateTotalTokens = totalTokens;
      stakePerShareValue += (accumulated * stakePrecisionValue) / (considerateTotalTokens == 0 ? 1 : considerateTotalTokens);
      stakePerShare = stakePerShareValue;
      accumulatedToReward = 0;
    }

    if(!isExemptReward(receiverAttributes)) _updateHolder(receiver, receiverAmount, minTokenHolder, stakePerShareValue, stakePrecisionValue);
  }

  function _updateHolder(address holder, uint256 amount, uint minTokenHolder, uint stakePerShareValue, uint stakePrecisionValue) private {
    // If holder has less than minTokenHoldToStake, then does not participate on staking
    uint256 considerateAmount = minTokenHolder <= amount ? amount : 0;
    uint256 holderAmount = holderMap[holder].amountToken;

    if (holderAmount > 0) calculateDistribution(holder, holderAmount, stakePerShareValue, stakePrecisionValue);

    if (considerateAmount > 0 && holderAmount == 0 ) {
      addToHoldersList(holder);
    } else if (considerateAmount == 0 && holderAmount > 0) {
      removeFromHoldersList(holder);
    }
    totalTokens = (totalTokens - holderAmount) + considerateAmount;
    holderMap[holder].amountToken = considerateAmount;
    holderMap[holder].entryPointMarkup = (considerateAmount * stakePerShareValue) / stakePrecisionValue;
  }

  function addToHoldersList(address holder) private {
    holderMap[holder].arrayIndex = _holders.length;
    _holders.push(holder);
  }

  function removeFromHoldersList(address holder) private {
    address lastHolder = _holders[_holders.length - 1];
    uint256 holderIndexRemoved = holderMap[holder].arrayIndex;
    _holders[holderIndexRemoved] = lastHolder;
    _holders.pop();
    holderMap[lastHolder].arrayIndex = holderIndexRemoved;
    holderMap[holder].arrayIndex = 0;
  }

  function calculateDistribution(address holder, uint amountToken, uint stakePerShareValue, uint stakePrecisionValue) private returns (uint) {
    uint256 entryPointMarkup = holderMap[holder].entryPointMarkup;
    uint256 totalToBePaid = (amountToken * stakePerShareValue) / stakePrecisionValue;

    if (totalToBePaid <= entryPointMarkup) return holderMap[holder].pendingReceive;
    uint256 newPendingAmount = holderMap[holder].pendingReceive + (totalToBePaid - entryPointMarkup);
    holderMap[holder].pendingReceive = newPendingAmount;
    holderMap[holder].entryPointMarkup = totalToBePaid;
    return newPendingAmount;
  }

  // --------------------- Private Methods -------------------------

  function buyBackWithDecimals(uint256 decimalAmount, address destAddress) private {
    uint256 maxBalance = getTokenBalanceOf(WBNB, address(this));
    if (maxBalance < decimalAmount) revert("insufficient WBNB amount on contract");

    address liquidityPair = liquidityPool;
    uint liquidityAttribute = _attributeMap[liquidityPair];

    uint newAttributes = setExemptTxLimit(liquidityAttribute, true);
    newAttributes = setExemptFee(liquidityAttribute, true);
    _attributeMap[liquidityPair] = newAttributes;

    address helperAddress = swapHelperAddress;

    (uint112 reserve0, uint112 reserve1) = getTokenReserves(liquidityPair);
    bool reversed = isReversed(liquidityPair, WBNB);
    if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

    tokenTransfer(WBNB, liquidityPair, decimalAmount);

    uint256 tokenAmount = getAmountOut(decimalAmount, reserve0, reserve1);
    if (destAddress == address(0)) {
      swapToken(liquidityPair, reversed ? tokenAmount : 0, reversed ? 0 : tokenAmount, helperAddress);
      _burn(helperAddress, tokenAmount);
    } else {
      swapToken(liquidityPair, reversed ? tokenAmount : 0, reversed ? 0 : tokenAmount, destAddress);
    }
    _attributeMap[liquidityPair] = liquidityAttribute;
  }
}