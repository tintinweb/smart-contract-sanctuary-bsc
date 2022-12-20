// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BEP721.sol";
import "./Ownable.sol";
import "./BEP721URIStorage.sol";
import "./Counters.sol";

contract MyToken is BEP721, BEP721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() BEP721("CryptoDiamonds", "CMD") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://wow-studio-metadata.s3.us-east-1.amazonaws.com/capacitors/{id}";
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(BEP721, BEP721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(BEP721, BEP721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}