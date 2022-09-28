/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


interface ARMANFT {
    function safeTransferFrom(address from,address to, uint256 tokenid,bytes memory data) external;
}

contract test {
    ARMANFT public parentNFT;
     constructor() {
        parentNFT = ARMANFT(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8); // Change it to your NFT contract addr
    }

    function stake(uint256 _tokenId) public {
        parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId, "0x00");
    } 
}