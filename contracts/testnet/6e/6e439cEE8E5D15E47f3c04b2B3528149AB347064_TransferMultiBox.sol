/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

pragma experimental ABIEncoderV2;

interface RunBoxInterface{
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function getBoxType(uint256 tokenId) external view returns (uint256);
    function setApprovalForAll(address operator, bool _approved) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract TransferMultiBox {
    RunBoxInterface runboxContract;

    struct Box {
        uint256 tokenId;
        uint256 boxType;
    }

    constructor(address _addressRunBox) {
        runboxContract = RunBoxInterface(_addressRunBox);
    }
    //GET INFO BOXS OWNER
    function getListBoxByOwner(address owner) public view returns (Box[] memory) { 
        uint256 balance = runboxContract.balanceOf(owner);
        Box[] memory boxs = new Box[](balance);      
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = runboxContract.tokenOfOwnerByIndex(owner, i);
            uint256 typeBox = runboxContract.getBoxType(tokenId);
            Box memory box;
            box.tokenId = tokenId;
            box.boxType = typeBox;
            boxs[i] = box;
        }
        return boxs;
    } 

   function getListBoxIdByType(address owner, uint256 boxType) public view returns (uint256[] memory) { 
        uint256 totalType = getTotalBoxByType(owner, boxType);
        uint256 balance = runboxContract.balanceOf(owner);
        uint256[] memory listIdsByType = new uint256[](totalType);
        uint256 indexBox = 0;
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = runboxContract.tokenOfOwnerByIndex(owner, i);
            uint256 boxTypeById = runboxContract.getBoxType(tokenId);
            if(boxType == boxTypeById) {
                listIdsByType[indexBox] = tokenId;
                indexBox++;
            }           
        }
        return listIdsByType;
    }

    function getTotalBoxByType(address owner, uint256 boxType) public view returns (uint256) { 
        uint256 balance = runboxContract.balanceOf(owner);
        uint256 countBoxType;
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = runboxContract.tokenOfOwnerByIndex(owner, i);
            uint256 boxTypeById = runboxContract.getBoxType(tokenId);
            if(boxType == boxTypeById) {
                countBoxType++;
            }
        }
        return countBoxType;
    }

    function getTotalBoxByOwner(address owner) public view returns (uint256) { 
        return runboxContract.balanceOf(owner);
    }

    //TRANSFER BOX
    function getListBoxIdByOwner(address owner) private view returns (uint256[] memory) { 
        uint256 balance = runboxContract.balanceOf(owner);
        uint256[] memory listIds = new uint256[](balance);      
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = runboxContract.tokenOfOwnerByIndex(owner, i);
            listIds[i] = tokenId;
        }
        return listIds;
    } 

    function transferAllMultibox(address receiver) public { 
        uint256[] memory listIds = getListBoxIdByOwner(msg.sender);    
        for (uint i = 0; i < listIds.length; i++) {
           runboxContract.transferFrom(msg.sender, receiver, listIds[i]);
        }        
    } 

    function transferMultibox(address receiver, uint256 boxType, uint256 amount) public { 
        uint256[] memory listIds = getListBoxIdByType(msg.sender, boxType);    
        for (uint i = 0; i < amount; i++) {
           runboxContract.transferFrom(msg.sender, receiver, listIds[i]);
        }        
    }    
}