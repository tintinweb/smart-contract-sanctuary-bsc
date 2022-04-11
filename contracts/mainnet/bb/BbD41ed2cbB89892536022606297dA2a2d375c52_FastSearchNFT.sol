/**
 *Submitted for verification at BscScan.com on 2022-04-11
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
    function getValueByTokenId(uint256 tokenId) external view returns(uint256);
    function tokenOfOwner(address owner) external view returns (uint256[] memory);
}



interface IStakingRewards {
    function stakeFresh(address ownerAdrr,uint256 tokenId) external;
    function ownerTokenId(uint256 tokenId) external view returns (address);
    function getOwnerStakeTokenIDs(address Owner) external view returns (uint256[] memory);
}

contract FastSearchNFT {
    IERC721 public NFT_Token;
    IStakingRewards public DeFi_Token;

    constructor(){
        NFT_Token = IERC721(0x1F599A0281d024bfeF7e198bDae78B49A6e87049);
        DeFi_Token = IStakingRewards(0x55F2856706872F69E8CfC00C2abDf2d4adf6aE50);
    }
    function searchIDsValueAdress(uint256 from,uint256 to) external  view returns (uint256[] memory,address[] memory){
        uint256[] memory valuelist = new uint256[](to-from+1);
        address[] memory Adress_list = new address[](to-from+1);
        uint256 ith=0;
        for(uint256 iD=from; iD<=to; iD++) {
            uint256 value = NFT_Token.getValueByTokenId(iD);
            address address0 = NFT_Token.ownerOf(iD);
            if(address0==address(DeFi_Token)){
                address0 =  DeFi_Token.ownerTokenId(iD);
            }    
            Adress_list[ith] = address0;    
            valuelist[ith] = value;
            ith++;
        }
        return (valuelist,Adress_list);
    }
    function searchIDsValueAdressMinDegree(uint256 from,uint256 to,uint256 minDegree) external  view returns (uint256,uint256[] memory,address[] memory){
        uint256[] memory valuelist = new uint256[](to-from+1);
        address[] memory Adress_list = new address[](to-from+1);
        uint256 ith=0;
        for(uint256 iD=from; iD<=to; iD++) {
            uint256 value = NFT_Token.getValueByTokenId(iD);
            if(value<minDegree) continue;

            address address0 = NFT_Token.ownerOf(iD);
            if(address0==address(DeFi_Token)){
                address0 =  DeFi_Token.ownerTokenId(iD);
            }
            Adress_list[ith] = address0;    
            valuelist[ith] = value;
            ith++;
        }
        return (ith,valuelist,Adress_list);
    }

    function searchID(uint256 tokenId) public view returns (uint256,address){
        address address0;
        uint256 value = NFT_Token.getValueByTokenId(tokenId);
        address0 = NFT_Token.ownerOf(tokenId);
        if(address0==address(DeFi_Token)){
           address0 =  DeFi_Token.ownerTokenId(tokenId);
        }
        return (value,address0);
    }

    function searchIDsValue(uint256 formSmall,uint256 toBig) external  view returns (uint256[] memory){
        uint256[] memory valuelist = new uint256[](toBig-formSmall+1);
        uint256 ith=0;
        for(uint256 iD=formSmall; iD<=toBig; iD++) {
            uint256 value = NFT_Token.getValueByTokenId(iD);
            valuelist[ith] = value;
            ith++;
        }
        return valuelist;
    }
    function searchIDsAddress(uint256[] calldata tokenIdArr) external  view returns (address[] memory){
        address[] memory Adress_list = new address[](tokenIdArr.length);
        for(uint256 i=0; i<tokenIdArr.length; ++i) {
            address address0 = NFT_Token.ownerOf(tokenIdArr[i]);
            if(address0==address(DeFi_Token)){
                address0 =  DeFi_Token.ownerTokenId(tokenIdArr[i]);
            }    
            Adress_list[i] = address0;         
        }
        return Adress_list;
    }

    function ownerIDs(address addr) external  view returns (uint256[] memory){
        uint256[] memory tokenArr1 = NFT_Token.tokenOfOwner(addr);
        uint256[] memory tokenArr2 = DeFi_Token.getOwnerStakeTokenIDs(addr);

        uint256[] memory tokenArr  = new uint256[](tokenArr1.length+tokenArr2.length);
        for(uint256 i=0; i<tokenArr1.length; ++i) {
            tokenArr[i] = tokenArr1[i];      
        }
        for(uint256 i=0; i<tokenArr2.length; ++i) {
            tokenArr[i+tokenArr1.length] = tokenArr2[i];      
        }
        return tokenArr;
    }
    function tokenIDsAddress(uint256[] calldata tokenIdArr) external  view returns (uint256[] memory){
        uint256[] memory tokenDegree = new uint256[](tokenIdArr.length);

        for(uint256 i=0; i<tokenIdArr.length; ++i) {
            tokenDegree[i] = NFT_Token.getValueByTokenId(tokenIdArr[i]);  
        }
        return tokenDegree;
    }
}