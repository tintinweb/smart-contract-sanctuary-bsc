// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IPancakeRouter02.sol";
import "./IERC20.sol";

contract Swap {
    IPancakeRouter02 pancakeswapRouter;

    constructor() {
        pancakeswapRouter = IPancakeRouter02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
    }

    function generatePortfolioWith10Assets(address[] memory portfolioAssets)
        public
        payable
    {
        uint256 deadline = block.timestamp + 15;
        uint256 amount = msg.value / 10;

        for (uint256 i = 0; i < portfolioAssets.length; i++) {
            address[] memory path = new address[](2);
            path[0] = pancakeswapRouter.WETH();
            path[1] = portfolioAssets[i];

            pancakeswapRouter.swapExactETHForTokens{value: amount}(
                0,
                path,
                msg.sender,
                deadline
            );
        }
    }

    function getExchangeRate(uint256 amountIn, address toToken)
        public
        view
        returns (uint256[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = pancakeswapRouter.WETH();
        path[1] = toToken;

        return pancakeswapRouter.getAmountsOut(amountIn, path);
    }

    /*struct TokenInformation {
        address tokenAddress;
        uint256 weight;
        uint256 minAmountOut;
    }

    TokenInformation[] portfolio;

    function validPortfolio(TokenInformation[] memory portfolioTokens)
        public
        view
        returns (bool)
    {
        uint256 weight;
        for (uint256 i; i < portfolio.length; i++) {
            weight += portfolioTokens[i].weight;
        }

        return weight == 100;
    }

    function generatePortfolio(TokenInformation[] memory portfolioTokens)
        public
        payable
    {
        require(validPortfolio(portfolioTokens));

        uint256 amountPerShare = msg.value / 100;
        uint256 deadline = block.timestamp + 15;

        for (uint256 i; i < portfolio.length; i++) {
            address[] memory path = new address[](2);
            path[0] = pancakeswapRouter.WETH();
            path[1] = portfolioTokens[i].tokenAddress;

            uint256 amount = amountPerShare * portfolioTokens[i].weight;

            pancakeswapRouter.swapExactETHForTokens{value: amount}(
                portfolioTokens[i].minAmountOut,
                path,
                msg.sender,
                deadline
            );
        }
    }
    
    function generate5050Portfolio(
        uint256 minAmountOut1,
        uint256 minAmountOut2,
        address portfolioToken1,
        address portfolioToken2
    ) public payable {
        uint256 deadline = block.timestamp + 15;

        uint256 amount = msg.value / 2;
        uint256 amount2 = msg.value - amount;

        address[] memory path = new address[](2);
        path[0] = pancakeswapRouter.WETH();
        path[1] = portfolioToken1;

        pancakeswapRouter.swapExactETHForTokens{value: amount}(
            minAmountOut1,
            path,
            msg.sender,
            deadline
        );

        address[] memory path2 = new address[](2);
        path2[0] = pancakeswapRouter.WETH();
        path2[1] = portfolioToken2;

        pancakeswapRouter.swapExactETHForTokens{value: amount2}(
            minAmountOut2,
            path2,
            msg.sender,
            deadline
        );
    }

    function swapTokenToToken(
        uint256 amount,
        uint256 amountOutMin,
        address[] calldata path
    ) public {
        require(path.length >= 2);

        uint256 deadline = block.timestamp + 15;
        address fromToken = path[0];

        // Approve the router to spend amount
        IERC20(fromToken).approve(
            0x10ED43C718714eb63d5aA57B78B54704E256024E,
            amount
        );

        pancakeswapRouter.swapExactTokensForTokens(
            amount,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }*/
}