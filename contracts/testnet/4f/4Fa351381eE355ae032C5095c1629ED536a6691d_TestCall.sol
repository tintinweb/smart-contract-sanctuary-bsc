/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

contract TestCall
{
  address private AD;

  constructor(address addr)
  {
    AD = addr;
  }

  fallback() payable external
    {

    }

    receive() payable external
    {
 
    }

  function call_____ssss(bytes calldata data) external
  {
    (bool success, ) = AD.call( data );
    require(success, "call message err!");
  }

  function call_____value(uint256 amount, bytes calldata data) external
  {
    (bool success, ) = AD.call{value : amount}( data );
    require(success, "call message err!");
  }
}