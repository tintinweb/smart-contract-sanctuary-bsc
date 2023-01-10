/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

// BEP20 Token Contract
contract BCUSDToken {
    string public name = "BlockChain USD2";
    string public symbol = "BCUSD2";
    uint8 public decimals = 18;
    uint public totalSupply = 100000000 * (10 ** uint(decimals));
    uint public mintingFinished = 1;

    // Mapping from address to balance
    mapping(address => uint) public balanceOf;

    // BEP3 functions
    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    function getbalanceOf(address who) public view returns (uint) {
        return balanceOf[who];
    }

    function approve(address spender, uint value) public returns (bool) {
        // Implement approve function...
    }

    function transfer(address to, uint value) public returns (bool) {
        // Implement transfer function...
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        // Implement transferFrom function...
    }

    // Constructor function
    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }
}