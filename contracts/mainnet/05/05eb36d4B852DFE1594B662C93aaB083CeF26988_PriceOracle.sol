//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IStable {
    function calculatePrice() external view returns (uint256);
}

contract PriceOracle {

    IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function LPStatsForToken(address token0, address token1) external view returns (uint256, uint256) {
        return _lpAmountsForToken(token0, token1);
    }

    /**
        Works For BNB, Regular Tokens And Surge Tokens
     */
    function priceOf(address token) public view returns (uint256) {
        return token == WETH ? priceOfBNB() : priceOfToken(token, WETH);
    }

    function priceOfTokenBackedByStable(address token, address stable) public view returns (uint256) {
        (uint256 p0, uint256 p1) = _lpAmountsForToken(token, stable);
        return( ( p1 * IStable(stable).calculatePrice() ) / p0 );
    }

    /**
        Takes An Array of Addresses and returns an equal sized array of prices
        Works For BNB, Regular Tokens And Surge Tokens
     */
    function pricesOf(address[] calldata tokens) external view returns (uint256[] memory) {
        uint256[] memory prices = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            prices[i] = priceOf(tokens[i]);
        }
        return prices;
    }

    function priceOfToken(address token0, address token1) public view returns (uint256) {
        (uint256 p0, uint256 p1) = _lpAmountsForToken(token0, token1);
        return( ( p1 * priceOfBNB()) / p0);
    }

    function priceOfBNB() public view returns (uint256) {
        address token = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address LP = IUniswapV2Factory(router.factory()).getPair(token, WETH);
        uint256 amt0 = IERC20(token).balanceOf(LP);
        uint256 amt1 = IERC20(WETH).balanceOf(LP);
        return ( amt0 * 10**18 / amt1);
    }

    function _lpAmountsForToken(address token0, address token1) internal view returns (uint256, uint256) {
        address LP = IUniswapV2Factory(router.factory()).getPair(token0, token1);
        uint256 amt0 = IERC20(token0).balanceOf(LP);
        uint256 amt1 = IERC20(token1).balanceOf(LP);
        return ( amt0 / 10**IERC20(token0).decimals(), amt1 / 10**IERC20(token1).decimals());
    }
}