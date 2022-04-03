/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract calculator{ 
    uint256 public a;
    uint256 public b;
    function addCalc(uint256 _a, uint256 _b) public pure returns(uint256){
        uint256 result;
        result = _a+_b;
        return result;
    }
    function subCalc(uint256 _a, uint256 _b) public pure returns(uint256){
        uint256 result;
        result = _a-_b;
        return result;     
    }
    function mulCalc(uint256 _a, uint256 _b) public pure returns(uint256){
        uint256 result;
        result = _a*_b;
        return result;    
    }
}