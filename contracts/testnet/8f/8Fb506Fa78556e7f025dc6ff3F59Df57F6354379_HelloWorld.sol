/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract HelloWorld {

  uint public myFavoriteNumber = 88;
  uint public yourFavoriteNumber;

  function myFavoriteNumberPlusYourFavoriteNumber() public view returns (uint) { 
    return myFavoriteNumber + yourFavoriteNumber;
  }
  
  function setYourFavoriteNumber(uint a) public payable {
    if( msg.value > 1 wei ) { // 1 ether == 1000000000000000000
      yourFavoriteNumber = a; 
    }
  }
}