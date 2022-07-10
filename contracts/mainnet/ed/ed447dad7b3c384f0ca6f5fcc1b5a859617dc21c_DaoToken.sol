// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract DaoToken is ERC20, Ownable {

  mapping(address => bool) private liquidityPool;
  mapping(address => bool) private whitelistTax;
  mapping(address => uint256) private lastTrade;
  mapping (address => bool) isTxLimitExempt;


  uint8 private sellTax;
  uint8 private buyTax;
  uint8 private transferTax;
  uint8 private tradeCooldown;
  uint256 public _maxTxAmount = 1000000 * 1 ether; 
  address private marketingPool;



  event changeTax(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changeCooldown(uint8 tradeCooldown);
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changeWhitelistTax(address _address, bool status);
  event changeMarketingPool(address marketingPool);

  constructor() ERC20("RATSCOIN TEAM DAO", "RATSDAO") {
    _mint(msg.sender, 100000000 * 1 ether);
    sellTax = 0;
    buyTax = 0;
    transferTax = 0;
    tradeCooldown = 15;
    isTxLimitExempt[owner()] = true;
    isTxLimitExempt[address(this)] = true;
  }

  function setTaxes(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) external onlyOwner {
    require(_sellTax < 20);
    require(_buyTax < 20);
    require(_transferTax < 5);
    sellTax = _sellTax;
    buyTax = _buyTax;
    transferTax = _transferTax;
    emit changeTax(_sellTax,_buyTax,_transferTax);
  }

  function getTaxes() external pure returns (uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) {
    return (_sellTax, _buyTax, _transferTax);
  }

  function setCooldownForTrades(uint8 _tradeCooldown) external onlyOwner {
    require(_tradeCooldown < 61);
    tradeCooldown = _tradeCooldown;
    emit changeCooldown(_tradeCooldown);
  }

  function setLiquidityPoolStatus(address _lpAddress, bool _status) external onlyOwner {
    liquidityPool[_lpAddress] = _status;
    emit changeLiquidityPoolStatus(_lpAddress, _status);
  }

  function setWhitelist(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit changeWhitelistTax(_address, _status);
  }

  function setMarketingPool(address _marketingPool) external onlyOwner {
    marketingPool = _marketingPool;
    emit changeMarketingPool(_marketingPool);
  }

  function checkTxLimit(address sender, uint256 amount) internal view {
    require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

  function setIsTxLimitExempt(address wallet, bool exempt) external onlyOwner {
    isTxLimitExempt[wallet] = exempt;
    }

  function setTxLimit(uint256 amount) public onlyOwner {
    _maxTxAmount = amount;
    }

  function sweep() external onlyOwner {
    address payable _owner = payable(msg.sender);
    _owner.transfer(address(this).balance);
    }

  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    uint256 taxAmount;
    if(liquidityPool[sender] == true) {
      checkTxLimit(receiver, amount); 
      //It's an LP Pair and it's a buy
      taxAmount = (amount * buyTax) / 100;
    } else if(liquidityPool[receiver] == true) {      
      //It's an LP Pair and it's a sell
      taxAmount = (amount * sellTax) / 100;

      require(lastTrade[sender] < (block.timestamp - tradeCooldown), string("No consecutive sells allowed. Please wait."));
      lastTrade[sender] = block.timestamp;

    } else if(whitelistTax[sender] || whitelistTax[receiver] || sender == marketingPool || receiver == marketingPool) {
      taxAmount = 0;
    } else {
      taxAmount = (amount * transferTax) / 100;
    }
    
    if(taxAmount > 0) {
      super._transfer(sender, marketingPool, taxAmount);
    }    
    super._transfer(sender, receiver, amount - taxAmount);
  }

  function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override {
    require(_to != address(this), string("No transfers to contract allowed."));    
    super._beforeTokenTransfer(_from, _to, _amount);
  }

}