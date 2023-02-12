/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StableToken {
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor()  {
        totalSupply = 500000000;
        balanceOf[msg.sender] = totalSupply;
        name = "BTrade USD";
        symbol = "BTUSD";
        decimals = 18;
    }

    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance.");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }
    
}