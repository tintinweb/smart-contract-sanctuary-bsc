/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
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


contract PriceTest {
    AggregatorV3Interface internal priceFeed;

    address  addressOfPrice = 0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941;

    /**
     * Network: BSC 
     * Aggregator: BUSD/BNB
     * Address: 0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941
     */
     
    constructor() public {
        priceFeed = AggregatorV3Interface(addressOfPrice);
    }

    function upRsAddress(uint32 _mode,address _addOfPrice) public returns(address){
        if(_mode == 1){
        addressOfPrice = _addOfPrice ;
        priceFeed = AggregatorV3Interface(addressOfPrice);
        }
        return _addOfPrice;
    }


  

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

     function getLatestPriceExternal() external view returns (int) {
    return getLatestPrice();
  }



    
     
}