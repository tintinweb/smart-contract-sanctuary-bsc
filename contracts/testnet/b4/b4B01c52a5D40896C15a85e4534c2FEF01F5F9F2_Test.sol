// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Test
{
    uint256 public value;

    function setValue(uint256 _val) external returns(uint256) {
        value = _val;
        return value;
    }
}