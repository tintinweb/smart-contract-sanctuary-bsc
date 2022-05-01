/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

//SPDX-License-Identifier:MIT
pragma solidity >=0.7.0 <=0.9.0;

contract test04{
   uint number;

   function setNumber(uint _number) public {
       number = _number;
   }

   function getNumber() public view returns(uint) {
       return number;
   }
}