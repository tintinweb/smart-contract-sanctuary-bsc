//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
contract  Poka {
   uint256  public  total =90000000;
   uint256  public  add;
   function testAdd() external {

    require( total > 0,"324324");
    add += 50000000 ;
    total -= add;
   }
}