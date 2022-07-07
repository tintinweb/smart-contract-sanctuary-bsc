// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.4.0;
import "./BEP20Detailed.sol";
import "./BEP20.sol";
import "./IPancakeSwapRouter.sol";
import "./SafeMathInt.sol";
interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract CATKEN is BEP20Detailed, BEP20 {
  using SafeMath for uint256;
  using SafeMathInt for int256;
  mapping(address => bool) public liquidityPool;
  mapping(address => bool) public whitelistTax;

  uint8 public buyTax;
  uint8 public sellTax; 
  uint8 public transferTax;

  uint256 private taxAmount;

  address public marketingPool;
  address public LiquidityPool2;
  address public DevPool;
  address public RewardsPool;
  bool public tradingOpen;

  uint8 public mktTaxPercent;
  uint8 public LiquidityTaxPercent;
  uint8 public DevTaxPercent;
  uint8 private RewardsPoolTaxPercent;

  //swap 
  IPancakeSwapRouter public uniswapV2Router;
  bool public enableTax;
  address public _lpAddress;
  uint256 public launchedAt;
  event changeTax(bool _enableTax, uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changeTaxPercent(uint8 _mktTaxPercent,uint8 _LiquidityTaxPercent,uint8 _DevTaxPercent,uint8 _RewardsPoolTaxPercent);
  event changeWhitelistTax(address _address, bool status);  
  
 
  constructor() payable BEP20Detailed("CAT SAKEN", "CATKEN", 18) {
    uint256 totalTokens = 100000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    sellTax = 6;
    buyTax = 6;
    transferTax = 0;
    enableTax = true;
    tradingOpen = false;
    marketingPool   =      0x6Ce9dDAaCa6685F570f940e88f02FDe46181B56F;
    LiquidityPool2  =      address(this);
    DevPool         =      0x538a75C894b5De332470f0D83F1AF0d9cbA5DCdF;
    RewardsPool     =      0xaa62Fd49aba13222E8da9417c428140389393e9a;
    
    mktTaxPercent = 35;
    LiquidityTaxPercent = 15;
    DevTaxPercent = 35;
    RewardsPoolTaxPercent = 15;
    
    whitelistTax[address(this)] = true;
    whitelistTax[marketingPool] = true;
    whitelistTax[LiquidityPool2] = true;
    whitelistTax[DevPool] = true;
    whitelistTax[RewardsPool] = true;
    whitelistTax[owner()] = true;
    whitelistTax[address(0)] = true;
    

    uniswapV2Router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//pancakeroter v2
    _approve(address(this), address(uniswapV2Router), ~uint256(0));

    _lpAddress = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    liquidityPool[_lpAddress] = true;
  }
  function setTaxes(bool _enableTax, uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) external onlyOwner {
    require(_sellTax < 9);
    require(_buyTax < 9);
    require(_transferTax < 9);
    enableTax = _enableTax;
    sellTax = _sellTax;
    buyTax = _buyTax;
    transferTax = _transferTax;
    emit changeTax(_enableTax,_sellTax,_buyTax,_transferTax);
  }
  function setTaxPercent(uint8 _mktTaxPercent, uint8 _LiquidityTaxPercent, uint8 _DevTaxPercent, uint8 _RewardsPoolTaxPercent) external onlyOwner {
    require(_mktTaxPercent +  _LiquidityTaxPercent + _DevTaxPercent + _RewardsPoolTaxPercent == 100);
    mktTaxPercent = _mktTaxPercent;
    LiquidityTaxPercent = _LiquidityTaxPercent;
    DevTaxPercent = _DevTaxPercent;
    RewardsPoolTaxPercent = _RewardsPoolTaxPercent;
    emit changeTaxPercent(_mktTaxPercent,_LiquidityTaxPercent,_DevTaxPercent,_RewardsPoolTaxPercent);
  }

  function setWhitelist(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit changeWhitelistTax(_address, _status);
  }
  function getTaxes() external view returns (uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) {
    return (sellTax, buyTax, transferTax);
  } 
  //update swap

  //Tranfer and tax
  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    if (amount == 0) {
        super._transfer(sender, receiver, 0);
        return;
    }
    


    if(enableTax && !whitelistTax[sender] && !whitelistTax[receiver]){
      require(tradingOpen, "Trading not open yet");
      if(block.number - launchedAt <= 3 ){
        //is bot
        buyTax = 80;
        sellTax = 80;
      }
      //swap
      if(liquidityPool[sender] == true) {
        //It's an LP Pair and it's a buy
        taxAmount = (amount * buyTax) / 100;
      } else if(liquidityPool[receiver] == true) {      
        //It's an LP Pair and it's a sell
        taxAmount = (amount * sellTax) / 100;
      } else {
        taxAmount = (amount * transferTax) / 100;
      }

      
      if(taxAmount > 0) {
        uint256 mktTax = taxAmount.div(100).mul(mktTaxPercent);
        uint256 RewardsTax = taxAmount.div(100).mul(RewardsPoolTaxPercent);
        uint256 DevTax = taxAmount.div(100).mul(DevTaxPercent);
        uint256 Pool2Tax = taxAmount - mktTax - RewardsTax - DevTax;
        if(mktTax>0){
          super._transfer(sender, marketingPool, mktTax);
        }
        if(RewardsTax>0){
          super._transfer(sender, RewardsPool, RewardsTax);
        }
        if(DevTax>0){
          super._transfer(sender, DevPool, DevTax);
        }
        if(Pool2Tax>0){
          super._transfer(sender, address(this) , Pool2Tax);
        }
      }    
      super._transfer(sender, receiver, amount - taxAmount);
    }else{
      super._transfer(sender, receiver, amount);
    }
  }
  function launch() external onlyOwner {
    launchedAt = block.number;
    tradingOpen = true;

    }

  //common
  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  function AirDrop(address[] memory dests, uint256 amount) external onlyOwner {
    require(amount * dests.length <= balanceOf(msg.sender) , string("Transfer amount exceeds balance"));
    uint256 i = 0;
    while (i < dests.length) {
        transfer(dests[i] , amount);
        i++;
    }
  } 
  receive() external payable {}
}