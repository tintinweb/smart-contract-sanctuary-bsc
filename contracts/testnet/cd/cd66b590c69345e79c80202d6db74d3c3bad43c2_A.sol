/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
contract A {
  mapping (address => uint256) values;

  function getValue(address _addr) public pure returns (bytes32 storagePointer) {
    assembly {
      storagePointer := _addr
      
    }
    
    return storagePointer;
  }
}