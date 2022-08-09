// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ERC721.sol";

contract True is ERC721, Ownable {
    uint256 public maxTokenId;
    string baseuri;

    constructor() ERC721("True NFT", "TRUE") {
        baseuri = "http://shop.ahjsc.top/";
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        require(!super._exists(tokenId), "The tokenId already exists");
        super._safeMint(to, tokenId, "");
        if (maxTokenId < tokenId) {
            maxTokenId = tokenId;
        }
    }

    function mintBatch(address to, uint256[] memory tokenIds) public {
        require(!exists(tokenIds), "tokenId already exists");
        for (uint256 index = 0; index < tokenIds.length; index++) {
            mint(to, tokenIds[index]);
        }
    }

    function exists(uint256[] memory tokenIds) public view returns (bool) {
        for (uint256 index = 0; index < tokenIds.length; index++) {
            if (!exists(tokenIds[index])) {
                return false;
            }
        }
        return true;
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return super._exists(tokenId);
    }

    function burn(uint256 tokenId) public onlyOwner {
        super._burn(tokenId);
    }

    function burnBatch(uint256[] memory tokenIds) public onlyOwner {
        for (uint256 index = 0; index < tokenIds.length; index++) {
            burn(tokenIds[index]);
        }
    }

    function setBaseUri(string memory uri) public onlyOwner {
        baseuri = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseuri;
    }
}