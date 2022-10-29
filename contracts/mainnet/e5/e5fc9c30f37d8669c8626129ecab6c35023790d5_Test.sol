/**
 *Submitted for verification at BscScan.com on 2022-10-29
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Test {
    function test(
        address _receiveSide,
        bytes memory _calldata
    ) public returns (bool success, bytes memory data) {
        (success, data) = _receiveSide.call(_calldata);
    }
}