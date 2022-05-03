// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./OracleConfig.sol";

import "./UniswapHelper.sol";
import "./IERC20Extended.sol";
import "./IExternalOracle.sol";

struct Observation {
    uint256 timestamp;
    uint256 acc;
}

contract Oracle is OracleConfig {
    using FixedPoint for *;

    /// @notice The number of wei in 1 ETH
    uint256 public constant ethBaseUnit = 1e18;

    /// @notice A common scaling factor to maintain precision
    uint256 public constant expScale = 1e18;

    /// @notice The precision factor of base asset's (ETH) price
    uint256 public basePricePrecision;

    /// @notice The base asset address
    address public eth;

    /// @notice Official prices by symbol hash
    mapping(address => uint256) public prices;

    /// @notice The old observation for each symbolHash
    mapping(address => Observation) public oldObservations;

    /// @notice The new observation for each symbolHash
    mapping(address => Observation) public newObservations;

    /// @notice Stores underlying address for different cTokens
    mapping(address => address) public underlyings;

    /// @notice The event emitted when the stored price is updated
    event PriceUpdated(address underlying, uint256 price);

    /// @notice The event emitted when the uniswap window changes
    event UniswapWindowUpdated(
        address indexed underlying,
        uint256 oldTimestamp,
        uint256 newTimestamp,
        uint256 oldPrice,
        uint256 newPrice
    );

    /// @notice The event emitted when the cToken underlying mapping is updated
    event CTokenUnderlyingUpdated(address cToken, address underlying);

    constructor(address baseAsset_, uint256 basePricePrecision_) public {
        require(
            basePricePrecision_ <= ethBaseUnit,
            "basePricePrecision_ max limit exceeded"
        );

        eth = baseAsset_;
        basePricePrecision = basePricePrecision_;
    }

    function _setConfig(address underlying, TokenConfig memory config) public {
        // already performs some checks
        _setConfigInternal(underlying, config);

        if (config.priceSource == PriceSource.UNISWAP) {
            address uniswapMarket = config.uniswapMarket;
            require(uniswapMarket != address(0), "must have uni market");
            if (config.isPairWithStablecoin) {
                uint8 decimals;
                // verify precision of quote currency (stablecoin)
                if (IUniswapV2Pair(uniswapMarket).token0() == underlying) {
                    decimals = IERC20(IUniswapV2Pair(uniswapMarket).token1())
                        .decimals();
                } else {
                    decimals = IERC20(IUniswapV2Pair(uniswapMarket).token0())
                        .decimals();
                }
                require(
                    10**uint256(decimals) == basePricePrecision,
                    "basePricePrecision mismatch"
                );
            }
            uint256 cumulativePrice = currentCumulativePrice(config);
            oldObservations[underlying].timestamp = block.timestamp;
            newObservations[underlying].timestamp = block.timestamp;
            oldObservations[underlying].acc = cumulativePrice;
            newObservations[underlying].acc = cumulativePrice;
            emit UniswapWindowUpdated(
                underlying,
                block.timestamp,
                block.timestamp,
                cumulativePrice,
                cumulativePrice
            );
        }
        if (config.priceSource == PriceSource.EXTERNAL_ORACLE) {
            require(
                config.externalOracle != address(0),
                "must have external oracle"
            );
        }
    }

    function _setConfigs(
        address[] memory _underlyings,
        TokenConfig[] memory _configs
    ) external {
        require(_underlyings.length == _configs.length, "length mismatch");
        for (uint256 i = 0; i < _underlyings.length; i++) {
            _setConfig(_underlyings[i], _configs[i]);
        }
    }

    function _setUnderlyingForCToken(address cToken, address underlying)
        public
    {
        require(msg.sender == admin, "Unauthorized");
        require(underlyings[cToken] == address(0), "underlying already exists");
        require(
            cToken != address(0) && underlying != address(0),
            "invalid input"
        );
        require(configExists(underlying), "token config not found");

        underlyings[cToken] = underlying;
        emit CTokenUnderlyingUpdated(cToken, underlying);
    }

    function _setUnderlyingForCTokens(
        address[] memory _cTokens,
        address[] memory _underlyings
    ) external {
        require(_cTokens.length == _underlyings.length, "length mismatch");
        for (uint256 i = 0; i < _cTokens.length; i++) {
            _setUnderlyingForCToken(_cTokens[i], _underlyings[i]);
        }
    }

    /**
     * @notice Get the official price for an underlying asset
     * @param underlying The address to fetch the price of
     * @return Price denominated in USD
     */
    function price(address underlying) public view returns (uint256) {
        return priceInternal(underlying);
    }

    function priceInternal(address underlying) internal view returns (uint256) {
        TokenConfig memory config = getTokenConfig(underlying);

        if (config.priceSource == PriceSource.UNISWAP)
            return prices[underlying];
        if (config.priceSource == PriceSource.ONE_USD)
            return basePricePrecision;
        if (config.priceSource == PriceSource.EXTERNAL_ORACLE) {
            uint8 oracleDecimals = IExternalOracle(config.externalOracle)
                .decimals();
            (, int256 answer, , , ) = IExternalOracle(config.externalOracle)
                .latestRoundData();
            require(answer > 0, "invalid answer");
            return
                mul(uint256(answer), basePricePrecision) /
                (10**uint256(oracleDecimals));
        }
    }

    /**
     * @notice Get the underlying price of a cToken
     * @dev Implements the PriceOracle interface for Compound v2.
     * @param cToken The cToken address for price retrieval
     * @return Price denominated in USD for the given cToken address
     */
    function getUnderlyingPrice(address cToken)
        external
        view
        returns (uint256)
    {
        address underlying = underlyings[cToken];
        TokenConfig memory config = getTokenConfig(underlying);

        // Comptroller needs prices in the format: ${raw price} * 1e(36 - baseUnit)
        uint256 factor = 1e36 / basePricePrecision;
        return mul(factor, priceInternal(underlying)) / config.baseUnit;
    }

    /**
     * @notice Update oracle prices
     * @param cToken The cToken address
     */
    function updatePrice(address cToken) external {
        address underlying = underlyings[cToken];
        if (underlying != address(0)) {
            updateUnderlyingPrice(underlying);
        }
    }

    /**
     * @notice Update oracle prices
     * @param underlying The underlying address
     */
    function updateUnderlyingPrice(address underlying) public {
        updateEthPrice();

        if (underlying != eth) {
            uint256 ethPrice = prices[eth];
            updatePriceInternal(underlying, ethPrice);
        }
    }

    /**
     * @notice Open function to update all prices
     */
    function updatePrices(address[] memory _underlyings) external {
        for (uint256 i = 0; i < _underlyings.length; i++) {
            updateUnderlyingPrice(_underlyings[i]);
        }
    }

    /**
     * @notice Update ETH price, and recalculate stored price by comparing to anchor
     */
    function updateEthPrice() public {
        uint256 ethPrice = fetchEthPrice();
        updatePriceInternal(eth, ethPrice);
    }

    function updatePriceInternal(address underlying, uint256 ethPrice)
        internal
    {
        TokenConfig memory config = getTokenConfig(underlying);

        if (config.priceSource == PriceSource.UNISWAP) {
            uint256 anchorPrice;
            if (underlying == eth) {
                anchorPrice = ethPrice;
            } else if (config.isPairWithStablecoin) {
                anchorPrice = fetchAnchorPrice(underlying, config, ethBaseUnit);
            } else {
                anchorPrice = fetchAnchorPrice(underlying, config, ethPrice);
            }

            prices[underlying] = anchorPrice;
            emit PriceUpdated(underlying, anchorPrice);
        }
    }

    /**
     * @dev Fetches the current token/quoteCurrency price accumulator from uniswap.
     */
    function currentCumulativePrice(TokenConfig memory config)
        internal
        view
        returns (uint256)
    {
        (
            uint256 cumulativePrice0,
            uint256 cumulativePrice1,

        ) = UniswapV2OracleLibrary.currentCumulativePrices(
                config.uniswapMarket
            );
        if (config.isUniswapReversed) {
            return cumulativePrice1;
        } else {
            return cumulativePrice0;
        }
    }

    /**
     * @dev Fetches the current eth/usd price from uniswap, with basePricePrecision as precision.
     *  Conversion factor is 1e18 for eth/usd market, since we decode uniswap price statically with 18 decimals.
     */
    function fetchEthPrice() internal returns (uint256) {
        return fetchAnchorPrice(eth, getTokenConfig(eth), ethBaseUnit);
    }

    /**
     * @dev Fetches the current token/usd price from uniswap, with basePricePrecision as precision.
     */
    function fetchAnchorPrice(
        address underlying,
        TokenConfig memory config,
        uint256 conversionFactor
    ) internal virtual returns (uint256) {
        (
            uint256 nowCumulativePrice,
            uint256 oldCumulativePrice,
            uint256 oldTimestamp
        ) = pokeWindowValues(underlying, config);

        // This should be impossible, but better safe than sorry
        require(block.timestamp > oldTimestamp, "now must come after before");
        uint256 timeElapsed = block.timestamp - oldTimestamp;

        // Calculate uniswap time-weighted average price
        // Underflow is a property of the accumulators: https://uniswap.org/audit.html#orgc9b3190
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((nowCumulativePrice - oldCumulativePrice) / timeElapsed)
        );
        uint256 rawUniswapPriceMantissa = priceAverage.decode112with18();
        uint256 unscaledPriceMantissa = mul(
            rawUniswapPriceMantissa,
            conversionFactor
        );
        uint256 anchorPrice;

        // Adjust rawUniswapPrice according to the units of the non-ETH asset
        // In the case of ETH, we would have to scale by 1e6 / USDC_UNITS, but since baseUnit2 is 1e6 (USDC), it cancels

        // In the case of non-ETH tokens
        // a. pokeWindowValues already handled uniswap reversed cases, so priceAverage will always be Token/ETH TWAP price.
        // b. conversionFactor = ETH price * 1e6
        // unscaledPriceMantissa = priceAverage(token/ETH TWAP price) * expScale * conversionFactor
        // so ->
        // anchorPrice = priceAverage * tokenBaseUnit / ethBaseUnit * ETH_price * 1e6
        //             = priceAverage * conversionFactor * tokenBaseUnit / ethBaseUnit
        //             = unscaledPriceMantissa / expScale * tokenBaseUnit / ethBaseUnit
        anchorPrice =
            mul(unscaledPriceMantissa, config.baseUnit) /
            ethBaseUnit /
            expScale;
        return anchorPrice;
    }

    /**
     * @dev Get time-weighted average prices for a token at the current timestamp.
     *  Update new and old observations of lagging window if period elapsed.
     */
    function pokeWindowValues(address underlying, TokenConfig memory config)
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 cumulativePrice = currentCumulativePrice(config);
        Observation memory newObservation = newObservations[underlying];

        // Update new and old observations if elapsed time is greater than or equal to anchor period
        uint256 timeElapsed = block.timestamp - newObservation.timestamp;
        if (timeElapsed >= config.twapPeriod) {
            oldObservations[underlying].timestamp = newObservation.timestamp;
            oldObservations[underlying].acc = newObservation.acc;

            newObservations[underlying].timestamp = block.timestamp;
            newObservations[underlying].acc = cumulativePrice;
            emit UniswapWindowUpdated(
                underlying,
                newObservation.timestamp,
                block.timestamp,
                newObservation.acc,
                cumulativePrice
            );
        }
        return (
            cumulativePrice,
            oldObservations[underlying].acc,
            oldObservations[underlying].timestamp
        );
    }

    /// @dev Overflow proof multiplication
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./Administrable.sol";

contract OracleConfig is Administrable {
    /// @dev Describe how to interpret the fixedPrice in the TokenConfig.
    enum PriceSource {
        ONE_USD, /// implies the price is 1 USD
        UNISWAP, /// implies the price is fetched from uniswap
        EXTERNAL_ORACLE /// implies the price is read externally
    }

    /// @dev Describe how the USD price should be determined for an asset.
    ///  There should be 1 TokenConfig object for each supported asset.
    struct TokenConfig {
        uint256 baseUnit;
        uint256 twapPeriod;
        address uniswapMarket;
        bool isUniswapReversed;
        bool isPairWithStablecoin;
        address externalOracle;
        PriceSource priceSource;
    }

    /// @notice The number of tokens this contract currently supports
    uint256 public numTokens;

    mapping(address => TokenConfig) internal tokenConfigs;

    function _setConfigInternal(address underlying, TokenConfig memory config)
        internal
    {
        require(msg.sender == admin, "unauthorized");
        require(tokenConfigs[underlying].baseUnit == 0, "config exists");
        require(config.baseUnit != 0, "invalid config");

        tokenConfigs[underlying] = config;
        numTokens++;
    }

    /**
     * @notice Get the config for an underlying asset
     * @param underlying The address of the underlying asset of the config to get
     * @return config The config object
     */
    function getTokenConfig(address underlying)
        public
        view
        returns (TokenConfig memory config)
    {
        require(configExists(underlying), "token config not found");
        config = tokenConfigs[underlying];
    }

    /**
     * @notice Get if the config for an underlying asset exists
     * @param underlying The address of the underlying asset of the config
     * @return exists boolean result
     */
    function configExists(address underlying)
        public
        view
        returns (bool exists)
    {
        TokenConfig memory config = tokenConfigs[underlying];
        exists = config.baseUnit != 0 ? true : false;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

// Based on code from https://github.com/Uniswap/uniswap-v2-periphery

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // returns a uq112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator)
        internal
        pure
        returns (uq112x112 memory)
    {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << 112) / denominator);
    }

    // decode a uq112x112 into a uint with 18 decimals of precision
    function decode112with18(uq112x112 memory self)
        internal
        pure
        returns (uint256)
    {
        // we only have 256 - 224 = 32 bits to spare, so scaling up by ~60 bits is dangerous
        // instead, get close to:
        //  (x * 1e18) >> 112
        // without risk of overflowing, e.g.:
        //  (x) / 2 ** (112 - lg(1e18))
        return uint256(self._x) / 5192296858534827;
    }
}

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2**32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(address pair)
        internal
        view
        returns (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        )
    {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        ) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative +=
                uint256(FixedPoint.fraction(reserve1, reserve0)._x) *
                timeElapsed;
            // counterfactual
            price1Cumulative +=
                uint256(FixedPoint.fraction(reserve0, reserve1)._x) *
                timeElapsed;
        }
    }
}

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

/**
 * @title ERC 20 Token Standard Interface
 *  https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

interface IExternalOracle {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256);

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

contract Administrable {
    /**
     * @notice Administrator for this contract
     */
    address public admin;

    /**
     * @notice Pending administrator for this contract
     */
    address public pendingAdmin;

    /**
     * @notice Emitted when pendingAdmin is changed
     */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
     * @notice Emitted when pendingAdmin is accepted, which means admin is updated
     */
    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() internal {
        // Set admin to caller
        admin = msg.sender;
    }

    /**
     * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @param newPendingAdmin New pending admin.
     * @return uint 0=success, otherwise a revert
     */
    function _setPendingAdmin(address newPendingAdmin)
        public
        returns (uint256)
    {
        // Check caller = admin
        if (msg.sender != admin) {
            revert("unauthorized");
        }

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return 0;
    }

    /**
     * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
     * @dev Admin function for pending admin to accept role and update admin
     * @return uint 0=success, otherwise a revert
     */
    function _acceptAdmin() public returns (uint256) {
        // Check caller is pendingAdmin and pendingAdmin ≠ address(0)
        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            revert("unauthorized");
        }

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

        return 0;
    }
}