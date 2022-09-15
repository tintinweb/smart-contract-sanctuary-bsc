// SPDX-License-Identifier: MIT

 pragma solidity ^0.8.0;

 import "./ERC721.sol" ;

 contract NFT is ERC721 
 {

    constructor ( uint256 tokenId , string memory URI) ERC721 ("MEHRUN" , "MKH")
  {

      _safeMint(msg.sender, tokenId);
    _tokenURIs [tokenId] = URI ;

  }

 }