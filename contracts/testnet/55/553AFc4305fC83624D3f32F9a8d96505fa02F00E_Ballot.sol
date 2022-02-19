/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// File: W1/Ballot.sol




/*Ballot is a voting system created by Parsa Bahmani in June 2020*/

pragma solidity >=0.7.0 <0.9.0;

contract Ballot {
    struct Proposal {
        uint8 voteCount;
    }
    Proposal[] public proposals;

    struct Voter {
        uint8 vote;
        uint8 weight;
        bool voted;
    }
    mapping (address => Voter) public voters;

    address public chairperson; 

    constructor (uint8 proposalCount) {
        chairperson = msg.sender; 
        voters[chairperson].weight = 2;

        for (uint8 i=0; i<proposalCount; i++){
            proposals.push (Proposal({voteCount: 0}));
        }
    }

    function register(address voterAdd) public {
        require (voterAdd != chairperson, "chairperson cannot register again");
        require(msg.sender == chairperson, "inly chairperson can register!");
        require(voters[voterAdd].voted == false, "voter alreeady voted");
        voters[voterAdd].weight=1;
    }

 function vote (uint8 proposalID) public {
        require(voters [msg.sender].weight != 0 , "you don't registered yet!");
        require(voters [msg.sender].voted == false , "you already voted!");
        voters[msg.sender].vote = proposalID;
        voters[msg.sender].voted == true;
        proposals[proposalID].voteCount += voters[msg.sender].weight;
    }

    function count () public view returns(uint8 winnerProp_ID, uint8 winnerProp_VoteCount) {
        uint numberOfProps = proposals.length;
        for (uint8 i=0; i<numberOfProps; i++){
              if (proposals[i].voteCount > winnerProp_VoteCount)
                    winnerProp_VoteCount = proposals[i].voteCount;
                    winnerProp_ID = i;
                }
        }
    }