/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// File: contracts/interface/IUSDOracle.sol

//SPDX-License-Identifier: MIT



interface IUSDOracle {
  // Must 8 dec, same as chainlink decimals.
  function getPrice(address token) external view returns (uint256);
}

// File: contracts/AggregatorV3Interface.sol



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
// File: contracts/usdOracle.sol


pragma solidity 0.8.9;



contract DTokenUSDOracle is IUSDOracle {

  mapping(address => AggregatorV3Interface) public aggregators;
  event SetAggregator(address indexed token, AggregatorV3Interface indexed aggregator);

  function setAggregator(address token, AggregatorV3Interface aggregator) external {
    uint8 dec = aggregator.decimals();
    require(dec == 8, "not support decimals");
    aggregators[token] = aggregator;
    emit SetAggregator(token, aggregator);
  }

  // get latest price
  function getPrice(address token) external override view returns (uint256) {
    (, int256 price, , , ) = aggregators[token].latestRoundData();
    require(price >= 0, "Negative Price!");
    return uint256(price);
  }

}