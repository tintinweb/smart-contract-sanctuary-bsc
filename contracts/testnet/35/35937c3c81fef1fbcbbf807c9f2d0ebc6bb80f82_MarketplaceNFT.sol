// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
 
import "./nf-token-metadata.sol";
import "./ownable.sol";
 
contract MarketplaceNFT is NFTokenMetadata, Ownable {
 
 struct NFT{
    uint256 tokenId;
    string uri;
  }
 
  constructor() {
    nftName = "Football Game NFT";
    nftSymbol = "Football Game NFT";
  }
 
 
  function mint(address _to, uint256 _tokenId, string calldata _uri) external {
    super._mint(_to, _tokenId);
    super._setTokenUri(_tokenId, _uri);
  }

  function mint(address _to, NFT[] memory data) external {
     for(uint i=0; i < data.length; ++i){
      super._mint(_to, data[i].tokenId);
      super._setTokenUri(data[i].tokenId, data[i].uri);
     }
  }
 
}