// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

contract Test {
    uint256 value;

    function setValue(uint256 data) external {
        value = data;
    }

    function getValue2() external view returns (uint256) {
        return value;
    }

}