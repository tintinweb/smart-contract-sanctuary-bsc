/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

pragma solidity 0.7.5;

contract mahan{

string  data = "Hello World";

 function setStorage(string memory value) public{

 data = value;

 } 

 function getStorage() public view returns (string memory){

     return data;
 }
}