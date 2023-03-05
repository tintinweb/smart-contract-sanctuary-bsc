/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NextGenToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    uint256 constant public targetPrice = 1 * 10 ** 18; // 1 Indian rupee
    uint256 public totalWeight;
    mapping(address => uint256) public weightOf;

    constructor() {
        name = "NextGenToken";
        symbol = "NXGT";
        decimals = 18;
        totalSupply = 0;
        totalWeight = 0;
    }

    function deposit(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero.");

        uint256 weight = amount * targetPrice;
        balanceOf[msg.sender] += amount;
        weightOf[msg.sender] += weight;
        totalSupply += amount;
        totalWeight += weight;
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero.");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance.");

        uint256 weight = amount * targetPrice;
        balanceOf[msg.sender] -= amount;
        weightOf[msg.sender] -= weight;
        totalSupply -= amount;
        totalWeight -= weight;
    }

    function getStablePrice() public view returns (uint256) {
        if (totalSupply == 0) {
            return targetPrice;
        } else {
            return totalWeight / totalSupply;
        }
    }

    function buy() external payable {
        uint256 price = getStablePrice();
        uint256 amount = msg.value / price;
        deposit(amount);
    }

    function sell(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero.");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance.");

        uint256 price = getStablePrice();
        uint256 value = amount * price;
        require(address(this).balance >= value, "Insufficient liquidity.");

        withdraw(amount);
        payable(msg.sender).transfer(value);
    }
}