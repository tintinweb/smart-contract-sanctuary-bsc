/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT
// author https://biubiu.tools
// BiuBiu.Tools: Start exploring web3 here.
// Based on Uniswap V2 router

pragma solidity ^0.8.0;

interface IUniswapV2Router {
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract PriceOracle {
    address uniswapV2RouterAddr;
    address[] public path;

    constructor(
        address c,
        address weth,
        address usd
    ) {
        uniswapV2RouterAddr = c;
        path.push(weth);
        path.push(usd);
    }

    // How much ETH for USD
    function latestAnswer(uint256 amountOut) public view returns (uint256) {
        IUniswapV2Router router = IUniswapV2Router(uniswapV2RouterAddr);
        uint256[] memory amounts = router.getAmountsIn(amountOut, path);
        return amounts[0];
    }
}