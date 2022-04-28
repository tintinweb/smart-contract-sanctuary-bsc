/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract changeString {
    address public owner;
    string public name;
    constructor(string memory _name, address _owner){
        name = _name;
        owner = _owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setName(string memory _name) public onlyOwner returns(bool) {
        name = _name;
        return true;
    }
}