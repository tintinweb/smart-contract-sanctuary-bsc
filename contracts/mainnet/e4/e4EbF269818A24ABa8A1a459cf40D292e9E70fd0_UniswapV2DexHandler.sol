/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IDexHandler {
    function getAmountOut(
        address _dex,
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut
    ) external view returns (address pair, uint256 amountOut);
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);
}

interface IUniswapV2Router {
    function factory() external view returns (address);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract UniswapV2DexHandler is IDexHandler {
    constructor() {}

    function getAmountOut(
        address _dex,
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut
    ) external view override returns (address pair, uint256 amountOut) {
        address factory = IUniswapV2Router(_dex).factory();
        pair = IUniswapV2Factory(factory).getPair(_tokenIn, _tokenOut);
        if (pair != address(0)) {
            (uint256 reserveIn, uint256 reserveOut, ) = IUniswapV2Pair(pair).getReserves();
            if (_tokenIn > _tokenOut) {
                (reserveIn, reserveOut) = (reserveOut, reserveIn);
            }
            amountOut = IUniswapV2Router(_dex).getAmountOut(_amountIn, reserveIn, reserveOut);
            if (amountOut == 0) {
                pair = address(0);
            }
        }
    }
}