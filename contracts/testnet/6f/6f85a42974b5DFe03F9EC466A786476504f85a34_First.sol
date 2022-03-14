/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


contract First {

    function testRequire(uint i) public pure{
        require(i<=10,"i > 10  6");
    }


   function testRevert(uint i) public pure{

       if(i>10){
           revert("i > 10");
       }

   }

    uint public num = 123;
   function testAssert() public view{
       assert(num == 123);
   }


    function foo (uint i) public{
        num+=1;
        require(i<10,"i > 10");
    }
}