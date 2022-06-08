/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Greeter {
  uint256 public total;
  event Mint(address msg, uint256 total);
  
  function mint() public payable {
    uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % 100;
    if(total > random && random > 50){
      total -= random;
    }else{
      total += random;
    }
    emit Mint(msg.sender, total);
  }
}