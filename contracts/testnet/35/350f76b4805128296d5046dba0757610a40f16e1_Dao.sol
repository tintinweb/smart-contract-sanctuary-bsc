/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

abstract contract ERC20 {
    function balanceOf(address whom) public view virtual returns (uint256);
}

contract Dao {
    address public owner;
    uint256 public nextProposal;
    ERC20 token = ERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint256 public totalProposal;
    uint256 public totalProposalPassed;

    constructor() {
        owner = msg.sender;
        nextProposal = 1;
        totalProposal = 0;
        totalProposalPassed = 0;
    }

    struct proposal {
        uint256 id;
        bool exists;
        string description;
        uint256 deadline;
        uint256 votesUp;
        uint256 votesDown;
        mapping(address => bool) voteStatus;
        bool countConducted;
        bool passed;
    }

    mapping(uint256 => proposal) public Proposals;

    event proposalCreated(uint256 id, string description, address proposer);

    event newVote(
        uint256 votesUp,
        uint256 votesDown,
        address voter,
        uint256 proposal,
        bool votedFor
    );

    event proposalCount(uint256 id, bool passed);

    function checkProposalEligibility(address _voter)
        private
        view
        returns (bool)
    {
        if (token.balanceOf(_voter) >= 0) {
            return true;
        }

        return false;
    }

    function checkVoteEligibility(address _voter) private view returns (bool) {
        if (token.balanceOf(_voter) >= 0) {
            return true;
        }

        return false;
    }

    function createProposal(string memory _description, uint256 _blocks)
        public
    {
        require(msg.sender == owner, "Only Owner Can Create Proposal");
        /*require(
            checkProposalEligibility(msg.sender),
            "Only {token} holders can put forth Proposals"
        );*/

        proposal storage newProposal = Proposals[nextProposal];
        newProposal.id = nextProposal;
        newProposal.exists = true;
        newProposal.description = _description;
        newProposal.deadline = block.number + _blocks;

        emit proposalCreated(nextProposal, _description, msg.sender);
        nextProposal++;
        totalProposal++;
    }

    function voteOnProposal(uint256 _id, bool _vote) public {
        require(Proposals[_id].exists, "This Proposal does not exist");
        require(
            checkVoteEligibility(msg.sender),
            "You can not vote on this Proposal"
        );
        require(
            !Proposals[_id].voteStatus[msg.sender],
            "You have already voted on this Proposal"
        );
        require(
            block.number <= Proposals[_id].deadline,
            "The deadline has passed for this Proposal"
        );

        proposal storage p = Proposals[_id];

        if (_vote) {
            p.votesUp++;
        } else {
            p.votesDown++;
        }

        p.voteStatus[msg.sender] = true;

        emit newVote(p.votesUp, p.votesDown, msg.sender, _id, _vote);
    }

    function countVotes(uint256 _id) public {
        require(msg.sender == owner, "Only Owner Can Count Votes");
        require(Proposals[_id].exists, "This Proposal does not exist");
        require(
            block.number > Proposals[_id].deadline,
            "Voting has not concluded"
        );
        require(!Proposals[_id].countConducted, "Count already conducted");

        proposal storage p = Proposals[_id];

        if (Proposals[_id].votesDown < Proposals[_id].votesUp) {
            p.passed = true;
            totalProposalPassed++;
        }

        p.countConducted = true;

        emit proposalCount(_id, p.passed);
    }
}