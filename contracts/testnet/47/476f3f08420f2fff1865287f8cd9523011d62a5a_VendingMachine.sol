/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract VendingMachine {
    address public owner;
    mapping (address => uint) public DonutBalances;

    constructor() {
        owner = msg.sender;
        DonutBalances[address(this)] = 10000;
    }

    function getVendingMachineBalance() public view returns (uint) {
        return DonutBalances[address(this)];
    }
    
    function restock(uint amount) public {
        require(msg.sender == owner, "Only owner can restock this machine");
        DonutBalances[address(this)] += amount;
    } 

    function purchase(uint amount) public payable {
        require(msg.value >= amount * 2 ether, "You must pay at least 2 ether per donut");
        require(DonutBalances[address(this)] >= amount, "Not enough donets to fulfill the order");
        DonutBalances[address(this)] -= amount;
        DonutBalances[msg.sender] += amount;
    }
}