/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract SpinToWin {
    address public tokenAddress;
    uint public totalDeposits;
    
    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }
    
    function deposit(uint amount) public {
        IERC20 token = IERC20(tokenAddress);
        require(token.allowance(msg.sender, address(this)) >= amount, "Allowance is not enough");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        totalDeposits += amount;
    }
    
    function approve(uint amount) public {
        IERC20 token = IERC20(tokenAddress);
        token.approve(address(this), amount);
    }
}