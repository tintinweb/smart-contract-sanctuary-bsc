/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

pragma solidity 0.5.16;
interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
}

contract testOracle {

  address private _owner = msg.sender;
  address private coinA = 0x5B0F7C1336F3BFB1D07798F37c9EA0583314792A; 
  address private coinB = address(0x0); 
  address private routerAddr = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
  address private factoryAddr = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;  

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function getCurrentPrice() public view returns(uint256) {
    uint256 r0;
    uint256 r1;
    IFactory f = IFactory(factoryAddr);
    address pairAddr = f.getPair(coinA, coinB);
    if(pairAddr != address(0x0)) {
      IUniswapV2Pair uniPair = IUniswapV2Pair(pairAddr);
      address r0addr = uniPair.token0();
      if(r0addr == coinB || r0addr == coinA) {
        if(r0addr == coinB) {
          (r0, r1, ) = uniPair.getReserves();
        } else {
          (r1, r0, ) = uniPair.getReserves();
        }
        return (r1 * 1e18 / r0);
      }
    }
    return 0;
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