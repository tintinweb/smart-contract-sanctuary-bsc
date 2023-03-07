/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenSale {
    address public tokenAddress;
    uint256 public tokenPrice;
    
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 price);
    event PriceChanged(uint256 oldPrice, uint256 newPrice);
    
    constructor(address _tokenAddress, uint256 _tokenPrice) {
        tokenAddress = _tokenAddress;
        tokenPrice = _tokenPrice;
    }
    
    function buyTokens() payable public {
        uint256 amount = msg.value * (10 ** 18) / tokenPrice;
        require(amount >= (5 * (10 ** 15)), "Minimum purchase amount not met");
        
        IERC20 token = IERC20(tokenAddress);
        uint256 balanceBefore = token.balanceOf(address(this));
        require(token.transfer(msg.sender, amount), "Token transfer failed");
        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter == balanceBefore - amount, "Token balance incorrect after transfer");
        
        emit TokensPurchased(msg.sender, amount, tokenPrice);
    }
    
    function changeTokenPrice(uint256 newPrice) public {
        emit PriceChanged(tokenPrice, newPrice);
        tokenPrice = newPrice;
    }
}