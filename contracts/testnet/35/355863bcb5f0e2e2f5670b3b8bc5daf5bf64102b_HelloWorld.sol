/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract HelloWorld {
    string name;
    function getName() public view returns(string memory) {
        return name;
    }
    function changeName(string memory _name) public {
        name=_name;
    }
}