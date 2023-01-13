/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

pragma solidity ^0.8.0;
//SPDX-License-Identifier: UNLICENSED
contract DiamondToken {
    string public name = "Diamond Token";
    string public symbol = "DMN";
    uint8 public decimals = 18;
    uint public totalSupply = 10000;

    mapping(address => uint) public balanceOf;
    address public owner;

    constructor() public {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
    }

    function transfer(address to, uint value) public {
        require(balanceOf[msg.sender] >= value && value > 0);
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
    }

    function mine() public {
        require(msg.sender == owner);
        totalSupply += 1;
        balanceOf[owner] += 1;
    }

    function burn(uint value) public {
        require(balanceOf[msg.sender] >= value && value > 0);
        totalSupply -= value;
        balanceOf[msg.sender] -= value;
    }
    
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner);
        owner = newOwner;
    }
}