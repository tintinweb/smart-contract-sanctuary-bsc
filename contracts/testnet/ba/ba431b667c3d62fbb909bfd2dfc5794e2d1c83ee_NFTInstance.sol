//SPDX-Lisence-Identifier: MIT

pragma solidity ^0.8.10;

import "./ERC721URIStorage.sol";

contract NFTInstance is ERC721URIStorage {
    uint256 private _tokenIds = 0; 

    constructor() ERC721(unicode"NFT Course Work 😎", "NCW") {}

    function giveNFT(address to, string memory uri) public returns (uint256) {
        uint256 nftId = _tokenIds;
        _tokenIds++;

        _mint(to, nftId);
        setTokenURI(nftId, uri);

        return nftId;
    }

}