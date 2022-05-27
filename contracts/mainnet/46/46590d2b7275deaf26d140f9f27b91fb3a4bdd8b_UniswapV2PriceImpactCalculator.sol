// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IUniswapV2Pair.sol";
import "./IERC20Metadata.sol";

library UniswapV2PriceImpactCalculator {
    function calculateSellPriceImpact(address tokenAddress, address pairAddress, uint256 value) public view returns (uint256) {
        value = value * 998 / 1000;

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        (uint256 r0, uint256 r1,) = pair.getReserves();

        IERC20Metadata token0 = IERC20Metadata(pair.token0());
        IERC20Metadata token1 = IERC20Metadata(pair.token1());

        if(address(token1) == tokenAddress) {
            IERC20Metadata tokenTemp = token0;
            token0 = token1;
            token1 = tokenTemp;

            uint256 rTemp = r0;
            r0 = r1;
            r1 = rTemp;
        }

        uint256 product = r0 * r1;

        uint256 r0After = r0 + value;
        uint256 r1After = product / r0After;

        return (10000 - (r1After * 10000 / r1)) * 998 / 1000;
    }
}