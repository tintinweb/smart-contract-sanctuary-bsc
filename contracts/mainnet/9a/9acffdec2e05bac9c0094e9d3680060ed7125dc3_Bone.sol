/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT

/**
 
*/


pragma solidity ^0.8.0;

contract Bone {
    string public name = "Bone";
    string public symbol = "Bne";
    uint8 public decimals = 18;
  uint256 public totalSupply = 230000000 * 10**decimals; 
    address public owner;
    address public marketingWallet;

    uint256 public buyTax = 3;
    uint256 public sellTax = 3;
    uint256 public transferFee = 1;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _marketingWallet) {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        marketingWallet = _marketingWallet;
    }

    function setMarketingWallet(address _marketingWallet) public onlyOwner {
        marketingWallet = _marketingWallet;
    }

    function buy() public payable {
        uint256 amount = msg.value * (10 ** decimals) / getPrice();
        require(amount > 0, "Insufficient amount");

        uint256 taxAmount = amount * buyTax / 100;
        uint256 transferAmount = amount - taxAmount;

        require(balanceOf[owner] >= taxAmount, "Insufficient balance");

        balanceOf[owner] -= taxAmount;
        balanceOf[msg.sender] += transferAmount;

        (bool success, ) = marketingWallet.call{value: taxAmount}("");
        require(success, "Marketing transfer failed");

        emit Transfer(owner, msg.sender, transferAmount);
    }

    function sell(uint256 amount) public {
        require(amount > 0, "Insufficient amount");

        uint256 taxAmount = amount * sellTax / 100;
        uint256 transferAmount = amount - taxAmount;

        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[owner] += taxAmount;
        balanceOf[msg.sender] -= amount;

        (bool success, ) = marketingWallet.call{value: taxAmount}("");
        require(success, "Marketing transfer failed");

        payable(msg.sender).transfer(transferAmount);

        emit Transfer(msg.sender, owner, amount);
    }

    function transfer(address to, uint256 amount) public {
        require(amount > 0, "Insufficient amount");

        uint256 feeAmount = amount * transferFee / 100;
        uint256 transferAmount = amount - feeAmount;

        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += transferAmount;

        (bool success, ) = marketingWallet.call{value: feeAmount}("");
        require(success, "Marketing transfer failed");

        emit Transfer(msg.sender, to, transferAmount);
    }

    function getPrice() public view returns (uint256) {
        return totalSupply / (10 ** decimals) / address(this).balance;
    }
}