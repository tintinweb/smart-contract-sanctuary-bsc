/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract area_of_rect{
    function areaRect(uint256 height, uint256 width) public pure returns(uint256){
        uint256 area;
        area = height * width;
        return area;
    } 
}