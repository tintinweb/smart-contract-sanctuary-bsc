// SPDX-License-Identifier: MIT
import "./Context.sol";
import "./Address.sol";
import "./String.sol";
import "./ERC721.sol";
import "./Counter.sol";

// File: contracts/MyToken.sol


pragma solidity ^0.8.4;







contract MyToken is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    string private _baseUri;

    Counters.Counter private _tokenIdCounter;
    uint256 public maxSupply;
    uint256 public maxMintPerWallet = 3;

    mapping(address => bool) whitelist;

    constructor(string memory _tokenName, string memory _tokenSymbol, uint256 _maxSupply) ERC721(_tokenName, _tokenSymbol) {
        maxSupply = _maxSupply;
    }

    function addToWhitelist(address[] calldata toAddAddresses) 
    external onlyOwner
    {
        for (uint i = 0; i < toAddAddresses.length; i++) {
            whitelist[toAddAddresses[i]] = true;
        }
    }

    function removeFromWhitelist(address[] calldata toRemoveAddresses)
    external onlyOwner
    {
        for (uint i = 0; i < toRemoveAddresses.length; i++) {
            delete whitelist[toRemoveAddresses[i]];
        }
    }

    function setBaseURI(string calldata baseUri) external onlyOwner() {
        _baseUri = baseUri;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }

    function _burn(uint256 tokenId) internal override (ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function safeMint(address to, string memory uri)
        public
    {
        require (totalSupply() < maxSupply);
        require (whitelist[msg.sender], "NOT_IN_WHITELIST");
        require (balanceOf(msg.sender) < maxMintPerWallet, "REACH_MAX_MINT");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
}