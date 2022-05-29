/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
contract foo{
    function checkbal() public view returns(uint){
     return address(this).balance;
    }
}