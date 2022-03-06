/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Count {

  uint public counter;

  constructor(uint x) {
    counter = x;
  }

  function count() public {
    counter = counter + 1;
  }


  function set(uint x) public {
      counter =  x;
  }

   function get()  public view returns(uint){
       return counter;
   }

}