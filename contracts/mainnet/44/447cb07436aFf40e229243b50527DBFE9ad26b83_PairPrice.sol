// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IPancakePair.sol";
import "./IPancakeFactory.sol";
import "./PancakeLibrary.sol";
import "./Ownable.sol";

contract PairPrice is PancakeLibrary, Ownable {

    constructor(address _auth) Ownable(_auth) {

    }

    function cumulateMUTAmountOut(uint256 USDTAmountIn) external view returns (uint256 res) {
        address pairAddress = IPancakeFactory(auth.getPancakeFactory()).getPair(auth.getUSDTToken(), auth.getFarmToken());
        (
            uint112 reserve0, 
            uint112 reserve1, 
        ) = IPancakePair(pairAddress).getReserves();
        res = getAmountOut(USDTAmountIn, reserve1, reserve0);
    }

    function cumulateUSDTAmountOut(uint256 MUTAmountIn) external view returns (uint256 res) {
        address pairAddress = IPancakeFactory(auth.getPancakeFactory()).getPair(auth.getUSDTToken(), auth.getFarmToken());
        (
            uint112 reserve0, 
            uint112 reserve1, 
        ) = IPancakePair(pairAddress).getReserves();
        res = getAmountOut(MUTAmountIn, reserve0, reserve1);

        
    }
}