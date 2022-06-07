// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./SwapToken.sol";

contract SwapTokenAction {
    SwapToken public swapToken;

    function approveToSwap(IERC20 token, address tokenToSwap) public {
        token.approve(tokenToSwap, 100000000000000000);
    }

    function swapTokenToETH(address token, uint256 amountIn, uint256 amountOutMin ) public {
        swapToken.swapExactTokensForETHSupportingFeeOnTransferTokens(token, amountIn, amountOutMin);
    }

}