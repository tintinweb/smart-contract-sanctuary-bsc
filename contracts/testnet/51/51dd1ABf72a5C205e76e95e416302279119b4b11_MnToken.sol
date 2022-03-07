/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MnToken {
    uint256 public result;
   


  function test(uint256 b)public{
           result=b; 
    }

    function getResult()public view returns (uint256){
        return result;
    }
    
}