//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

contract PriceOracle {

    IUniswapV2Router02 router = IUniswapV2Router02(0x39255DA12f96Bb587c7ea7F22Eead8087b0a59ae);

    address constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    /**
        Works For BNB, Regular Tokens And Surge Tokens
     */
    function priceOfACCU() external view returns (uint256) {
        address token = 0x9cb949e8c256C3EA5395bbe883E6Ee6a20Db6045;

        address LP = IUniswapV2Factory(router.factory()).getPair(token, BUSD);
        uint256 amt0 = IERC20(token).balanceOf(LP) / 10**IERC20(token).decimals();
        uint256 amt1 = IERC20(BUSD).balanceOf(LP) / 10**18;

        return ( amt1 * 10**18 ) / amt0;
    }

    function priceOfTRUTH() external view returns (uint256) {
        return priceOfToken(0x55a633B3FCe52144222e468a326105Aa617CC1cc);
    }

    function LPStatsForToken(address token) external view returns (uint256, uint256) {
        return _lpAmountsForToken(token);
    }

    /**
        Works For BNB, Regular Tokens And Surge Tokens
     */
    function priceOf(address token) public view returns (uint256) {
        return token == WETH ? priceOfBNB() : priceOfToken(token);
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

    function priceOfToken(address token) public view returns (uint256) {
        (uint256 p0, uint256 p1) = _lpAmountsForToken(token);
        return( ( p1 * priceOfBNB()) / p0);
    }

    function priceOfBNB() public view returns (uint256) {
        address token = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address LP = IUniswapV2Factory(router.factory()).getPair(token, router.WETH());
        uint256 amt0 = IERC20(token).balanceOf(LP);
        uint256 amt1 = IERC20(router.WETH()).balanceOf(LP);
        return ( amt0 * 10**18 / amt1);
    }

    function _lpAmountsForToken(address token) internal view returns (uint256, uint256) {
        address LP = IUniswapV2Factory(router.factory()).getPair(token, WETH);
        uint256 amt0 = IERC20(token).balanceOf(LP);
        uint256 amt1 = IERC20(router.WETH()).balanceOf(LP);
        return ( amt0 / 10**IERC20(token).decimals(), amt1 / 10**18);
    }
}