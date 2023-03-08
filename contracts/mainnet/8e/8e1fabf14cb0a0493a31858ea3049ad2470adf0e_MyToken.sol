/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

pragma solidity ^0.8.0;

contract MyToken {
  string public name = "My Token";
  string public symbol = "MTK";
  uint256 public totalSupply = 1000000000000000000000000; // 1 billion tokens
  uint8 public decimals = 18;

  mapping(address => uint256) public balanceOf;

  constructor() {
    balanceOf[msg.sender] = totalSupply;
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value);
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    return true;
  }
}