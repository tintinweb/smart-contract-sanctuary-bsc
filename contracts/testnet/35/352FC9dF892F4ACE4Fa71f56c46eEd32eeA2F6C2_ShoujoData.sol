/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface ERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
}

contract ShoujoData {

    ERC721 cryptoshoujo;

    constructor(address cs) {
        cryptoshoujo = ERC721(cs);
    }

    function getAllIdsOwnedBy(address owner) external view returns(uint256[] memory) {
        uint256 total = cryptoshoujo.balanceOf(owner);
        uint256[] memory ids = new uint256[](total);
        for (uint256 i = 0; i < total; i++) {
            ids[i] = cryptoshoujo.tokenOfOwnerByIndex(owner, i);
        }

        return ids;
    }
}