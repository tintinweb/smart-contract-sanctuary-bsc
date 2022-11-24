// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract CommitUtil {
  function getCommitHash(
    address account_,
    uint256 userSeed_,
    bytes32 houseSeed_
  ) external pure returns (bytes32 commit) {
    commit = keccak256(abi.encode(houseSeed_, userSeed_, account_));
  }
}