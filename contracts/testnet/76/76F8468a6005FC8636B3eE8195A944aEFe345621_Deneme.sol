/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Deneme {
    string public txt = "Hello, World!!!!!!!!!!";

    function getTxt() public view returns(string memory) {
        return txt;
    }
}