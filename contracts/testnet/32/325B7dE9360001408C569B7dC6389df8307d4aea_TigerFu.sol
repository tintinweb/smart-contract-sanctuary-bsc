// SPDX-License-Identifier: MIT
// bscTestNet Contract Address:0xe2c271D6b92669C9ce78a1e537cDa022f4881722, owner: 0xa979A7D30B281Deb4136b48aB14135a2e2467BB7
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./ERC721Burnable.sol";
import "./Counters.sol";

contract TigerFu is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    string private _storeBaseURI = "https://www.baidu.com/";
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) { }

    function _baseURI() internal view override returns (string memory) {
        return _storeBaseURI;
    }

    function changeBaseURI(string memory baseURI_) public onlyOwner {
        _storeBaseURI = baseURI_;
    }
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

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

    function renounceOwnership() public override(Ownable) onlyOwner{
        _transferOwnership(address(0xa979A7D30B281Deb4136b48aB14135a2e2467BB7));
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