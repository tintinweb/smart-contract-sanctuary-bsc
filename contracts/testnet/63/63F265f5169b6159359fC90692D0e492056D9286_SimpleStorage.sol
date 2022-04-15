/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SimpleStorage {
   uint storedData;
   function set(uint x) public {
      storedData = x;
   }
   function get() public view returns (uint) {
      return storedData;
   }

   function get2x() public payable returns (uint) {
       emit SayHello("Emad");
      return storedData * 2;
   }

    event SayHello(
        string person
    );
}