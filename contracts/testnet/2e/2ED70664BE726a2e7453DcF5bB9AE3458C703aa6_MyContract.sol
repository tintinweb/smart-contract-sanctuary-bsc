/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MyContract{
    string public name="Hello Babu";

    function myFunc(string memory _name) public {
        name = _name;
    }
}