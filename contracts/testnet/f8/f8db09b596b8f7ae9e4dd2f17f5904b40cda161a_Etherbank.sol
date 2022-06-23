/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;
contract Etherbank {//is ReentrancyGuard  
    
//    using Address for address payable;
  mapping(address=>uint) public  balances;

  function deposit()external payable{
      balances[msg.sender] +=msg.value;
  }
  function withdraw()external {// nonReentrant  
      require(balances[msg.sender]>0,"withdrawl amount is not enough"); 
       payable(msg.sender).transfer(balances[msg.sender]);
       balances[msg.sender]=0;
      
  }
  function getbalance()external view returns(uint){
      return address(this).balance;
  }
}