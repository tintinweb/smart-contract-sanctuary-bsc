/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

interface RunBoxInterface{
  function balanceOf(address owner) external view returns (uint256 balance);
  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
  function getBoxType(uint256 tokenId) external view returns (uint256);
}

contract TranferMultiBox {
    RunBoxInterface runboxContract;

    struct Box {
        uint256 tokenId;
        uint256 boxType;
    }

    constructor(address _addressRunBox) {
        runboxContract = RunBoxInterface(_addressRunBox);
    }

    function getListBoxByUser(address user) public view returns (Box[] memory) { 
        uint256 balance = runboxContract.balanceOf(user);
        Box[] memory boxs = new Box[](balance);      
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = runboxContract.tokenOfOwnerByIndex(user, i);
            uint256 typeBox = runboxContract.getBoxType(tokenId);
            Box memory box;
            box.tokenId = tokenId;
            box.boxType = typeBox;
            boxs[i] = box;
        }
        return boxs;
    } 
}