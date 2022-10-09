/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;


interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
    function getDegreeByTokenId(uint256 tokenId) external view returns(uint256);
    function getLastUpdateTimeByTokenId(uint256 tokenId) external view returns(uint256);
    function tokenOfOwner(address owner) external view returns (uint256[] memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}

contract FastSearchNFT3 {
    using Address for address;
    constructor(){
    }
    function searchIDsValueAdress(address tokenNFT,uint256 from,uint256 to) external  view returns (
        uint256[] memory tokenIDArr,
        uint256[] memory valuelist,
        address[] memory Adress_list,
        bool[] memory bContractArr){
        IERC721 NFT_Token = IERC721(tokenNFT);

        tokenIDArr = new uint256[](to-from+1);
        valuelist = new uint256[](to-from+1);
        Adress_list = new address[](to-from+1);
        bContractArr = new bool[](to-from+1);
        uint256 ith=0;
        uint256 value;
        address address0;
        for(uint256 iD=from; iD<=to; iD++) {
            value = NFT_Token.getDegreeByTokenId(iD);
            address0 = NFT_Token.ownerOf(iD); 
            tokenIDArr[ith] = iD;  
            valuelist[ith] = value;
            Adress_list[ith] = address0;    
            bContractArr[ith] = address0.isContract();
            ith++;
        }
        return (tokenIDArr,valuelist,Adress_list,bContractArr);
    }

    function searchIDsValuelist(address tokenNFT,uint256 from,uint256 to) external  view returns (
        uint256[] memory valuelist){
        IERC721 NFT_Token = IERC721(tokenNFT);
        valuelist = new uint256[](to-from+1);
         
        uint256 ith=0;
        uint256 value;
        for(uint256 iD=from; iD<=to; iD++) {
            value = NFT_Token.getDegreeByTokenId(iD);
            valuelist[ith] = value;
            ith++;
        }
        return (valuelist);
    }

    function searchIDsAdress_list(address tokenNFT,uint256 from,uint256 to) external  view returns (
        address[] memory Adress_list){
        IERC721 NFT_Token = IERC721(tokenNFT);
        Adress_list = new address[](to-from+1);
        uint256 ith=0;
        for(uint256 iD=from; iD<=to; iD++) {
            Adress_list[ith] = NFT_Token.ownerOf(iD);  
            ith++;
        }
        return (Adress_list);
    }
    function searchIDsAdressIsContract(address tokenNFT,uint256 from,uint256 to) external  view returns (
        bool[] memory bContractArr){
        IERC721 NFT_Token = IERC721(tokenNFT);

        bContractArr = new bool[](to-from+1);
        uint256 ith=0;
        address address0;
        for(uint256 iD=from; iD<=to; iD++) {
            address0 = NFT_Token.ownerOf(iD);   
            bContractArr[ith] = address0.isContract();
            ith++;
        }
        return (bContractArr);
    }
    struct sNFTOwner{
        address nft;
        address ownerAddr;
        uint256[] tokenIds;
    }
    function nftsOwnerIDs(address[] calldata nftAdressArr,address addr) external  view returns (sNFTOwner[] memory nftOwners){
        nftOwners  = new sNFTOwner[](nftAdressArr.length);

        for(uint256 i=0; i<nftAdressArr.length; ++i) {
            IERC721 NFT_Token = IERC721(nftAdressArr[i]);
            nftOwners[i].nft = nftAdressArr[i];   
            nftOwners[i].ownerAddr = addr;   
            nftOwners[i].tokenIds = NFT_Token.tokenOfOwner(addr);
        }
        return nftOwners;
    }

    struct sNFTUri{
        address nft;
        address ownerAddr;
        string[] uris;
    }
    function nftOwnerUris(address nftAdress,address addr) public view returns (string[] memory uris){
        IERC721 NFT_Token = IERC721(nftAdress);
        uint256[] memory tokenIds = NFT_Token.tokenOfOwner(addr);
        uris  = new string[](tokenIds.length);
        for(uint256 i=0; i<tokenIds.length; ++i) {
            uris[i] = NFT_Token.tokenURI(tokenIds[i]);
        }
        return uris;
    }
    function nftsOwnerUris(address[] calldata nftAdressArr,address addr) external  view returns (sNFTUri[] memory nfturis){
        nfturis  = new sNFTUri[](nftAdressArr.length);
        for(uint256 i=0; i<nftAdressArr.length; ++i) {
            nfturis[i].nft = nftAdressArr[i];   
            nfturis[i].ownerAddr = addr;   
            nfturis[i].uris =  nftOwnerUris(nftAdressArr[i],addr);
        }
        return nfturis;
    }
    function nftTokensUris(address nftAdress,uint256[] calldata tokenIds) public view returns (string[] memory uris){
        IERC721 NFT_Token = IERC721(nftAdress);
        uris  = new string[](tokenIds.length);
        for(uint256 i=0; i<tokenIds.length; ++i) {
            uris[i] = NFT_Token.tokenURI(tokenIds[i]);
        }
        return uris;
    }
}