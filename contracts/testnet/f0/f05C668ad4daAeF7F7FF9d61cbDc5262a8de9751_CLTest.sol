/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: None
pragma solidity 0.8.4;

contract CLTest {
  uint256 public ts;
  address public caller;

  function upkeepCall() public {
    ts = block.timestamp;
    caller = msg.sender;
  }
}