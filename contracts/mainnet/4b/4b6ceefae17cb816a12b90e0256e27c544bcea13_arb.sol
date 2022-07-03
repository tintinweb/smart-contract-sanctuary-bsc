/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract arb {

function reserves(address[2] memory marketPairs) external view returns (uint112, uint112,uint112,uint112, uint112) {
//gasConsumed = gasLimit * gasPrice = 200 000 * 5*10**9 = 1x10**15 = 0.001bnb
(uint112 bnbReserves0,uint112 bnbReserves1,) = IUniswapV2Pair(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16).getReserves();
uint112 C = bnbReserves1/bnbReserves0;
(uint112 sushiReserves0, uint112 sushiReserves1,) = IUniswapV2Pair(marketPairs[0]).getReserves(); //returns an array [tokenR, busdR]
(uint112 uniReserves0, uint112 uniReserves1,) = IUniswapV2Pair(marketPairs[1]).getReserves(); 
return (sushiReserves0, sushiReserves1, uniReserves0, uniReserves1, C);
}

}

//return targets AddressArray, payloads BytesArray, uint256 repay

//what do we need, we need respectively: amount_in, o = l/2 optimal tokens, expected receive busd


//3 options
//1) Get reserves -> calculate profit in rust -> encode in either RUST OR SOL
//3) Get REserves -> calculate profit in solidity -> encode in ...? Advantage to not mess with numbers float etc
//2) do all solidity ? not possible