/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface BIFIBalanceToken {
  function balanceOf(address account) external view returns (uint256);
}

interface BIFIMaxi {
  function want() external view returns (BIFIBalanceToken);
  function balanceOf(address account) external view returns (uint256);
  function getPricePerFullShare() external view returns (uint256);
}

contract BIFIPoolBalance {

  BIFIMaxi public maxi;
  BIFIBalanceToken public gov;

  constructor(BIFIMaxi _bifiMaxiVault, BIFIBalanceToken _governancePool) {
    maxi = _bifiMaxiVault;
    gov = _governancePool;
  }

  function balanceOf(address account) external view returns (uint256) {
    uint ppfs = maxi.getPricePerFullShare();
    return maxi.balanceOf(account) * ppfs / 1e18 + gov.balanceOf(account);
  }

}