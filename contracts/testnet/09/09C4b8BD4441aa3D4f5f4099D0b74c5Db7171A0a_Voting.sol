pragma solidity ^0.6.4;

contract Voting {
    event ProposalCreated(address indexed proposedBy);
    event Voted(address indexed voter);

    struct Proposal {
        string title;
        address proposedBy;
        uint256 voteCountPos;
        uint256 voteCountNeg;
        mapping(address => Voter) voters;
        address[] votersAddress;
    }

    struct Voter {
        bool agreed;
        bool voted;
    }

    Proposal[] proposals;

    function getNumProposals() public view returns (uint256) {
        return proposals.length;
    }

    function getNumVoters(uint256 proposalId) public view returns (uint256) {
        Proposal storage p = proposals[proposalId];
        return p.votersAddress.length;
    }

    function getVoterAddress(uint256 proposalId, uint256 voterId)
        public
        view
        returns (address)
    {
        Proposal storage p = proposals[proposalId];
        return p.votersAddress[voterId];
    }

    function hasVoted(uint256 proposalId, address votersAddress)
        public
        view
        returns (bool)
    {
        Proposal storage p = proposals[proposalId];
        return p.voters[votersAddress].voted;
    }

    function getProposal(uint256 proposalId)
        public
        view
        returns (
            uint256,
            string memory,
            address,
            uint256,
            uint256
        )
    {
        if (proposals.length > 0) {
            Proposal storage p = proposals[proposalId]; // Get the proposal
            return (
                proposalId,
                p.title,
                p.proposedBy,
                p.voteCountPos,
                p.voteCountNeg
            );
        }
    }

    function addProposal(string memory title) public {
        Proposal memory proposal;
        proposal.title = title;
        proposal.proposedBy = msg.sender;
        proposals.push(proposal);
        emit ProposalCreated(msg.sender);
    }

    function vote(uint256 proposalInt, bool agreed) public {
        Proposal storage p = proposals[proposalInt]; // Get the proposal
        require(
            !hasVoted(proposalInt, msg.sender),
            "You have already voted for this proposal"
        );
        if (agreed) {
            p.voteCountPos += 1;
        } else {
            p.voteCountNeg += 1;
        }
        p.voters[msg.sender].agreed = agreed;
        p.voters[msg.sender].voted = true;
        p.votersAddress.push(msg.sender);

        emit Voted(msg.sender);
    }
}