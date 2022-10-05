/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract testContractMethod {
    function testRevert(string memory str) pure  public  {
         revert(string(abi.encodePacked("Test Revert : ", str)));
    }
}