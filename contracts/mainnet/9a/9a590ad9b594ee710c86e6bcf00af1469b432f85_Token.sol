/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7; 
contract Token {
    mapping(address => uint) public balances;    
    uint public totalSupply = 13703599913 * 10 ** 18;
    string public name ="AFFLUENT";
    string public symbol ="AFU";
    uint public decimals = 18;

    event transfer(address indexed from, address indexed to, uint value);
    constructor() {
        balances[msg.sender] = totalSupply;
    }
        function balanceOf(address owner) public view returns(uint) {
            return balances[owner];
        }

        
}