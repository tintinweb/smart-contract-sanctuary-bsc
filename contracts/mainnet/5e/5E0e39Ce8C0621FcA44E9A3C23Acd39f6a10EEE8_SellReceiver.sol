//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

interface IStaking {
    function distributor() external view returns (address);
}

contract SellReceiver {

    // Main Token
    IToken public constant token = IToken(0x988ce53ca8d210430d4a9af0DF4b7dD107A50Db6);

    // Dev Fee Address
    address public maxi = 0x19DC4126976E0b6af1c68141E13a73524a1D68Ed;

    // Router
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address[] private path = [ address(token), router.WETH() ];

    modifier onlyOwner() {
        require(
            msg.sender == token.getOwner(),
            'Only Owner'
        );
        _;
    }

    function trigger() external {
        
        // ensure there is balance to distribute
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // burn half of tokens
        token.burn(balance / 2);

        // sell remainder of tokens
        uint256 tokensToSell = token.balanceOf(address(this));
        if (tokensToSell > 0) {
            token.approve(address(router), tokensToSell);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokensToSell, 0, path, address(this), block.timestamp + 100
            );
        }
        if (address(this).balance > 0) {
            (bool s,) = payable(IStaking(maxi).distributor()).call{value: address(this).balance}("");
            require(s);   
        }
    }

    function setMaxi(address maxi_) external onlyOwner {
        maxi = maxi_;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(IERC20 token_) external onlyOwner {
        token_.transfer(msg.sender, token_.balanceOf(address(this)));
    }

    receive() external payable {}
}