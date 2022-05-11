/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SimpleStorage {
  uint data;

  function updateData(uint _data) external {
    data = _data;
  }

  function readData() external view returns(uint) {
    return data;
  }
}