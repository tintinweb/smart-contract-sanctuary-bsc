// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IRouter.sol";
import "./IERC20.sol";

contract Bot {
    IRouter public Router = IRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    IERC20 public WBNB = IERC20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
    address public USDC = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;

    function buyTokens(address tokenAddress, uint256 priceToBuy) payable external {
        require(msg.value > 1, "Send amount is too low");
        uint256 price = getPrice(tokenAddress, true, 0); //WBNB/Token

        //TODO convert dollar price
        uint256 dollar = getDollarPrice(); //WBNB/USDC
        uint256 dollarPrice = price/dollar; //USDC/Token
        //TODO wait for another round
        if(dollarPrice > priceToBuy) {}

        WBNB.deposit{value: msg.value}();
        WBNB.approve(address(Router), msg.value);

        uint256 decimals = IERC20(tokenAddress).decimals();
        uint256 amountOutMin = (price - price/10) * msg.value / (10**decimals);
        address[] memory path = createPath(address(WBNB), tokenAddress);
        Router.swapExactTokensForTokens(msg.value, amountOutMin, path, address(this), block.timestamp + 30000);
    }

    function sellTokens(address tokenAddress, uint256 priceToSell) external {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        require(balance > 0, "You do not have these tokens");

        uint256 decimals = IERC20(tokenAddress).decimals();
        uint256 price = getPrice(tokenAddress, false, decimals); //Token/WBNB

        //TODO convert dollar price
        uint256 dollar = getDollarPrice(); //WBNB/USDC
        uint256 dollarPrice = price*dollar; //Token/USDC
        //TODO wait for another round
        if(dollarPrice < priceToSell) {}

        IERC20(tokenAddress).approve(address(Router), balance);

        uint256 amountOutMin = (price - price/10) * balance / 1 ether;
        address[] memory path = createPath(tokenAddress, address(WBNB));
        Router.swapExactTokensForTokens(balance, amountOutMin, path, address(this), block.timestamp + 30000);
        //TODO return BNB to user
    }

    function returnBNBToUser() internal {
        uint256 wTokenBalance = WBNB.balanceOf(address(this)); 
        WBNB.withdraw(wTokenBalance);
        payable(msg.sender).transfer(address(this).balance);
    }

    function getPrice(address tokenAddress, bool isBuy, uint256 decimals) internal view returns(uint256) {
        address[] memory path = isBuy ? createPath(address(WBNB), tokenAddress) : createPath(tokenAddress, address(WBNB));
        uint256 amountIn = isBuy ? 1 ether : 10**decimals;

        uint256[] memory price = Router.getAmountsOut(amountIn, path);
        return price[1];
    }

    function getDollarPrice() internal view returns(uint256) {
        address[] memory path = createPath(address(WBNB), USDC);
        uint256[] memory price = Router.getAmountsOut(1 ether, path);
        return price[1];
    }

    function createPath(address tokenIn, address tokenOut) internal pure returns(address[] memory) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        return path;
    }
}