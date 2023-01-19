// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./Ownable.sol";
import "./ERC721URIStorage.sol";

contract BNBMiner is ERC721URIStorage, Ownable {

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    uint256 public tokenId = 1;

    function mint(uint256 quantity, string memory _uri) public onlyOwner {
        for(uint i = 0; i < quantity; i++) {
            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, _uri);
            tokenId++;
        }
    }
    
}