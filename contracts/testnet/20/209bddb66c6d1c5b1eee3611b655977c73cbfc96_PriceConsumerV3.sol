/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

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

contract PriceConsumerV3 {

    AggregatorV3Interface public priceFeed;

    constructor () {
        priceFeed = AggregatorV3Interface(0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7);
    }

    function getLatestPrice() public view returns (uint){
        (,int price,,,) = priceFeed.latestRoundData();
        return uint(price);
    }

    function getDecimals() public view returns(uint8 decimals){
        decimals = priceFeed.decimals();
    }

    function ETHtoUSD() public view returns(uint price){
        price = getLatestPrice()/getDecimals();
    }
}