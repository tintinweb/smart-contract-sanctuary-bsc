/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ProfileFactory{
    //storage profile contract
    mapping (address => address) public profiles;

    function createProfileContract() public{
        address dir_newContract = address(new Profile(msg.sender));
        profiles[msg.sender] = dir_newContract;
    }
}

interface NFT{
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256); //ERC721Enumerable
    function tokenURI(uint256 tokenId) external view returns (string memory); //ERC721Metadata
}

contract Profile{
    
    address public owner;

    struct NFTProperty{
        address contractNFT;
        uint256 index;
    }

    struct ProfileStructure{
        string nickname;
        string about;
        NFTProperty profileImage;
        NFTProperty coverImage;
    }
    //features
    struct InformationStructure{
        bool visible;
        string name;
        string surname;
        string birthDate;
        string homeAddress;
        string city;
        string state;
        string country;
        string phone;
        string email;
    }

    ProfileStructure public profile;
    InformationStructure private information;

    constructor(address _owner){
        owner = _owner;
        //profile = profileStructure("Jean", "Profesional ambicioso y con formacion en Ingenieria de Sistemas.","as","as");
    }

    modifier onlyOwner(){
        require(msg.sender==owner, "No tienes permisos");
        _;
    }

    function setProfile(string memory _nickname, string memory _about, NFTProperty memory _profileImage, NFTProperty memory _coverImage) public onlyOwner(){
        validateProperty(_profileImage, msg.sender);
        validateProperty(_coverImage, msg.sender);
        profile = ProfileStructure(_nickname, _about, _profileImage, _coverImage);
    }

    function validateProperty(NFTProperty memory _nft, address _owner) private view{
        if(_nft.contractNFT != 0x0000000000000000000000000000000000000000){
            require(getBalance(_nft.contractNFT, _owner) != 0, "Usted no tiene ningun nft de este contrato!");
            require(getOwner(_nft.contractNFT, _nft.index) == _owner, "A usted no le pertenece este token!");
        }
    }

    /*
    ** Methods of Contract NFT
    */
    function getBalance(address _contract, address _owner) private view returns (uint256) {
        return NFT(_contract).balanceOf(_owner);
    }

    function getTokenId(address _contract, address _owner, uint256 _index) private view returns (uint256) {
        return NFT(_contract).tokenOfOwnerByIndex(_owner, _index);
    }

    function getTokenURI(address _contract, uint256 _index) private view returns (string memory) {
        return NFT(_contract).tokenURI(_index);
    }

    function getOwner(address _contract, uint256 _index) private view returns (address){
        return NFT(_contract).ownerOf(_index);
    }
}