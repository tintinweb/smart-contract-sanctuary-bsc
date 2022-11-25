/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
contract A{
   error Invoked1();
   function invoke1() public{
      revert Invoked1();
   }
      function invoke2() public{
      require(false,"false invoke2");
   }
}

contract B{
    event Created(address newContract);   
      function invoke(uint256 i) public {
          A a=new A();
          if(i==1)
            a.invoke1();
          if(i==2)
            a.invoke2();
   }
}