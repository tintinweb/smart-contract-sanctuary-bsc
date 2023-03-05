// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IAggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

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

contract OraclePriceFeed {
    IAggregatorV3Interface public bnbPriceFeed;
    IAggregatorV3Interface public ethPriceFeed;

    constructor(address _bnbPriceFeed, address _ethPriceFeed) {
        bnbPriceFeed = IAggregatorV3Interface(_bnbPriceFeed);
        ethPriceFeed = IAggregatorV3Interface(_ethPriceFeed);
    }

    /**
     * Returns the latest price of BNB in USD, scaled by 1e8
     */
    function getBnbPrice() public view returns (int256) {
        (, int256 price, , , ) = bnbPriceFeed.latestRoundData();
        return price;
    }

    /**
     * Returns the latest price of ETH in USD, scaled by 1e8
     */
    function getEthPrice() public view returns (int256) {
        (, int256 price, , , ) = ethPriceFeed.latestRoundData();
        return price;
    }
}