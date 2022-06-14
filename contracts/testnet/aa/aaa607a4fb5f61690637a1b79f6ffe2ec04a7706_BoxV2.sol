/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

contract BoxV2 {
    uint public val;
    // function initilaize (uint _val) external {
    //     val = _val;
    // }

    function inc() external {
        val += 1;
    }
}