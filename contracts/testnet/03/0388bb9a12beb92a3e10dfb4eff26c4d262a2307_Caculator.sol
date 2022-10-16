/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

contract Caculator{

 uint256 public result;

function add(uint256 x, uint256 y) public{
    result = x + y;
 }
function subtract(uint256 x, uint256 y) public{
    result = x - y;
 }
function multiplication(uint256 x, uint256 y) public{  
    result = x * y;
}
 
function division(uint256 x, uint256 y) public{
    
    result = x / y;
 }

function modulus(uint256 x, uint256 y) public{
    
    result = x % y;

}

function retrieve() public view returns (uint256){
    return result;
}
 

}