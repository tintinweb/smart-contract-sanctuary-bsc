/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract testContractMethod {
    address testUser = address(0);

    function testRevert() public  {
        testUser = msg.sender;
         revert("Test Revert");
    }
}