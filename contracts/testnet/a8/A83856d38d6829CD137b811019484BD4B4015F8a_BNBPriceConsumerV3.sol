/**
 *Submitted for verification at BscScan.com on 2022-12-28
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

// File: BNBpricefeed.sol


pragma solidity ^0.8.7;


contract BNBPriceConsumerV3 {
    AggregatorV3Interface internal BNBFeed;
    AggregatorV3Interface internal DAIFeed;
    AggregatorV3Interface internal USDCFeed;
    AggregatorV3Interface internal USDTFeed;
    /**
     * Network: BNB test network
     * Aggregator: BNB/USD
     * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
     */
    constructor() {
        BNBFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        DAIFeed= AggregatorV3Interface(0xE4eE17114774713d2De0eC0f035d4F7665fc025D);  //DAI
        USDCFeed = AggregatorV3Interface(0x90c069C4538adAc136E051052E14c1cD799C41B7);  //USDC
        USDTFeed = AggregatorV3Interface(0xEca2605f0BCF2BA5966372C99837b1F182d3D620);   //usdt
    }

    
    function getBNB_Price() public view returns (int) {
        ( , int price ,,,) = BNBFeed.latestRoundData();
        return price;
    }
    
    function getUSDC_Price() public view returns (int) {
        (   , int price ,,,) = USDCFeed.latestRoundData();
        return price;
    }
     function getDAI_Price() public view returns (int) {
        (  , int price ,,,) = DAIFeed.latestRoundData();
        return price;
    }
    function getUSDT_Price() public view returns (int) {
        (  , int price ,,,) = USDTFeed.latestRoundData();
        return price;
    }
}