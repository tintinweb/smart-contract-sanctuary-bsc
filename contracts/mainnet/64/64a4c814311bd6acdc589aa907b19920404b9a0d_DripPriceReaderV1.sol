/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

interface IBR34P {
    function balanceOf(address who) external view returns (uint);
}

interface IFountain {
    function getTokenToBnbInputPrice(uint tokenSold) external view returns (uint);
}

interface IPancakeSwapV1Router {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory);
}

contract DripPriceReaderV1 {
    address BR34P = 0xa86d305A36cDB815af991834B46aD3d7FbB38523;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address DRIP = 0x20f663CEa80FaCE82ACDFA3aAE6862d246cE0333;

    IFountain fountain = IFountain(0x4Fe59AdcF621489cED2D674978132a54d432653A);
    IBR34P br34p = IBR34P(BR34P);
    IPancakeSwapV1Router pcsV1 = IPancakeSwapV1Router(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
    IPancakeSwapV1Router pcsV2 = IPancakeSwapV1Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    AggregatorV3Interface internal bnbPriceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

    function getBnbPrice() public view returns (uint) {
        (,int price,,,) = bnbPriceFeed.latestRoundData();
        return uint(price * (10 ** 10));
    }

    function getDripBnbRatio() public view returns (uint dripBnbRatio){
        dripBnbRatio = fountain.getTokenToBnbInputPrice(1 ether);
    }

    function getDripFoundtainPrice() public view returns (uint price){
        uint bnbPrice = getBnbPrice();
        uint dripBnbRatio = fountain.getTokenToBnbInputPrice(1 ether);
        
        price = (dripBnbRatio * bnbPrice) / (10 ** 18); 
    }

    function getDripPcsPrice() public view returns (uint price){
        address[] memory path = new address[](2);

        path[0] = DRIP;
        path[1] = BUSD;
        
        uint[] memory results = pcsV2.getAmountsOut(1 ether, path);
        price = results[1];
    }


    function getBr34pBnbRatio() public view returns (uint br34pBnbRatio){
        address[] memory path = new address[](2);

        path[0] = BR34P;
        path[1] = WBNB;
        
        uint[] memory results = pcsV1.getAmountsOut(10 ** 8, path);
        br34pBnbRatio = results[1];
    }
    
    function getBr34pPrice() public view returns (uint price){
        address[] memory path = new address[](3);

        path[0] = BR34P;
        path[1] = WBNB;
        path[2] = BUSD;
        uint[] memory results = pcsV1.getAmountsOut(10 ** 8, path);
        price = results[2];
    }

    function getAllStats() public view returns (uint bnbPrice, uint dripBnbRatio, uint dripFountainPrice, uint dripPcsPrice, uint br34pBnbRatio, uint br34pPrice){
        bnbPrice = getBnbPrice();
        dripBnbRatio = getDripBnbRatio();
        dripFountainPrice = getDripFoundtainPrice();
        dripPcsPrice = getDripPcsPrice();
        br34pBnbRatio = getBr34pBnbRatio();
        br34pPrice = getBr34pPrice();
    }
}