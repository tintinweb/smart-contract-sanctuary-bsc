/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

pragma solidity ^0.8.4;

contract Bank {
    mapping(address => uint) balance;
    address owner;
    
    constructor() {
        owner = msg.sender; // address that deploys contract will be the owner
    }
    
    function addBalance(uint _toAdd) public returns(uint) {
        require(msg.sender == owner);
        balance[msg.sender] += _toAdd;
        return balance[msg.sender];
    }
}