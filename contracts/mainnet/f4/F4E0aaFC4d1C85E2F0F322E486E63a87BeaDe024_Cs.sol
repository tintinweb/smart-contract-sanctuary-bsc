/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

contract Cs {
 address owner;
 uint  k;
 string stringStr = "hello!world";
 
 mapping (address => uint256) _balances;
 
 constructor() public {
   owner = msg.sender;
 }

 modifier onlyOwner() {
  require(msg.sender == owner);
  _;
 }

 function get() public view returns(address){
    return owner;
 }
 function gete() public view returns(address){
    return msg.sender;
 }

 function gai() public onlyOwner{
    k=0;
 }

 function getStringAll() public view returns(string memory){
        return stringStr;
    }

function jd(uint sz) public{
    k += sz;
    _balances[msg.sender] += sz;
}

function  zg() public view returns(uint256){
   return k;
}

function qbzr(address zh) public view returns(uint){
     uint sz = _balances[zh];
     return sz;
}


}