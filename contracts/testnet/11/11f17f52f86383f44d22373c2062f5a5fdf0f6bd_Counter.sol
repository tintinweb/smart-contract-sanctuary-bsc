/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.3;

contract Counter{
    uint public count;

    function add() public {
        count += 1;
    }

    function jian() public {
        count -= 1;
    }

    function show() view public returns(uint){
        return count;
    }
}