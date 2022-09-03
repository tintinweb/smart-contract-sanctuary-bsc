// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @custom:experimental This is an experimental contract for testing purposes
contract PancakeSwapMock {

  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) {
    reserve0 = 500000 * (10**8);
    reserve1 = 5000000 * (10**8);
    blockTimestampLast = 41234231;
  }
}