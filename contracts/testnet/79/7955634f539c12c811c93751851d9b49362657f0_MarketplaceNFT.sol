// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
 
import "./nf-token-metadata.sol";
import "./Owner.sol";
 
contract MarketplaceNFT is NFTokenMetadata, Owner {
 
 struct NFT{
    uint256 tokenId;
    string uri;
  }

  uint private cost; 
 
  constructor() {
    nftName = "Market Place NFT";
    nftSymbol = "Market Place NFT";
    cost = 0.05 ether;
  }
 
 
  function mint(address _to, uint256 _tokenId, string calldata _uri) external payable {
    require (msg.value>=cost, "Minting wont be possible as you donot have needed funds");
    super._mint(_to, _tokenId);
    super._setTokenUri(_tokenId, _uri);
  }

  function getcost() public view returns(uint MinitingCostInBNB)
  {
      return cost;
  }

  function setCost(uint mintingcostinBNB) public isOwner{
      cost = mintingcostinBNB;
  }

  function getbalance() public isOwner view returns (uint256 balance){

    return address(this).balance;
  }

  function transferFunds(address trasnferaddress) public isOwner {

     (bool success,  ) = trasnferaddress.call{value: address(this).balance}("");
      require(success, "Failed to transfer the funds, aborting.");

  } 

 
}