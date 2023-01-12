// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

contract BoxV2 {
  uint public val;

  // function initialize(uint _val) external {
  //   val = _val;
  // }

  function increase() external {
    val += 1;
  }
}