// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Box {
  uint256 public val;

  function inc() external {
    val += 2;
  }

  function getVal() external view returns (uint256) {
    return val;
  }
}