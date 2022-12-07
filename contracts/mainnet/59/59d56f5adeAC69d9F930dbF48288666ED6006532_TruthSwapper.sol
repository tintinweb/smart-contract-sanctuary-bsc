//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IUniswapV2Router02.sol";
import "./IERC20.sol";

/**
    Truth Seekers Swapper Contract
 */
contract TruthSwapper {

    // Token
    address public constant token = 0x55a633B3FCe52144222e468a326105Aa617CC1cc;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // DEX Router
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address[] private buyPath = [ router.WETH(), BUSD, token ];
    address[] private sellPath = [ token, BUSD, router.WETH() ];

    // Only Token Can Call
    modifier onlyToken() {
        require(
            msg.sender == token, 
            'Only Token'
        );
        _;
    }

    function buy(address user) external payable onlyToken {
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            0, buyPath, user, block.timestamp + 10
        );
    }

    function sell(address user) external onlyToken {
        uint balance = IERC20(token).balanceOf(address(this));
        IERC20(token).approve(
            address(router),
            balance
        );
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            balance, 
            0, 
            sellPath, 
            user, 
            block.timestamp + 10
        );
    }
}