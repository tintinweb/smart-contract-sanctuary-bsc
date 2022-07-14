//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IPriceOracle {
    function priceOf(address token) external view returns (uint256);
}

interface IPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract LPPriceOracle {

    IPriceOracle public oracle = IPriceOracle(0x952B02F1973a1157cfE1B43d62aC6E1e921C5D00);

    function priceOf(address token) public view returns (uint256) {
        return oracle.priceOf(token);
    }

    function priceOfLPInFarm(address LP, address farm) public view returns (uint256) {

        // get balance of farm versus LP total supply
        uint256 totalSupply = IERC20(LP).totalSupply();
        uint256 balance = IERC20(LP).balanceOf(farm);

        if (balance == 0 || totalSupply == 0) {
            return 0;
        }

        // fetch tokens in LP
        address token0 = IPair(LP).token0();
        address token1 = IPair(LP).token1();

        // fetch prices of tokens
        uint256 price0 = priceOf(token0);
        uint256 price1 = priceOf(token1);

        // fetch balance of tokens in LP
        uint256 bal0 = IERC20(token0).balanceOf(LP);
        uint256 bal1 = IERC20(token1).balanceOf(LP);

        // multiply price times balances in LP
        uint val0 = ( bal0 * price0 ) / 10**IERC20(token0).decimals();
        uint val1 = ( bal1 * price1 ) / 10**IERC20(token1).decimals();

        // add values together - value of total LP
        uint256 value = val0 + val1;

        // multiply total LP value by ratio of Farm Holdings vs Total Supply
        return ( value * balance ) / totalSupply;
    }

    function priceOfLP(address LP) public view returns (uint256) {

        // get balance of farm versus LP total supply
        uint256 totalSupply = IERC20(LP).totalSupply();

        if (totalSupply == 0) {
            return 0;
        }

        // fetch tokens in LP
        address token0 = IPair(LP).token0();
        address token1 = IPair(LP).token1();

        // fetch prices of tokens
        uint256 price0 = priceOf(token0);
        uint256 price1 = priceOf(token1);

        // fetch balance of tokens in LP
        uint256 bal0 = IERC20(token0).balanceOf(LP);
        uint256 bal1 = IERC20(token1).balanceOf(LP);

        // multiply price times balances in LP
        uint val0 = ( bal0 * price0 ) / 10**IERC20(token0).decimals();
        uint val1 = ( bal1 * price1 ) / 10**IERC20(token1).decimals();

        // add values together - value of total LP
        uint256 value = val0 + val1;

        // multiply total LP value by ratio of Farm Holdings vs Total Supply
        return ( value * 10**18 ) / totalSupply;
    }


}