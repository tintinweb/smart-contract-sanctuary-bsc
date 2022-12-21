/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

pragma solidity ^0.8.17;

// Creating a contract
contract GeeksForGeeksRandom
{
 
// Initializing the state variable
uint randNonce = 0;
 
// Defining a function to generate
// a random number
function randMod(uint _modulus) internal returns(uint)
{
   // increase nonce
   randNonce++; 
   return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
 }
}