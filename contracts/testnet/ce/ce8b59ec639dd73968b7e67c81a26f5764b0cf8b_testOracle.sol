/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

pragma solidity 0.5.16;
interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
}

interface IOracle {
  function getCurrentPrice() external view returns (uint256);
}

contract testOracle {

  address private _owner = msg.sender;
  address private stable; 
  address private token;

  address private routerAddr = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
  address private factoryAddr = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;  

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function getPrice(address addr) public view returns(uint256) {
    uint256 r0;
    uint256 r1;
    IFactory f = IFactory(factoryAddr);
    address pairAddr = f.getPair(address(this), addr);
    if(pairAddr != address(0x0)) {
      IUniswapV2Pair uniPair = IUniswapV2Pair(pairAddr);
      address r0addr = uniPair.token0();
      if(r0addr == addr || r0addr == address(this)) {
        if(r0addr == addr) {
          (r0, r1, ) = uniPair.getReserves();
        } else {
          (r1, r0, ) = uniPair.getReserves();
        }
      }
      return (r1 * 1e18 / r0);
    }
    return 0;
  }

  function getCurrentPrice(address ) public view returns(uint256) {
    return getPrice(stable);
  }

  function setPriceSource(address _token, address _stable) external onlyOwner {
    stable = _stable;
    token = _token;
  }

  function setRouter(address _routerAddr, address _factoryAddr) external onlyOwner {
    routerAddr = _routerAddr;
    factoryAddr = _factoryAddr;
  }

}