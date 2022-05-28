/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

contract Randomm  {
  uint256 public count = 0;
  mapping(uint256 => uint256) public _randomResult;
  function random(uint number) public returns(uint) {
        uint256 random = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty, msg.sender, count))) % number;
        count = count + 1;
        _randomResult[count] = random;
        return count;
    }
    function randomResult(uint256 index) public view returns(uint256) {
      return _randomResult[index];
    }
    function currentCount() public view returns(uint256) {
      return count;
    }
}