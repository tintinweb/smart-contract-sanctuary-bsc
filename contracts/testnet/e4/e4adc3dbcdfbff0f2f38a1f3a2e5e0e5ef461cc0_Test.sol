/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

/**
 *Submitted for verification at Etherscan.io on 2022-01-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Test
{
    error toto();
uint256 value;

function calc(uint256 val) public{
    if(val>10){
        revert toto();
    }
value=val;
}
}