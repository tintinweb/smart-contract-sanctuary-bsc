/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

/******

TG: https://t.me/test089899

******/


// SPDX-License-Identifier: GPL-3.0


pragma solidity 0.8.3;

contract examplemodifier{

    address public owner;
    uint256 public account;
  
   constructor (){
       owner = msg.sender;
       account = 0 ;
   }
modifier onlyowner(){
  require(msg.sender == owner , "onlyOwner");
  _;
}
  function updateaccount(uint256 _account) public onlyowner {
     
          account =  _account;
      
  }

}