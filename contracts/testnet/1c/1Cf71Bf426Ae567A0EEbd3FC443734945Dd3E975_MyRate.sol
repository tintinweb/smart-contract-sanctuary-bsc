// SPDX-License-Identifier: MIT
pragma solidity ^0.5.5;

import "@chainlink/contracts/src/v0.5/interfaces/AggregatorV3Interface.sol";

contract MyRate {
    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Binance Smart Chain Testnet
     * Aggregator: BNB/USD
     * Address: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     */
    constructor() public {
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
    }

    function getRate() public returns (uint256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        price = price / 10**6; // get BNB price in cents
        price = 1000000000000000000 / price; //calculate amount of BNB wei for one centUSD
        uint256 a = 10000000000000000000 / uint256(85); //calculate amount of MyToken wei for one centUSD
        uint256 exchangeRate = a / uint256(price); //calculate _rate for crowdsale
        return uint256(exchangeRate);
    }
}

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