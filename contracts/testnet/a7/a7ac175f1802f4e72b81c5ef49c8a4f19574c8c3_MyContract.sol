// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./ERC721.sol";
import "./ERC721URIStorage.sol";



contract MyContract is ERC721,ERC721URIStorage {

     uint public tokenIds;
     address public admin;
     
     function  incrementTokenId() private{
         tokenIds = tokenIds+1;
     }


    constructor()  ERC721("HUMAID","HUM"){
        tokenIds=0;
        admin=msg.sender;

    }

     function  createNFT(
         string memory _tokenURI
        ) external {
        require(admin==msg.sender,"Only Admin Can Mint NFTs");
        incrementTokenId();
        _mint(msg.sender, tokenIds);
        _setTokenURI(tokenIds, _tokenURI);
        
    }

       function _burn(
        uint256 tokenId
        ) internal virtual override(
            ERC721,
            ERC721URIStorage
        ) {
        
        // _resetArtist(tokenId);
        _burn(tokenId);
    }


      function tokenURI(
        uint256 tokenId
        ) public view virtual override(
            ERC721,
            ERC721URIStorage
        ) returns (string memory URI){
        
        return super.tokenURI(tokenId);
    }

}