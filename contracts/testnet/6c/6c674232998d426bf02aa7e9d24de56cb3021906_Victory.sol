/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

contract Victory{

     uint256 result;
     string message = "welcome to victory calculator" ;
     function add (uint256 a, uint256 b, uint256 c) public returns (uint256) {
       return result = a + b + c ;
     }
     function sub (uint256 a, uint256 b, uint256 c) public returns (uint256) {
       return result = a - b - c ;
     }
     function mul (uint256 a, uint256 b, uint256 c) public returns (uint256) {
       return result = a * b * c ; 
     }
     function divide (uint256 a, uint256 b, uint256 c) public returns (uint256) {
       return result = a / b / c ;
     }
     function getresult () public view returns (uint256) {
       return result ;
     }
}