// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import './interfaces/IAlgebraFactory.sol';
import './interfaces/IDataStorageOperator.sol';

import './libraries/DataStorage.sol';
import './libraries/Sqrt.sol';
import './libraries/AdaptiveFee.sol';

import './libraries/Constants.sol';

contract DataStorageOperator is IDataStorageOperator {
  uint256 constant UINT16_MODULO = 65536;
  uint128 constant MAX_VOLUME_PER_LIQUIDITY = 100000 << 64; // maximum meaningful ratio of volume to liquidity

  using DataStorage for DataStorage.Timepoint[UINT16_MODULO];

  DataStorage.Timepoint[UINT16_MODULO] public override timepoints;
  AdaptiveFee.Configuration public feeConfig;

  address private immutable pool;
  address private immutable factory;

  modifier onlyPool() {
    require(msg.sender == pool, 'only pool can call this');
    _;
  }

  constructor(address _pool) {
    factory = msg.sender;
    pool = _pool;
  }

  /// @inheritdoc IDataStorageOperator
  function initialize(uint32 time, int24 tick) external override onlyPool {
    return timepoints.initialize(time, tick);
  }

  /// @inheritdoc IDataStorageOperator
  function changeFeeConfiguration(AdaptiveFee.Configuration calldata _feeConfig) external override {
    require(msg.sender == factory || msg.sender == IAlgebraFactory(factory).owner());

    require(uint256(_feeConfig.alpha1) + uint256(_feeConfig.alpha2) + uint256(_feeConfig.baseFee) <= type(uint16).max, 'Max fee exceeded');
    require(_feeConfig.gamma1 != 0 && _feeConfig.gamma2 != 0 && _feeConfig.volumeGamma != 0, 'Gammas must be > 0');

    feeConfig = _feeConfig;
    emit FeeConfiguration(_feeConfig);
  }

  /// @inheritdoc IDataStorageOperator
  function getSingleTimepoint(
    uint32 time,
    uint32 secondsAgo,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    external
    view
    override
    onlyPool
    returns (
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulative,
      uint112 volatilityCumulative,
      uint256 volumePerAvgLiquidity
    )
  {
    uint16 oldestIndex;
    // check if we have overflow in the past
    uint16 nextIndex = index + 1; // considering overflow
    if (timepoints[nextIndex].initialized) {
      oldestIndex = nextIndex;
    }

    DataStorage.Timepoint memory result = timepoints.getSingleTimepoint(time, secondsAgo, tick, index, oldestIndex, liquidity);
    (tickCumulative, secondsPerLiquidityCumulative, volatilityCumulative, volumePerAvgLiquidity) = (
      result.tickCumulative,
      result.secondsPerLiquidityCumulative,
      result.volatilityCumulative,
      result.volumePerLiquidityCumulative
    );
  }

  /// @inheritdoc IDataStorageOperator
  function getTimepoints(
    uint32 time,
    uint32[] memory secondsAgos,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    external
    view
    override
    onlyPool
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives,
      uint112[] memory volatilityCumulatives,
      uint256[] memory volumePerAvgLiquiditys
    )
  {
    return timepoints.getTimepoints(time, secondsAgos, tick, index, liquidity);
  }

  /// @inheritdoc IDataStorageOperator
  function getAverages(
    uint32 time,
    int24 tick,
    uint16 index,
    uint128 liquidity
  ) external view override onlyPool returns (uint112 TWVolatilityAverage, uint256 TWVolumePerLiqAverage) {
    return timepoints.getAverages(time, tick, index, liquidity);
  }

  /// @inheritdoc IDataStorageOperator
  function write(
    uint16 index,
    uint32 blockTimestamp,
    int24 tick,
    uint128 liquidity,
    uint128 volumePerLiquidity
  ) external override onlyPool returns (uint16 indexUpdated) {
    return timepoints.write(index, blockTimestamp, tick, liquidity, volumePerLiquidity);
  }

  /// @inheritdoc IDataStorageOperator
  function calculateVolumePerLiquidity(
    uint128 liquidity,
    int256 amount0,
    int256 amount1
  ) external pure override returns (uint128 volumePerLiquidity) {
    uint256 volume = Sqrt.sqrtAbs(amount0) * Sqrt.sqrtAbs(amount1);
    uint256 volumeShifted;
    if (volume >= 2**192) volumeShifted = (type(uint256).max) / (liquidity > 0 ? liquidity : 1);
    else volumeShifted = (volume << 64) / (liquidity > 0 ? liquidity : 1);
    if (volumeShifted >= MAX_VOLUME_PER_LIQUIDITY) return MAX_VOLUME_PER_LIQUIDITY;
    else return uint128(volumeShifted);
  }

  /// @inheritdoc IDataStorageOperator
  function window() external pure override returns (uint32) {
    return DataStorage.WINDOW;
  }

  /// @inheritdoc IDataStorageOperator
  function getFee(
    uint32 _time,
    int24 _tick,
    uint16 _index,
    uint128 _liquidity
  ) external view override onlyPool returns (uint16 fee) {
    (uint88 volatilityAverage, uint256 volumePerLiqAverage) = timepoints.getAverages(_time, _tick, _index, _liquidity);

    return AdaptiveFee.getFee(volatilityAverage / 15, volumePerLiqAverage, feeConfig);
  }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/**
 * @title The interface for the Algebra Factory
 * @dev Credit to Uniswap Labs under GPL-2.0-or-later license:
 * https://github.com/Uniswap/v3-core/tree/main/contracts/interfaces
 */
interface IAlgebraFactory {
  /**
   *  @notice Emitted when the owner of the factory is changed
   *  @param newOwner The owner after the owner was changed
   */
  event Owner(address indexed newOwner);

  /**
   *  @notice Emitted when the vault address is changed
   *  @param newVaultAddress The vault address after the address was changed
   */
  event VaultAddress(address indexed newVaultAddress);

  /**
   *  @notice Emitted when a pool is created
   *  @param token0 The first token of the pool by address sort order
   *  @param token1 The second token of the pool by address sort order
   *  @param pool The address of the created pool
   */
  event Pool(address indexed token0, address indexed token1, address pool);

  /**
   *  @notice Emitted when the farming address is changed
   *  @param newFarmingAddress The farming address after the address was changed
   */
  event FarmingAddress(address indexed newFarmingAddress);

  event FeeConfiguration(
    uint16 alpha1,
    uint16 alpha2,
    uint32 beta1,
    uint32 beta2,
    uint16 gamma1,
    uint16 gamma2,
    uint32 volumeBeta,
    uint16 volumeGamma,
    uint16 baseFee
  );

  /**
   *  @notice Returns the current owner of the factory
   *  @dev Can be changed by the current owner via setOwner
   *  @return The address of the factory owner
   */
  function owner() external view returns (address);

  /**
   *  @notice Returns the current poolDeployerAddress
   *  @return The address of the poolDeployer
   */
  function poolDeployer() external view returns (address);

  /**
   * @dev Is retrieved from the pools to restrict calling
   * certain functions not by a tokenomics contract
   * @return The tokenomics contract address
   */
  function farmingAddress() external view returns (address);

  function vaultAddress() external view returns (address);

  /**
   *  @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
   *  @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
   *  @param tokenA The contract address of either token0 or token1
   *  @param tokenB The contract address of the other token
   *  @return pool The pool address
   */
  function poolByPair(address tokenA, address tokenB) external view returns (address pool);

  /**
   *  @notice Creates a pool for the given two tokens and fee
   *  @param tokenA One of the two tokens in the desired pool
   *  @param tokenB The other of the two tokens in the desired pool
   *  @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0. tickSpacing is retrieved
   *  from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
   *  are invalid.
   *  @return pool The address of the newly created pool
   */
  function createPool(address tokenA, address tokenB) external returns (address pool);

  /**
   *  @notice Updates the owner of the factory
   *  @dev Must be called by the current owner
   *  @param _owner The new owner of the factory
   */
  function setOwner(address _owner) external;

  /**
   * @dev updates tokenomics address on the factory
   * @param _farmingAddress The new tokenomics contract address
   */
  function setFarmingAddress(address _farmingAddress) external;

  /**
   * @dev updates vault address on the factory
   * @param _vaultAddress The new vault contract address
   */
  function setVaultAddress(address _vaultAddress) external;

  /**
   * @notice Changes initial fee configuration for new pools
   * @dev changes coefficients for sigmoids: α / (1 + e^( (β-x) / γ))
   * alpha1 + alpha2 + baseFee (max possible fee) must be <= type(uint16).max
   * gammas must be > 0
   * @param alpha1 max value of the first sigmoid
   * @param alpha2 max value of the second sigmoid
   * @param beta1 shift along the x-axis for the first sigmoid
   * @param beta2 shift along the x-axis for the second sigmoid
   * @param gamma1 horizontal stretch factor for the first sigmoid
   * @param gamma2 horizontal stretch factor for the second sigmoid
   * @param volumeBeta shift along the x-axis for the outer volume-sigmoid
   * @param volumeGamma horizontal stretch factor the outer volume-sigmoid
   * @param baseFee minimum possible fee
   */
  function setBaseFeeConfiguration(
    uint16 alpha1,
    uint16 alpha2,
    uint32 beta1,
    uint32 beta2,
    uint16 gamma1,
    uint16 gamma2,
    uint32 volumeBeta,
    uint16 volumeGamma,
    uint16 baseFee
  ) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;
pragma abicoder v2;

import '../libraries/AdaptiveFee.sol';

interface IDataStorageOperator {
  event FeeConfiguration(AdaptiveFee.Configuration feeConfig);

  /**
   * @notice Returns data belonging to a certain timepoint
   * @param index The index of timepoint in the array
   * @dev There is more convenient function to fetch a timepoint: getTimepoints(). Which requires not an index but seconds
   * @return initialized Whether the timepoint has been initialized and the values are safe to use,
   * blockTimestamp The timestamp of the observation,
   * tickCumulative The tick multiplied by seconds elapsed for the life of the pool as of the timepoint timestamp,
   * secondsPerLiquidityCumulative The seconds per in range liquidity for the life of the pool as of the timepoint timestamp,
   * volatilityCumulative Cumulative standard deviation for the life of the pool as of the timepoint timestamp,
   * averageTick Time-weighted average tick,
   * volumePerLiquidityCumulative Cumulative swap volume per liquidity for the life of the pool as of the timepoint timestamp
   */
  function timepoints(uint256 index)
    external
    view
    returns (
      bool initialized,
      uint32 blockTimestamp,
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulative,
      uint88 volatilityCumulative,
      int24 averageTick,
      uint144 volumePerLiquidityCumulative
    );

  /// @notice Initialize the dataStorage array by writing the first slot. Called once for the lifecycle of the timepoints array
  /// @param time The time of the dataStorage initialization, via block.timestamp truncated to uint32
  /// @param tick Initial tick
  function initialize(uint32 time, int24 tick) external;

  /// @dev Reverts if an timepoint at or before the desired timepoint timestamp does not exist.
  /// 0 may be passed as `secondsAgo' to return the current cumulative values.
  /// If called with a timestamp falling between two timepoints, returns the counterfactual accumulator values
  /// at exactly the timestamp between the two timepoints.
  /// @param time The current block timestamp
  /// @param secondsAgo The amount of time to look back, in seconds, at which point to return an timepoint
  /// @param tick The current tick
  /// @param index The index of the timepoint that was most recently written to the timepoints array
  /// @param liquidity The current in-range pool liquidity
  /// @return tickCumulative The cumulative tick since the pool was first initialized, as of `secondsAgo`
  /// @return secondsPerLiquidityCumulative The cumulative seconds / max(1, liquidity) since the pool was first initialized, as of `secondsAgo`
  /// @return volatilityCumulative The cumulative volatility value since the pool was first initialized, as of `secondsAgo`
  /// @return volumePerAvgLiquidity The cumulative volume per liquidity value since the pool was first initialized, as of `secondsAgo`
  function getSingleTimepoint(
    uint32 time,
    uint32 secondsAgo,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    external
    view
    returns (
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulative,
      uint112 volatilityCumulative,
      uint256 volumePerAvgLiquidity
    );

  /// @notice Returns the accumulator values as of each time seconds ago from the given time in the array of `secondsAgos`
  /// @dev Reverts if `secondsAgos` > oldest timepoint
  /// @param time The current block.timestamp
  /// @param secondsAgos Each amount of time to look back, in seconds, at which point to return an timepoint
  /// @param tick The current tick
  /// @param index The index of the timepoint that was most recently written to the timepoints array
  /// @param liquidity The current in-range pool liquidity
  /// @return tickCumulatives The cumulative tick since the pool was first initialized, as of each `secondsAgo`
  /// @return secondsPerLiquidityCumulatives The cumulative seconds / max(1, liquidity) since the pool was first initialized, as of each `secondsAgo`
  /// @return volatilityCumulatives The cumulative volatility values since the pool was first initialized, as of each `secondsAgo`
  /// @return volumePerAvgLiquiditys The cumulative volume per liquidity values since the pool was first initialized, as of each `secondsAgo`
  function getTimepoints(
    uint32 time,
    uint32[] memory secondsAgos,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    external
    view
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives,
      uint112[] memory volatilityCumulatives,
      uint256[] memory volumePerAvgLiquiditys
    );

  /// @notice Returns average volatility in the range from time-WINDOW to time
  /// @param time The current block.timestamp
  /// @param tick The current tick
  /// @param index The index of the timepoint that was most recently written to the timepoints array
  /// @param liquidity The current in-range pool liquidity
  /// @return TWVolatilityAverage The average volatility in the recent range
  /// @return TWVolumePerLiqAverage The average volume per liquidity in the recent range
  function getAverages(
    uint32 time,
    int24 tick,
    uint16 index,
    uint128 liquidity
  ) external view returns (uint112 TWVolatilityAverage, uint256 TWVolumePerLiqAverage);

  /// @notice Writes an dataStorage timepoint to the array
  /// @dev Writable at most once per block. Index represents the most recently written element. index must be tracked externally.
  /// @param index The index of the timepoint that was most recently written to the timepoints array
  /// @param blockTimestamp The timestamp of the new timepoint
  /// @param tick The active tick at the time of the new timepoint
  /// @param liquidity The total in-range liquidity at the time of the new timepoint
  /// @param volumePerLiquidity The gmean(volumes)/liquidity at the time of the new timepoint
  /// @return indexUpdated The new index of the most recently written element in the dataStorage array
  function write(
    uint16 index,
    uint32 blockTimestamp,
    int24 tick,
    uint128 liquidity,
    uint128 volumePerLiquidity
  ) external returns (uint16 indexUpdated);

  /// @notice Changes fee configuration for the pool
  function changeFeeConfiguration(AdaptiveFee.Configuration calldata feeConfig) external;

  /// @notice Calculates gmean(volume/liquidity) for block
  /// @param liquidity The current in-range pool liquidity
  /// @param amount0 Total amount of swapped token0
  /// @param amount1 Total amount of swapped token1
  /// @return volumePerLiquidity gmean(volume/liquidity) capped by 100000 << 64
  function calculateVolumePerLiquidity(
    uint128 liquidity,
    int256 amount0,
    int256 amount1
  ) external pure returns (uint128 volumePerLiquidity);

  /// @return windowLength Length of window used to calculate averages
  function window() external view returns (uint32 windowLength);

  /// @notice Calculates fee based on combination of sigmoids
  /// @param time The current block.timestamp
  /// @param tick The current tick
  /// @param index The index of the timepoint that was most recently written to the timepoints array
  /// @param liquidity The current in-range pool liquidity
  /// @return fee The fee in hundredths of a bip, i.e. 1e-6
  function getFee(
    uint32 time,
    int24 tick,
    uint16 index,
    uint128 liquidity
  ) external view returns (uint16 fee);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import './Constants.sol';

/// @title AdaptiveFee
/// @notice Calculates fee based on combination of sigmoids
library AdaptiveFee {
  // alpha1 + alpha2 + baseFee must be <= type(uint16).max
  struct Configuration {
    uint16 alpha1; // max value of the first sigmoid
    uint16 alpha2; // max value of the second sigmoid
    uint32 beta1; // shift along the x-axis for the first sigmoid
    uint32 beta2; // shift along the x-axis for the second sigmoid
    uint16 gamma1; // horizontal stretch factor for the first sigmoid
    uint16 gamma2; // horizontal stretch factor for the second sigmoid
    uint32 volumeBeta; // shift along the x-axis for the outer volume-sigmoid
    uint16 volumeGamma; // horizontal stretch factor the outer volume-sigmoid
    uint16 baseFee; // minimum possible fee
  }

  /// @notice Calculates fee based on formula:
  /// baseFee + sigmoidVolume(sigmoid1(volatility, volumePerLiquidity) + sigmoid2(volatility, volumePerLiquidity))
  /// maximum value capped by baseFee + alpha1 + alpha2
  function getFee(
    uint88 volatility,
    uint256 volumePerLiquidity,
    Configuration memory config
  ) internal pure returns (uint16 fee) {
    uint256 sumOfSigmoids = sigmoid(volatility, config.gamma1, config.alpha1, config.beta1) +
      sigmoid(volatility, config.gamma2, config.alpha2, config.beta2);

    if (sumOfSigmoids > type(uint16).max) {
      // should be impossible, just in case
      sumOfSigmoids = type(uint16).max;
    }

    return uint16(config.baseFee + sigmoid(volumePerLiquidity, config.volumeGamma, uint16(sumOfSigmoids), config.volumeBeta)); // safe since alpha1 + alpha2 + baseFee _must_ be <= type(uint16).max
  }

  /// @notice calculates α / (1 + e^( (β-x) / γ))
  /// that is a sigmoid with a maximum value of α, x-shifted by β, and stretched by γ
  /// @dev returns uint256 for fuzzy testing. Guaranteed that the result is not greater than alpha
  function sigmoid(
    uint256 x,
    uint16 g,
    uint16 alpha,
    uint256 beta
  ) internal pure returns (uint256 res) {
    if (x > beta) {
      x = x - beta;
      if (x >= 6 * uint256(g)) return alpha; // so x < 19 bits
      uint256 g8 = uint256(g)**8; // < 128 bits (8*16)
      uint256 ex = exp(x, g, g8); // < 155 bits
      res = (alpha * ex) / (g8 + ex); // in worst case: (16 + 155 bits) / 155 bits
      // so res <= alpha
    } else {
      x = beta - x;
      if (x >= 6 * uint256(g)) return 0; // so x < 19 bits
      uint256 g8 = uint256(g)**8; // < 128 bits (8*16)
      uint256 ex = g8 + exp(x, g, g8); // < 156 bits
      res = (alpha * g8) / ex; // in worst case: (16 + 128 bits) / 156 bits
      // g8 <= ex, so res <= alpha
    }
  }

  /// @notice calculates e^(x/g) * g^8 in a series, since (around zero):
  /// e^x = 1 + x + x^2/2 + ... + x^n/n! + ...
  /// e^(x/g) = 1 + x/g + x^2/(2*g^2) + ... + x^(n)/(g^n * n!) + ...
  function exp(
    uint256 x,
    uint16 g,
    uint256 gHighestDegree
  ) internal pure returns (uint256 res) {
    // calculating:
    // g**8 + x * g**7 + (x**2 * g**6) / 2 + (x**3 * g**5) / 6 + (x**4 * g**4) / 24 + (x**5 * g**3) / 120 + (x**6 * g^2) / 720 + x**7 * g / 5040 + x**8 / 40320

    // x**8 < 152 bits (19*8) and g**8 < 128 bits (8*16)
    // so each summand < 152 bits and res < 155 bits
    uint256 xLowestDegree = x;
    res = gHighestDegree; // g**8

    gHighestDegree /= g; // g**7
    res += xLowestDegree * gHighestDegree;

    gHighestDegree /= g; // g**6
    xLowestDegree *= x; // x**2
    res += (xLowestDegree * gHighestDegree) / 2;

    gHighestDegree /= g; // g**5
    xLowestDegree *= x; // x**3
    res += (xLowestDegree * gHighestDegree) / 6;

    gHighestDegree /= g; // g**4
    xLowestDegree *= x; // x**4
    res += (xLowestDegree * gHighestDegree) / 24;

    gHighestDegree /= g; // g**3
    xLowestDegree *= x; // x**5
    res += (xLowestDegree * gHighestDegree) / 120;

    gHighestDegree /= g; // g**2
    xLowestDegree *= x; // x**6
    res += (xLowestDegree * gHighestDegree) / 720;

    xLowestDegree *= x; // x**7
    res += (xLowestDegree * g) / 5040 + (xLowestDegree * x) / (40320);
  }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

library Constants {
  uint8 internal constant RESOLUTION = 96;
  uint256 internal constant Q96 = 0x1000000000000000000000000;
  uint256 internal constant Q128 = 0x100000000000000000000000000000000;
  // fee value in hundredths of a bip, i.e. 1e-6
  uint16 internal constant BASE_FEE = 500;
  int24 internal constant TICK_SPACING = 60;

  // max(uint128) / ( (MAX_TICK - MIN_TICK) / TICK_SPACING )
  uint128 internal constant MAX_LIQUIDITY_PER_TICK = 11505743598341114571880798222544994;

  uint32 internal constant MAX_LIQUIDITY_COOLDOWN = 1 days;
  uint8 internal constant MAX_COMMUNITY_FEE = 250;
  uint256 internal constant COMMUNITY_FEE_DENOMINATOR = 1000;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import './FullMath.sol';

/// @title DataStorage
/// @notice Provides price, liquidity, volatility data useful for a wide variety of system designs
/// @dev Instances of stored dataStorage data, "timepoints", are collected in the dataStorage array
/// Timepoints are overwritten when the full length of the dataStorage array is populated.
/// The most recent timepoint is available by passing 0 to getSingleTimepoint()
library DataStorage {
  uint32 public constant WINDOW = 1 days;
  uint256 private constant UINT16_MODULO = 65536;
  struct Timepoint {
    bool initialized; // whether or not the timepoint is initialized
    uint32 blockTimestamp; // the block timestamp of the timepoint
    int56 tickCumulative; // the tick accumulator, i.e. tick * time elapsed since the pool was first initialized
    uint160 secondsPerLiquidityCumulative; // the seconds per liquidity since the pool was first initialized
    uint88 volatilityCumulative; // the volatility accumulator; overflow after ~34800 years is desired :)
    int24 averageTick; // average tick at this blockTimestamp
    uint144 volumePerLiquidityCumulative; // the gmean(volumes)/liquidity accumulator
  }

  /// @notice Calculates volatility between two sequential timepoints with resampling to 1 sec frequency
  /// @param dt Timedelta between timepoints, must be within uint32 range
  /// @param tick0 The tick at the left timepoint, must be within int24 range
  /// @param tick1 The tick at the right timepoint, must be within int24 range
  /// @param avgTick0 The average tick at the left timepoint, must be within int24 range
  /// @param avgTick1 The average tick at the right timepoint, must be within int24 range
  /// @return volatility The volatility between two sequential timepoints
  /// If the requirements for the parameters are met, it always fits 88 bits
  function _volatilityOnRange(
    int256 dt,
    int256 tick0,
    int256 tick1,
    int256 avgTick0,
    int256 avgTick1
  ) internal pure returns (uint256 volatility) {
    // On the time interval from the previous timepoint to the current
    // we can represent tick and average tick change as two straight lines:
    // tick = k*t + b, where k and b are some constants
    // avgTick = p*t + q, where p and q are some constants
    // we want to get sum of (tick(t) - avgTick(t))^2 for every t in the interval (0; dt]
    // so: (tick(t) - avgTick(t))^2 = ((k*t + b) - (p*t + q))^2 = (k-p)^2 * t^2 + 2(k-p)(b-q)t + (b-q)^2
    // since everything except t is a constant, we need to use progressions for t and t^2:
    // sum(t) for t from 1 to dt = dt*(dt + 1)/2 = sumOfSequence
    // sum(t^2) for t from 1 to dt = dt*(dt+1)*(2dt + 1)/6 = sumOfSquares
    // so result will be: (k-p)^2 * sumOfSquares + 2(k-p)(b-q)*sumOfSequence + dt*(b-q)^2
    int256 K = (tick1 - tick0) - (avgTick1 - avgTick0); // (k - p)*dt
    int256 B = (tick0 - avgTick0) * dt; // (b - q)*dt
    int256 sumOfSquares = (dt * (dt + 1) * (2 * dt + 1)); // sumOfSquares * 6
    int256 sumOfSequence = (dt * (dt + 1)); // sumOfSequence * 2
    volatility = uint256((K**2 * sumOfSquares + 6 * B * K * sumOfSequence + 6 * dt * B**2) / (6 * dt**2));
  }

  /// @notice Transforms a previous timepoint into a new timepoint, given the passage of time and the current tick and liquidity values
  /// @dev blockTimestamp _must_ be chronologically equal to or greater than last.blockTimestamp, safe for 0 or 1 overflows
  /// @param last The specified timepoint to be used in creation of new timepoint
  /// @param blockTimestamp The timestamp of the new timepoint
  /// @param tick The active tick at the time of the new timepoint
  /// @param prevTick The active tick at the time of the last timepoint
  /// @param liquidity The total in-range liquidity at the time of the new timepoint
  /// @param averageTick The average tick at the time of the new timepoint
  /// @param volumePerLiquidity The gmean(volumes)/liquidity at the time of the new timepoint
  /// @return Timepoint The newly populated timepoint
  function createNewTimepoint(
    Timepoint memory last,
    uint32 blockTimestamp,
    int24 tick,
    int24 prevTick,
    uint128 liquidity,
    int24 averageTick,
    uint128 volumePerLiquidity
  ) private pure returns (Timepoint memory) {
    uint32 delta = blockTimestamp - last.blockTimestamp;

    last.initialized = true;
    last.blockTimestamp = blockTimestamp;
    last.tickCumulative += int56(tick) * delta;
    last.secondsPerLiquidityCumulative += ((uint160(delta) << 128) / (liquidity > 0 ? liquidity : 1)); // just timedelta if liquidity == 0
    last.volatilityCumulative += uint88(_volatilityOnRange(delta, prevTick, tick, last.averageTick, averageTick)); // always fits 88 bits
    last.averageTick = averageTick;
    last.volumePerLiquidityCumulative += volumePerLiquidity;

    return last;
  }

  /// @notice comparator for 32-bit timestamps
  /// @dev safe for 0 or 1 overflows, a and b _must_ be chronologically before or equal to currentTime
  /// @param a A comparison timestamp from which to determine the relative position of `currentTime`
  /// @param b From which to determine the relative position of `currentTime`
  /// @param currentTime A timestamp truncated to 32 bits
  /// @return res Whether `a` is chronologically <= `b`
  function lteConsideringOverflow(
    uint32 a,
    uint32 b,
    uint32 currentTime
  ) private pure returns (bool res) {
    res = a > currentTime;
    if (res == b > currentTime) res = a <= b; // if both are on the same side
  }

  /// @dev guaranteed that the result is within the bounds of int24
  /// returns int256 for fuzzy tests
  function _getAverageTick(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    int24 tick,
    uint16 index,
    uint16 oldestIndex,
    uint32 lastTimestamp,
    int56 lastTickCumulative
  ) internal view returns (int256 avgTick) {
    uint32 oldestTimestamp = self[oldestIndex].blockTimestamp;
    int56 oldestTickCumulative = self[oldestIndex].tickCumulative;

    if (lteConsideringOverflow(oldestTimestamp, time - WINDOW, time)) {
      if (lteConsideringOverflow(lastTimestamp, time - WINDOW, time)) {
        index -= 1; // considering underflow
        Timepoint storage startTimepoint = self[index];
        avgTick = startTimepoint.initialized
          ? (lastTickCumulative - startTimepoint.tickCumulative) / (lastTimestamp - startTimepoint.blockTimestamp)
          : tick;
      } else {
        Timepoint memory startOfWindow = getSingleTimepoint(self, time, WINDOW, tick, index, oldestIndex, 0);

        //    current-WINDOW  last   current
        // _________*____________*_______*_
        //           ||||||||||||
        avgTick = (lastTickCumulative - startOfWindow.tickCumulative) / (lastTimestamp - time + WINDOW);
      }
    } else {
      avgTick = (lastTimestamp == oldestTimestamp) ? tick : (lastTickCumulative - oldestTickCumulative) / (lastTimestamp - oldestTimestamp);
    }
  }

  /// @notice Fetches the timepoints beforeOrAt and atOrAfter a target, i.e. where [beforeOrAt, atOrAfter] is satisfied.
  /// The result may be the same timepoint, or adjacent timepoints.
  /// @dev The answer must be contained in the array, used when the target is located within the stored timepoint
  /// boundaries: older than the most recent timepoint and younger, or the same age as, the oldest timepoint
  /// @param self The stored dataStorage array
  /// @param time The current block.timestamp
  /// @param target The timestamp at which the reserved timepoint should be for
  /// @param lastIndex The index of the timepoint that was most recently written to the timepoints array
  /// @param oldestIndex The index of the oldest timepoint in the timepoints array
  /// @return beforeOrAt The timepoint recorded before, or at, the target
  /// @return atOrAfter The timepoint recorded at, or after, the target
  function binarySearch(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    uint32 target,
    uint16 lastIndex,
    uint16 oldestIndex
  ) private view returns (Timepoint storage beforeOrAt, Timepoint storage atOrAfter) {
    uint256 left = oldestIndex; // oldest timepoint
    uint256 right = lastIndex >= oldestIndex ? lastIndex : lastIndex + UINT16_MODULO; // newest timepoint considering one index overflow
    uint256 current = (left + right) >> 1; // "middle" point between the boundaries

    do {
      beforeOrAt = self[uint16(current)]; // checking the "middle" point between the boundaries
      (bool initializedBefore, uint32 timestampBefore) = (beforeOrAt.initialized, beforeOrAt.blockTimestamp);
      if (initializedBefore) {
        if (lteConsideringOverflow(timestampBefore, target, time)) {
          // is current point before or at `target`?
          atOrAfter = self[uint16(current + 1)]; // checking the next point after "middle"
          (bool initializedAfter, uint32 timestampAfter) = (atOrAfter.initialized, atOrAfter.blockTimestamp);
          if (initializedAfter) {
            if (lteConsideringOverflow(target, timestampAfter, time)) {
              // is the "next" point after or at `target`?
              return (beforeOrAt, atOrAfter); // the only fully correct way to finish
            }
            left = current + 1; // "next" point is before the `target`, so looking in the right half
          } else {
            // beforeOrAt is initialized and <= target, and next timepoint is uninitialized
            // should be impossible if initial boundaries and `target` are correct
            return (beforeOrAt, beforeOrAt);
          }
        } else {
          right = current - 1; // current point is after the `target`, so looking in the left half
        }
      } else {
        // we've landed on an uninitialized timepoint, keep searching higher
        // should be impossible if initial boundaries and `target` are correct
        left = current + 1;
      }
      current = (left + right) >> 1; // calculating the new "middle" point index after updating the bounds
    } while (true);

    atOrAfter = beforeOrAt; // code is unreachable, to suppress compiler warning
    assert(false);
  }

  /// @dev Reverts if an timepoint at or before the desired timepoint timestamp does not exist.
  /// 0 may be passed as `secondsAgo' to return the current cumulative values.
  /// If called with a timestamp falling between two timepoints, returns the counterfactual accumulator values
  /// at exactly the timestamp between the two timepoints.
  /// @param self The stored dataStorage array
  /// @param time The current block timestamp
  /// @param secondsAgo The amount of time to look back, in seconds, at which point to return an timepoint
  /// @param tick The current tick
  /// @param index The index of the timepoint that was most recently written to the timepoints array
  /// @param oldestIndex The index of the oldest timepoint
  /// @param liquidity The current in-range pool liquidity
  /// @return targetTimepoint desired timepoint or it's approximation
  function getSingleTimepoint(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    uint32 secondsAgo,
    int24 tick,
    uint16 index,
    uint16 oldestIndex,
    uint128 liquidity
  ) internal view returns (Timepoint memory targetTimepoint) {
    uint32 target = time - secondsAgo;

    // if target is newer than last timepoint
    if (secondsAgo == 0 || lteConsideringOverflow(self[index].blockTimestamp, target, time)) {
      Timepoint memory last = self[index];
      if (last.blockTimestamp == target) {
        return last;
      } else {
        // otherwise, we need to add new timepoint
        int24 avgTick = int24(_getAverageTick(self, time, tick, index, oldestIndex, last.blockTimestamp, last.tickCumulative));
        int24 prevTick = tick;
        {
          if (index != oldestIndex) {
            Timepoint memory prevLast;
            Timepoint storage _prevLast = self[index - 1]; // considering index underflow
            prevLast.blockTimestamp = _prevLast.blockTimestamp;
            prevLast.tickCumulative = _prevLast.tickCumulative;
            prevTick = int24((last.tickCumulative - prevLast.tickCumulative) / (last.blockTimestamp - prevLast.blockTimestamp));
          }
        }
        return createNewTimepoint(last, target, tick, prevTick, liquidity, avgTick, 0);
      }
    }

    require(lteConsideringOverflow(self[oldestIndex].blockTimestamp, target, time), 'OLD');
    (Timepoint memory beforeOrAt, Timepoint memory atOrAfter) = binarySearch(self, time, target, index, oldestIndex);

    if (target == atOrAfter.blockTimestamp) {
      return atOrAfter; // we're at the right boundary
    }

    if (target != beforeOrAt.blockTimestamp) {
      // we're in the middle
      uint32 timepointTimeDelta = atOrAfter.blockTimestamp - beforeOrAt.blockTimestamp;
      uint32 targetDelta = target - beforeOrAt.blockTimestamp;

      // For gas savings the resulting point is written to beforeAt
      beforeOrAt.tickCumulative += ((atOrAfter.tickCumulative - beforeOrAt.tickCumulative) / timepointTimeDelta) * targetDelta;
      beforeOrAt.secondsPerLiquidityCumulative += uint160(
        (uint256(atOrAfter.secondsPerLiquidityCumulative - beforeOrAt.secondsPerLiquidityCumulative) * targetDelta) / timepointTimeDelta
      );
      beforeOrAt.volatilityCumulative += ((atOrAfter.volatilityCumulative - beforeOrAt.volatilityCumulative) / timepointTimeDelta) * targetDelta;
      beforeOrAt.volumePerLiquidityCumulative +=
        ((atOrAfter.volumePerLiquidityCumulative - beforeOrAt.volumePerLiquidityCumulative) / timepointTimeDelta) *
        targetDelta;
    }

    // we're at the left boundary or at the middle
    return beforeOrAt;
  }

  /// @notice Returns the accumulator values as of each time seconds ago from the given time in the array of `secondsAgos`
  /// @dev Reverts if `secondsAgos` > oldest timepoint
  /// @param self The stored dataStorage array
  /// @param time The current block.timestamp
  /// @param secondsAgos Each amount of time to look back, in seconds, at which point to return an timepoint
  /// @param tick The current tick
  /// @param index The index of the timepoint that was most recently written to the timepoints array
  /// @param liquidity The current in-range pool liquidity
  /// @return tickCumulatives The tick * time elapsed since the pool was first initialized, as of each `secondsAgo`
  /// @return secondsPerLiquidityCumulatives The cumulative seconds / max(1, liquidity) since the pool was first initialized, as of each `secondsAgo`
  /// @return volatilityCumulatives The cumulative volatility values since the pool was first initialized, as of each `secondsAgo`
  /// @return volumePerAvgLiquiditys The cumulative volume per liquidity values since the pool was first initialized, as of each `secondsAgo`
  function getTimepoints(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    uint32[] memory secondsAgos,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    internal
    view
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives,
      uint112[] memory volatilityCumulatives,
      uint256[] memory volumePerAvgLiquiditys
    )
  {
    tickCumulatives = new int56[](secondsAgos.length);
    secondsPerLiquidityCumulatives = new uint160[](secondsAgos.length);
    volatilityCumulatives = new uint112[](secondsAgos.length);
    volumePerAvgLiquiditys = new uint256[](secondsAgos.length);

    uint16 oldestIndex;
    // check if we have overflow in the past
    uint16 nextIndex = index + 1; // considering overflow
    if (self[nextIndex].initialized) {
      oldestIndex = nextIndex;
    }

    Timepoint memory current;
    for (uint256 i = 0; i < secondsAgos.length; i++) {
      current = getSingleTimepoint(self, time, secondsAgos[i], tick, index, oldestIndex, liquidity);
      (tickCumulatives[i], secondsPerLiquidityCumulatives[i], volatilityCumulatives[i], volumePerAvgLiquiditys[i]) = (
        current.tickCumulative,
        current.secondsPerLiquidityCumulative,
        current.volatilityCumulative,
        current.volumePerLiquidityCumulative
      );
    }
  }

  /// @notice Returns average volatility in the range from time-WINDOW to time
  /// @param self The stored dataStorage array
  /// @param time The current block.timestamp
  /// @param tick The current tick
  /// @param index The index of the timepoint that was most recently written to the timepoints array
  /// @param liquidity The current in-range pool liquidity
  /// @return volatilityAverage The average volatility in the recent range
  /// @return volumePerLiqAverage The average volume per liquidity in the recent range
  function getAverages(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    int24 tick,
    uint16 index,
    uint128 liquidity
  ) internal view returns (uint88 volatilityAverage, uint256 volumePerLiqAverage) {
    uint16 oldestIndex;
    Timepoint storage oldest = self[0];
    uint16 nextIndex = index + 1; // considering overflow
    if (self[nextIndex].initialized) {
      oldest = self[nextIndex];
      oldestIndex = nextIndex;
    }

    Timepoint memory endOfWindow = getSingleTimepoint(self, time, 0, tick, index, oldestIndex, liquidity);

    uint32 oldestTimestamp = oldest.blockTimestamp;
    if (lteConsideringOverflow(oldestTimestamp, time - WINDOW, time)) {
      Timepoint memory startOfWindow = getSingleTimepoint(self, time, WINDOW, tick, index, oldestIndex, liquidity);
      return (
        (endOfWindow.volatilityCumulative - startOfWindow.volatilityCumulative) / WINDOW,
        uint256(endOfWindow.volumePerLiquidityCumulative - startOfWindow.volumePerLiquidityCumulative) >> 57
      );
    } else if (time != oldestTimestamp) {
      uint88 _oldestVolatilityCumulative = oldest.volatilityCumulative;
      uint144 _oldestVolumePerLiquidityCumulative = oldest.volumePerLiquidityCumulative;
      return (
        (endOfWindow.volatilityCumulative - _oldestVolatilityCumulative) / (time - oldestTimestamp),
        uint256(endOfWindow.volumePerLiquidityCumulative - _oldestVolumePerLiquidityCumulative) >> 57
      );
    }
  }

  /// @notice Initialize the dataStorage array by writing the first slot. Called once for the lifecycle of the timepoints array
  /// @param self The stored dataStorage array
  /// @param time The time of the dataStorage initialization, via block.timestamp truncated to uint32
  /// @param tick Initial tick
  function initialize(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    int24 tick
  ) internal {
    require(!self[0].initialized);
    self[0].initialized = true;
    self[0].blockTimestamp = time;
    self[0].averageTick = tick;
  }

  /// @notice Writes an dataStorage timepoint to the array
  /// @dev Writable at most once per block. Index represents the most recently written element. index must be tracked externally.
  /// @param self The stored dataStorage array
  /// @param index The index of the timepoint that was most recently written to the timepoints array
  /// @param blockTimestamp The timestamp of the new timepoint
  /// @param tick The active tick at the time of the new timepoint
  /// @param liquidity The total in-range liquidity at the time of the new timepoint
  /// @param volumePerLiquidity The gmean(volumes)/liquidity at the time of the new timepoint
  /// @return indexUpdated The new index of the most recently written element in the dataStorage array
  function write(
    Timepoint[UINT16_MODULO] storage self,
    uint16 index,
    uint32 blockTimestamp,
    int24 tick,
    uint128 liquidity,
    uint128 volumePerLiquidity
  ) internal returns (uint16 indexUpdated) {
    Timepoint storage _last = self[index];
    // early return if we've already written an timepoint this block
    if (_last.blockTimestamp == blockTimestamp) {
      return index;
    }
    Timepoint memory last = _last;

    // get next index considering overflow
    indexUpdated = index + 1;

    uint16 oldestIndex;
    // check if we have overflow in the past
    if (self[indexUpdated].initialized) {
      oldestIndex = indexUpdated;
    }

    int24 avgTick = int24(_getAverageTick(self, blockTimestamp, tick, index, oldestIndex, last.blockTimestamp, last.tickCumulative));
    int24 prevTick = tick;
    if (index != oldestIndex) {
      Timepoint storage _prevLast = self[index - 1]; // considering index underflow
      uint32 _prevLastBlockTimestamp = _prevLast.blockTimestamp;
      int56 _prevLastTickCumulative = _prevLast.tickCumulative;
      prevTick = int24((last.tickCumulative - _prevLastTickCumulative) / (last.blockTimestamp - _prevLastBlockTimestamp));
    }

    self[indexUpdated] = createNewTimepoint(last, blockTimestamp, tick, prevTick, liquidity, avgTick, volumePerLiquidity);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0 || ^0.5.0 || ^0.6.0 || ^0.7.0;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
  /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
  /// @param a The multiplicand
  /// @param b The multiplier
  /// @param denominator The divisor
  /// @return result The 256-bit result
  /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
  function mulDiv(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {
    // 512-bit multiply [prod1 prod0] = a * b
    // Compute the product mod 2**256 and mod 2**256 - 1
    // then use the Chinese Remainder Theorem to reconstruct
    // the 512 bit result. The result is stored in two 256
    // variables such that product = prod1 * 2**256 + prod0
    uint256 prod0 = a * b; // Least significant 256 bits of the product
    uint256 prod1; // Most significant 256 bits of the product
    assembly {
      let mm := mulmod(a, b, not(0))
      prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    // Make sure the result is less than 2**256.
    // Also prevents denominator == 0
    require(denominator > prod1);

    // Handle non-overflow cases, 256 by 256 division
    if (prod1 == 0) {
      assembly {
        result := div(prod0, denominator)
      }
      return result;
    }

    ///////////////////////////////////////////////
    // 512 by 256 division.
    ///////////////////////////////////////////////

    // Make division exact by subtracting the remainder from [prod1 prod0]
    // Compute remainder using mulmod
    // Subtract 256 bit remainder from 512 bit number
    assembly {
      let remainder := mulmod(a, b, denominator)
      prod1 := sub(prod1, gt(remainder, prod0))
      prod0 := sub(prod0, remainder)
    }

    // Factor powers of two out of denominator
    // Compute largest power of two divisor of denominator.
    // Always >= 1.
    uint256 twos = -denominator & denominator;
    // Divide denominator by power of two
    assembly {
      denominator := div(denominator, twos)
    }

    // Divide [prod1 prod0] by the factors of two
    assembly {
      prod0 := div(prod0, twos)
    }
    // Shift in bits from prod1 into prod0. For this we need
    // to flip `twos` such that it is 2**256 / twos.
    // If twos is zero, then it becomes one
    assembly {
      twos := add(div(sub(0, twos), twos), 1)
    }
    prod0 |= prod1 * twos;

    // Invert denominator mod 2**256
    // Now that denominator is an odd number, it has an inverse
    // modulo 2**256 such that denominator * inv = 1 mod 2**256.
    // Compute the inverse by starting with a seed that is correct
    // correct for four bits. That is, denominator * inv = 1 mod 2**4
    uint256 inv = (3 * denominator) ^ 2;
    // Now use Newton-Raphson iteration to improve the precision.
    // Thanks to Hensel's lifting lemma, this also works in modular
    // arithmetic, doubling the correct bits in each step.
    inv *= 2 - denominator * inv; // inverse mod 2**8
    inv *= 2 - denominator * inv; // inverse mod 2**16
    inv *= 2 - denominator * inv; // inverse mod 2**32
    inv *= 2 - denominator * inv; // inverse mod 2**64
    inv *= 2 - denominator * inv; // inverse mod 2**128
    inv *= 2 - denominator * inv; // inverse mod 2**256

    // Because the division is now exact we can divide by multiplying
    // with the modular inverse of denominator. This will give us the
    // correct result modulo 2**256. Since the preconditions guarantee
    // that the outcome is less than 2**256, this is the final result.
    // We don't need to compute the high bits of the result and prod1
    // is no longer required.
    result = prod0 * inv;
    return result;
  }

  /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
  /// @param a The multiplicand
  /// @param b The multiplier
  /// @param denominator The divisor
  /// @return result The 256-bit result
  function mulDivRoundingUp(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {
    if (a == 0 || ((result = a * b) / a == b)) {
      require(denominator > 0);
      assembly {
        result := add(div(result, denominator), gt(mod(result, denominator), 0))
      }
    } else {
      result = mulDiv(a, b, denominator);
      if (mulmod(a, b, denominator) > 0) {
        require(result < type(uint256).max);
        result++;
      }
    }
  }

  /// @notice Returns ceil(x / y)
  /// @dev division by 0 has unspecified behavior, and must be checked externally
  /// @param x The dividend
  /// @param y The divisor
  /// @return z The quotient, ceil(x / y)
  function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
    assembly {
      z := add(div(x, y), gt(mod(x, y), 0))
    }
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.5.0 || ^0.6.0 || ^0.7.0 || ^0.8.0;

library Sqrt {
  /// @notice Gets the square root of the absolute value of the parameter
  function sqrtAbs(int256 _x) internal pure returns (uint256 result) {
    // get abs value
    int256 mask = _x >> (256 - 1);
    uint256 x = uint256((_x ^ mask) - mask);
    if (x == 0) result = 0;
    else {
      uint256 xx = x;
      uint256 r = 1;
      if (xx >= 0x100000000000000000000000000000000) {
        xx >>= 128;
        r <<= 64;
      }
      if (xx >= 0x10000000000000000) {
        xx >>= 64;
        r <<= 32;
      }
      if (xx >= 0x100000000) {
        xx >>= 32;
        r <<= 16;
      }
      if (xx >= 0x10000) {
        xx >>= 16;
        r <<= 8;
      }
      if (xx >= 0x100) {
        xx >>= 8;
        r <<= 4;
      }
      if (xx >= 0x10) {
        xx >>= 4;
        r <<= 2;
      }
      if (xx >= 0x8) {
        r <<= 1;
      }
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1; // @dev Seven iterations should be enough.
      uint256 r1 = x / r;
      result = r < r1 ? r : r1;
    }
  }
}