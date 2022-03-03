/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// Solidity program to demonstrate on how
// to generate a Pedersen Hash On The Baby Jubjub Elliptic Curve
// for DecentraWorld's DeMix MerkleTree Function 
// Learn more at https://DecentraWorld.co or our GitHub page

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract PHashGeneratorForDEWO
{
   uint256 _babyjubjubcurvep = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
   //Credit: Hat, Barry White. n.d. “Baby-Jubjub Supporting Evidence.” GitHub.
   //https://github.com/barryWhiteHat/baby_jubjub

//function to calculate any key(word) as Pedersen Hash on the Baby-Jubjub Elliptic Curve
 function zeroValueGenerator(string memory _keyword) external view returns(uint256) {
  return uint256(keccak256(abi.encodePacked(_keyword))) % _babyjubjubcurvep ; 
  //Pedersen Hash On The Baby Jubjub Elliptic Curve
  //Resource Credit: Jordi Baylina1 and Marta Bell´es1,2
  //https://iden3-docs.readthedocs.io/en/latest/_downloads/4b929e0f96aef77b75bb5cfc0f832151/Pedersen-Hash.pdf
 }

    function hash(string memory _text) public pure returns (bytes32) {
        return keccak256(abi.encode(_text));
    }


}