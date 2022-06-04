/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: MIT
    pragma solidity 0.8.9;
    
    contract Claim {
    
        uint256 number;
    
        function updateData(uint256 num) public {
            number = num;
        }
    
        function retrieve() public view returns (uint256){
            return number;
        }
    }