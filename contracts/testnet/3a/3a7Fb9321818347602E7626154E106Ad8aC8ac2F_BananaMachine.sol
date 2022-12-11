/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract BananaMachine {

    // state variables
    address public owner;
    mapping (address => uint) public BananaBalances;

    // set the owner as th address that deployed the contract
    // set the initial vending machine balance to 100
    constructor() {
        owner = msg.sender;
        BananaBalances[address(this)] = 200;
    }

    function getBananaMachineBalance() public view returns (uint) {
        return BananaBalances[address(this)];
    }

    // Let the owner restock the vending machine
    function restock(uint amount) public {
        require(msg.sender == owner, "Only the owner can restock.");
        BananaBalances[address(this)] += amount;
    }

    // Purchase donuts from the vending machine
    function buy(uint amount) public payable {
        require(msg.value >= (0.1 ether * amount),"You must pay at least 0.1 ETH per banana");
        require(BananaBalances[address(this)] >= amount, "Not enough banana in stock to complete this purchase");
        BananaBalances[address(this)] -= amount;
        BananaBalances[msg.sender] += amount;
    }

    function withdraw(uint _amount) external {
    require(msg.sender == owner, "Only the owner can withdraw banana money");

    
    payable(msg.sender).transfer(_amount);    
}
}