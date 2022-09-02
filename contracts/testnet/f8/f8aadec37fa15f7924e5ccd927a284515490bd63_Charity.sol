/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

contract Charity {
    event ProposalIDList(bytes32 indexed ngoID, uint256 indexed proposalID);

    event ProposalTable(
        address ngoAddress,
        uint256 indexed proposalID,
        string title,
        string description,
        uint256 amtThreshold
    );

    event Transfer(
        uint256 indexed proposalID,
        address from,
        address receiver,
        uint256 amount,
        string message,
        uint256 timestamp
    );

    struct NGO {
        bytes32 _id;
        address wallet_address;
        bool ngoExists;
    }

    uint256 curr_id = 0;

    struct Proposal {
        uint256 id;
        bytes32 postOwner;
        string title;
        string content;
        uint256 amt; // funds received
        uint256 amtThreshold; // funds to be raised
        bool proposalExists; // to check if proposal already exists
        bool closed; // true if proposal has raised required funds
    }

    // Map of all NGOs
    mapping(bytes32 => NGO) public ngoRegistry;
    mapping(uint256 => Proposal) public proposalRegistry;

    function createNGO() public {
        bytes32 id = keccak256(abi.encode(msg.sender));
        ngoRegistry[id]._id = id;
        ngoRegistry[id].wallet_address = msg.sender;
        ngoRegistry[id].ngoExists = true;
    }

    function createProposal(
        string memory title,
        string memory content,
        uint256 amtThreshold
    ) public returns (bool) {
        bytes32 NGOId = keccak256(abi.encode(msg.sender));
        if (ngoRegistry[NGOId].ngoExists) {
            uint256 id = curr_id;
            curr_id += 1;

            proposalRegistry[id].proposalExists = true;
            proposalRegistry[id].closed = false;
            proposalRegistry[id].postOwner = NGOId;
            proposalRegistry[id].id = id;
            proposalRegistry[id].title = title;
            proposalRegistry[id].content = content;
            proposalRegistry[id].amt = 0;
            proposalRegistry[id].amtThreshold = amtThreshold * (1 ether);

            emit ProposalIDList(NGOId, id);
            emit ProposalTable(msg.sender, id, title, content, amtThreshold);
            return true;
        }
        return false;
    }

    function transferFunds(uint256 proposalID, string memory message)
        public
        payable
    {
        if (proposalRegistry[proposalID].proposalExists) {
            bytes32 NGOId = proposalRegistry[proposalID].postOwner;

            if (ngoRegistry[NGOId].ngoExists) {
                address receiver = ngoRegistry[NGOId].wallet_address;

                if (msg.sender != receiver) {
                    payable(receiver).transfer(msg.value);
                    emit Transfer(
                        proposalID,
                        msg.sender,
                        receiver,
                        msg.value,
                        message,
                        block.timestamp
                    );
                    proposalRegistry[proposalID].amt += msg.value;

                    if (proposalReachedThreshold(proposalID)) {
                        proposalRegistry[proposalID].closed = true;
                    }
                }
            }
        }
    }

    function proposalReachedThreshold(uint256 proposalID)
        private
        view
        returns (bool)
    {
        return
            proposalRegistry[proposalID].amt >=
            proposalRegistry[proposalID].amtThreshold;
    }

    function getProposal(uint256 proposalID)
        public
        view
        returns (
            bytes32,
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        return (
            proposalRegistry[proposalID].postOwner,
            proposalRegistry[proposalID].title,
            proposalRegistry[proposalID].content,
            proposalRegistry[proposalID].amt,
            proposalRegistry[proposalID].amtThreshold,
            proposalRegistry[proposalID].closed
        );
    }
}