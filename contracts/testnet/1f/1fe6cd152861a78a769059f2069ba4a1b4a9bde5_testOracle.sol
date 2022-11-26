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
  uint256 public allowedPriceChange = 50; 
  bool public useMinPrice = true;

  struct Path {
    address[] p;
    uint256 index;
    uint256 distance;
    uint8 decimals;
  }

  Path[] private paths;

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
    uint256 change = priceIncrease ? a * 1000 / b : 1000 - 1000 * a / b;
    return change;
  }

  function addPath(address[] memory p, uint8 inputDecimals) public onlyOwner {
    uint256 index = paths.length;
    Path memory newPath = Path(p, index, 0, inputDecimals);
    paths.push(newPath);
  }

  function setAllowedPriceChange(uint256 c) public onlyOwner {
    allowedPriceChange = c;
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

  function getPrices() external view returns(uint256 [] memory) {
    uint256 [] memory arr;
    for(uint256 i=0; i < paths.length; i++) {
        uint256 dollars = pathToPrice(i); 
        arr[i] = dollars;
    }
    return arr;
  }

  function bubbleSort(uint256 [] memory arr) public view onlyOwner returns(uint256 [] memory) {
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
    uint[] memory r = router.getAmountsIn(10e18 / buyAmount, thePath.p);
    if(r.length > 0) {  
      uint256 decimals = thePath.decimals;
      uint256 dollars = buyAmount * r[0] * (10 ** (18 - decimals)) / r[r.length-1]; 
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
    uint256 bigValue = 10e20;
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
    uint256 [] memory arr;
    for(uint256 i=0; i < paths.length; i++) {
      uint256 dollars = pathToPrice(i); 
      arr[i] = dollars;
    }
    arr = bubbleSort(arr);
    return arr[arr.length / 2];
  }

  function getTimeWeightedPrice(uint256 bestPrice) public view returns (uint256) {
    uint256 change = getPercentageChange(bestPrice, currentPrice);
    if(change > allowedPriceChange) {  
      uint256 temp = bestPrice > currentPrice ? currentPrice * 101/100 : currentPrice * 99/100;
      return temp;
    } 
    if(bestPrice !=0) {
      return bestPrice;
    } 
    return currentPrice;
  }

  function getCurrentPrice() public view returns (uint256) {
    uint256 bestPrice = getBestPrice();
    return getTimeWeightedPrice(bestPrice);
  }

  function getCurrentPrice2() public returns (uint256) {
    uint256 bestPrice = getBestPrice();
    uint256 timeWeightedPrice = getTimeWeightedPrice(bestPrice);
    if(block.timestamp > 120 + lastUpdate && bestPrice != timeWeightedPrice) {
      currentPrice = timeWeightedPrice;
      lastUpdate = block.timestamp;
    }           
    return timeWeightedPrice;
  }

  function setCurrentPrice(uint256 p) public onlyOwner {
    require(p > 0);
    uint256 change = getPercentageChange(p, currentPrice);
    require(change < 500);
    currentPrice = p;
    lastUpdate = block.timestamp;
  }  

  function setCurrentPrice2(uint256 p) public onlyOwner {
    currentPrice = p;
    lastUpdate = block.timestamp;
  }

  function setBuyAmount(uint256 a) public onlyOwner {
    buyAmount = a;
  }  

}