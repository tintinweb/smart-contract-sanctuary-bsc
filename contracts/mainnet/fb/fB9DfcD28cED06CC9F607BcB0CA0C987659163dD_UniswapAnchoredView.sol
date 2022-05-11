// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./UniswapConfig.sol";
import "./UniswapLib.sol";
import "./Ownable.sol";

struct Observation {
    uint timestamp;
    uint acc;
}

struct PriceData {
    uint248 price;
    bool failoverActive;
}

interface AggregatorValidatorInterface {
    
    function latestAnswer() external view returns(int256);

    function latestRoundData() external view returns(uint80, int256, uint256, uint256, uint80);
    
}

contract UniswapAnchoredView is  UniswapConfig, Ownable {
    
    enum Error {
        NO_ERROR,
        ANCHOR_PRICE_TOO_LARGE_1,
        ANCHOR_PRICE_TOO_LARGE_2,
        REPORTED_PRICE_TOO_LARGE_1,
        REPORTED_PRICE_LESS_THAN_ZERO,
        MULTIPLY_ERROR
    }
    
    using FixedPoint for *;

    /// @notice The number of wei in 1 ETH
    uint public constant ethBaseUnit = 1e18;

    /// @notice A common scaling factor to maintain precision
    uint public constant expScale = 1e18;

    /// @notice The highest ratio of the new price to the anchor price that will still trigger the price to be updated
    uint public immutable upperBoundAnchorRatio;

    /// @notice The lowest ratio of the new price to the anchor price that will still trigger the price to be updated
    uint public immutable lowerBoundAnchorRatio;

    /// @notice The minimum amount of time in seconds required for the old uniswap price accumulator to be replaced
    uint public immutable anchorPeriod;

    /// @notice Official prices by symbol hash
    mapping(bytes32 => PriceData) public prices;

    /// @notice The old observation for each symbolHash
    mapping(bytes32 => Observation) public oldObservations;

    /// @notice The new observation for each symbolHash
    mapping(bytes32 => Observation) public newObservations;

    /// @notice The event emitted when new prices are posted but the stored price is not updated due to the anchor
    event PriceGuarded(bytes32 indexed symbolHash, uint reporter, uint anchor);

    /// @notice The event emitted when the stored price is updated
    event PriceUpdated(bytes32 indexed symbolHash, uint price);

    /// @notice The event emitted when anchor price is updated
    event AnchorPriceUpdated(bytes32 indexed symbolHash, uint anchorPrice, uint oldTimestamp, uint newTimestamp);

    /// @notice The event emitted when the uniswap window changes
    event UniswapWindowUpdated(bytes32 indexed symbolHash, uint oldTimestamp, uint newTimestamp, uint oldPrice, uint newPrice);

    /// @notice The event emitted when failover is activated
    event FailoverActivated(bytes32 indexed symbolHash);

    /// @notice The event emitted when failover is deactivated
    event FailoverDeactivated(bytes32 indexed symbolHash);
    
    event Fail(Error);

    bytes32 constant ethHash = 0x3ed03c38e59dc60c7b69c2a4bf68f9214acd953252b5a90e8f5f59583e9bc3ae;

    /**
     * @notice Construct a uniswap anchored view for a set of token configurations
     * @dev Note that to avoid immature TWAPs, the system must run for at least a single anchorPeriod before using.
     *      NOTE: Reported prices are set to 1 during construction. We assume that this contract will not be voted in by
     *      governance until prices have been updated through `validate` for each TokenConfig.
     * @param anchorToleranceMantissa_ The percentage tolerance that the reporter may deviate from the uniswap anchor
     * @param anchorPeriod_ The minimum amount of time required for the old uniswap price accumulator to be replaced
     * @param configs The static token configurations which define what prices are supported and how
     */
    constructor(uint anchorToleranceMantissa_,
                uint anchorPeriod_,
                TokenConfig[] memory configs) UniswapConfig(configs) public {

        anchorPeriod = anchorPeriod_;

        // Allow the tolerance to be whatever the deployer chooses, but prevent under/overflow (and prices from being 0)
        upperBoundAnchorRatio = anchorToleranceMantissa_ > uint(-1) - 100e16 ? uint(-1) : 100e16 + anchorToleranceMantissa_;
        lowerBoundAnchorRatio = anchorToleranceMantissa_ < 100e16 ? 100e16 - anchorToleranceMantissa_ : 1;

        for (uint i = 0; i < configs.length; i++) {
            TokenConfig memory config = configs[i];
            require(config.baseUnit > 0, "baseUnit must be greater than zero");
            address uniswapMarket = config.uniswapMarket;
            if (config.priceSource == PriceSource.REPORTER) {
                require(uniswapMarket != address(0), "reported prices must have an anchor");
                require(config.reporter != address(0), "reported price must have a reporter");
                bytes32 symbolHash = config.symbolHash;
                prices[symbolHash].price = 1;
                uint cumulativePrice = currentCumulativePrice(config);
                oldObservations[symbolHash].timestamp = block.timestamp;
                newObservations[symbolHash].timestamp = block.timestamp;
                oldObservations[symbolHash].acc = cumulativePrice;
                newObservations[symbolHash].acc = cumulativePrice;
                emit UniswapWindowUpdated(symbolHash, block.timestamp, block.timestamp, cumulativePrice, cumulativePrice);
            }else if (config.priceSource == PriceSource.UNISWAP) {
            require(uniswapMarket != address(0), "reported prices must have an anchor");
            bytes32 symbolHash = config.symbolHash;
            prices[symbolHash].price = 1;
            uint cumulativePrice = currentCumulativePrice(config);
            oldObservations[symbolHash].timestamp = block.timestamp;
            newObservations[symbolHash].timestamp = block.timestamp;
            oldObservations[symbolHash].acc = cumulativePrice;
            newObservations[symbolHash].acc = cumulativePrice;
            emit UniswapWindowUpdated(symbolHash, block.timestamp, block.timestamp, cumulativePrice, cumulativePrice);
            } else {
                require(uniswapMarket == address(0), "only reported prices utilize an anchor");
            }
        }
    }
    
    
    function addNewConfig(TokenConfig memory config) public onlyOwner {
        
        require(config.baseUnit > 0, "baseUnit must be greater than zero");
        
        address uniswapMarket = config.uniswapMarket;
        if (config.priceSource == PriceSource.REPORTER) {
            require(uniswapMarket != address(0), "reported prices must have an anchor");
            require(config.reporter != address(0), "reported price must have a reporter");
            bytes32 symbolHash = config.symbolHash;
            prices[symbolHash].price = 1;
            uint cumulativePrice = currentCumulativePrice(config);
            oldObservations[symbolHash].timestamp = block.timestamp;
            newObservations[symbolHash].timestamp = block.timestamp;
            oldObservations[symbolHash].acc = cumulativePrice;
            newObservations[symbolHash].acc = cumulativePrice;
            emit UniswapWindowUpdated(symbolHash, block.timestamp, block.timestamp, cumulativePrice, cumulativePrice);
        }
        else if (config.priceSource == PriceSource.UNISWAP) {
            require(uniswapMarket != address(0), "reported prices must have an anchor");
            bytes32 symbolHash = config.symbolHash;
            prices[symbolHash].price = 1;
            uint cumulativePrice = currentCumulativePrice(config);
            oldObservations[symbolHash].timestamp = block.timestamp;
            newObservations[symbolHash].timestamp = block.timestamp;
            oldObservations[symbolHash].acc = cumulativePrice;
            newObservations[symbolHash].acc = cumulativePrice;
            emit UniswapWindowUpdated(symbolHash, block.timestamp, block.timestamp, cumulativePrice, cumulativePrice);
        }
        else if (config.priceSource == PriceSource.CHAINLINK || config.priceSource == PriceSource.AUST) {
            require(uniswapMarket == address(0), "reported prices must not have an anchor");
            bytes32 symbolHash = config.symbolHash;
            prices[symbolHash].price = 1;
            emit PriceUpdated(config.symbolHash, 1);
        }
        else {
            require(uniswapMarket == address(0), "only reported prices utilize an anchor");
        }
        
        tokenConfigInfo.push(config);
        uint newIndex = tokenConfigInfo.length-1;
        
        config_exist memory new_config = config_exist({
                index:newIndex,
                exist:true
            });
        
        gTokenIndex[config.gToken] = new_config;
        underlyingTokenIndex[config.underlying] = new_config;
        symbolHashTokenIndex[config.symbolHash] = new_config;
        reporterTokenIndex[config.reporter] = new_config;
        
    }
    
    function updateConfig(TokenConfig memory config) public onlyOwner {
        
        require(gTokenIndex[config.gToken].exist,"config does not exist fo this gtoken");
        uint index = gTokenIndex[config.gToken].index;
        tokenConfigInfo[index] = config;
    }

    /**
     * @notice Get the official price for a symbol
     * @param symbol The symbol to fetch the price of
     * @return Price denominated in USD, with 6 decimals
     */
    function price(string memory symbol) external view returns (Error,uint) {
        TokenConfig memory config = getTokenConfigBySymbol(symbol);
        return priceInternal(config);
    }

    function priceInternal(TokenConfig memory config) internal view returns (Error,uint) {
        if (config.priceSource == PriceSource.REPORTER || 
        config.priceSource == PriceSource.UNISWAP || config.priceSource == PriceSource.CHAINLINK ||  config.priceSource == PriceSource.AUST) return (Error.NO_ERROR,prices[config.symbolHash].price);
        // config.fixedPrice holds a fixed-point number with scaling factor 10**6 for FIXED_USD
        if (config.priceSource == PriceSource.FIXED_USD) return (Error.NO_ERROR,config.fixedPrice);
        if (config.priceSource == PriceSource.FIXED_ETH) {
            uint usdPerEth = prices[ethHash].price;
            require(usdPerEth > 0, "ETH price not set, cannot convert to dollars");
            // config.fixedPrice holds a fixed-point number with scaling factor 10**18 for FIXED_ETH
            
            (Error error,uint ans) = mul(usdPerEth, config.fixedPrice);
            
            if(error != Error.NO_ERROR){
            return(error,0);
            }
            
            return (Error.NO_ERROR,ans / ethBaseUnit);
        }
    }

    /**
     * @notice Get the underlying price of a gToken
     * @dev Implements the PriceOracle interface for Green Planet.
     * @param gToken The gToken address for price retrieval
     * @return Price denominated in USD, with 18 decimals, for the given gToken address
     */
    function getUnderlyingPrice(address gToken) public view returns (uint) {
        TokenConfig memory config = getTokenConfigByGToken(gToken);
         // Comptroller needs prices in the format: ${raw price} * 1e36 / baseUnit
         // The baseUnit of an asset is the amount of the smallest denomination of that asset per whole.
         // For example, the baseUnit of ETH is 1e18.
         // Since the prices in this view have 6 decimals, we must scale them by 1e(36 - 6)/baseUnit
        uint256 baseUnit = getTokenConfigBySymbolHash(ethHash).gToken == config.gToken ? 1e18 : config.baseUnit;
        
        (,uint ans) = priceInternal(config);
        
        (,uint res) = mul(1e30, ans);
        
        return (res / baseUnit);
    }

    /**
     * @notice This is called when interest accrued in a market or by everyone
     * @dev called by reporter or owner
     * @param gToken address
     * @return err uint , valid bool
     */
    function validate(address gToken) external returns (Error,bool valid) {
        
        
        //Anyone can call validate if the market is calling it fetch the config using the Gtoken market address otherwise fetch the config using the gToken address given
        // NOTE: We don't do any access control on msg.sender here. The access control is done in getTokenConfigByReporter,
        // which will REVERT if an unauthorized address is passed.
        
        //check for stables
        TokenConfig memory usdConfig = getTokenConfigByGToken(gToken);
        
        if(usdConfig.priceSource == PriceSource.FIXED_USD)
        return(Error.NO_ERROR,true);
        
        TokenConfig memory config = getTokenConfigByGToken(msg.sender);
        
        config = config.gToken == msg.sender ? config : getTokenConfigByGToken(gToken);

        if(config.priceSource == PriceSource.UNISWAP){

          (,uint ethPrice) = fetchEthAnchorPrice();

          (,uint256 anchorPrice) = fetchAnchorPrice(config.symbolHash, config, ethPrice);
          prices[config.symbolHash].price = uint248(anchorPrice);
          emit PriceUpdated(config.symbolHash, anchorPrice);
          
          return(Error.NO_ERROR,true);

        }
        else if(config.priceSource == PriceSource.CHAINLINK){

          (,int256 currentAnswer,,,) = (AggregatorValidatorInterface(config.reporter).latestRoundData());
          (,uint256 reportedPrice) = convertReportedPrice(config, currentAnswer);
          prices[config.symbolHash].price = uint248(reportedPrice);
          emit PriceUpdated(config.symbolHash, reportedPrice);
          
          return(Error.NO_ERROR,true);

        }else if(config.priceSource == PriceSource.AUST){

          // get aust price from CHAINLINK
          (,int256 currentAnswer,,,) = (AggregatorValidatorInterface(config.reporter).latestRoundData());

					// get UST price from price oracle in 1e18
          uint256 ustPrice = getUnderlyingPrice(address(0xa5ae8459e710F95ca0C93d73F63a66d9996F1ACE));

		            // multiply ust price to aust price
          (, uint currentAnswerStore) = mul(uint(currentAnswer), ustPrice);

					// adjusting aust price by 1e18
          currentAnswer = int256(currentAnswerStore / 1e18);

					// converts aust price in 1e9 format
          (,uint256 reportedPrice) = convertReportedPrice(config, currentAnswer);

					// save aust price in prices array
          prices[config.symbolHash].price = uint248(reportedPrice);

					// emit priceUpdated events
          emit PriceUpdated(config.symbolHash, reportedPrice);
          
          return(Error.NO_ERROR,true);

        }

        
        (,int256 currentAnswer,,,) = (AggregatorValidatorInterface(config.reporter).latestRoundData());
        (Error error2,uint256 reportedPrice) = convertReportedPrice(config, currentAnswer);
        
        if(error2 != Error.NO_ERROR){
            emit Fail(error2);
            return(error2,false);
        }
        
        (Error error3,uint256 anchorPrice) = calculateAnchorPriceFromEthPrice(config);
        
        if(error3 != Error.NO_ERROR){
            emit Fail(error3);
            return(error3,false);
        }

        PriceData memory priceData = prices[config.symbolHash];
        if (priceData.failoverActive) {
            
            if(anchorPrice >= 2**248){
                emit Fail(Error.ANCHOR_PRICE_TOO_LARGE_2);
                return(Error.ANCHOR_PRICE_TOO_LARGE_2,false);
            }
            
            prices[config.symbolHash].price = uint248(anchorPrice);
            emit PriceUpdated(config.symbolHash, anchorPrice);
        } 
        else{
            
            (Error error4,bool ans) = isWithinAnchor(reportedPrice, anchorPrice);
            
            if(error4 != Error.NO_ERROR){
            emit Fail(error4);
            return(error4,false);
            }
            
            if (ans) {
                
                if(reportedPrice >= 2**248){
                    emit Fail(Error.REPORTED_PRICE_TOO_LARGE_1);
                    return(Error.REPORTED_PRICE_TOO_LARGE_1,false);
                    
                }
                
                prices[config.symbolHash].price = uint248(reportedPrice);
                emit PriceUpdated(config.symbolHash, reportedPrice);
                valid = true;
            } else {
                
                emit PriceGuarded(config.symbolHash, reportedPrice, anchorPrice);
                
            } 
            
        } 
        
    }

    /**
     * @notice In the event that a feed is failed over to Uniswap TWAP, this function can be called
     * by anyone to update the TWAP price.
     * @dev This only works if the feed represented by the symbolHash is failed over, and will revert otherwise
     * @param symbolHash bytes32
     */
    function pokeFailedOverPrice(bytes32 symbolHash) public returns(Error){
        PriceData memory priceData = prices[symbolHash];
        require(priceData.failoverActive, "Failover must be active");
        TokenConfig memory config = getTokenConfigBySymbolHash(symbolHash);
        (Error error,uint anchorPrice) = calculateAnchorPriceFromEthPrice(config);
        if(error != Error.NO_ERROR){
            return(error);
        }
        require(anchorPrice < 2**248, "Anchor price too large");
        prices[config.symbolHash].price = uint248(anchorPrice);
        emit PriceUpdated(config.symbolHash, anchorPrice);
        return(Error.NO_ERROR);
    }

    /**
     * @notice Calculate the anchor price by fetching price data from the TWAP
     * @param config TokenConfig
     * @return anchorPrice uint
     */
    function calculateAnchorPriceFromEthPrice(TokenConfig memory config) internal returns (Error,uint anchorPrice) {
        (Error error,uint ethPrice) = fetchEthAnchorPrice();
        
        if(error != Error.NO_ERROR){
            return(error,0);
        }
        
        require(config.priceSource == PriceSource.REPORTER, "only reporter prices get posted");
        if (config.symbolHash == ethHash) {
            anchorPrice = ethPrice;
            return(Error.NO_ERROR,anchorPrice);
        } else {
            (error,anchorPrice) = fetchAnchorPrice(config.symbolHash, config, ethPrice);
            if(error != Error.NO_ERROR){
            return(error,0);
        }
        }
    }

    /**
     * @notice Convert the reported price to the 6 decimal format that this view requires
     * @param config TokenConfig
     * @param reportedPrice from the reporter
     * @return convertedPrice uint256
     */
    function convertReportedPrice(TokenConfig memory config, int256 reportedPrice) internal view returns (Error,uint256) {
        
        if(reportedPrice < 0){
            return(Error.REPORTED_PRICE_LESS_THAN_ZERO,0);
        }
        
        uint256 unsignedPrice = uint256(reportedPrice);
        uint256 baseUnit = getTokenConfigBySymbolHash(ethHash).gToken == config.gToken ? 1e18 : config.baseUnit;
        
        (Error err,uint temp) = mul(unsignedPrice, config.reporterMultiplier);
        
        if(err != Error.NO_ERROR){
            return(err,0);
        }
            
        uint256 convertedPrice = temp / baseUnit;
        return (Error.NO_ERROR,convertedPrice);
    }


    function isWithinAnchor(uint reporterPrice, uint anchorPrice) internal view returns (Error,bool) {
        if (reporterPrice > 0) {
            
            (Error err,uint temp) = mul(anchorPrice, 100e16);
            
            if(err != Error.NO_ERROR){
            return(err,false);
            }
            
            uint anchorRatio = temp / reporterPrice;
            
            return (Error.NO_ERROR,anchorRatio <= upperBoundAnchorRatio && anchorRatio >= lowerBoundAnchorRatio);
        }
        return (Error.NO_ERROR,false);
    }

    /**
     * @dev Fetches the current token/eth price accumulator from uniswap.
     */
    function currentCumulativePrice(TokenConfig memory config) internal view returns (uint) {
        (uint cumulativePrice0, uint cumulativePrice1,) = UniswapV2OracleLibrary.currentCumulativePrices(config.uniswapMarket);
        if (config.isUniswapReversed) {
            return cumulativePrice1;
        } else {
            return cumulativePrice0;
        }
    }

    /**
     * @dev Fetches the current eth/usd price from uniswap, with 6 decimals of precision.
     *  Conversion factor is 1e18 for eth/usdc market, since we decode uniswap price statically with 18 decimals.
     */
    function fetchEthAnchorPrice() internal returns (Error,uint) {
        return fetchAnchorPrice(ethHash, getTokenConfigBySymbolHash(ethHash), ethBaseUnit);
    }

    /**
     * @dev Fetches the current token/usd price from uniswap, with 6 decimals of precision.
     * @param conversionFactor 1e18 if seeking the ETH price, and a 6 decimal ETH-USDC price in the case of other assets
     */
    function fetchAnchorPrice(bytes32 symbolHash, TokenConfig memory config, uint conversionFactor) internal virtual returns (Error,uint) {
        (uint nowCumulativePrice, uint oldCumulativePrice, uint oldTimestamp) = pokeWindowValues(config);

        // This should be impossible, but better safe than sorry
        require(block.timestamp > oldTimestamp, "now must come after before");
        
        uint timeElapsed = block.timestamp - oldTimestamp;

        // Calculate uniswap time-weighted average price
        // Underflow is a property of the accumulators: https://uniswap.org/audit.html#orgc9b3190
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(uint224((nowCumulativePrice - oldCumulativePrice) / timeElapsed));
        uint rawUniswapPriceMantissa = priceAverage.decode112with18();
        (Error error1,uint unscaledPriceMantissa) = mul(rawUniswapPriceMantissa, conversionFactor);
        if(error1 != Error.NO_ERROR){
            return(error1,0);
        }
        uint anchorPrice;

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
        
        {
            TokenConfig memory newConfig = config;
            (Error error2,uint temp) = mul(unscaledPriceMantissa, newConfig.baseUnit);
            if(error2 != Error.NO_ERROR){
                return(error2,0);
                
            }
            anchorPrice = temp / ethBaseUnit / expScale;
        }
        
        

        emit AnchorPriceUpdated(symbolHash, anchorPrice, oldTimestamp, block.timestamp);

        return (Error.NO_ERROR,anchorPrice);
    }

    /**
     * @dev Get time-weighted average prices for a token at the current timestamp.
     *  Update new and old observations of lagging window if period elapsed.
     */
    function pokeWindowValues(TokenConfig memory config) internal returns (uint, uint, uint) {
        bytes32 symbolHash = config.symbolHash;
        uint cumulativePrice = currentCumulativePrice(config);

        Observation memory newObservation = newObservations[symbolHash];

        // Update new and old observations if elapsed time is greater than or equal to anchor period
        uint timeElapsed = block.timestamp - newObservation.timestamp;
        if (timeElapsed >= anchorPeriod) {
            oldObservations[symbolHash].timestamp = newObservation.timestamp;
            oldObservations[symbolHash].acc = newObservation.acc;

            newObservations[symbolHash].timestamp = block.timestamp;
            newObservations[symbolHash].acc = cumulativePrice;
            emit UniswapWindowUpdated(config.symbolHash, newObservation.timestamp, block.timestamp, newObservation.acc, cumulativePrice);
        }
        return (cumulativePrice, oldObservations[symbolHash].acc, oldObservations[symbolHash].timestamp);
    }

    /**
     * @notice Activate failover, and fall back to using failover directly.
     * @dev Only the owner can call this function
     */
    function activateFailover(bytes32 symbolHash) external onlyOwner() {
        require(!prices[symbolHash].failoverActive, "Already activated");
        prices[symbolHash].failoverActive = true;
        emit FailoverActivated(symbolHash);
        pokeFailedOverPrice(symbolHash);
    }

    /**
     * @notice Deactivate a previously activated failover
     * @dev Only the owner can call this function
     */
    function deactivateFailover(bytes32 symbolHash) external onlyOwner() {
        require(prices[symbolHash].failoverActive, "Already deactivated");
        prices[symbolHash].failoverActive = false;
        emit FailoverDeactivated(symbolHash);
    }

    /// @dev Overflow proof multiplication
    function mul(uint a, uint b) internal pure returns (Error,uint) {
        if (a == 0) return (Error.NO_ERROR,0);
        uint c = a * b;
        
        if(c / a != b){
            return(Error.MULTIPLY_ERROR,0);
        }
    
        return (Error.NO_ERROR,c);
    }
}