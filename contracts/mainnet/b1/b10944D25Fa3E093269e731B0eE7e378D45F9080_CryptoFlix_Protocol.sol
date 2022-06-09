// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "./ERC20.sol";

import "./Authorized.sol";
import "./IPancake.sol";
import "./SwapHelper.sol";

contract CryptoFlix_Protocol is Authorized, ERC20 {
  address constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address constant ZERO = 0x0000000000000000000000000000000000000000;
  address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

  string constant _name = "CryptoFlix Protocol";
  string constant _symbol = "CFLIX";

  // Token supply control
  uint8 constant decimal = 18;
  uint8 constant decimalBUSD = 18;  
  uint256 constant maxSupply = 10_000_000 * (10 ** decimal);
  
  uint256 public _maxTxAmount = maxSupply;
  uint256 public _maxAccountAmount = maxSupply;
  
  uint256 public totalBurned;

  // Fees
  uint256 public feeAdministrationWallet = 300; // 3%
  uint256 public feeDevelopmentWallet = 0; // 0%
  uint256 public feePool = 100; // 1%

  bool internal pausedToken = false;
  bool internal pausedStake = false;

  // special wallet permissions
  mapping (address => bool) public exemptOperatePausedToken;
  mapping (address => bool) public exemptFee;
  mapping (address => bool) public exemptFeeReceiver;
  mapping (address => bool) public exemptTxLimit;
  mapping (address => bool) public exemptAmountLimit;
  mapping (address => bool) public exemptStaker;

  // trading pairs
  address public liquidityPool;

  address public administrationWallet;
  address public developingWallet;

  SwapHelper private swapHelper;

  address WBNB_BUSD_PAIR = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
  address WBNB_TOKEN_PAIR;

  bool private _noReentrancy = false;

  function getOwner() external view returns (address) { return owner(); }

  function getFeeTotal() public view returns(uint256) { return feeAdministrationWallet + feeDevelopmentWallet + feePool; }

  function enableToken() external isAuthorized(0) { pausedToken = false; }

  function togglePauseStake(bool pauseState) external isAuthorized(0) { pausedStake = pauseState; }

  function getSwapHelperAddress() external view returns (address) { return address(swapHelper); }

  // Fee Setup
  function setFeeAdministrationWallet(uint256 feeAmount) external isAuthorized(1) { feeAdministrationWallet = feeAmount; }
  function setFeeDevelopmentWallet(uint256 feeAmount) external isAuthorized(1) { feeDevelopmentWallet = feeAmount; }
  function setFeePool(uint256 feeAmount) external isAuthorized(1) { feePool = feeAmount; }

  function setMaxTxAmountWithDecimals(uint256 decimalAmount) public isAuthorized(1) { _maxTxAmount = decimalAmount; }

  function setMaxTxAmount(uint256 amount) external isAuthorized(1) { setMaxTxAmountWithDecimals(amount * (10 ** decimal)); }

  function setMaxAccountAmountWithDecimals(uint256 decimalAmount) public isAuthorized(1) { _maxAccountAmount = decimalAmount; }

  function setMaxAccountAmount(uint256 amount) external isAuthorized(1) { setMaxAccountAmountWithDecimals(amount * (10 ** decimal)); }

  // Excempt Controllers
  function setExemptOperatePausedToken(address account, bool operation) public isAuthorized(0) {exemptOperatePausedToken[account] = operation; }
  function setExemptFee(address account, bool operation) public isAuthorized(2) { exemptFee[account] = operation; }
  function setExemptFeeReceiver(address account, bool operation) public isAuthorized(2) { exemptFeeReceiver[account] = operation; }
  function setExemptTxLimit(address account, bool operation) public isAuthorized(2) { exemptTxLimit[account] = operation; }
  function setExemptAmountLimit(address account, bool operation) public isAuthorized(2) { exemptAmountLimit[account] = operation; }
  function setExemptStaker(address account, bool operation) public isAuthorized(2) { exemptStaker[account] = operation; }

  // Special Wallets
  function setAdministrationWallet(address account) public isAuthorized(0) { administrationWallet = account; }
  function setDevelopingWallet(address account) public isAuthorized(0) { developingWallet = account; }
  
  receive() external payable { }

  constructor()ERC20(_name, _symbol) {
    PancakeRouter router = PancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    WBNB_TOKEN_PAIR = address(PancakeFactory(router.factory()).createPair(WBNB, address(this)));
    liquidityPool = WBNB_TOKEN_PAIR;

    // Liquidity pair
    exemptAmountLimit[WBNB_TOKEN_PAIR] = true;
    exemptTxLimit[WBNB_TOKEN_PAIR] = true;
    exemptStaker[WBNB_TOKEN_PAIR] = true;
    
    // Token address
    exemptFee[address(this)] = true;
    exemptTxLimit[address(this)] = true;
    exemptAmountLimit[address(this)] = true;
    exemptStaker[address(this)] = true;

    // DEAD Waller
    exemptTxLimit[DEAD] = true;
    exemptAmountLimit[DEAD] = true;
    exemptStaker[DEAD] = true;
    exemptFee[DEAD] = true;

    // Zero Waller
    exemptTxLimit[ZERO] = true;
    exemptAmountLimit[ZERO] = true;
    exemptStaker[ZERO] = true;

    //Owner wallet
    address ownerWallet = _msgSender();
    exemptFee[ownerWallet] = true;
    exemptTxLimit[ownerWallet] = true;
    exemptAmountLimit[ownerWallet] = true;
    exemptStaker[ownerWallet] = true;
    exemptOperatePausedToken[ownerWallet] = true;

    administrationWallet = 0x7194B83a8aA12E9d21644AF037FDA4446Ce12762;
    developingWallet = 0x7194B83a8aA12E9d21644AF037FDA4446Ce12762;

    exemptFee[administrationWallet] = true;
    exemptTxLimit[administrationWallet] = true;
    exemptAmountLimit[administrationWallet] = true;

    exemptFee[developingWallet] = true;
    exemptTxLimit[developingWallet] = true;
    exemptAmountLimit[developingWallet] = true;

    swapHelper = new SwapHelper();
    swapHelper.safeApprove(WBNB, address(this), type(uint256).max);
    swapHelper.transferOwnership(_msgSender());

    _mint(ownerWallet, maxSupply);

    pausedToken = true;
  }

  function decimals() public view override returns (uint8) { return decimal; }

  function _beforeTokenTransfer( address from, address, uint256 amount ) internal view override {
    require(amount <= _maxTxAmount || exemptTxLimit[from], "Excedded the maximum transaction limit");
    require(!pausedToken || exemptOperatePausedToken[from], "Token is paused");
  }

  function _afterTokenTransfer( address, address to, uint256 ) internal view override {
    require(_balances[to] <= _maxAccountAmount || exemptAmountLimit[to], "Excedded the maximum tokens that an wallet can hold");
  }

  function _transfer( address sender, address recipient,uint256 amount ) internal override {
    require(!_noReentrancy, "ReentrancyGuard: reentrant call happens");
    _noReentrancy = true;
    
    require(sender != address(0) && recipient != address(0), "transfer from the zero address");
    
    _beforeTokenTransfer(sender, recipient, amount);

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "transfer amount exceeds your balance");
    uint256 newSenderBalance = senderBalance - amount;
    _balances[sender] = newSenderBalance;

    uint256 feeAmount = 0;
    if (!exemptFee[sender] && !exemptFeeReceiver[recipient]) feeAmount = (getFeeTotal() * amount) / 10000;

    exchangeFeeParts(feeAmount);
    uint256 newRecipentAmount = _balances[recipient] + (amount - feeAmount);
    _balances[recipient] = newRecipentAmount;

    _afterTokenTransfer(sender, recipient, amount);

    _noReentrancy = false;
    emit Transfer(sender, recipient, amount);
  }

  function exchangeFeeParts(uint256 incomingFeeTokenAmount) private returns (bool){
    if (incomingFeeTokenAmount == 0) return false;
    _balances[address(this)] += incomingFeeTokenAmount;
    
    address pairWbnbToken = WBNB_TOKEN_PAIR;
    if (_msgSender() == pairWbnbToken || pausedStake) return false;
    uint256 feeTokenAmount = _balances[address(this)];
    _balances[address(this)] = 0;

    // Gas optimization
    address wbnbAddress = WBNB;
    (uint112 reserve0, uint112 reserve1) = getTokenReserves(pairWbnbToken);
    bool reversed = isReversed(pairWbnbToken, wbnbAddress);
    if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }
    _balances[pairWbnbToken] += feeTokenAmount;
    address swapHelperAddress = address(swapHelper);
    uint256 wbnbBalanceBefore = getTokenBalanceOf(wbnbAddress, swapHelperAddress);
    
    uint256 wbnbAmount = getAmountOut(feeTokenAmount, reserve1, reserve0);
    swapToken(pairWbnbToken, reversed ? 0 : wbnbAmount, reversed ? wbnbAmount : 0, swapHelperAddress);
    uint256 wbnbBalanceNew = getTokenBalanceOf(wbnbAddress, swapHelperAddress);  
    require(wbnbBalanceNew == wbnbBalanceBefore + wbnbAmount, "Wrong amount of swapped on WBNB");
    // Deep Stack problem avoid
    {
      // Gas optimization
      address busdAddress = BUSD;
      address pairWbnbBusd = WBNB_BUSD_PAIR;
      (reserve0, reserve1) = getTokenReserves(pairWbnbBusd);
      reversed = isReversed(pairWbnbBusd, wbnbAddress);
      if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

      uint256 busdBalanceBefore = getTokenBalanceOf(busdAddress, address(this));
      tokenTransferFrom(wbnbAddress, swapHelperAddress, pairWbnbBusd, wbnbAmount);
      uint256 busdAmount = getAmountOut(wbnbAmount, reserve0, reserve1);
      swapToken(pairWbnbBusd, reversed ? busdAmount : 0, reversed ? 0 : busdAmount, address(this));
      uint256 busdBalanceNew = getTokenBalanceOf(busdAddress, address(this));
      require(busdBalanceNew == busdBalanceBefore + busdAmount, "Wrong amount swapped on BUSD");

      uint totalFee = getFeeTotal();
      if (feeAdministrationWallet > 0) tokenTransfer(busdAddress, administrationWallet, (busdAmount * feeAdministrationWallet) / totalFee);
      if (feeDevelopmentWallet > 0) tokenTransfer(busdAddress, developingWallet, (busdAmount * feeDevelopmentWallet) / totalFee);
    }
    return true;
  }

  function burn(uint256 amount) external {
    _burn(_msgSender(), amount);
    totalBurned += amount;
  }

  function buyBackAndHold(uint256 amount, address receiver) external isAuthorized(3) { buyBackAndHoldWithDecimals(amount * (10 ** decimalBUSD), receiver); }

  function buyBackAndHoldWithDecimals(uint256 decimalAmount, address receiver) public isAuthorized(3) { buyBackWithDecimals(decimalAmount, receiver); }

  function buyBackAndBurn(uint256 amount) external isAuthorized(3) { buyBackAndBurnWithDecimals(amount * (10 ** decimalBUSD)); }

  function buyBackAndBurnWithDecimals(uint256 decimalAmount) public isAuthorized(3) { buyBackWithDecimals(decimalAmount, address(0)); }

  function buyBackWithDecimals(uint256 decimalAmount, address destAddress) private {
    uint256 maxBalance = getTokenBalanceOf(BUSD, address(this));
    if (maxBalance < decimalAmount) revert(string(abi.encodePacked("insufficient BUSD amount[", Strings.toString(decimalAmount), "] on contract[", Strings.toString(maxBalance), "]")));

    (uint112 reserve0,uint112 reserve1) = getTokenReserves(WBNB_BUSD_PAIR);
    bool reversed = isReversed(WBNB_BUSD_PAIR, BUSD);
    if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

    tokenTransfer(BUSD, WBNB_BUSD_PAIR, decimalAmount);
    uint256 wbnbAmount = getAmountOut(decimalAmount, reserve0, reserve1);
    swapToken(WBNB_BUSD_PAIR, reversed ? wbnbAmount : 0, reversed ? 0 : wbnbAmount, address(this));

    bool previousExemptFeeState = exemptFee[WBNB_TOKEN_PAIR];
    exemptFee[WBNB_TOKEN_PAIR] = true;
    
    address pairWbnbToken = WBNB_TOKEN_PAIR;
    address swapHelperAddress = address(swapHelper);
    (reserve0, reserve1) = getTokenReserves(pairWbnbToken);
    reversed = isReversed(pairWbnbToken, WBNB);
    if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }

    tokenTransfer(WBNB, pairWbnbToken, wbnbAmount);
    
    uint256 tokenAmount = getAmountOut(wbnbAmount, reserve0, reserve1);
    if (destAddress == address(0)) {
      swapToken(pairWbnbToken, reversed ? tokenAmount : 0, reversed ? 0 : tokenAmount, swapHelperAddress);
      _burn(swapHelperAddress, tokenAmount);
      totalBurned += tokenAmount;
    } else {
      swapToken(pairWbnbToken, reversed ? tokenAmount : 0, reversed ? 0 : tokenAmount, destAddress);
    }
    exemptFee[WBNB_TOKEN_PAIR] = previousExemptFeeState;
  }
 
  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
    require(amountIn > 0, 'Insufficient amount in');
    require(reserveIn > 0 && reserveOut > 0, 'Insufficient liquidity');
    uint256 amountInWithFee = amountIn * 9975;
    uint256 numerator = amountInWithFee  * reserveOut;
    uint256 denominator = (reserveIn * 10000) + amountInWithFee;
    amountOut = numerator / denominator;
  }

  // gas optimization on get Token0 from a pair liquidity pool
  function isReversed(address pair, address tokenA) internal view returns (bool) {
    address token0;
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x0dfe168100000000000000000000000000000000000000000000000000000000)
      failed := iszero(staticcall(gas(), pair, emptyPointer, 0x04, emptyPointer, 0x20))
      token0 := mload(emptyPointer)
    }
    if (failed) revert("Unable to check direction of tokenfrom pair");
    return token0 != tokenA;
  }

  // gas optimization on transfer token
  function tokenTransfer(address token, address recipient, uint256 amount) internal {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), recipient)
      mstore(add(emptyPointer, 0x24), amount)
      failed := iszero(call(gas(), token, 0, emptyPointer, 0x44, 0, 0))
    }
    if (failed) revert("Unable to transfer token to address");
  }

  // gas optimization on transfer from token method
  function tokenTransferFrom(address token, address from, address recipient, uint256 amount) internal {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), from)
      mstore(add(emptyPointer, 0x24), recipient)
      mstore(add(emptyPointer, 0x44), amount)
      failed := iszero(call(gas(), token, 0, emptyPointer, 0x64, 0, 0)) 
    }
    if (failed) revert("Unable to transfer from token to address");
  }

  // gas optimization on swap operation using a liquidity pool
  function swapToken(address pair, uint amount0Out, uint amount1Out, address receiver) internal {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x022c0d9f00000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), amount0Out)
      mstore(add(emptyPointer, 0x24), amount1Out)
      mstore(add(emptyPointer, 0x44), receiver)
      mstore(add(emptyPointer, 0x64), 0x80)
      mstore(add(emptyPointer, 0x84), 0)
      failed := iszero(call(gas(), pair, 0, emptyPointer, 0xa4, 0, 0))
    }
    if (failed) revert("Unable to swap to receiver");
  }

  // gas optimization on get balanceOf fron BEP20 or ERC20 token
  function getTokenBalanceOf(address token, address holder) internal view returns (uint112 tokenBalance) {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x70a0823100000000000000000000000000000000000000000000000000000000)
      mstore(add(emptyPointer, 0x04), holder)
      failed := iszero(staticcall(gas(), token, emptyPointer, 0x24, emptyPointer, 0x40))
      tokenBalance := mload(emptyPointer)
    }
    if (failed) revert("Unable to get balance from wallet");
  }

  // gas optimization on get reserves from liquidity pool
  function getTokenReserves(address pairAddress) internal view returns (uint112 reserve0, uint112 reserve1) {
    bool failed = false;
    assembly {
      let emptyPointer := mload(0x40)
      mstore(emptyPointer, 0x0902f1ac00000000000000000000000000000000000000000000000000000000)
      failed := iszero(staticcall(gas(), pairAddress, emptyPointer, 0x4, emptyPointer, 0x40))
      reserve0 := mload(emptyPointer)
      reserve1 := mload(add(emptyPointer, 0x20))
    }
    if (failed) revert("Unable to get reserves from pair");
  }

  function setWBNB_TOKEN_PAIR(address newPair) external isAuthorized(0) { WBNB_TOKEN_PAIR = newPair; }
  function setWBNB_BUSD_Pair(address newPair) external isAuthorized(0) { WBNB_BUSD_PAIR = newPair; }
  function getWBNB_TOKEN_PAIR() external view returns(address) { return WBNB_TOKEN_PAIR; }
  function getWBNB_BUSD_Pair() external view returns(address) { return WBNB_BUSD_PAIR; }

}