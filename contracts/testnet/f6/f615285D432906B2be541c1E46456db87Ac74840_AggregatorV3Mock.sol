// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./AggregatorV3Interface.sol";


contract AggregatorV3Mock is AggregatorV3Interface {

  struct Round{
    uint80 round;
    int256 answer;
    uint256 startedAt;
    uint256 updatedAt;
    uint80 answeredInRound;
  }
    
    uint80 latestRound;

    mapping(uint80 => Round) public rounds;
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        Round memory lateRound = rounds[latestRound];
        return (lateRound.round, lateRound.answer, lateRound.startedAt, lateRound.updatedAt, lateRound.answeredInRound);
    }

    function changeRound(int256 amount) public {
        latestRound++;
        uint80 newRound = latestRound;
        rounds[newRound] = Round(
          newRound,
          amount,
          block.timestamp,
          block.timestamp,
          123123
        );
        
    }

    function decimals() external view override returns (uint8) {}

    function description() external view override returns (string memory) {}

    function version() external view override returns (uint256) {}

    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
       Round memory round = rounds[_roundId];
        return (round.round, round.answer, round.startedAt, round.updatedAt, round.answeredInRound);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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