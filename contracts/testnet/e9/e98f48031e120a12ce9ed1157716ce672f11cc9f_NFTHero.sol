// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AccessControl.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Pausable.sol";
import "./Strings.sol";


contract NFTHero is ERC721, ERC721Enumerable, Pausable, AccessControl {
    using Strings for uint256;

    string private baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Hero {
        uint256 data;
        uint256 death;
    }

    mapping(uint256 => Hero) private nfts;

    event HeroResetd(uint256 indexed tokenId);


    constructor(
        string memory baseURI_,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        baseURI = baseURI_;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        Hero memory _nft = nfts[tokenId];
        return string(abi.encodePacked(baseURI , Strings.toString(_nft.data), ".json"));
    }

    function getHero(uint256 _nftId) external view returns (uint256,uint256){
        Hero memory _nft = nfts[_nftId];
        return (_nft.data, _nft.death);
    }
    function getHero2(uint256 _nftId) external view returns (uint256){
        return nfts[_nftId].data;
    }

    function creatHero(uint256 _nftId,uint256 _data,uint256 _death,address _owner) 
        external onlyRole(MINTER_ROLE){
        
        nfts[_nftId] = Hero(_data, _death);

        _mint(_owner, _nftId);
    }

    function deleteHero(uint256 _nftId) external onlyRole(MINTER_ROLE){
        super._burn(_nftId);
        delete(nfts[_nftId]);
    }

    function resetHero(uint256 _nftId,uint256 _newData,uint256 _death)external onlyRole(MINTER_ROLE){
        nfts[_nftId].data = _newData;
        nfts[_nftId].death = _death;
        emit HeroResetd(_nftId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){
        return super.supportsInterface(interfaceId);
    }


    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function pause() public whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }
    
    function _beforeTokenTransfer(address from,address to,uint256 tokenId)internal whenNotPaused
        override(ERC721, ERC721Enumerable){

        super._beforeTokenTransfer(from, to, tokenId);
    }

    
}