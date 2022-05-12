/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Lock {

  uint256 private constant BLOCK_OF_YEAR = 10512000;
  uint256 public expireTime;
  address public token;
  address public receiver;

  constructor(address _token, address _receiver) {
    token = _token;
    receiver = _receiver;
    expireTime = block.number + BLOCK_OF_YEAR;
  }

  function withdraw() external {
    require(block.number >= expireTime, "no expire");
    require(receiver == msg.sender, "not specical address");
    IERC20(token).transfer(receiver, IERC20(token).balanceOf(address(this)));
  }

}