// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Ownable.sol";

contract createNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    constructor(address _owner,string memory name,string memory symbol) ERC721(name, symbol) Ownable(_owner) {}

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function burn(uint256 tokenId) public onlyOwner{
        _burn(tokenId);
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

    function mint(address to, uint256 tokenId, string memory token_URI) public onlyOwner returns (uint256) {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, token_URI);
        return tokenId;
    }
}