// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Lock {
  event A(string value, uint256 indexed id);

  function a() external {
      emit A("test", 123);
  }
}