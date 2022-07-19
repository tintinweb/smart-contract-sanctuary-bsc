/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

contract PancakeSwapRouterMock{

    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        virtual
        returns (uint[] memory amounts)
    {
        amounts = new uint[](1);
        if(path[0] == 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c && path[1] == 0x03401e701Ca700a32c9dfdd6631787888B5DE85e){
            amounts[0] = amountIn/220;
        }else if(path[0] == 0x2523cCC751CFd372b3a4c9CF2538Fc4C565E2044 && path[1] == 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c){
            amounts[0] = amountIn*22;
        }
        return amounts;
    }
}