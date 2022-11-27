/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

pragma solidity 0.5.16;

interface Router {
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;    
  function getAmountsOut(uint amountIn, address[] calldata path) external  view returns (uint[] memory amounts);  
  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}




contract testOracle {

  Router public router;

  address private _owner = msg.sender;
  uint256 public currentPrice = 301690000000000000000;  
  uint256 public lastUpdate;
  uint256 public buyAmount = 10000;
  bool public useMinPrice = true;

  struct Path {
    address[] p;
    uint256 index;
    uint256 distance;
    uint8 decimals;
  }

  Path[] private paths; 

  constructor () public {
    address[] memory temp = new address[](2);
    temp[0] = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    temp[1] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    addPath(temp, 18);
    router = Router(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function getDistance(uint256 a, uint256 b) public pure returns (uint256) {
    if(a > b) {
        return a - b;
    } 
    return b - a;
  }

  function setRouter(address a) public {
    router = Router(a);
  }

  function getPercentageChange(uint256 a, uint256 b) public pure returns (uint256) {
    bool priceIncrease = a > b;
    uint256 change = priceIncrease ? 1000 * a / b  - 1000: 1000 - 1000 * a / b;
    return change;
  }

  function addPath(address[] memory p, uint8 inputDecimals) public onlyOwner {
    uint256 index = paths.length;
    Path memory newPath = Path(p, index, 0, inputDecimals);
    paths.push(newPath);
  }

  function setPriceMethod(bool setting) public onlyOwner {
    useMinPrice = setting;
  }  

  function overridePaths() public onlyOwner {
    uint256 pathLength = paths.length;
    Path memory lastPath = paths[pathLength - 1];
    for(uint256 i = 0; i < pathLength; i++) {
      paths.pop();
    }
    paths.push(lastPath);
  }

  function getPrices() public view returns(uint256 [] memory) {
    uint256 [] memory arr = new uint256[](paths.length);
    for(uint256 i = 0; i < paths.length; i++) {
        uint256 dollars = pathToPrice(i); 
        arr[i] = dollars;
    }
    return arr;
  }

  function bubbleSort(uint256 [] memory arr) public pure returns(uint256 [] memory) {
    for(uint256 i = 0; i <= arr.length-1; i++){
      for(uint256 j = 0; j < ( arr.length - i -1); j++){
        if(arr[j] > arr[j+1]){
          uint256 temp = arr[j];
          arr[j] = arr[j + 1];
          arr[j+1] = temp;
        }
      }
    }
    return arr;
  }

  function pathToPrice(uint256 index) public view returns (uint256) {
    Path memory thePath = paths[index];
    uint[] memory r = router.getAmountsIn(1e18 / buyAmount, thePath.p);
    if(r.length > 0) {  
      uint256 decimals = thePath.decimals;
      uint256 dollars = buyAmount * r[0] * (10 ** (18 - decimals)) ; 
      return dollars;     
    }
    return 0;
  }

  function getBestPrice() public view returns (uint256) {
    if(useMinPrice) {
      return getMinPrice();
    }
    return getMedianPrice();
  }

  function getMinPrice() public view returns (uint256) {
    uint256 bigValue = 10e30;
    uint256 minDistance = bigValue;
    uint256 bestPrice = bigValue;    
    for(uint256 i=0; i < paths.length; i++) {
      uint256 dollars = pathToPrice(i); 
      uint256 newMinDistance = getDistance(dollars, currentPrice);
      if(newMinDistance < minDistance) {
        minDistance = newMinDistance;
        bestPrice = dollars;
      }
    }
    return bestPrice;
  }

  function getMedianPrice() public view returns (uint256) {
    uint256 [] memory arr = bubbleSort(getPrices());
    return arr[arr.length / 2];
  }

  function getCurrentPrice() public view returns (uint256) {
    return getBestPrice();
  }

  function setCurrentPrice(uint256 p) public onlyOwner {
    currentPrice = p;
    lastUpdate = block.timestamp;
  }

  function setBuyAmount(uint256 a) public onlyOwner {
    buyAmount = a;
  }  

}