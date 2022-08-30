/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;
interface ERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
contract ERC721HELPER {
    function transferBatch(uint[] memory tokenIds,address to,address token) external{
        uint len=tokenIds.length;
        for(uint i;i<len;i++){
            ERC721(token).transferFrom(msg.sender,to,tokenIds[i]);
        }
    }
}