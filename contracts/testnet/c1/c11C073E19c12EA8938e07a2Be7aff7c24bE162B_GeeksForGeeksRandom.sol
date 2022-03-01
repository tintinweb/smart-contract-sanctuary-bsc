/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

// Solidity program to
// demonstrate on how
// to generate a random number
pragma solidity ^0.6.6;

// Creating a contract
contract GeeksForGeeksRandom
{

// Initializing the state variable
uint randNonce = 0;

// Defining a function to generate
// a random number

function testEncode() public pure returns(bytes memory) {
  return abi.encodePacked('tornado'); 
 }

 function testEncode2() public pure returns(uint) {
  return uint(keccak256(abi.encodePacked('tornado'))) % 21888242871839275222246405745257275088548364400416034343698204186575808495617 ; 
 }
}