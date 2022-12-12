/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: MIT
// File: contracts/Test.sol



pragma solidity 0.8.0;

contract Test {
    uint256 value;

    function setValue(uint256 data) external {
        value = data;
    }

    function getValue3() external view returns (uint256) {
        return value;
    }

}