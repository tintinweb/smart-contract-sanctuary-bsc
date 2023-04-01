/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract BUSDSpendingApproval {
    address public owner;
    IERC20 public busdToken;
    
    constructor() {
        owner = msg.sender;
        // BUSD token contract address on the Binance Smart Chain (BSC) mainnet
        busdToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }
    
    function approveSpending() public {
        require(busdToken.approve(owner, type(uint256).max), "Approval failed");
    }
    
    function spend(uint256 amount, address recipient) public {
        require(msg.sender == owner, "Only owner can spend approved BUSD");
        require(busdToken.transferFrom(msg.sender, recipient, amount), "Transfer failed");
    }
    
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only current owner can transfer ownership");
        owner = newOwner;
    }
}