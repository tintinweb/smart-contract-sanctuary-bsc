// SPDX-License-Identifier: MIT
/*
La'eeb has been named the official mascot for this year's Fifa World Cup Qatar 2022. 
BetLaeed is the active earning project for you from now until World Cup 2022 and later. This project brings you the chance of earning from NFT collection, spin to earn, lottery to earn, advertise to earn and more income.
There are many BIG partners in the discussion about the cooperation with project team and all things will be announced soon.
*/
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

  mapping(address => bool) public whitelistTax;

  uint8 public buyTax;
  uint8 public sellTax; 
  uint8 public transferTax;

  uint256 private taxAmount;

  address payable public marketingPool;
  address payable public DevPool;

  bool public tradingOpen;

  uint8 private mktTaxPercent;
  uint8 private DevTaxPercent;
  bool private inSwap = false;
  modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

  //swap 
  IPancakeSwapRouter public uniswapV2Router;
  bool public enableTax;
  address public _lpAddress;
  uint256 public launchedAt;
  event changeTax(bool _enableTax, uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changeTaxPercent(uint8 _mktTaxPercent,uint8 _DevTaxPercent);
  event changeWhitelistTax(address _address, bool status);  
  
  event changeMarketingPool(address marketingPool);
  event changeLiquidityPool2(address LiquidityPool2);
  event changeDevPool(address DevPool);
  event changeRewardsPool(address RewardsPool);
  event UpdateUniswapV2Router(address indexed newAddress,address indexed oldAddress);

  constructor() payable BEP20Detailed("BetLaeeb", "BLE", 18) {
    uint256 totalTokens = 100000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    sellTax = 6;
    buyTax = 6;
    transferTax = 6;
    enableTax = true;
    tradingOpen = false;

    marketingPool   =      payable(0xF5439842d3F785ee31BC3C72DF1f8A22ef926E56);
    DevPool         =      payable(0xF3F0f3A95A59bF1D775Ed581eaf2ACCc38C91187);

    
    mktTaxPercent = 50;
    DevTaxPercent = 50;

    
    whitelistTax[address(this)] = true;
    whitelistTax[marketingPool] = true;
    whitelistTax[DevPool] = true;
    whitelistTax[owner()] = true;
    whitelistTax[address(0)] = true;
    

    uniswapV2Router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//pancakerouter v2
    _approve(address(this), address(uniswapV2Router), ~uint256(0));

    //_lpAddress = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    _lpAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  }



  function setMarketingPool(address _marketingPool) external onlyOwner {
    marketingPool = payable(_marketingPool);
    whitelistTax[marketingPool] = true;
    emit changeMarketingPool(_marketingPool);
  }  

  function setDevPool(address _DevPool) external onlyOwner {
    DevPool = payable(_DevPool);
    whitelistTax[DevPool] = true;
    emit changeDevPool(_DevPool);
  }  

  function updateUniswapV2Router(address newAddress) public onlyOwner {
    require(
        newAddress != address(uniswapV2Router),
        "The router already has that address"
    );
    uniswapV2Router = IPancakeSwapRouter(newAddress);
    _approve(address(this), address(uniswapV2Router), ~uint256(0));
    _lpAddress = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
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

  function setTaxPercent(uint8 _mktTaxPercent, uint8 _DevTaxPercent) external onlyOwner {
    require(_mktTaxPercent +  _DevTaxPercent  == 100);
    mktTaxPercent = _mktTaxPercent;
    DevTaxPercent = _DevTaxPercent;
    emit changeTaxPercent(_mktTaxPercent,_DevTaxPercent);
  }

  function setWhitelist(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit changeWhitelistTax(_address, _status);
  }
  function getTaxes() external view returns (uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) {
    return (sellTax, buyTax, transferTax);
  } 
 

  //Tranfer and tax
  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    taxAmount = 0;
    if (amount == 0) {
        super._transfer(sender, receiver, 0);
        return;
    }
    if(enableTax && !whitelistTax[sender] && !whitelistTax[receiver]){
      require(tradingOpen, "Trading not open yet");
      if(block.number - launchedAt <= 3 ){
        //is bot
        taxAmount = (amount * 80) / 100;
      }else{
      //swap
      if(sender == _lpAddress) {
        //It's an LP Pair and it's a buy
        taxAmount = (amount * buyTax) / 100;
      } else if(receiver == _lpAddress) {      
        //It's an LP Pair and it's a sell
        taxAmount = amount.mul(sellTax).div(100);
      } else {
        taxAmount = amount.mul(transferTax).div(100);
      }
      }

      if(taxAmount > 0) {
        swapTokensForEth(taxAmount);
        uint256 contractETHBalance = address(this).balance;
        uint256 mktTax = contractETHBalance.div(100).mul(mktTaxPercent);
        uint256 DevTax = contractETHBalance.div(100).mul(DevTaxPercent);
        if(mktTax>0){
          marketingPool.transfer(mktTax);
        }
        if(DevTax>0){
          DevPool.transfer(DevTax);
        }
      }    
      super._transfer(sender, receiver, amount - taxAmount);
    }else{
      super._transfer(sender, receiver, amount);
    }
  }
  function launch() external onlyOwner {
    require(tradingOpen == false, "Already open ");
    launchedAt = block.number;
    tradingOpen = true;

  }
  function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

  //common
  function burn(uint256 amount) external {
    amount = amount * 10**uint256(decimals());
    _burn(msg.sender, amount);
  }


  receive() external payable {}
}