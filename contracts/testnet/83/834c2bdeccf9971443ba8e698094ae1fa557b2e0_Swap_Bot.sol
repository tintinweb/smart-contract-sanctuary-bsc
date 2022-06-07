pragma solidity 0.8.14;

// SPDX-License-Identifier: MIT

import "./Ownable.sol";
import "./Token.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Pair.sol";
import "./SafeMath.sol";

contract Swap_Bot is Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    event SwapedTokenForEth(uint256 EthAmount, uint256 TokenAmount);
    event SwapedEthForTokens(uint256 EthAmount);

    function swapToken(address token) public payable onlyOwner {

         uint256 bnbAmount = msg.value;        
        uint256 contractTokenBalance = address(this).balance.sub(bnbAmount);
        
        uint256[] memory amount = new uint256[](15);
        uint256 amountToBuy = bnbAmount.div(15);
        
        amount[0] = amountToBuy;
        amount[1] = amountToBuy;
        amount[2] = amountToBuy;
        amount[3] = amountToBuy;
        amount[4] = amountToBuy;
        amount[5] = amountToBuy;
        amount[6] = amountToBuy;
        amount[7] = amountToBuy;
        amount[8] = amountToBuy;
        amount[9] = amountToBuy;
        amount[10] = amountToBuy;
        amount[11] = amountToBuy;
        amount[12] = amountToBuy;
        amount[13] = amountToBuy;
        amount[14] = amountToBuy;
        
        uint256[] memory tokenAmount = new uint256[](15);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswapV2Router.WETH();
        uint256 amountToSell = getAmountsOut(token, amountToBuy, path);
        
        tokenAmount[0] = amountToSell;
        tokenAmount[1] = amountToSell;
        tokenAmount[2] = amountToSell;
        tokenAmount[3] = amountToSell;
        tokenAmount[4] = amountToSell;
        tokenAmount[5] = amountToSell;
        tokenAmount[6] = amountToSell;
        tokenAmount[7] = amountToSell;
        tokenAmount[8] = amountToSell;
        tokenAmount[9] = amountToSell;
        tokenAmount[10] = amountToSell;
        tokenAmount[11] = amountToSell;
        tokenAmount[12] = amountToSell;
        tokenAmount[13] = amountToSell;
        tokenAmount[14] = amountToSell;
        
        //bnbAmount = bnbAmount * 10**17;
        for (uint256 i = 0; i < amount.length; i++) {

            uint256 tokenBalance = Token(token).balanceOf(address(this));
            swapEthForTokens(amount[i]);
            uint256 tokenBough = Token(token).balanceOf(address(this)).sub(tokenBalance);
            swapTokensForEth(token, tokenBough.mul(55).div(100));

            if (address(this).balance <= contractTokenBalance.add(bnbAmount.div(1e3))) {
                uint256 tokenToSellAtOnec = Token(token).balanceOf(address(this));
                swapTokensForEth(token, tokenToSellAtOnec);
                payable(owner()).transfer(address(this).balance);
            }
        }
    }
    
    function getAmountsOut(address token, uint amountToBuy, address[] memory path) public view returns (uint256 amount) {
        uint256[] memory amounts = Token(token).getAmountsOut(amountToBuy, path);
        amount = amounts[0];
        return amount;
    }
    
    function swapEthForTokens(uint256 EthAmount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: EthAmount}(
                0,
                path,
                address(this),
                block.timestamp
            );
        emit SwapedEthForTokens(EthAmount);
    }

    function swapTokensForEth(address token, uint256 tokenAmount) private {
        uint256 ethAmount = address(this).balance;
        
        //@dev Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        Token(token).approve(address(uniswapV2Router), tokenAmount);

        //@dev Make the swap
        uniswapV2Router.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        
        ethAmount = address(this).balance.sub(ethAmount);
        emit SwapedTokenForEth(tokenAmount,ethAmount);
    }

    function transferBNB(address recipient, uint256 amount) public onlyOwner {
        payable(recipient).transfer(amount);
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(recipient != address(0), "Recipient is the zero address");
        Token(tokenAddress).transfer(recipient, amount);
    }

    receive() external payable {
        // just to receive BNB
    }
}