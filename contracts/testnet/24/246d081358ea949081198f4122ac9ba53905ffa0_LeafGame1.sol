/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface LeafLike {
 function transfer(address,uint) external returns (bool);
 function transferFrom(address,address,uint) external returns (bool);
 function balanceOf(address tokenOwner) external view returns (uint balance);
}


  /**
   * @title ContractName
   * @dev ContractDescription
   * @custom:dev-run-script ./scripts/ethers-lib.ts
   */


contract LeafGame1 {
 mapping (address => uint) public banked;
 LeafLike public leaf;

constructor(address leaf_) {
  leaf = LeafLike(leaf_);
 }
function leafGame1Balance() public view returns (uint) {
 return leaf.balanceOf(address(this));
 }
function depositMyTokens(uint256 amount) public {
 leaf.transferFrom(msg.sender, address(this), amount);
 banked[msg.sender] = banked[msg.sender] + amount;
 }
}