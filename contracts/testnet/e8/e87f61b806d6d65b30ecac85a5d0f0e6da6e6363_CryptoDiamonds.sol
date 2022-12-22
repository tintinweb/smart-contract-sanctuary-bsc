// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BEP721Burnable.sol";
import "./Ownable.sol";

contract CryptoDiamonds is BEP721Burnable, Ownable  {
    constructor() BEP721("CryptoDiamonds", "CMD") {}

    uint256 public tokenIdCounter = 1;
    uint256 public priceOfNFT;

    function safeMint(address to,uint256 amountOfNftMint) public onlyOwner{
        for(uint i = 1; i <= amountOfNftMint; i++) {
                _safeMint(to, tokenIdCounter);
                ownerNFTIds[to].availableNFTs.push(tokenIdCounter);
                tokenIdCounter++;
            }
    }

    function setNFTPrice(uint256 price) public onlyOwner returns(bool success){
            priceOfNFT = price;
            return true;
    } 
    
    function buyNFT(uint tokenId) public payable{ 
        require(msg.value >= priceOfNFT, "Please enter the correct amount!");
        require(ownerOf(tokenId) == owner(), "NFT is already sold!");
        for(uint256 i=0; i<ownerNFTIds[owner()].availableNFTs.length; i++){
            if(ownerNFTIds[owner()].availableNFTs[i] == tokenId){
                ownerNFTIds[owner()].availableNFTs[i] = ownerNFTIds[owner()].availableNFTs[ownerNFTIds[owner()].availableNFTs.length-1];
                ownerNFTIds[owner()].availableNFTs.pop();
            }
        }
           _transfer(owner(), msg.sender, tokenId);  
    }

    function viewOwnerNFTIds()
        public
        view
        returns (uint256[] memory)
    {   
        _viewOwnerNFTIds(owner());
        return ownerNFTIds[owner()].availableNFTs;
    }

    function withdraw() public onlyOwner returns(bool success) {
        payable(owner()).transfer(address(this).balance);
        return true;
    }
    
}