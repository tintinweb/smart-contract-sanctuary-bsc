/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;
 
contract deposit{
    receive() external payable {
    }
    fallback() external payable {
    }
    function getBalance() public view returns (uint){
        return address(this).balance  ;
    }
}