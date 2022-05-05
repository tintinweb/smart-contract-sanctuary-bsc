/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract MetaMachine {
    address public owner; 
    mapping (address => uint) public MetaBalances;

    constructor() {
        owner = msg.sender;
        MetaBalances[address(this)] = 10000;
    }

    function getMetaMachineBalance() public view returns (uint) {
        return MetaBalances[address(this)];
    }

    function restock(uint amount) public {
        require(msg.sender == owner, "Only owner can restock this machine");
        MetaBalances[address(this)] += amount;
    } 

    function purchase(uint amount) public payable {
        require(msg.value >= amount * 2 ether, "You must pay atleast 2 ether to buy the Meta");
        require(MetaBalances[address(this)] >= amount, "Insuficient Meta in the contract to fulfill the order, try with a lower number");
        MetaBalances[address(this)] -= amount; 
        MetaBalances[msg.sender] += amount;
    }
}