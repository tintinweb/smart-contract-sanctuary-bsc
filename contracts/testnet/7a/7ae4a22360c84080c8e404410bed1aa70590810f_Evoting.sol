/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

pragma solidity ^0.8.16;

contract Evoting {
    // Model a Candidate
    struct Candidate {
        uint id;  // starts from 1
        string name;
        uint numVotes;
    }

    // All Candidates by id
    mapping(uint => Candidate) public candidates;

    // Number of Candidates
    uint public numCandidates;

    // Store the addresses that have already voted
    mapping(address => bool) public voters;

    // To trigger this event whenever a vote is cast
    event votedEvent (
        uint indexed _candidateId
    );

    // Add a candidate by name into the mapping, auto-increment id
    function addCandidate (string memory _name) private {
        ++numCandidates;
        candidates[numCandidates] = Candidate(numCandidates, _name, 0);
    }

    // Constructor
    constructor() public {
        addCandidate("Alice");  // id is 1
        addCandidate("Bob");    // id is 2
    }

    // The caller address casts a vote for a candidate
    function vote (uint _candidateId) public {
        // require that they haven't voted before
        require(!voters[msg.sender], "already voted");

        // require a valid candidate
        require(_candidateId > 0 && _candidateId <= numCandidates, "invalid candidate id");

        // record that voter has voted
        voters[msg.sender] = true;  // msg.sender is the caller address

        // update candidate vote Count
        ++candidates[_candidateId].numVotes;

        // trigger voted event
        emit votedEvent(_candidateId);
    }
}