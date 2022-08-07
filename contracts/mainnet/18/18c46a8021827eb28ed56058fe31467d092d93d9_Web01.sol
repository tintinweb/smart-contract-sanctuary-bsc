// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Web01{

    string public constant url = 'web03.cn';
    mapping (uint => string) public names;
    uint public namesN;
    uint public constant D = 1;
    function addName(string memory _name) public {
        names[namesN++] = _name;
    }
    function addD(uint _d) public pure{
       D + _d;
    }
}