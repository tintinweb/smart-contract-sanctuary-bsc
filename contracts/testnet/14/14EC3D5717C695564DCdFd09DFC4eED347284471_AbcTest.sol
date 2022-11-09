/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

/**
 *Submitted for verification at Etherscan.io on 2021-05-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract AbcTest {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000 * 10 **18;
    string public name = "TFTest Token";
    string public symbol = "TFEST";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() { 
        balances[msg.sender] = totalSupply; 
    }
   
   function balanceOf(address owner) public view returns(uint) {
       return balances[owner];
   }


   function transfer(address to, uint value) public returns (bool) {
       require(balanceOf(msg.sender) >= value, 'balance too low');
       balances[to] += value;
       balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
       return true;
   }
   
   function trasnferFrom(address from, address to, uint value) public returns (bool) {
       require(balanceOf(from)>= value, 'balance too low');
       require(allowance[from][msg.sender] >= value, 'allwowance too low');
       balances[to] += value;
       balances[from] -= value;
       emit Transfer(from, to, value);
       return true;
   }
   
 function approve(address spender, uint value) public returns(bool) {
     allowance[msg.sender][spender] = value;
     emit Approval(msg.sender, spender, value);
     return true;
 }
}