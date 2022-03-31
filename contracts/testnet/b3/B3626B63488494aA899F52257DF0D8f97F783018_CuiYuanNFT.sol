// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./Counters.sol";
import "./MinterRole.sol";
import "./Pausable.sol";
import "./ERC721.sol";
import "./ICuiYuanNFT.sol";

contract CuiYuanNFT is Context, Ownable, MinterRole, Pausable, ERC721, ICuiYuanNFT {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _currentId;

    struct NftData {
        uint256 tokenId;
    }

    mapping(uint256 => NftData) private nftAttributes;
    
    event SafeMint(uint256 indexed tokenId);

    constructor() ERC721("CuiYuan", "CuiYuanNFT") public {

    }

    function safeMint(address to) public virtual override onlyMinter {

        _currentId.increment();
        uint256 tokenId = _currentId.current();

        NftData storage thisNft = nftAttributes[tokenId];
        thisNft.tokenId = tokenId;
        
        _safeMint(to, thisNft.tokenId);
        
        emit SafeMint(thisNft.tokenId);
    }

    function burn(uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    } 

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public onlyOwner {
        _setTokenURI(tokenId, tokenURI);
    }

    function getInfo(uint256 tokenId) public override view returns (uint256) {
        require(_exists(tokenId), "check house attributes for nonexistent tokenId");
        NftData storage thisNft = nftAttributes[tokenId];
        return thisNft.tokenId;
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}