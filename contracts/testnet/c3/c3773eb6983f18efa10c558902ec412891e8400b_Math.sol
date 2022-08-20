/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

pragma solidity ^0.8.6;
 contract Math {
     uint256 public result;

     function add(uint256 _value) public {
         result = result + _value;
     }

     function sub(uint256 _value) public {
         result = result - _value;
     }

 }