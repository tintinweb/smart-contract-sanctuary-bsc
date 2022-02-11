// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract BoxV2 {

    uint public val;

    // constructor(uint _val) {
    //     val = _val;
    // }

    function inc() external {
        val += 1;
    }

}