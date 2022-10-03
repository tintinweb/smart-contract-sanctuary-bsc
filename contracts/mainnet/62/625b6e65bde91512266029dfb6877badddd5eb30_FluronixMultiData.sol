// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;

//import "hardhat/console.sol";
import "./PancakeLibrary.sol";
import "./IPancakeFactory.sol";
import "./IERC20.sol";
import "./IPancakePair.sol";
import "./UniswapV2OracleLibrary.sol";
import './FixedPoint.sol';

contract FluronixMultiData{
    using FixedPoint for *;
    
    struct Result {
        bool success;
        address pool;
        uint[] reserves01;
    }
    struct PriceOutput {
        uint price;
        string inToken;
        address token;
    }
    struct PairResult {
        address pair;
        address[2] token01;
        string[2] token01Symbol;
        uint[2] token01Decimal;
        uint[] reserves01;
        PriceOutput[] token01Price;
    }

    struct GetPair{
        address token0;
        address token1;
    }

    // dex factory contract
    address[] private  dexFactory = [
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73, //Pancakeswap
        0x0841BD0B734E4F5853f0dD8d7Ea041c241fb0Da6, //Apeswap
        0x858E3312ed3A876947EA49d572A7C42DE08af7EE, //Biswap
        0x3CD1C46068dAEa5Ebb0d3f55F6915B10648062B8,//Mdex
        0x86407bEa2078ea5f5EB5A52B2caA963bC1F889Da //Babyswap
    ];

    address[] private  stableCoins =[
        0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, //BUSD
        0x55d398326f99059fF775485246999027B3197955, //USDT
        0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d, //USDC
        0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3 //DAI
    ];

    address private immutable WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    string[] private symbols =["BUSD", "USDT", "USDC","DAI"];
    

    // get the reserves from the given pairs
    function getMultiReserves(bool requireSuccess, address[] memory pools) public returns (Result[] memory returnData) {
        returnData = new Result[](pools.length);
        for(uint256 i = 0; i < pools.length; i++) {
            (bool success, bytes memory returnValue) = pools[i].call(abi.encodeWithSignature("getReserves()"));

            if (requireSuccess) {
                require(success, "Fluronix getMultiReserves: call failed");
            }
            uint[] memory reserves01 = new uint[](2);
            if(success){
                (uint reserves0, uint reserves1,) = abi.decode(returnValue, (uint, uint, uint));
                reserves01[0] = reserves0;
                reserves01[1] = reserves1;
            } 

            returnData[i] = Result(success, pools[i], reserves01);
        }
    }

    //Fetch multiple Pairs from a given exchange
    address[2] private token01;
    string[2] private token01Symbol;
    uint[2] private token01Decimal;
    function fetchMultiPairs(address exchangeFactory, uint start, uint stop) public  returns(PairResult[] memory pairDetails){
        require( stop > start, "Fluronix fetchMultiPairs: Start number must be less than stop number");
        uint range = stop - start;
        pairDetails = new PairResult[](range);

        uint count = 0;
        for(uint256 i = start; i < stop; i++) {

            address pair = IPancakeFactory(exchangeFactory).allPairs(i);
            if (pair == address(0)){// if index out of range
                continue;
            }
            // get tokens in pair
            (bool token0Success, bytes memory token0return) = pair.call(abi.encodeWithSignature("token0()"));
            (bool token1Success, bytes memory token1return) = pair.call(abi.encodeWithSignature("token1()"));
            if (token0Success == false || token1Success == false){ // continue fetching other pairs if the current pair token01 not found
                continue;
            }
            // decode bytes
            token01[0] = abi.decode(token0return, (address));
            token01[1] = abi.decode(token1return, (address));
            // get tokens symbols
            token01Symbol[0] =  IERC20(token01[0]).symbol();
            token01Symbol[1] =  IERC20(token01[1]).symbol();
            //get tokens decimals
            token01Decimal[0] = IERC20(token01[0]).decimals();
            token01Decimal[1] = IERC20(token01[1]).decimals();
            //get reserves of the pair
            address[] memory pool = new address[](1);
            pool[0] = pair;
            Result[] memory reservesStruct = getMultiReserves(false, pool);
         
            uint[] memory reserves01;
            PriceOutput[] memory token01Price = new PriceOutput[](2);

            if(reservesStruct[0].success){// if sucessfully fetched reserves
                reserves01 =  reservesStruct[0].reserves01;
                //get token01 prices
                token01Price[0] = getPrice(token01[0], 1 * 10 ** token01Decimal[0]); 
                token01Price[1] = getPrice(token01[1], 1 * 10 ** token01Decimal[1]); 
            }

            // finaly append to pairDetails array 
            pairDetails[count] = PairResult(pair, token01, token01Symbol, token01Decimal,reserves01, token01Price);
            count++;
        }
    }

    //get price of all the given tokens 
    function getMultiplePrice(address[] memory token, uint[] memory amountIn) public returns (PriceOutput[] memory prices){
        require(token.length == amountIn.length, "Fluronix getMultiplePrice: The number of token addresses should be the same number of amountIn");
        prices = new PriceOutput[](token.length);
        for(uint i = 0; i < token.length; i++){
            prices[i] = getPrice(token[i], amountIn[i]);
        }

    }

    // get multiple pair address from a given dex by  token addresses
    function getMultiPair(address exchangeFactory, GetPair[] memory address01 ) public view returns (address[] memory pairArray)  {
        pairArray = new address[](address01.length);
        for(uint i =0; i< address01.length; i++){
            pairArray[i] = IPancakeFactory(exchangeFactory).getPair(address01[i].token0, address01[i].token1);
        }

    }

    //Get USD price of a given token, if price not available in USD then return in BNB
    address private Pair;
    string private coinPicked;
    function getPrice(address token, uint amountIn)public  returns (PriceOutput memory out){
        //seearch dexFactory for pair so we can calculate USD price
        for(uint x = 0; x < dexFactory.length; x++){
            // loop through stable coins array to get the pair from the user token
            for(uint i=0; i < stableCoins.length; i++){
                    Pair  = IPancakeFactory(dexFactory[x]).getPair(token, stableCoins[i]);
                    if(Pair != address(0)){
                        coinPicked = symbols[i];
                        break;
                    }   
            } 
            if(Pair != address(0)){break;}  
        }

       if(Pair == address(0)){// if pair does not exit then pair with WBNB
            for(uint x = 0; x < dexFactory.length; x++){
                Pair  = IPancakeFactory(dexFactory[x]).getPair(token, WBNB);
                if(Pair != address(0)){
                    coinPicked = "WBNB";
                    break;
                }    
            }

       }
       if(Pair == address(0)){ //finally if non is available just return empty struct
        return out;
       }
        

        uint price0CumulativeLast = IPancakePair(Pair).price0CumulativeLast();
        uint price1CumulativeLast = IPancakePair(Pair).price1CumulativeLast();
        if(price0CumulativeLast ==0 || price1CumulativeLast == 0){
            return out;
        }
        (, , uint32 blockTimestampLast) = IPancakePair(Pair).getReserves();
        address token0 = IPancakePair(Pair).token0();



        ( uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(Pair);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        FixedPoint.uq112x112 memory price0Average = FixedPoint.uq112x112(
        uint224((price0Cumulative - price0CumulativeLast) / timeElapsed)
        );
        FixedPoint.uq112x112 memory price1Average = FixedPoint.uq112x112(
            uint224((price1Cumulative - price1CumulativeLast) / timeElapsed)
        );

        if (token == token0) {

            // NOTE: using FixedPoint for *
            // NOTE: mul returns uq144x112
            // NOTE: decode144 decodes uq144x112 to uint144
            out = PriceOutput(price0Average.mul(amountIn).decode144(), coinPicked, token);
        } else {
            out = PriceOutput(price1Average.mul(amountIn).decode144(), coinPicked, token);
        }
    }

}