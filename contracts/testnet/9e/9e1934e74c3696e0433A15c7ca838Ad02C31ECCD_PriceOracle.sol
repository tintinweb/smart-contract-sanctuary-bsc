// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../4. Interfaces/IPancakeSwap.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// USDT: 0x7ef95a0fee0dd31b22626fa2e10ee6a223f8a684
// DAI: 0x8a9424745056Eb399FD19a0EC26A14316684e274
// PairAddress: 0xaF9399F70d896dA0D56A4B2CbF95F4E90a6B99e8
// FactoryAddress: 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc

/// @title Radikal Price Oracle contract
/// @author Radikal Riders
/// @notice Provides token exchange 
/// @dev this contract interacts with every Radikals contract using tokens or with UsdtToMatic exchange
contract PriceOracle {

  // Chainlink price feed interface
  AggregatorV3Interface priceFeed;
  IPancakeSwap pancakeSwapInstance;
  constructor(
    address _pairAddress,
    address _priceFeedAddress
  ) 
  {
    pancakeSwapInstance = IPancakeSwap(_pairAddress);
    priceFeed = AggregatorV3Interface(_priceFeedAddress);
  }

  /// @dev used in MarketPlace, PVP, RewardPool, RecipesFactory, RidersFactory and RadikalLens contracts
  /// @param usdtQuantity usdt with 2 digits (e.g. 23,41 -> 2341)
  /// @return exchange  amount of radikal toknes in wei at current exchange
  function getUsdtToToken(uint usdtQuantity) external view returns(uint exchange) {
      (uint112 reserve0, uint112 reserve1, ) = pancakeSwapInstance.getReserves(); 
      return (10 ** 16) * usdtQuantity * reserve1 / reserve0;
  }
  
  /// @dev used RewardPool and RadikalLens contracts
  /// @param tokenQuantity Quantity of radikal tokens in wei to convert to Usdt
  /// @return exchange  amount of usdt with 2 digits (e.g. 23,41 -> 2341)
  function getTokenToUsdt(uint tokenQuantity) external view returns(uint exchange) {
    (uint112 reserve0, uint112 reserve1, ) = pancakeSwapInstance.getReserves(); 
    return tokenQuantity * reserve0 / ( reserve1 * (10**16) );
  }

  /// @dev used RecipesFactory and RidersFactory. This is a data feed from chainLink
  /// @return exchange  amount of usdt with 8 decimals
  function getLatestPrice() external view returns (int) {
    (
      /*uint80 roundID*/,
      int price,
      /*uint startedAt*/,
      /*uint timeStamp*/,
      /*uint80 answeredInRound*/
  ) = priceFeed.latestRoundData();
    return price; //If 1 Matcic = 200,34 it will return 20034000000
  }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeSwap {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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