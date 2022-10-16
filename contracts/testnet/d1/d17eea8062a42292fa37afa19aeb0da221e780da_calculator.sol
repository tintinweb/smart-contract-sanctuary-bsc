/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
contract calculator {
    uint256 public result;
    function add (uint256 x, uint256 y) public{
    result=x+y;
    }  
    function div (uint256 x, uint256 y) public{
    result=x/y;
}
function mul (uint256 x, uint256 y) public{
    result=x*y;
}
}