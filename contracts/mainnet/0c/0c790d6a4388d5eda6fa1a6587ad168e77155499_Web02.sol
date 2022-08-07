// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Web02 {

    string public constant url = 'web03.com';
    mapping (uint => string) public names;
    uint public namesN;
    uint public constant D = 1;
    uint public constant E = 2;

    function addName(string memory _name) public {
        names[namesN++] = _name;
    }

    function addD(uint _d) public view returns(uint256) {
       return D + _d;
    }
}