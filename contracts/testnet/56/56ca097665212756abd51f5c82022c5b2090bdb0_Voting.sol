/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.4.22;

contract Voting {
    mapping (bytes1 => uint8) public votesReceived;
    bytes1[] public candidateList;
    constructor(bytes1[] candidateName) public {
        candidateList = candidateName;
    }
    
    function validateCandidate(bytes1 candidateName) internal view returns(bool){
        for(uint8 i = 0;i <candidateList.length;i++){
            if(candidateName == candidateList[i])
                return true;
        }
        return false;
    }
    function vote(bytes1 candidateName) public{
        require(validateCandidate(candidateName));
        votesReceived[candidateName] +=1;
    }
    function totalVotesFor(bytes1 candidateName) public view returns(uint8){
        require(validateCandidate(candidateName));
        votesReceived[candidateName];

    }

}