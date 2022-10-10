// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;


import "./PancakeLibrary.sol";
import "./IPancakeFactory.sol";
import "./IERC20.sol";
import "./IPancakePair.sol";
import "./UniswapV2OracleLibrary.sol";
import "./FixedPoint.sol";
import "./SafeMath.sol";

contract FluronixMultiData{
    using FixedPoint for *;
    using SafeMath for uint;
    
    struct Result {
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
    struct GetPrice{
        address token;
        uint decimal;
    }


    // dex factory contract
    address[] private  dexFactory = [
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73, //Pancakeswap
        0x0841BD0B734E4F5853f0dD8d7Ea041c241fb0Da6, //Apeswap
        0x858E3312ed3A876947EA49d572A7C42DE08af7EE, //Biswap
        0x3CD1C46068dAEa5Ebb0d3f55F6915B10648062B8,//Mdex
        0x86407bEa2078ea5f5EB5A52B2caA963bC1F889Da, //Babyswap
        0xd6715A8be3944ec72738F0BFDC739d48C3c29349, //Nomiswap
        0xf0bc2E21a76513aa7CC2730C7A1D6deE0790751f //Knightswap
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
    function getMultiReserves(address[] memory pools) public view returns (Result[] memory returnData) {
        returnData = new Result[](pools.length);
        for(uint256 i = 0; i < pools.length; i++) {
            (uint reserves0, uint reserves1, ) = IPancakePair(pools[i]).getReserves();
            uint[] memory reserves01 = new uint[](2);
            reserves01[0] = reserves0;
            reserves01[1] = reserves1;
            returnData[i] = Result(pools[i], reserves01);
        }
    }

    //Fetch multiple Pairs from a given exchange
    function fetchMultiPairs(address exchangeFactory, uint start, uint step) public view returns(PairResult[] memory pairDetails){

        pairDetails = new PairResult[](step);
        //uint count;
        for(uint256 i; i < step; i++) {
            uint index = start + i;
            address pair = IPancakeFactory(exchangeFactory).allPairs(index);
            if (pair == address(0)){// if pair not fetched
                continue;
            }
            address[2] memory token01;
            string[2] memory token01Symbol;
            uint[2] memory token01Decimal;

            // get tokens in pair
            token01[0] = IPancakePair(pair).token0();
            token01[1] = IPancakePair(pair).token1();
            // continue fetching other pairs if the current pair token01 not found
            if (token01[0] == address(0) || token01[1] == address(0)){ 
                continue;
            }
            // get tokens symbols
            token01Symbol[0] =  IERC20(token01[0]).symbol();
            token01Symbol[1] =  IERC20(token01[1]).symbol();
            //get tokens decimals
            token01Decimal[0] = IERC20(token01[0]).decimals();
            token01Decimal[1] = IERC20(token01[1]).decimals();
            // if decimal or symbol not found then continue fetching other pairs

            if(keccak256(abi.encodePacked(token01Symbol[0])) == keccak256(abi.encodePacked("")) ||
             keccak256(abi.encodePacked(token01Symbol[1])) == keccak256(abi.encodePacked("")) ||
              token01Decimal[0] == 0 || token01Decimal[1]== 0){
                continue;
            }

            //get reserves of the pair
            address[] memory pool = new address[](1);
            pool[0] = pair;
            Result[] memory reservesStruct = getMultiReserves(pool);
         
            uint[] memory reserves01;
            PriceOutput[] memory token01Price = new PriceOutput[](2);

            if(reservesStruct[0].reserves01[0] != 0 && reservesStruct[0].reserves01[1] != 0){// if they are reserves in pool then fetch price
                reserves01 =  reservesStruct[0].reserves01;
                //get token01 prices
                token01Price[0] = quotePrice(token01[0], token01Decimal[0],false); 
                token01Price[1] = quotePrice(token01[1], token01Decimal[1], false); 
            }

            // finaly append to pairDetails array 
            pairDetails[i] = PairResult(pair, token01, token01Symbol, token01Decimal,reserves01, token01Price);
            //count++;
        }
    }

    // get multiple pair address from a given dex by  token addresses
    function getMultiPair(address exchangeFactory, GetPair[] memory address01 ) public view returns (address[] memory pairArray)  {
        pairArray = new address[](address01.length);
        for(uint i; i< address01.length; i++){
            pairArray[i] = IPancakeFactory(exchangeFactory).getPair(address01[i].token0, address01[i].token1);
        }

    }

    //get the total number of pairs in a given exchange 
    function getTotalNumPairs(address exchangeFactory) public view returns(uint){
        return  IPancakeFactory(exchangeFactory).allPairsLength();
    }

    //get price of all the given tokens 
    function quoteMultiplePrice(GetPrice[] memory token_decimal) public view returns (PriceOutput[] memory prices){
        prices = new PriceOutput[](token_decimal.length);
        for(uint i; i < token_decimal.length; i++){
            prices[i] = quotePrice(token_decimal[i].token, token_decimal[i].decimal,false);
        }

    }

    //Get USD price of a given token using quote, if price not available in USD then return in BNB
    function quotePrice(address token, uint decimal, bool planB)public view returns  (PriceOutput memory out){

        /**
          * In case the USD prices are incorrect probably because of reserves0 or reserves1 being tiny in USD pool then try plan B
         */
        address  Pair;
        string memory coinPicked;

        if(planB == false){
            //seearch dexFactory for pair so we can calculate USD price
            for(uint x; x < dexFactory.length; x++){
                // loop through stable coins array to get the pair from the user token
                for(uint i; i < stableCoins.length; i++){
                        address pair  = IPancakeFactory(dexFactory[x]).getPair(token, stableCoins[i]);
                        if(pair != address(0)){
                            (uint reserves0, uint reserves1,) = IPancakePair(pair).getReserves();
                            if(reserves0 != 0 && reserves1 !=0){// check to be sure reserves are not 0, if 0 continue the loop
                                Pair = pair;
                                coinPicked = symbols[i];
                                break;
                            }

                        }   
                } 
                if(Pair != address(0)){break;}  
            }
            if(Pair == address(0)){// if pair does not exit then pair with WBNB
                    for(uint x; x < dexFactory.length; x++){
                        Pair  = IPancakeFactory(dexFactory[x]).getPair(token, WBNB);
                        (uint reserves0, uint reserves1,) = IPancakePair(Pair).getReserves();
                        if(Pair != address(0) && reserves0 > 0 && reserves1 > 0){
                            coinPicked = "WBNB";
                            break;
                        }    
                    }
            }
        }
        else{// plan B
            for(uint x; x < dexFactory.length; x++){
                Pair  = IPancakeFactory(dexFactory[x]).getPair(token, WBNB);
                (uint reserves0, uint reserves1,) = IPancakePair(Pair).getReserves();
                if(Pair != address(0) && reserves0 > 0 && reserves1 > 0){
                    coinPicked = "WBNB";
                    break;
                }    
            }
        }

       if(Pair == address(0)){ //finally if non is available just return empty struct
        return out;
       }
       (uint reserves0, uint reserves1,) = IPancakePair(Pair).getReserves(); 
        if(reserves0 == 0 || reserves1 == 0){
            return out;
        }

        if (token == IPancakePair(Pair).token0()) {
            uint x = uint(1 *10**decimal).mul(reserves1) / reserves0;
            out = PriceOutput(x, coinPicked, token); 
        } else {
            uint x = uint(1 *10**decimal).mul(reserves0) / reserves1;
             out = PriceOutput(x, coinPicked, token); 
        }
    }

}