// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

contract TestFunc
{
  uint256 public V1 = 0;
  address public V2 = address(0);
  bytes public V3;

  constructor()
  {
    
  }

  function setValue1(uint256 v1, address v2, bytes calldata v3) external
  {
    V1 = v1;
    V2 = v2;
    V3 = v3;
  }

  function setValue2(uint256 v1, address v2, bytes calldata v3) external payable
  {
    V1 = v1;
    V2 = v2;
    V3 = v3;
  }
 
}