// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Counters.sol";
import "./Ownable.sol";

contract PIN721 is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    address public marketplace;

    struct Item {
        uint256 id;
        address creator;
        string uri; //metadata url
    }

    mapping(uint256 => Item) public Items; //id => Item

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {

    }

    function mint(string memory uri, uint256 tokenId) public returns (uint256) {
        uint256 newItemId = tokenId;
        _safeMint(msg.sender, newItemId);
        approve(marketplace, newItemId);

        Items[newItemId] = Item({id: newItemId, creator: msg.sender, uri: uri});

        return newItemId;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );
        return Items[tokenId].uri;
    }

    function setMarketplace(address market) external {
        require(msg.sender == owner(), "PIN721_INVALID_OWNER");
        marketplace = market;
    }
}