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
            (uint112 reserve0, uint112 reserve1,) = UniswapFunctions(addresses[i]).getReserves();
            array0[i] = reserve0;
            array1[i] = reserve1;
        }
        return (array0,array1);
    }


    function get_chosen_pairs_full(address[] memory tokenA,address[] memory tokenB, address[] memory factory) external view returns(address[] memory,address[] memory,address[] memory,string[] memory,string[] memory){
        require(tokenA.length == tokenB.length && tokenB.length == factory.length,"Merci d'envoyer des tableaux de meme taille. ");
        address[] memory Lps = new address[](tokenA.length);
        address[] memory token0_address = new address[](tokenA.length);
        address[] memory token1_address = new address[](tokenA.length);
        string[] memory token0_symbol = new string[](tokenA.length);
        string[] memory token1_symbol = new string[](tokenA.length);
        for(uint i = 0; i < tokenA.length; i++){
            //on met comme contract le factory du broker donné
            Lps[i] = UniswapFunctions(factory[i]).getPair(tokenA[i],tokenB[i]);
            token0_address[i] = UniswapFunctions(Lps[i]).token0();
            token1_address[i] = UniswapFunctions(Lps[i]).token1();
            token0_symbol[i] = UniswapFunctions(token0_address[i]).symbol();
            token1_symbol[i] = UniswapFunctions(token1_address[i]).symbol();
            
        }
        return (Lps,token0_address,token1_address,token0_symbol,token1_symbol);
    }

    

    function get_all_pairs_full(address factory, uint start, uint finish) external view returns(address[] memory,address[] memory,address[] memory, string[] memory, string[] memory){//return : Lp, token0 address, token1 address, token0 symbol, token1 symbol       
        uint len = finish - start;
        address[] memory Lps = new address[](len);
        address[] memory token0_address = new address[](len);
        address[] memory token1_address = new address[](len);
        string[] memory token0_symbol = new string[](len);
        string[] memory token1_symbol = new string[](len);

        for(uint i = start; i < finish; i++){
            //on filtre par factory :
            
            //on met comme contract le factory du broker donné
            Lps[i] = UniswapFunctions(factory).allPairs(i);
            token0_address[i] = UniswapFunctions(Lps[i]).token0();
            token1_address[i] = UniswapFunctions(Lps[i]).token1();
            token0_symbol[i] = UniswapFunctions(token0_address[i]).symbol();
            token1_symbol[i] = UniswapFunctions(token1_address[i]).symbol();
        }
        return (Lps,token0_address,token1_address,token0_symbol,token1_symbol);//
    }


    

}