/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bidding {
  address payable private _owner;

  uint256 private _tokenId;
  uint256 private _highestBid;

  constructor() {
    _owner = payable(msg.sender);

    _tokenId = 0;
    _highestBid = 0;
  }

  function bid(uint256 newTokenId) public payable {
    require(msg.value > _highestBid, "You need to overbid the last bid!");

    _tokenId = newTokenId;
    _highestBid = msg.value;
  }

  function tokenId() public view returns(uint256) {
    return _tokenId;
  }

  function highestBid() public view returns(uint256) {
    return _highestBid;
  }

  function withdraw() public {
    uint amount = address(this).balance;

    (bool success, ) = _owner.call{value: amount}("");
    require(success, "Failed to withdraw");
  }
}