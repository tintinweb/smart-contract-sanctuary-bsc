// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Testhash {   
   function callKeccak256() public pure returns(bytes32 result){
      return keccak256("headphone of roms 1");
   }  
}