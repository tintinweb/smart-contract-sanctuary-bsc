/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract MyContract {
    string public myString = "Hello world";

    function updateOurString(string memory _myString) public {
        myString = _myString;
    }
}