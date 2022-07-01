// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Oracle {
    mapping(uint256 => address) public oracles;

    /**
     * Network: BSC
     * Aggregator: BNB / USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */
    constructor() {
        oracles[3] = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; //BNB-BUSD Aggregator Chainlinkss
    }

    /**
     * Returns the latest price
     */

    modifier onlyDev() {
        //require(msg.sender == 0x40891d4c21e527f27023b1de0406e98f7199d9c0);
        if (msg.sender != 0x30268390218B20226FC101cD5651A51b12C07470) {
            revert("not the dev");
        }
        _;
    }

    function getLatestPrice(uint256 poolId) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            oracles[poolId]
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function addAggregator(address _newOracle, uint256 _poolId) public onlyDev {
        oracles[_poolId] = _newOracle;
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