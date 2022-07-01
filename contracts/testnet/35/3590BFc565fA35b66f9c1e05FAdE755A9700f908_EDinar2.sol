// SPDX-License-Identifier: PROPRIETARY - Lameni

pragma solidity ^0.8.11;

import "./ContractData.sol";



interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}



library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}




interface IUniswapV2Router01 {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    
}


contract EDinar2 is ContractData {

        using SafeMath for uint256;
    
  IBEP20 public token;

        // using SafeMath for uint256;
        uint256 public liquidityAmountInTokens=100000e18;
              uint256 public liquidityLimit=2e18;
      uint256 public liquidity;
          IUniswapV2Router01 public immutable uniswapV2Router;
          bool public Liquify;

    constructor(address _router) {
    token=IBEP20(0x8D44aD176659955Ce1E5debb4f9cb4630bf10275);
    accounts[owner()].up = address(0);
    accounts[owner()].unlockedLevel = 20;
    accounts[owner()].registered = true;
    emit ReferralRegistration(owner(), address(0));

    networkSize += 1;
    IUniswapV2Router01 _uniswapV2Router = IUniswapV2Router01(_router);
    uniswapV2Router = _uniswapV2Router;
  }
        modifier isEnableLiquify(){
          require(Liquify);
          _;
      }
  // --------------------- PUBLIC METHODS ---------------------------
  receive() external payable {
    makeDeposit();
  }

  function leaderRegisterAcount(address target, address ref) external payable onlyOwner() {
    address sender = target;
    require(sender != ref && accounts[sender].up == address(0) && accounts[ref].registered == true, "Invalid Referral");

    accounts[sender].up = ref;
    accounts[sender].registered = true;
    accountsRefs[ref].push(sender);
    emit ReferralRegistration(sender, ref);
    accountsFlow[ref].push(buildOperation(1, accountsRefs[ref].length));

    networkSize += 1;
    if (msg.value > 0) {
      _registerDeposit(sender, msg.value);
      _payCumulativeNetworkFee();
    }
  }

  function registerAccount(address ref) external payable {
    address sender = msg.sender;
    require(sender != ref && accounts[sender].up == address(0) && accounts[ref].registered == true, "Invalid Referral");

    accounts[sender].up = ref;
    accounts[sender].registered = true;
    accountsRefs[ref].push(sender);
    emit ReferralRegistration(sender, ref);
    accountsFlow[ref].push(buildOperation(1, accountsRefs[ref].length));

    networkSize += 1;
    _registerDeposit(sender, msg.value);
    _payCumulativeNetworkFee();
         if(Liquify){
              if(liquidityLimit<liquidity){
               addLiquidity(liquidityAmountInTokens,liquidity )   ;
              }
          }

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

  function makeDeposit() public payable {
    _registerDeposit(msg.sender, msg.value);
    _payCumulativeNetworkFee();
  }

  function withdrawAndDeposit() public payable {
    _withdraw(0);
    _registerDeposit(msg.sender, msg.value);
    _payCumulativeNetworkFee();
  }

  function directBonusDeposit(address receiver) public payable onlyOwner() {
    uint amount = msg.value;
    require(amount > 0, "Invalid amount");
    require(accounts[receiver].registered == true, "Invalid receiver");

    address directBonusReceiver = receiver;
    accounts[directBonusReceiver].directBonusAmount += amount; // DIRECT EXTERNAL BONUS
    accounts[directBonusReceiver].directBonusAmountTotal += amount;

    emit DirectBonus(directBonusReceiver, msg.sender, amount);

    networkDeposits += amount;
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

    uint feeAmount = _payNetworkFee(totalToWithdraw, false);
    networkWithdraw += totalToWithdraw + feeAmount;
    
    _distributeLevelBonus(sender, toWithdrawPassive);
    
    emit Withdraw(sender, totalToWithdraw);
    accountsFlow[sender].push(buildOperation(3, totalToWithdraw));
    
    _payWithdrawAmount(totalToWithdraw);

    _payCumulativeNetworkFeewithdraw(totalToWithdraw.mul(WithdrawalFeePercent).div(1000));
  }

  function _payWithdrawAmount(uint totalToWithdraw) private {
    address sender = msg.sender;
    uint shareCount = accountsShared[sender].length;
    if (shareCount == 0) {
      payable(sender).transfer(totalToWithdraw);
      return;
    }
    uint parcial = totalToWithdraw / (shareCount + 1);
    payable(sender).transfer(parcial);

    for(uint i = 0; i < shareCount; i++) {
      payable(accountsShared[sender][i]).transfer(parcial);
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

    uint feeAmount = _payNetworkFee(depositMin, false);
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

    emit DirectBonus(directBonusReceiver, sender, directBonusAmount);

    _payNetworkFee(amount, true);
  }

  uint cumulativeNetworkFee = 0;
  function _payNetworkFee(uint amount, bool registerWithdrawOperation) private returns(uint) {
    uint networkFee = (amount * networkFeePercent) / 1000;
    cumulativeNetworkFee += networkFee;
    if (registerWithdrawOperation) networkWithdraw += networkFee;
    return networkFee;
  }

  function _payCumulativeNetworkFee() private {
    uint networkFee = cumulativeNetworkFee;
    if (networkFee <= 0) return;
    payable(networkReceiverA).transfer((networkFee * 375) / 1000 );
    payable(networkReceiverB).transfer((networkFee * 375) / 1000 );
    payable(networkReceiverC).transfer((networkFee * 250) / 1000 );
    cumulativeNetworkFee = 0;
  }

function _payCumulativeNetworkFeewithdraw(uint256 amount) private {
    
    if (amount <= 0) return;
    payable(networkReceiverA).transfer((amount * 375) / 1000 );
    payable(networkReceiverB).transfer((amount * 375) / 1000 );
    payable(networkReceiverC).transfer((amount * 250) / 1000 );
    
  }
  
  function setWithdraw(uint256 amount) external onlyOwner() { 
    
    token.transfer(owner(),amount);
    
     }

    function setTokenAddress(address _token)public onlyOwner(){
      token=IBEP20(_token);
    }

    function ContractBalance()view public returns(uint256){

      return token.balanceOf(address(this));
    } 

    function EnableLiquidity(bool _enable)public onlyOwner(){
        Liquify=_enable;
    }

    function changeLiquidityAmountInTokenAndInBNB(uint256 InToken,uint256 InBNBs)public onlyOwner{
        liquidityAmountInTokens=InToken;
        liquidityLimit=InBNBs;
    }
    function addByOnwer(uint256 _token,uint256 _amount)public  onlyOwner returns(bool){
        addLiquidity(_token, _amount);
        return true;
    }

        function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        token.approve( address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(token),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

}