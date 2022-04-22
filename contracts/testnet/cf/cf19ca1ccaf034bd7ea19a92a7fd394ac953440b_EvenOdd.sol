/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract EvenOdd{
    function checked(uint _number) public pure returns(string memory) {
     string memory op;
     if(_number % 2 == 0){
         op="Even";
     } else {
         op="Odd";
     }
     return op;
    }
}