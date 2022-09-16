/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.7;


//By : 0xdaebak
//https://github.com/0xdaebak


contract ifContract{


function isContract(address addr) public view returns (bool) {
  uint size;
  assembly { size := extcodesize(addr) }
  return size > 0;
}




}