//SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;

import "./IUniswapV2Pair.sol";
import "./FixedPoint.sol";
import "./UniswapV2OracleLibrary.sol";
import "./UniswapV2Library.sol";
import "./IERC20.sol";
import "./IUniswapV2Factory.sol";
import "./SafeMath.sol";

library FluronixMultiDataERC20 {
    function refactorData(address token) public view returns(string memory symbol, uint decimals) {
        decimals = IERC20(token).decimals();
        symbol = IERC20(token).symbol();
    }
}

contract FetchPoolData {
    using FixedPoint for *;
    using SafeMath for uint;

    struct PairResult {
        address pair;
        address[] token01;
        string[] token01Symbol;
        uint[] token01Decimal;
        uint[] reserves01;
        PriceOutput[] token01Price;
    }
    struct Result {
        address pool;
        uint[] reserves01;
    }
    struct PriceOutput {
        uint price;
        string inToken;
        address token;
        uint32 timeElapsed;
    }
    struct GetPair {
        address token0;
        address token1;
    }
    struct GetPriceStruct {
        address token;
        uint amountIn;
        uint decimals;
    }
    struct GetPriceMyFactoryStruct {
        address token;
        uint amountIn;
        uint decimals;
        address factory;
    }

    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // dex factory contract
    address[] private  dexFactory = [
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73, // Pancakeswap
        0x858E3312ed3A876947EA49d572A7C42DE08af7EE, // Biswap
        0x3CD1C46068dAEa5Ebb0d3f55F6915B10648062B8,// MDEX
        0x0841BD0B734E4F5853f0dD8d7Ea041c241fb0Da6, // Apeswap
        0xd6715A8be3944ec72738F0BFDC739d48C3c29349, // Nomiswap
        0x86407bEa2078ea5f5EB5A52B2caA963bC1F889Da // Babyswap
    ];

    address[] private stableCoins = [
        0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, // BUSD
        0x55d398326f99059fF775485246999027B3197955, // USDT
        0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d, // USDC
        0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3 // DAI
    ];
    string[] private symbols = ["BUSD", "USDT", "USDC", "DAI"];

    // Fetch pair info such as it's address, token0/1, symbol0/1, decimal0/1, reserves0/1, tokenPrice0/1 from a given exchange
    function fetchMultiPairs(address exchangeFactory, uint start, uint step) public view returns(PairResult[] memory pairDetails) {

        pairDetails = new PairResult[](step);

        for(uint256 i; i < step; i++) {
            // (bool success, bytes memory returnbytes) = exchangeFactory.call(abi.encodeWithSignature("allPairs(uint256)", index));
            address pair =  IUniswapV2Factory(exchangeFactory).allPairs(start + i);
            if (pair == address(0)) { // if pair is a 0x address continue to next pair in factory
                continue;
            }

            address[] memory token01 = new address[](2);
            string[] memory token01Symbol = new string[](2);
            uint[] memory token01Decimal = new uint[](2);

            // Get tokens in pair
            token01[0] = IUniswapV2Pair(pair).token0();
            token01[1] = IUniswapV2Pair(pair).token1();

            // Continue fetching next pair if the current pair token01 not found
            if (token01[0] == address(0) || token01[1] == address(0)) { 
                continue;
            }

            // Get token0 symbol & decimal
            try FluronixMultiDataERC20.refactorData(token01[0]) returns(string memory symbol, uint decimals) {
                token01Symbol[0] =  symbol;
                token01Decimal[0] = decimals;
            }
            catch {
                // If decimal or symbol not found then continue fetching next pair
                continue;
            }
            // Get token1 symbol & decimal
            try FluronixMultiDataERC20.refactorData(token01[1]) returns(string memory symbol, uint decimals) {
                token01Symbol[1] =  symbol;
                token01Decimal[1] = decimals;
            }
            catch {
                // If decimal or symbol not found then continue fetching next pair
                continue;
            }

            // Get reserves of the pair
            address[] memory pool = new address[](1);
            pool[0] = pair;
            Result[] memory reservesStruct = getMultiReserves(pool);
         
            uint[] memory reserves01;
            PriceOutput[] memory token01Price = new PriceOutput[](2);

            if (reservesStruct[0].reserves01[0] != 0 && reservesStruct[0].reserves01[1] != 0) { // If there are reserves in pool then fetch price
                reserves01 =  reservesStruct[0].reserves01;
                // Get token0/1 prices
                token01Price[0] = getPrice(token01[0], 1 * 10 ** token01Decimal[0], token01Decimal[0]); 
                token01Price[1] = getPrice(token01[1], 1 * 10 ** token01Decimal[1], token01Decimal[1]); 
            }

            // Finaly append to pairDetails array 
            pairDetails[i] = PairResult(pair, token01, token01Symbol, token01Decimal,reserves01, token01Price);
        }
    }

    // Get the total number of pairs for a given exchange 
    function getTotalNumPairs(address exchangeFactory) public view returns(uint) {
        return IUniswapV2Factory(exchangeFactory).allPairsLength();
    }

    // Get the price for given tokens
    function quoteMultiplePrice(GetPriceStruct[] memory token_amountIn_decimals) public view returns(PriceOutput[] memory prices) {
        prices = new PriceOutput[](token_amountIn_decimals.length);
        for (uint i; i < token_amountIn_decimals.length; i++) {
            prices[i] = getPrice(token_amountIn_decimals[i].token, token_amountIn_decimals[i].amountIn, token_amountIn_decimals[i].decimals);
        }
    }

    // Get the price for given tokens
    function quoteMultiplePriceMyFactory(GetPriceMyFactoryStruct[] memory token_amountIn_decimals_factory) public view returns(PriceOutput[] memory pricesFactory) {
        pricesFactory = new PriceOutput[](token_amountIn_decimals_factory.length);
        for (uint i; i < token_amountIn_decimals_factory.length; i++) {
            pricesFactory[i] = getPriceMyFactory(token_amountIn_decimals_factory[i].token, token_amountIn_decimals_factory[i].amountIn, token_amountIn_decimals_factory[i].decimals, token_amountIn_decimals_factory[i].factory);
        }
    }

    // Get the reserves for given pairs
    function getMultiReserves(address[] memory pools) public view returns(Result[] memory returnData) {
        returnData = new Result[](pools.length);
        for (uint256 i = 0; i < pools.length; i++) {
            (uint reserves0, uint reserves1, ) = IUniswapV2Pair(pools[i]).getReserves();
            uint[] memory reserves01 = new uint[](2);
            reserves01[0] = reserves0;
            reserves01[1] = reserves1;
            returnData[i] = Result(pools[i], reserves01);
        }
    }

    // Get USD price of a given token using reserves (this function was made to only be called by getPrice() function)
    function reservePrice(address token, address pair, uint decimals) public view returns(uint x) {
        (uint reserves0, uint reserves1, ) = IUniswapV2Pair(pair).getReserves(); 
        if (reserves0 == 0 || reserves1 == 0) {
            return x;
        }

        if (token == IUniswapV2Pair(pair).token0()) {
            uint x = uint(1 *10**decimals).mul(reserves1) / reserves0;
        } else {
            uint x = uint(1 *10**decimals).mul(reserves0) / reserves1;
        }
    }

    // Get USD price of a given token, if price is not available in USD then return in WBNB
    function getPrice(address token, uint amountIn, uint decimals) public view returns(PriceOutput memory out) {
        
        address Pair;
        string memory coinPicked;
        address tokennn = token;
        uint tokenDecimals = decimals;
        uint amountUsed = amountIn;

        // Search dexFactory list for a pair so that we can calculate USD price
        for (uint x = 0; x < dexFactory.length; x++) {
            // Loop through stable coins array to get the pair from the given token
            for (uint i = 0; i < stableCoins.length; i++) {
                Pair  = IUniswapV2Factory(dexFactory[x]).getPair(token, stableCoins[i]);
                if (Pair != address(0)) {
                    coinPicked = symbols[i];
                    break;
                }   
            } 
            if (Pair != address(0)){break;}  
        }

        if (Pair == address(0)) { // If pair does not exist then pair with WBNB
            for (uint x = 0; x < dexFactory.length; x++) {
                Pair = IUniswapV2Factory(dexFactory[x]).getPair(token, WBNB);
                if (Pair != address(0)) {
                    coinPicked = "WBNB";
                    break;
                }    
            }
        }

        if (Pair == address(0)) { // Finally if no pair is available then just return an empty struct
            return out;
        }
        
        (, , uint32 blockTimestampLast) = IUniswapV2Pair(Pair).getReserves();
        if (blockTimestampLast == 0) {
            return out;
        }

        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(Pair);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        FixedPoint.uq112x112 memory price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - IUniswapV2Pair(Pair).price0CumulativeLast()) / timeElapsed));
        FixedPoint.uq112x112 memory price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - IUniswapV2Pair(Pair).price1CumulativeLast()) / timeElapsed));

        address pairToo = Pair;

        // Calculate price using TWAP, if the price == 0 or timeElapsed == 0 then use pair's reserves to calc price
        if (tokennn == IUniswapV2Pair(Pair).token0()) {

            uint price = price0Average.mul(amountUsed).decode144();
            out = PriceOutput(price, coinPicked, tokennn, timeElapsed);

            if (price == 0 || timeElapsed == 0) {
                
                uint x = reservePrice(tokennn, pairToo, tokenDecimals);
                out = PriceOutput(x, coinPicked, tokennn, timeElapsed);
            }

        } else {

            uint price = price1Average.mul(amountUsed).decode144();
            out = PriceOutput(price, coinPicked, tokennn, timeElapsed);

            if (price == 0 || timeElapsed == 0) {
                uint x = reservePrice(tokennn, pairToo, tokenDecimals);
                out = PriceOutput(x, coinPicked, tokennn, timeElapsed);
            }
        }
    }

    // Get USD price of a given token, if price is not available in USD then return in WBNB
    function getPriceMyFactory(address token, uint amountIn, uint decimals, address myFactory) public view returns(PriceOutput memory out) {
        
        address Pair;
        string memory coinPicked;
        address tokennn = token;
        uint tokenDecimals = decimals;
        uint amountUsed = amountIn;

        // Search myFactory list for a pair so that we can calculate USD price
        for (uint x = 0; x < 1; x++) {
            // Loop through stable coins array to get the pair from the given token
            for (uint i = 0; i < stableCoins.length; i++) {
                Pair  = IUniswapV2Factory(myFactory).getPair(token, stableCoins[i]);
                if (Pair != address(0)) {
                    coinPicked = symbols[i];
                    break;
                }   
            } 
            if (Pair != address(0)){break;}  
        }

        if (Pair == address(0)) { // If pair does not exist then pair with WBNB
            for (uint x = 0; x < 1; x++) {
                Pair = IUniswapV2Factory(myFactory).getPair(token, WBNB);
                if (Pair != address(0)) {
                    coinPicked = "WBNB";
                    break;
                }    
            }
        }

        if (Pair == address(0)) { // Finally if no pair is available then just return an empty struct
            return out;
        }
        
        (, , uint32 blockTimestampLast) = IUniswapV2Pair(Pair).getReserves();
        if (blockTimestampLast == 0) {
            return out;
        }

        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(Pair);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        FixedPoint.uq112x112 memory price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - IUniswapV2Pair(Pair).price0CumulativeLast()) / timeElapsed));
        FixedPoint.uq112x112 memory price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - IUniswapV2Pair(Pair).price1CumulativeLast()) / timeElapsed));

        address pairToo = Pair;

        // Calculate price using TWAP, if the price == 0 or timeElapsed == 0 then use pair's reserves to calc price
        if (tokennn == IUniswapV2Pair(Pair).token0()) {

            uint price = price0Average.mul(amountUsed).decode144();
            out = PriceOutput(price, coinPicked, tokennn, timeElapsed);

            if (price == 0 || timeElapsed == 0) {
                
                uint x = reservePrice(tokennn, pairToo, tokenDecimals);
                out = PriceOutput(x, coinPicked, tokennn, timeElapsed);
            }

        } else {

            uint price = price1Average.mul(amountUsed).decode144();
            out = PriceOutput(price, coinPicked, tokennn, timeElapsed);

            if (price == 0 || timeElapsed == 0) {
                uint x = reservePrice(tokennn, pairToo, tokenDecimals);
                out = PriceOutput(x, coinPicked, tokennn, timeElapsed);
            }
        }
    }

    // Get multiple pair addresses from a given dex by token addresses
    function getMultiPair(address exchangeFactory, GetPair[] memory address01) public view returns(address[] memory pairArray) {
        pairArray = new address[](address01.length);
        for (uint i; i< address01.length; i++) {
            pairArray[i] = IUniswapV2Factory(exchangeFactory).getPair(address01[i].token0, address01[i].token1);
        }
    }
}