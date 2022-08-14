//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract DAO {
    // variables
    struct Member {
        address publicAddress;
        uint256 score;
        bool active;
    }

    struct CandidancyProposal {
        address candidate;
        uint256 forVotes;
        uint256 againstVotes;
        address[] sponsors;
        address[] voters;
        mapping(address => bool) voted;
    }

    Member[] public allMembers;

    uint256 SCORE_AFTER_VOTE = 100;
    address public OWNER;

    mapping(address => Member) public members;

    mapping(address => CandidancyProposal) public candidancyProposals;

    mapping(address => bool) public blacklisted;

    uint256 public proposalsCreated = 0;

    constructor() {
        members[msg.sender].publicAddress = msg.sender;
        members[msg.sender].score = 0;
        members[msg.sender].active = true;
        OWNER = msg.sender;
        allMembers.push(members[msg.sender]);
    }

    function signAsSponsor(address user) public {
        require(members[msg.sender].active,"not a member");
        candidancyProposals[user].sponsors.push(msg.sender);
    }

    function getSponsorsOfProposal(address user)
        public
        view
        returns (address[] memory)
    {
        return candidancyProposals[user].sponsors;
    }

    function calculateResult(address user) public returns (bool) {
        require(msg.sender == OWNER,"only the owner can call this function");
        uint256 forVotes = candidancyProposals[user].forVotes;
        uint256 againstVotes = candidancyProposals[user].againstVotes;
        if (forVotes > againstVotes) {
            
            members[candidancyProposals[user].candidate].publicAddress = candidancyProposals[user].candidate;
            members[candidancyProposals[user].candidate].score = 0;
            members[candidancyProposals[user].candidate].active = true;
            // add scores for sponsor
            for (
                uint256 i;
                i < candidancyProposals[user].sponsors.length;
                i++
            ) {
                members[candidancyProposals[user].sponsors[i]]
                    .score += SCORE_AFTER_VOTE;
            }
            return true;
        } else {
            blacklisted[candidancyProposals[user].candidate] = true;
            // substract scores for sponsor
            for (
                uint256 i;
                i < candidancyProposals[user].sponsors.length;
                i++
            ) {
                members[candidancyProposals[user].sponsors[i]]
                    .score -= SCORE_AFTER_VOTE;
            }
            return false;
        }
    }

    function voteToCandidancyProposal(bool vote, address user) public {
        // give vote
        require(members[msg.sender].active,"not a member");
        require(!blacklisted[user],"user is blacklisted");
        require(!members[user].active,"user is already a member");
        require(candidancyProposals[user].candidate != msg.sender,"you can't vote for yourself");
        require(!candidancyProposals[user].voted[msg.sender],"you have already voted");

        if (vote) {
            candidancyProposals[user].forVotes++;
        } else {
            candidancyProposals[user].againstVotes++;
        }

        candidancyProposals[user].voters.push(msg.sender);
        candidancyProposals[user].voted[msg.sender] = true;
    }

    function saveCandidancyProposal() public {
        require(!blacklisted[msg.sender],"user is blacklisted");

        candidancyProposals[msg.sender].candidate = msg.sender;
        candidancyProposals[msg.sender].forVotes = 0;
        candidancyProposals[msg.sender].againstVotes = 0;

        proposalsCreated++;
    }

    function trasferOwnership(address user) public {
        require(msg.sender == OWNER,"only the owner can call this function");
        require(user != address(0),"user is not valid");
        OWNER = user;
        members[OWNER].publicAddress = OWNER;
        members[OWNER].score = 0;
        members[OWNER].active = true;
        allMembers.push(members[OWNER]);
    }

    function setScore(uint256 score) public {
        require(msg.sender == OWNER,"only the owner can call this function");
        SCORE_AFTER_VOTE = score;
    }
}