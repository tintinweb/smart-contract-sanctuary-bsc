/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Web03{
    constructor() public {

    }
    string public constant url = 'web03.cn';
    mapping (uint => string) public names;
    uint public namesN;
    function addName(string memory _name) public {
        names[namesN++] = _name;
    }
}