/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


 
 contract test {
     uint time;
     uint public balance = address(this).balance;
     constructor(){
         time = block.timestamp;
     }
     receive () external payable {}
     function update() public {
         time = block.timestamp;
     }
   
     function currentTime() public view returns(uint,uint){
         return (block.timestamp,1e18);
    }
     
    function withdrawCoin() public {
        payable(msg.sender).transfer(address(this).balance);
    }
 }