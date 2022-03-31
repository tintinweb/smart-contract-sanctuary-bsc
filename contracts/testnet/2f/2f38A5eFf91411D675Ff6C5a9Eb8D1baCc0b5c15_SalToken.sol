/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract SalToken{
    
     // Name
       string public Name = "Dev Token";
       // Symble
       string public Symble = "Dev"; 
      //  Decimal
      uint256 public Decimal = 18;
      //  Total Supply
      uint public TotalSupply;
      
      // Transfer event
      event Transfer(address sender, address to, uint256 amount);
      // Approval event
      event Approval(address From, address spender, uint256 amount);   
      
      // Blance mapping
      mapping (address => uint256) public balanceOf;
      // Allowance mapping
      mapping (address => mapping(address => uint256)) public allowance;
            
      constructor (uint256 _totalsupply){
          TotalSupply = _totalsupply;
          balanceOf[msg.sender] = _totalsupply;
      }
      
     // Transfer function
     function transfer(address _To, uint256 _amount) public {
     // The use that is transfering must have the  sufficient balance
     require(balanceOf[msg.sender] >= _amount , 'You have not sufficient balance');
     // Subtract the amount from sender
     balanceOf[msg.sender] -= _amount;
     // Add the amount to the user transfered
     balanceOf[msg.sender] += _amount;
     // emit transfer event
     emit Transfer(msg.sender, _To, _amount);
     }
      
     // Approve function 
     function Approve(address _spender, uint256 _amount) public{
     // increase Allowance
     allowance[msg.sender][_spender] += _amount;
     // emit allowance event
     emit Approval(msg.sender, _spender, _amount);
     }
     
     // TransferFrom function
     function TransferFrom(address _from, address _to, uint256 _amount) public{
     // Check the balance of from user
     require(balanceOf[_from] >= _amount, 'The user from which money has to be deducted does not have enough balance');
     // Check the allowance of the msg.sender
     require(allowance[_from][msg.sender] >= _amount, 'The spender doees not have required balance');
     // Subtract the amount from user
     balanceOf[_from] -= _amount;
     // Add the amount to user
     balanceOf[_to] += _amount;
     // Decrase the amount
     allowance[_from][msg.sender] -= _amount;
     // emit Transfer
     emit Transfer(_from, _to, _amount);  
     // emit Approval
     emit Approval(_from, msg.sender, _amount);
         
     }    
}