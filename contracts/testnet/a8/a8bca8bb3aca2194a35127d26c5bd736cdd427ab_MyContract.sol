/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface NFT{
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256); //ERC721Enumerable
    function tokenURI(uint256 tokenId) external view returns (string memory); //ERC721Metadata
}

contract MyContract{
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function getBalance(address _as, address _bas) public view returns (uint256) {
        return NFT(_as).balanceOf(_bas);
    }

    function getTokenId(address _contract, address _owner, uint256 _index) public view returns (uint256) {
        return NFT(_contract).tokenOfOwnerByIndex(_owner, _index);
    }

    function getTokenURI(address _contract, uint256 _index) public view returns (string memory) {
        return NFT(_contract).tokenURI(_index);
    }

    function getOwner(address _contract, uint256 _index) external view returns (address){
        return NFT(_contract).ownerOf(_index);
    }
}