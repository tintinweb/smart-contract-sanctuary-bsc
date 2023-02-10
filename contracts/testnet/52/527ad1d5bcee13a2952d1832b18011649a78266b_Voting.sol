/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.4.6;

contract Voting { 

 mapping (bytes32 => uint8) public votesReceived; 
 
 
 
 bytes32[] public candidateList; 

 function Voting(bytes32[] candidateNames) 
 { 

 candidateList = candidateNames; 

 } 
 function totalVotesFor(bytes32 candidate) returns (uint8) 
 { 

 require(validCandidate(candidate)); 
 return votesReceived[candidate]; 

 } 
 function voteForCandidate(bytes32 candidate)
 { 

 require(validCandidate(candidate)); 
 votesReceived[candidate] += 1; 

 } 
 function validCandidate(bytes32 candidate) returns (bool) 
 { 

 for(uint i = 0; i < candidateList.length; i++) 
 { 
 if (candidateList[i] == candidate)
  { 
 return true; 
 } 
 } 
 return false; 
 } 
 
 function getCandidateList() constant returns (bytes32[]) 
 { 
 return candidateList; 
 } 
}