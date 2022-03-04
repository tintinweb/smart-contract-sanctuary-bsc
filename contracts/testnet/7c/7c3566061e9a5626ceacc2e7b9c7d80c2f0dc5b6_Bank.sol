/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    
   mapping (address=>uint)  receiveds;

   function withdrawAll() public returns(bool) {
        uint amount =  address(this).balance;

        return payable( msg.sender).send(amount);
    }


    function getBalance(address addr) public view returns (uint) {
        return receiveds[addr];
    }

     receive() external payable {
         receiveds[msg.sender]+=msg.value;
     }
    
    fallback() external payable {
        receiveds[msg.sender]+=msg.value;
    }
}