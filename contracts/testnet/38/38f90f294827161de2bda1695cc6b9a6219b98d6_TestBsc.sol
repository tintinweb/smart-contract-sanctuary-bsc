/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract TestBsc {
    
    uint256 aState;

    function revertMe() public  {

        require(1==2, "1 must be 2");

        aState++;
    }
}