/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

pragma solidity ^0.4.17;
contract Contract {
 string ipfsHash;
 
 function sendHash(string x) public {
   ipfsHash = x;
 }

 function getHash() public view returns (string x) {
   return ipfsHash;
 }
}