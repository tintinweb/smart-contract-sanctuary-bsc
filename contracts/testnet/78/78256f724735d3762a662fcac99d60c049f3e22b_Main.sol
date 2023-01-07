/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

contract Main {
    string username;

    function setUserName(string memory name) public {
        username = name;
    }

    function printMessage() public view returns(string memory) {
        bytes memory concat_strings;
        concat_strings = abi.encodePacked("Welcome, ");
        concat_strings = abi.encodePacked(concat_strings, username);
        concat_strings = abi.encodePacked(concat_strings, "!!!");
        string memory message = string(concat_strings);

        return message;

    }
}