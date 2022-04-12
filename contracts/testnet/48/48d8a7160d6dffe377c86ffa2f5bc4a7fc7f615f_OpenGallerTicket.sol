// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Context.sol";
import "./Ownable.sol";
import "./IERC721Receiver.sol";


interface IGallerTicket {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IDracooMaster {
    function safeMint(address to) external returns (uint256);
}

// must be assigned as a MinterRole of "DracooMaster" contract
contract OpenGallerTicket is IERC721Receiver, Ownable {
    IDracooMaster public dracoo;

    // signer
    bool private _isAvailable;
    address public ticket;


    event OpenTicketForDracoo(address indexed owner, address indexed ticketAddress, uint256 indexed dracooTokenId, uint256 ticketTokenId);

    constructor (address dracooAddress, address _ticket) public {
        dracoo = IDracooMaster(dracooAddress);
        _isAvailable = false;
        ticket = _ticket;
    }

    function setAvailable(bool newState) external onlyOwner {
        _isAvailable = newState;
    }

    function isAvailable() public view returns(bool) {
        return _isAvailable;
    }

    function setTicket(address _ticket) external onlyOwner {
        ticket = _ticket;
    }

    // must call ticket contract's "setApproveForAll"
    function openTicketForDracoo(uint256 ticketTokenId) public returns(uint256) {
        require(isAvailable(), "not available now");
        IGallerTicket(ticket).safeTransferFrom(msg.sender, address(this), ticketTokenId);
        uint256 dracooTokenId = dracoo.safeMint(msg.sender);
        emit OpenTicketForDracoo(msg.sender, ticket, dracooTokenId, ticketTokenId);
        return dracooTokenId;
    }

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }

}