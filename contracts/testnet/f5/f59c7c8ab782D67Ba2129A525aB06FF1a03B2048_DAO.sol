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
        Member memory member = Member(msg.sender, 0, true);
        members[msg.sender] = member;
        OWNER = msg.sender;
        allMembers.push(member);
    }

    function signAsSponsor(address user) public {
        require(members[msg.sender].active);
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
        require(msg.sender == OWNER);
        uint256 forVotes = candidancyProposals[user].forVotes;
        uint256 againstVotes = candidancyProposals[user].againstVotes;
        if (forVotes > againstVotes) {
            // if candidate wins
            Member memory newMember = Member(
                candidancyProposals[user].candidate,
                0,
                true
            );
            members[candidancyProposals[user].candidate] = newMember;
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
        require(members[msg.sender].active);
        require(candidancyProposals[user].candidate != msg.sender);
        require(!candidancyProposals[user].voted[msg.sender]);

        if (vote) {
            candidancyProposals[user].forVotes++;
        } else {
            candidancyProposals[user].againstVotes++;
        }

        candidancyProposals[user].voters.push(msg.sender);
        candidancyProposals[user].voted[msg.sender] = true;
    }

    function saveCandidancyProposal() public {
        require(!blacklisted[msg.sender]);
        CandidancyProposal storage newProposal = candidancyProposals[
            msg.sender
        ];

        newProposal.candidate = msg.sender;
        newProposal.forVotes = 0;
        newProposal.againstVotes = 0;

        proposalsCreated++;
    }

    function trasferOwnership(address user) public {
        require(msg.sender == OWNER);
        require(user != address(0));
        OWNER = user;
        Member memory member = Member(user, 0, true);
        members[user] = member;
        allMembers.push(member);
    }

    function setScore(uint256 score) public {
        require(msg.sender == OWNER);
        SCORE_AFTER_VOTE = score;
    }
}