/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// File: @chainlink/contracts/src/v0.5/interfaces/AggregatorV3Interface.sol
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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

// File: packageprice.sol

/**
  *  Lexeon package price smart contract
  *
  *  888                                                  
  *  888                                                  
  *  888                                                  
  *  888      .d88b.  888  888  .d88b.   .d88b.  88888b.  
  *  888     d8P  Y8b `Y8bd8P' d8P  Y8b d88""88b 888 "88b 
  *  888     88888888   X88K   88888888 888  888 888  888 
  *  888     Y8b.     .d8""8b. Y8b.     Y88..88P 888  888 
  *  88888888 "Y8888  888  888  "Y8888   "Y88P"  888  888 
  *  
 */

pragma solidity >=0.4.23 <0.6.0;


contract LexeonPackagesPrice {
    AggregatorV3Interface internal priceFeed;
    address private owner;
    uint256 private minimumPackagePrice = 50;
    mapping(uint8 => mapping(uint8 => uint256)) packages;
    event PriceUpdated(uint8 _matrix, uint8 _packageNum, uint256 _amount);
    modifier isPackageExist (uint8 _matrix, uint8 _packageNum) {
        if(_matrix == 1 || _matrix == 3) {
            require(_packageNum >= 1 && _packageNum <= 15, "Learning package does not exist!");
            _;
        } else if (_matrix == 2) {
            require(_packageNum >= 1 && _packageNum <= 8, "Learning package does not exist!");
            _;
        }
    }
    modifier isMatrixExist (uint8 _matrix) {
        require(_matrix >= 1 && _matrix <= 3, "Matrix not exist!");
        _;
    }
    modifier onlyOwner () {
        require(owner == tx.origin, "Only owner of smart contract can call this method!");
        _;
    }
    modifier canNotBeSame (uint8 _matrix, uint8 _packageNum, uint256 _newPrice) {
        require(_newPrice != packages[_matrix][_packageNum], "Please add different package price!");
        _;
    }
    modifier shouldBeGreater (uint256 _newPrice) {
        require(_newPrice >= minimumPackagePrice, "Package price should be equal or greater than minimum price!");
        _;
    }
    constructor (address _owner) public {
        priceFeed = AggregatorV3Interface(0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941);
        owner = _owner;
        // prices in usd
        packages[1][1] = 50; packages[3][1] = 50; packages[2][1] = 50;
        packages[1][2] = 100; packages[3][2] = 100; packages[2][2] = 150;
        packages[1][3] = 200; packages[3][3] = 200; packages[2][3] = 450;
        packages[1][4] = 350; packages[3][4] = 350; packages[2][4] = 1250;
        packages[1][5] = 500; packages[3][5] = 500; packages[2][5] = 3750;
        packages[1][6] = 1000; packages[3][6] = 1000; packages[2][6] = 11250;
        packages[1][7] = 1500; packages[3][7] = 1500; packages[2][7] = 33750;
        packages[1][8] = 2500; packages[3][8] = 2500; packages[2][8] = 101250;
        packages[1][9] = 4000; packages[3][9] = 4000;
        packages[1][10] = 7500; packages[3][10] = 7500;
        packages[1][11] = 10000; packages[3][11] = 10000;
        packages[1][12] = 18000; packages[3][12] = 18000;
        packages[1][13] = 30000; packages[3][13] = 30000;
        packages[1][14] = 50000; packages[3][14] = 50000;
        packages[1][15] = 75000; packages[3][15] = 75000;
    }
    function getLatestPrice() public view returns (uint256) {
        (            
            /*uint80 roundID*/,
            int256 price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }
    function transferOwnerShip(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    function setPrice (uint8 _matrix, uint8 _packageNum, uint256 _newPrice)
    public
    onlyOwner 
    isMatrixExist(_matrix)
    isPackageExist(_matrix, _packageNum)
    canNotBeSame(_matrix, _packageNum, _newPrice)
    shouldBeGreater(_newPrice) {
        packages[_matrix][_packageNum] = _newPrice;
        emit PriceUpdated(_matrix, _packageNum, _newPrice);
    }
    function getPrice (uint8 _matrix, uint8 _packageNum) 
    public view isMatrixExist(_matrix)
    isPackageExist(_matrix, _packageNum)
    returns(uint256){
        return packages[_matrix][_packageNum] * getLatestPrice();
    }
}