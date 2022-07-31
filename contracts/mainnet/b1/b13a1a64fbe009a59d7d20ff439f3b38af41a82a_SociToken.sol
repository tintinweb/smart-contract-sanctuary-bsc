// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.4;
import "./BEP20Detailed.sol";
import "./BEP20.sol";
import "./IPancakeSwapRouter.sol";
import "./SafeMathInt.sol";

contract SociToken is BEP20Detailed, BEP20 {
  using SafeMath for uint256;
  using SafeMathInt for int256;
  mapping(address => bool) public liquidityPool;
  mapping(address => bool) public whitelistTax;

  uint8 public buyTax;
  uint8 public sellTax; 
  uint8 public transferTax;
  uint256 private taxAmount;
  address public marketingWallet;
  address public TeamWallet;
  uint8 public mktPercent;

  //swap 
  IPancakeSwapRouter public uniswapV2Router;
  uint256 public swapTokensAtAmount;
  uint256 public swapTokensMaxAmount;
  bool public swapping;
  bool public enableTax;

  event changeTax(bool _enableTax, uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changesetMarketingPercent(uint8 _mktTaxPercent);
  event changePairForTax(address lpAddress, bool taxenable);
  event changeMarketingWallet(address marketingWallet);
  event changeTeamWallet(address TeamWallet);
  event changeWhitelistTax(address _address, bool status);  
  event UpdateUniswapV2Router(address indexed newAddress,address indexed oldAddress);
  
 
  constructor() payable BEP20Detailed("SociBall", "SOCI", 18) {
    uint256 totalSupply = 10000000 * 10**uint256(decimals());
    _mint(msg.sender, totalSupply);
    sellTax = 9;
    buyTax = 9;
    transferTax = 0;
    enableTax = false;
    marketingWallet = 0x0B7df63b1DBa8cf4934a2FFA215dfd099F14f9C8;
    TeamWallet = 0xa5419c766379d203Ce8e733c35BCcC8D76108429;
    mktPercent = 90;

    whitelistTax[address(this)] = true;
    whitelistTax[marketingWallet] = true;
    whitelistTax[TeamWallet] = true;
    whitelistTax[owner()] = true;
    whitelistTax[address(0)] = true;
  
    uniswapV2Router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    _approve(address(this), address(uniswapV2Router), ~uint256(0));
    swapTokensAtAmount = totalSupply*2/10**6; 
    swapTokensMaxAmount = totalSupply*2/10**4; 
  }

  

  //update fee
  function enablePairForTax(address _lpAddress, bool _taxenable) external onlyOwner {
    liquidityPool[_lpAddress] = _taxenable;
    emit changePairForTax(_lpAddress, _taxenable);
  }
  function setMarketingWallet(address _marketingWallet) external onlyOwner {
    marketingWallet = _marketingWallet;
    whitelistTax[marketingWallet] = true;
    emit changeMarketingWallet(_marketingWallet);
  }  
  function setTeamWallet(address _TeamWallet) external onlyOwner {
    TeamWallet = _TeamWallet;
    whitelistTax[TeamWallet] = true;
    emit changeTeamWallet(_TeamWallet);
  }  
  function setTaxes(bool _enableTax, uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) external onlyOwner {
    require(_sellTax < 10,"Need: sellTax < 10");
    require(_buyTax < 10,"Need: buyTax < 10");
    require(_transferTax < 10,"Need: transferTax < 10");
    enableTax = _enableTax;
    sellTax = _sellTax;
    buyTax = _buyTax;
    transferTax = _transferTax;
    emit changeTax(_enableTax,_sellTax,_buyTax,_transferTax);
  }
  function setMarketingPercent(uint8 _mktPercent) external onlyOwner {
    require(_mktPercent <= 100,"Need: mktPercent <= 100");
    mktPercent = _mktPercent;
    emit changesetMarketingPercent(_mktPercent);
  }

  function setWhitelist(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit changeWhitelistTax(_address, _status);
  }
  function getTaxes() external view returns (uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) {
    return (sellTax, buyTax, transferTax);
  } 

  //update swap
  function updateUniswapV2Router(address newAddress) public onlyOwner {
    require(
        newAddress != address(uniswapV2Router),
        "The router already has that address"
    );
    uniswapV2Router = IPancakeSwapRouter(newAddress);
    _approve(address(this), address(uniswapV2Router), ~uint256(0));
    emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
  }
  function setSwapTokensAtAmount(uint256 _swapTokensAtAmount, uint256 _swapTokensMaxAmount) external onlyOwner {
    require(swapTokensAtAmount > totalSupply()*2/10**6,"Min is totalSupply()*2/10**6");
    require(swapTokensMaxAmount > swapTokensAtAmount && swapTokensMaxAmount < totalSupply()*2/10**4,"need: swapTokensMaxAmount > swapTokensAtAmount && swapTokensMaxAmount < totalSupply()*2/10**4");
    swapTokensAtAmount = _swapTokensAtAmount;
    swapTokensMaxAmount = _swapTokensMaxAmount;
  }
  
  //Tranfer and tax
  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    if (amount == 0) {
        super._transfer(sender, receiver, 0);
        return;
    }

    if(enableTax && !whitelistTax[sender] && !whitelistTax[receiver]){
      //swap
      uint256 contractTokenBalance = balanceOf(address(this));
      bool canSwap = contractTokenBalance >= swapTokensAtAmount;
      if ( canSwap && !swapping && sender != owner() && receiver != owner() ) {
          if(contractTokenBalance > swapTokensMaxAmount){
            contractTokenBalance = swapTokensMaxAmount;
          }
          swapping = true;
          swapAndSendToFee(contractTokenBalance);
          swapping = false;
      }

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
        uint256 mktTax = taxAmount.mul(mktPercent).div(100);
        uint256 TeamWalletTax = taxAmount - mktTax;
        if(mktTax>0){
          super._transfer(sender, marketingWallet, mktTax);
        }
        if(TeamWalletTax>0){
          super._transfer(sender, address(this) , TeamWalletTax);
        }
      }    
      super._transfer(sender, receiver, amount - taxAmount);
    }else{
      super._transfer(sender, receiver, amount);
    }
  }

  function swapAndSendToFee(uint256 tokens) private {
    swapTokensForEth(tokens);
    uint256 newBalance = address(this).balance;
    if(newBalance>0){
      payable(TeamWallet).transfer(newBalance);
    }
  }

  function swapTokensForEth(uint256 tokenAmount) private {
      // generate the uniswap pair path of token -> weth
      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = uniswapV2Router.WETH();
      // make the swap
      try
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        )
      {} catch {}
  }

  receive() external payable {}
}