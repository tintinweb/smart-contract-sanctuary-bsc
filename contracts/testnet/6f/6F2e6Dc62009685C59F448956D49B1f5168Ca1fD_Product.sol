/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

contract Product {
    string public name;
    address public owner;

    constructor(string memory _name, address _owner) {
        name = _name;
        owner = _owner;
    }

    function setName(string memory _name) external {
        name = _name;
    }

    function setOwner(address _owner) external {
        require(msg.sender == owner, "caller is not owner");
        owner = _owner;
    }
}