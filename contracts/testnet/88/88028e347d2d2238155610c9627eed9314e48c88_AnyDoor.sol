/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract AnyDoor {
    string public owner;

    constructor(string memory _owner) payable {
        owner = _owner;
    }

    function anydoor() public pure returns (string memory) {
        return "Welcome to AnyDoor!";
    }
}