/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface NFTToken {
    function lastTokenId() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract GetNFT {

    NFTToken nftToken = NFTToken(0x3AF172b31438B7891D6b9c983f6baB15614EB593);

    function getLastTokenId() public view returns(uint256) {
        return nftToken.lastTokenId();
    }

    function getOwnerOf(uint256 tokenId) public view returns(address) {
        return nftToken.ownerOf(tokenId);
    }

    function getHolds() external view returns(address [] memory) {
        address[] memory holds = new address[](150);
        for(uint256 i = 100001;i<=getLastTokenId();i++) {
            holds[i] = getOwnerOf(i);
        }
        return holds;
    }
}