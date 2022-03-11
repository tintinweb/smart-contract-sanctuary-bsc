// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


interface IPancakeSwapRouter {   
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


contract GetPrice {
    IPancakeSwapRouter public pancakeRouter;

    constructor(address src) {
        pancakeRouter = IPancakeSwapRouter(src);
    }

    function getSwapPrice(address[] calldata path, uint256 amountIn) public view returns(uint256[] memory) {
        uint256[] memory amountOut = pancakeRouter.getAmountsOut(amountIn, path);
        return amountOut;
    }

}