/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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


contract XRPPriceConsumer {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: BNB Chain
     * Aggregator: XRP/USD
     * Address: 0x4046332373C24Aed1dC8bAd489A04E187833B28d
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x4046332373C24Aed1dC8bAd489A04E187833B28d);
    }

    function getDecimals() public view returns(uint8){
        // return priceFeed.decimals();
        return 8;
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

    function xrp2USD(uint256 xrpAmount) public view returns (uint256) {
        uint256 latestPrice = uint256(getLatestPrice());
        return xrpAmount * latestPrice;
    }

    function USD2xrp(uint256 usd) public view returns (uint256) {
        uint256 latestPrice = uint256(getLatestPrice());
        uint256 result = usd * (10 ** 8) * (10**8) / latestPrice ;
        return result;
    }

}