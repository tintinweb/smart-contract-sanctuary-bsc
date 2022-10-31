/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


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

// File: 1_Storage_flat.sol


pragma solidity >=0.4.22 <0.9.0;


contract PriceConsumerV3 {

    AggregatorV3Interface internal USDCpriceFeed;
    AggregatorV3Interface internal USDTpriceFeed;
    AggregatorV3Interface internal BNBpriceFeed;

    /**
     * Network: BSC
     * USDC: 0x51597f405303c4377e36123cbc172b13269ea163
     * USDT: 0xb97ad0e74fa7d920791e90258a6e2085088b4320
     * BNB: 0x0567f2323251f0aab15c8dfb1967e4e8a7d42aee
     */
    constructor(address _usdcFeed, address _usdtFeed, address _bnbFeed) {
        USDCpriceFeed = AggregatorV3Interface(_usdcFeed);
        USDTpriceFeed = AggregatorV3Interface(_usdtFeed);
        BNBpriceFeed = AggregatorV3Interface(_bnbFeed);
    }

    /**
     * Returns the usdc latest price
     */
    function getUSDCLatestPrice() public view returns (uint256) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = USDCpriceFeed.latestRoundData();
        return uint256(price);
    }
    /**
     * Returns the usdc latest price
     */
    function getUSDTLatestPrice() public view returns (uint256) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = USDTpriceFeed.latestRoundData();
        return uint256(price);
    }
    /**
     * Returns the usdc latest price
     */
    function getBLatestPrice() public view returns (uint256) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = BNBpriceFeed.latestRoundData();
        return uint256(price);
    }
}