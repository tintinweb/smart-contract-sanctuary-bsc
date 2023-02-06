/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// File: contracts/1_SampleContract.sol

//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

contract SampleContract {

    string public myString = "Hello World";

    function updateString(string memory _newString) public {
        myString = _newString;
    }
}