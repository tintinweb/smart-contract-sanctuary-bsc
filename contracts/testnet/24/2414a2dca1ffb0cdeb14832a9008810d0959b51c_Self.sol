/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Self{
    uint256 public A = 1e9;

    function del() external payable{
        selfdestruct( payable(msg.sender));
    }
}