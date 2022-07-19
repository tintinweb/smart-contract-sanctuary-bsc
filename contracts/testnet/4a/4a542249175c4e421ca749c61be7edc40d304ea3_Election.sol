/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Election {
    

    constructor ()  {
        addCandidate("candidate 1");
        addCandidate("candidate 2");
    }

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }
    mapping(uint => Candidate) public candidatesList; 
    mapping(address=>bool) public alreadyvotedList; 
    uint public candidatesCount;
    event votedEvent ( uint indexed _candidateId);

    function addCandidate(string memory name) private {
        candidatesCount ++;
        candidatesList[candidatesCount] = Candidate(candidatesCount, name, 0);

    }

    function vote(uint _candidateId) public returns (address) {
      require(!alreadyvotedList[msg.sender],"already voted");

      require(_candidateId > 0 && _candidateId <=candidatesCount,"candidateId cannot be greater");  
      alreadyvotedList[msg.sender]=true;
      candidatesList[_candidateId].voteCount ++;
      emit votedEvent(_candidateId);
      return msg.sender;
    }

 
}