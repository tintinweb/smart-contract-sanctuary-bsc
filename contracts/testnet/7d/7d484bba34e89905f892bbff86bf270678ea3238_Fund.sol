/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Fund{

    uint public total;

    function get() public view returns(uint){
        return total;
    }

    function set(uint no) public{
        total = no;
    }
}