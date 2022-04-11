/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
contract kaiyuanUNLICENSED {
    string name;
    address owner;
    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    }
    function getNumber() public view returns(string memory) {
        return name;
    }
    function changeNumber(string memory _name) public {
        name = _name;
    }

    function kill() public {
        selfdestruct(payable(owner));
    }
}