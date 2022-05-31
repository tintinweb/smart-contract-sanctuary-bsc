/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ArrayUtils{
    
    function map(uint[] memory self, function (uint) pure returns (uint) f)
      internal
      pure
      returns(uint[] memory r)
    {
      r = new uint[](self.length);
      for(uint i  = 0; i < self.length; i++){
          r[i] = f(self[i]);
      }
    }
    
    function reduce(
      uint[] memory self,
      function(uint, uint) pure returns (uint) f
    )
      internal
      pure
      returns(uint r)
    {
      r = self[0];
      for(uint i = 1; i < self.length; i++){
          r = f(r, self[i]);
      }
    }
    
    function range(uint length) internal pure returns(uint[] memory r){
      r = new uint[](length);
      for(uint i = 0; i < r.length; i++){
          r[i] = i;
        }
    }
    
}