/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint count;

    function getCount() public view returns(uint){
        return count;
    }

    function incrementCount() public {
        count = count + 1;
    }
}