// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token721.sol";

contract MyERC721Card is ERC721Token {
    struct Card {
        string name;
        uint256 level;
    }

    Card[] public cards;
    address public owner;

    constructor()
        ERC721Token("CRASH PET", "PET", "https://j1kl2asjdlk.usemoralis.com/")
    {
        owner = msg.sender;
    }

    function mintCard(
        string memory name,
        address account,
        string memory tokenURI_
    ) public {
        require(owner == msg.sender);
        uint256 cardId = cards.length;
        cards.push(Card(name, 1));
        _mint(account, cardId);
        setTokenURI(cardId, tokenURI_);
    }
}