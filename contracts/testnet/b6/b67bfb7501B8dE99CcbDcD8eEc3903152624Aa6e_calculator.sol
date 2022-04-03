/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract calculator{ 
    function addCalc(uint256 a, uint256 b) public pure returns(uint256){
        uint256 result;
        result = a+b;
        return result;
    }
    function subCalc(uint256 a, uint256 b) public pure returns(uint256){
        uint256 result;
        result = a-b;
        return result;     
    }
    function mulCalc(uint256 a, uint256 b) public pure returns(uint256){
        uint256 result;
        result = a*b;
        return result;    
    }
}