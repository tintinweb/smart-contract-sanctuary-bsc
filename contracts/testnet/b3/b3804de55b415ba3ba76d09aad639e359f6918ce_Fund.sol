/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Fund{
    uint public total;

    function get() public view returns(uint){
        return total;
    }

    function set(uint no) public{
        total = no;
    }
}

//0xB3804dE55B415Ba3bA76D09aaD639E359f6918Ce