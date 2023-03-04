/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenPresale {
    address payable public owner;
    address public tokenAddress;
    uint256 public totalTokensForSale;
    uint256 public tokensSold;
    uint256 public tokenPrice;
    mapping(address => uint256) public balances;
    
    event TokenPurchased(address indexed buyer, uint256 amount);
    
    constructor(address _tokenAddress, uint256 _totalTokensForSale, uint256 _tokenPrice) {
        owner = payable(msg.sender);
        tokenAddress = _tokenAddress;
        totalTokensForSale = _totalTokensForSale;
        tokenPrice = _tokenPrice;
    }
    
    function buyTokens() payable external {
        require(msg.value > 0, "Must send BNB to purchase tokens");
        
        uint256 tokensToBuy = msg.value * tokenPrice;
        require(tokensSold + tokensToBuy <= totalTokensForSale, "Not enough tokens left for sale");
        
        balances[msg.sender] += tokensToBuy;
        tokensSold += tokensToBuy;
        emit TokenPurchased(msg.sender, tokensToBuy);
    }
    
    function withdrawTokens() external {
        require(msg.sender == owner, "Only the owner can withdraw tokens");
        
        IBEP20 token = IBEP20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        
        token.transfer(owner, balance);
    }
    
    function withdrawBNB() external {
        require(msg.sender == owner, "Only the owner can withdraw BNB");
        
        uint256 balance = address(this).balance;
        require(balance > 0, "No BNB to withdraw");
        
        owner.transfer(balance);
    }
}