/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

//"SPDX-License-Identifier: UNLICENSED"
pragma solidity >0.6.0 <0.9.0;

interface UniswapFunctions{
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function symbol() external view returns (string memory);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
}

contract MultiCallSacha{

    function priceMulticall(address[] memory addresses) external view returns(uint112[] memory,uint112[] memory){
        uint112[] memory array0 = new uint112[](addresses.length);
        uint112[] memory array1 = new uint112[](addresses.length);
        for(uint112 i = 0; i < addresses.length; i++){
            (array0[i], array1[i],) = UniswapFunctions(addresses[i]).getReserves();
        }
        return (array0,array1);
    }

    function symbol_Multicall(address[] memory Lp) external view returns(address[] memory, address[] memory ){
        address[] memory token0_ = new address[](Lp.length);
        address[] memory token1_ = new address[](Lp.length);

        for(uint i = 0; i < Lp.length; i++){
            token0_[i] = UniswapFunctions(Lp[i]).token0();
            token1_[i] = UniswapFunctions(Lp[i]).token1();
        }
        return (token0_,token1_);
    }

    function symbol_Names_Multicall(address[] memory tokenA, address[] memory tokenB) external view returns(string[] memory, string[] memory ){
        require(tokenA.length == tokenB.length,"Merci d'envoyer des tableaux de meme taille. ");
        string[] memory token0_symbol = new string[](tokenA.length);
        string[] memory token1_symbol = new string[](tokenA.length);

        for(uint i = 0; i < tokenA.length; i++){
            token0_symbol[i] = UniswapFunctions(tokenA[i]).symbol();
            token1_symbol[i] = UniswapFunctions(tokenB[i]).symbol();
        }
        return (token0_symbol,token1_symbol);
    }



    function get_chosen_pairs(address[] memory tokenA,address[] memory tokenB, address[] memory factory) external view returns(address[] memory){
        require(tokenA.length == tokenB.length && tokenB.length == factory.length,"Merci d'envoyer des tableaux de meme taille. ");
        address[] memory Lps = new address[](tokenA.length);
        for(uint i = 0; i < tokenA.length; i++){
            //on met comme contract le factory du broker donné
            Lps[i] = UniswapFunctions(factory[i]).getPair(tokenA[i],tokenB[i]);
        }
        return (Lps);
    }

    

    function get_all_pairs(address factory, uint start, uint finish) external view returns(address[] memory,address[] memory,address[] memory){//return : Lp, token0 address, token1 address, token0 symbol, token1 symbol       
        uint len = finish - start;
        address[] memory Lps = new address[](len);
        address[] memory token0_address = new address[](len);
        address[] memory token1_address = new address[](len);

        for(uint i = start; i < finish; i++){
            //on filtre par factory :
            
            //on met comme contract le factory du broker donné
            Lps[i-start] = UniswapFunctions(factory).allPairs(i);
            token0_address[i-start] = UniswapFunctions(Lps[i-start]).token0();
            token1_address[i-start] = UniswapFunctions(Lps[i-start]).token1();
            
        }
        return (Lps,token0_address,token1_address);//
    }


    

}