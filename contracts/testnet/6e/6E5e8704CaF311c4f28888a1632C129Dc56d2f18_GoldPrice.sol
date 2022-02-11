// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/// @author Amazie Team
/// @title Price Consumer V3
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
contract GoldPrice {
    AggregatorV3Interface internal priceFeed;
    /**
     * Network: Binance Smart Chain Testnet
     * Aggregator: ETH/USD
     * Address: 0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7
     * Decimal: 8 (1e10)
     */
     /**
     * Network: Binance Smart Chain
     * Aggregator: XAU/USD
     * Address: 0x86896fEB19D8A607c3b11f2aF50A0f239Bd71CD0
     * Decimal: 8 (1e10)
     */
     constructor() {
        priceFeed = AggregatorV3Interface(0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (, int price,,uint timeStamp,) = priceFeed.latestRoundData();
        require(timeStamp > 0, "Round not complete");
        return price * 1e10;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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