/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract test {

    string checker;

    function push(string calldata _s) public {
        checker = _s;
    }

    function getValue() public view returns (string memory) {
        return checker;
    }

}