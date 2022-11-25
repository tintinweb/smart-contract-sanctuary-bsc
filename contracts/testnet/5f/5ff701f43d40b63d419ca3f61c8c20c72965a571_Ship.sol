/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Ship {
  uint x;
  uint y;

  constructor() {
    x = 0;
    y = 0;
  }

  function update(uint _x, uint _y) public {
    x = _x;
    y = _y;
  }
  function fire() public view returns (uint, uint) {
    return (x, y);
  }
  function place(uint width, uint height) public view returns (uint, uint) {
    uint _x = random(width*height, width+height) % width;
    uint _y = random(width+height, width*height) % height;
    return (_x, _y);
  }
  function random(uint a, uint b) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, address(this), a, b)));
  }
}