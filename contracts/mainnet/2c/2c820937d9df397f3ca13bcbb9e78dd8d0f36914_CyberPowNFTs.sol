// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../ERC721.sol";
import "../ERC721Enumerable.sol";
import "../ERC721URIStorage.sol";
import "../Ownable.sol";
import "../Counters.sol";


contract CyberPowNFTs is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 MAX_SUPPLY = 200;

    constructor() ERC721("CyberPow NFTs", "CPOWN") {}

    function safeMint(address to, string memory uri, uint256 amount) public onlyOwner {
        require (amount <= MAX_SUPPLY, "number of mints is greater than the total supply!");
        for(uint256 i=0; i<amount; i++){
            uint256 tokenId = _tokenIdCounter.current();
            require (tokenId <= MAX_SUPPLY, "All NFTs have been minted!");
            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
            _setTokenURI(tokenId, uri);
     }
        
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}