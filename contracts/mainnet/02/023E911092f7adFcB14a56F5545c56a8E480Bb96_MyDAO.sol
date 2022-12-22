/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

pragma solidity ^0.6.12;

//SPDX-License-Identifier: MIT

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

// This contract represents a simple DAO with governance by voting.
// Members can propose actions and vote on them.
// A proposal can pass if it receives a majority of votes within a certain time period.
contract MyDAO {
    using SafeMath for uint256;

    // The address of the contract owner (the creator of the DAO)
    address public owner;

    // The total number of members in the DAO
    uint256 public numMembers;

    // Mapping of member addresses to their membership information
    mapping(address => Member) public members;

    // Struct to store membership information for a member
    struct Member {
        // The member's voting weight, in tokens
        uint256 votingWeight;
        // Whether the member has voted on the current proposal (true) or not (false)
        bool hasVoted;
    }

    // The address of the contract that holds the tokens used for voting
    address public votingTokenContract;

    // The current proposal being voted on
    Proposal public currentProposal;

    // Struct to store information about a proposal
    struct Proposal {
        // The address of the member who proposed the action
        address member;
        // The action being proposed
        string action;
        // The number of tokens that have been voted in favor of the proposal
        uint256 yesVotes;
        // The number of tokens that have been voted against the proposal
        uint256 noVotes;
        // The total number of tokens that have been voted
        uint256 totalVotes;
        // The voting deadline for the proposal
        uint256 deadline;
        // Whether the proposal has passed (true) or not (false)
        bool passed;
    }

    // Event emitted when a proposal is created
    event ProposalCreated(
        address indexed member,
        uint256 indexed proposalId,
        string action,
        uint256 votingDeadline
    );

    // Event emitted when a member votes on a proposal
    event VoteCast(
        address indexed member,
        uint256 indexed proposalId,
        bool vote
    );

    // Event emitted when a proposal passes or fails
    event ProposalResult(
        uint256 indexed proposalId,
        bool passed
    );

    // Constructor function, called when the contract is deployed
    constructor() public {
        // Set the contract owner as the initial member of the DAO
        owner = msg.sender;
        numMembers = 1;
        members[owner].votingWeight = 1;
    }

    // Function to add a new member to the DAO
    function addMember(address _member, uint256 _votingWeight) public {
        // Check that the caller is the contract owner
        require(msg.sender == owner, "Only the owner can add new members");
        // Check that the member is not already a member
         require(members[_member].votingWeight == 0, "Member is already a member");
    }
}