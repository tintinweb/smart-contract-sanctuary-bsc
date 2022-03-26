// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Ownable.sol";
import "./Counters.sol";

contract NFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    //Id of the next token
    Counters.Counter private tokenCounter;
    uint256 public immutable MaxTotalSupply;
    string private baseURI;
    address public marketAddress;
    uint256 public immutable ReservedAmount;

    modifier onlyOwnerOrMarket() {
        require(
            owner() == _msgSender() || marketAddress == _msgSender(),
            "Ownable: caller is not the owner or market"
        );
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint256 MaxTotalSupply_,
        uint256 ReservedAmount_
    ) ERC721(name_, symbol_) {
        baseURI = baseURI_;
        MaxTotalSupply = MaxTotalSupply_;
        ReservedAmount = ReservedAmount_;
    }

    function setMarketAddress(address _marketAddress) public onlyOwner {
        require(_marketAddress != address(0), "NFT: Zero address");
        marketAddress = _marketAddress;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
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

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function safeMint(address to) public onlyOwner {
        require(
            tokenCounter.current() < ReservedAmount,
            "NFT: Out of ReservedAmount"
        );
        tokenCounter.increment();
        _safeMint(to, tokenCounter.current());
    }

    function safeMintById(address to, uint256 tokenId)
        external
        onlyOwnerOrMarket
    {
        require(tokenId > ReservedAmount, "NFT: TokenId reserved");
        require(tokenId <= MaxTotalSupply, "NFT: Out of MaxTotalSupply");
        _safeMint(to, tokenId);
    }

    function reserveRemaining() public view returns (uint256) {
        return ReservedAmount - tokenCounter.current();
    }

    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721, ERC721URIStorage)
    {
        ERC721URIStorage._burn(tokenId);
    }
}