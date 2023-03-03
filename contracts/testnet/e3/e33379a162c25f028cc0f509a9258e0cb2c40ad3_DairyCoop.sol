/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract DairyCoop {
    
    address admin;
    ERC20 milkToken;
    mapping(address => uint256) milkBalances;
    
    event MilkPurchased(address indexed buyer, uint256 amount);
    event MilkSold(address indexed seller, uint256 amount);
    
    constructor(address _admin, address _milkToken) {
        admin = _admin;
        milkToken = ERC20(_milkToken);
    }
    
    function sellMilk(uint256 amount) public {
        require(milkToken.balanceOf(msg.sender) >= amount, "Insufficient milk balance");
        require(milkToken.allowance(msg.sender, address(this)) >= amount, "Not enough milk allowance");
        require(milkToken.transferFrom(msg.sender, address(this), amount), "Milk transfer failed");
        milkBalances[msg.sender] += amount;
        emit MilkSold(msg.sender, amount);
    }
    
    function buyMilk(uint256 amount) public {
        require(milkBalances[msg.sender] >= amount, "Insufficient milk balance");
        milkBalances[msg.sender] -= amount;
        require(milkToken.transfer(msg.sender, amount), "Milk transfer failed");
        emit MilkPurchased(msg.sender, amount);
    }
    
    function withdrawMilk(uint256 amount) public {
        require(msg.sender == admin, "Only the admin can withdraw milk");
        require(milkToken.balanceOf(address(this)) >= amount, "Insufficient milk balance");
        require(milkToken.transfer(admin, amount), "Milk transfer failed");
    }
    
}