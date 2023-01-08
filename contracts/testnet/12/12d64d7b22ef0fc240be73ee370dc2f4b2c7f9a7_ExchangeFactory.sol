/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ExchangeFactory {
    receive() external payable {}
    function getAmountOut(uint256 amountIn, address token0, address token1, address pair, uint32 exchangeId) external view returns(uint256) {
        return amountIn * 101 / 100;
    }
}