/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6;


contract BulletRouterScheleton {

  function sendTo(address payable[] calldata addrs, uint[] calldata amounts) public payable {
  }

  function bullet(
    uint256 amountOutMin,
    address[] calldata path,
    uint8 wallets,
    address to,
    uint256 deadline,
    uint8 maxTax
  )
    public
    payable
    virtual
    returns (uint256[] memory amounts)
  {
   
  }

  function bulletExactTokens(
    uint256 amountOut,
    address[] calldata path,
    uint8 wallets,
    address to,
    uint256 deadline,
    uint8 maxTax
  )
    public
    payable
    virtual
    returns (uint256[] memory amounts)
  {
  }

  function bulletHeadshot(bytes12 orderId)
    public
    payable
    virtual
    returns (uint256[] memory amounts)
  {
   
  }

  function bulletHeadshotExact(bytes12 orderId)
    public
    payable
    virtual
    returns (uint256[] memory amounts)
  {
  
  }

}