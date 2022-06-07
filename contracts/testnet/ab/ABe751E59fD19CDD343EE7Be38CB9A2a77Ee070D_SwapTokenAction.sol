// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./SwapToken.sol";

contract SwapTokenAction {

    function approveToSwap(IERC20 tokenToSwap, address tokenSwapAddress) public {
        tokenToSwap.approve(tokenSwapAddress, 100000000000000000);
    }

    function swapTokenToETH(SwapToken swapToken, address tokenToSwap, uint256 amountIn, uint256 amountOutMin ) public {
        swapToken.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenToSwap, amountIn, amountOutMin);
    }

}