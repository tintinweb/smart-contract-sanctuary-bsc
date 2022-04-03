/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract largest_of_three{
    function largest(uint256 a, uint256 b, uint256 c) public pure returns(uint256){
        uint256 large;
        if(a>b && a>c){
            large = a;
        }
        else if(b>a && b>c){
            large = b;
        }
        else{
            large = c;
        }
        return large;
    } 
}