/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

//SPDX-License-Identifier: None
pragma solidity 0.8.13;

contract kaiyuanUNLICENSED {
    string name;
    constructor(string memory _name) {
        name = _name;
    }
    function getNumber() public view returns(string memory) {
        return name;
    }
    function changeNumber(string memory _name) public {
        name = _name;
    }
}