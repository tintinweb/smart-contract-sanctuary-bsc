/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IENGINE {
    function contribution_id() external view returns (uint256);
    function contribution_idowner(uint256 index) external view returns (address);
}

contract readabledata {

function getPacksSlot(address engine,address account,uint256 slot) external view returns (uint256) {
    uint256 i;
    uint256 skip;
    IENGINE a = IENGINE(engine);
    uint256 max = a.contribution_id();
    while (i <= max) {
      address owner = a.contribution_idowner(i);
      if(account==owner){
          if(slot==skip){
              return i;
          }else{
              skip++;
          }
      }
      i++;
    }
    return 0;
}

}