/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT
    pragma solidity 0.8.9;
        
    contract Claiming {
        
       uint256 number;
        
       function updateValues(uint256 num) public {
          number = num;
       }
        
       function retrieve() public view returns (uint256){
          return number;
       }
    }