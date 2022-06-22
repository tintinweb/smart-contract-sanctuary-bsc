/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract Test {
    string public name;

    function setName(string memory _name) public {
        name = _name;
    }

    function getName() public view returns (string memory) {
        return name;
    }
}