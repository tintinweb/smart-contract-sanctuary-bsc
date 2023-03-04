/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

pragma solidity ^0.8.0;

contract Voting {
    // Candidate struct
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    // Array of candidates
    Candidate[] public candidates;

    // Mapping of voter addresses to their vote choice
    mapping(address => uint256) public votes;

    // Constructor to add candidates to the array
    constructor() {
        candidates.push(Candidate("Candidate 1", 0));
        candidates.push(Candidate("Candidate 2", 0));
        candidates.push(Candidate("Candidate 3", 0));
        candidates.push(Candidate("Candidate 4", 0));
        candidates.push(Candidate("Candidate 5", 0));
        candidates.push(Candidate("Candidate 6", 0));
        candidates.push(Candidate("Candidate 7", 0));
        candidates.push(Candidate("Candidate 8", 0));
        candidates.push(Candidate("Candidate 9", 0));
        candidates.push(Candidate("Candidate 10", 0));
    }

    // Function to cast a vote
    function vote(uint256 candidateIndex) public {
        require(candidateIndex < candidates.length, "Invalid candidate index.");
        require(votes[msg.sender] == 0, "You have already voted.");

        candidates[candidateIndex].voteCount++;
        votes[msg.sender] = candidateIndex + 1;
    }

    // Function to get the winner
    function getWinner() public view returns (string memory) {
        uint256 highestVoteCount = 0;
        uint256 winnerIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > highestVoteCount) {
                highestVoteCount = candidates[i].voteCount;
                winnerIndex = i;
            }
        }

        return candidates[winnerIndex].name;
    }
}