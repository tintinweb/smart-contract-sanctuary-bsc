// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract BoxV3 {
    uint public val;

    // function initialize(uint _val) external {
    //     val = _val;
    // }

    function incx() external {
        val += 1;
    }
}