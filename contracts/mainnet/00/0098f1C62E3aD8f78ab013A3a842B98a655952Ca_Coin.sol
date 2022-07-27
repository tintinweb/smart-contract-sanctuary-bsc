/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.15;



contract Coin {
    
    mapping(address => uint) public balances;
    mapping (address => uint ) public allowance;
    uint public decimals = 18;
    uint public totalSupply= 1000 *10 **12;
    string public name = "ELON BAND ";
    string public symbol = "ELBD";

    event Transfer(address indexed from, address indexed to, uint value);
    
    event Approval(address indexed owner , address indexed spender, uint value);
   

    constructor ()   {
        balances[msg.sender]  = totalSupply;
     
            
    }

    function balanceOf(address owner) public view returns (uint){
        return balances[owner];

    }
    function transfer(address to, uint value ) public returns (bool){
        require (balanceOf(msg.sender) >= value, "balance too low ");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to , value);
        return true;
    }
    function transferfrom(address from, address to, uint value ) public returns(bool){
        require(balanceOf(from)>= value, "balance too low ");
        require(allowance[msg.sender] >= value);
        balances[to] += value ;
        emit Transfer(from, to , value);
     
        

        return true;

    }
    function approval(address spender,uint value) public returns (bool){
        allowance[spender] = value ;
        emit Approval(msg.sender, spender, value);
        return true ;
    }
    function depositing (uint256 deposit) public payable{
        require(msg.value==deposit);
        deposit = msg.value;
    }
  

   
  
}