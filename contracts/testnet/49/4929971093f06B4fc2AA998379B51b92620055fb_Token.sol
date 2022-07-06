// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

interface IAggregatorV3Interface{

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

contract Token {

    // IAggregatorV3Interface internal priceFeed;

    // /**
    //  * Network: Rinkeby
    //  * Aggregator: ETH/USD
    //  * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
    //  */
    // constructor() {
    //     priceFeed = IAggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    // }

    /**
     * Returns the latest price
     */
    function getLatestPrice(IAggregatorV3Interface priceFeed) public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}