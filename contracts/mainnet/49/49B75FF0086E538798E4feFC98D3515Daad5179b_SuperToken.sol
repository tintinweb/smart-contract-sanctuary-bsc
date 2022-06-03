// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BEP20Detailed.sol";
import "./BEP20.sol";

contract SuperToken is BEP20Detailed, BEP20 {
  
  uint256 constant private MAX_PERCENT = 100;

  mapping(address => bool) private isBlacklist;
  mapping(address => bool) private liquidityPool;
  mapping(address => bool) private whitelistTax;
  mapping(address => uint256) private lastTrade;

  uint8 private buyTax;
  uint8 private sellTax;
  uint8 private tradeCooldown;
  uint8 private transferTax;
  //uint256 private taxAmount;

  address private marketingPool;

  event ChangeBlacklist(address _wallet, bool status);
  event ChangeCooldown(uint8 tradeCooldown);
  event ChangeTax(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event ChangeLiquidityPoolStatus(address lpAddress, bool status);
  event ChangeMarketingPool(address marketingPool);
  event ChangeWhitelistTax(address _address, bool status);

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    uint8 _decimals, // 18
    uint256 _supply, // 5000000
    uint8 _sellT, // 3
    uint8 _buyT, // 1
    uint8 _transferT, // 1
    uint8 _tradeC, // 10
    address _marketingWallet // address
  ) BEP20Detailed(_tokenName, _tokenSymbol, _decimals) {
    uint256 totalTokens = _supply * 10**uint256(_decimals);
    _mint(msg.sender, totalTokens);

    sellTax = _sellT;
    buyTax = _buyT;
    transferTax = _transferT;
    tradeCooldown = _tradeC;
    marketingPool = _marketingWallet;
  }

  function setBlacklist(address _wallet, bool _status) external onlyOwner {
    isBlacklist[_wallet] = _status;
    emit ChangeBlacklist(_wallet, _status);
  }

  function setCooldownForTrades(uint8 _tradeCooldown) external onlyOwner {
    tradeCooldown = _tradeCooldown;
    emit ChangeCooldown(_tradeCooldown);
  }

  function setLiquidityPoolStatus(address _lpAddress, bool _status)
    external
    onlyOwner
  {
    liquidityPool[_lpAddress] = _status;
    emit ChangeLiquidityPoolStatus(_lpAddress, _status);
  }

  function setMarketingPool(address _marketingPool) external onlyOwner {
    marketingPool = _marketingPool;
    emit ChangeMarketingPool(_marketingPool);
  }

  function setTaxes(
    uint8 _sellTax,
    uint8 _buyTax,
    uint8 _transferTax
  ) external onlyOwner {
    require(_sellTax < 25);
    require(_buyTax < 25);
    require(_transferTax < 25);
    sellTax = _sellTax;
    buyTax = _buyTax;
    transferTax = _transferTax;
    emit ChangeTax(_sellTax, _buyTax, _transferTax);
  }

  function getTaxes()
    external
    view
    returns (
      uint8 _sellTax,
      uint8 _buyTax,
      uint8 _transferTax
    )
  {
    return (sellTax, buyTax, transferTax);
  }

  function setWhitelist(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit ChangeWhitelistTax(_address, _status);
  }

  function _transfer(
    address sender,
    address receiver,
    uint256 amount
  ) internal virtual override {
    require(
      receiver != address(this),
      string("No transfers to contract allowed.")
    );

    require(!isBlacklist[sender], "User blacklisted");
    
    uint256 taxAmount = 0;

    if (liquidityPool[sender] == true) {
      //It's an LP Pair and it's a buy
      taxAmount = (amount * buyTax) / MAX_PERCENT;
    } else if (liquidityPool[receiver] == true) {
      //It's an LP Pair and it's a sell
      taxAmount = (amount * sellTax) / MAX_PERCENT;

      uint256 transactionTime = block.timestamp;
      require(
        lastTrade[sender] < (transactionTime - tradeCooldown),
        string("No consecutive sells allowed. Please wait.")
      );

      lastTrade[sender] = transactionTime;
    } else if (
      whitelistTax[sender] ||
      whitelistTax[receiver] ||
      sender == marketingPool ||
      receiver == marketingPool
    ) {
      taxAmount = 0;
    } else {
      taxAmount = (amount * transferTax) / MAX_PERCENT;
    }

    if (taxAmount > 0) {
      super._transfer(sender, marketingPool, taxAmount);
    }
    super._transfer(sender, receiver, amount - taxAmount);
  }
}