// SPDX-License-Identifier: GPL-3.0

import "./flypaper.sol";

pragma solidity ^0.6.12;

contract SwapMeet_Vote {

    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    struct Project {
        bytes32 title;
    }

    uint _minimum;

    FlyPaper public flyPaper;

    address public initiator;

    modifier eligible() {
        flyPaper = FlyPaper(0x5168C0112B6b55A2719f798590F124DBbB001ea6);
        uint balance = flyPaper.balanceOf(msg.sender);
        require (balance > 1000000000000000);
        _;
    }

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    /** 
    * @dev Create a new ballot to choose one of proposalNames
    */
    constructor(bytes32[] memory voteDetails) public {
        initiator = msg.sender;

        for (uint i = 0; i < voteDetails.length; i++) {
            proposals.push(Proposal({
                name: voteDetails[i],
                voteCount: 0
            }));
        }
    }

    /**
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */
    function vote(uint proposal) public eligible {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    /** 
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return winnerName_ the name of the winner
     */
    function winnerName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}