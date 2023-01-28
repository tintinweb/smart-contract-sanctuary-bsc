/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IRewardRouter {
  function claim(uint256 tokenid) external returns (bool);
}

contract HokbClaimAll {

  constructor() {}

  function MultiClaim(uint256[] memory ids,address router) public returns (bool) {
    uint256 i = 0;
    do{
        IRewardRouter(router).claim(ids[i]);
        i++;
    }while(i<ids.length);
    return true;
  }

}