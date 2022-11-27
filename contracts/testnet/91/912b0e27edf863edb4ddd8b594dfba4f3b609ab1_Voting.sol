/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// File: contracts/Voting..sol


pragma solidity ^0.8.17;

/*
    This is the voting smart contract for proposals
*/
contract Voting {
    //variables declaration
     struct Proposal {
         uint256 vote;
         mapping(address => bool) voters;
     }
     mapping(string => Proposal) GLOBAL_PROPOSAL;
     
      
     /* 
        To vote on a proposal
    */
     function vote(string memory _proposalId) external returns(bool){
          Proposal storage _proposal = GLOBAL_PROPOSAL[_proposalId];
          //check if user has voted already
          require(!_proposal.voters[msg.sender], "Has voted already");
          //increment vote
          _proposal.voters[msg.sender] = true;
          _proposal.vote = _proposal.vote + 1;
          return true;
     }
     /*
        To get vote details of a proposal
    */
    function getProposal(string memory _proposalId) external view returns(uint256, bool) {
        Proposal storage _prop = GLOBAL_PROPOSAL[_proposalId];
        return (_prop.vote, _prop.voters[msg.sender]);
    }

}