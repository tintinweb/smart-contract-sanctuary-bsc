/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

pragma solidity 0.5.16;

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
}
 
contract SimpleOracle {
  
  address private _owner = msg.sender;
  address private coinA =	address(0x0); 
  address private coinB =	address(0x0); 
  address private routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address private factoryAddr = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;  
  uint256 public lastPrice; 
  uint256 private timeStamp; 
  uint256 private v = 2592000; 

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  constructor() public {
    lastPrice = getOnchainPrice();
    timeStamp = now;
  }

  function getOnchainPrice() public view returns(uint256) {
    uint256 r0;
    uint256 r1;
    IFactory f = IFactory(factoryAddr);
    address pairAddr = f.getPair(coinA, coinB);
    if(pairAddr != address(0x0)) {
      IUniswapV2Pair uniPair = IUniswapV2Pair(pairAddr);
      address r0addr = uniPair.token0();
      if(r0addr == coinB || r0addr == coinA) {
        if(r0addr == coinA) {
          (r0, r1, ) = uniPair.getReserves();
        } else {
          (r1, r0, ) = uniPair.getReserves();
        }
        return (r1 * 1e18 / r0);
      }
    }
    return 0;
  }

  function getCurrentPrice() public view returns(uint256) {
    uint256 onChainPrice = getOnchainPrice();
    if(onChainPrice > 1e20 * 11/10) onChainPrice = 1e20 * 11/10;
    uint256 timePassed = now - timeStamp;
    return (v * lastPrice + timePassed * onChainPrice) / (timePassed + v);
  }

  function update(uint256 _slippage) external onlyOwner {

    uint256 onChainPrice = getOnchainPrice();
    uint256 minPrice = lastPrice * (100 - _slippage) / 100;
    uint256 maxPrice = lastPrice * (100 + _slippage) / 100;

    require((onChainPrice > minPrice && onChainPrice < maxPrice) || _slippage == 0);
    lastPrice = onChainPrice;
    timeStamp = now;

  }

  function changeOwner(address newOwner) external onlyOwner {
    _owner = newOwner;
  }

  function setLastPrice(uint256 _lastPrice) external onlyOwner {
    lastPrice = _lastPrice;
  }

  function setV(uint256 _v) external onlyOwner {
    v = _v;
  }

  function setPriceSource(address _coinA, address _coinB) external onlyOwner {
    coinA = _coinA;
    coinB = _coinB;
  }

  function setRouter(address _routerAddr, address _factoryAddr) external onlyOwner {
    routerAddr = _routerAddr;
    factoryAddr = _factoryAddr;
  }

}


/* 
Disclaimer: This contract should only be used for rough price estimations, and not where accurate prices are critical. 
*/