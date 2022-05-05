/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract Greeting {
    string public name;
    string public GreetingPrefix = "Hello ";

    constructor(string memory InitialName) {
        name = InitialName;
    }

    function settheName(string memory myName) public {
        name = myName;
    }

    function getGreetings() public view returns (string memory) {
        return string(abi.encodePacked(GreetingPrefix, name));
    }
}