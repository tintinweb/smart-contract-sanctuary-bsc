/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IERC20 {

    function balanceOf(address owner) external view returns (uint);
    function deposit() external payable;
    function transferFrom(address from, address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);

}

interface IUniswapV2Pair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

contract Swap {
    IUniswapV2Pair pair = IUniswapV2Pair(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16);
    IERC20 wbnb = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    function withdraw() public {
        // wbnb -> busd 0.01

       (uint112 _reserve0, uint112 _reserve1,) = pair.getReserves(); // gas savings

        uint256 amountIn = 1e16;
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * uint256(_reserve1);
        uint denominator = (uint256(_reserve0) * 1000) + (amountInWithFee);
        uint256 amountOut = numerator / denominator;

        wbnb.transferFrom(msg.sender, address(pair), amountIn);
        pair.swap(0, amountOut, msg.sender, new bytes(0));
    }
}