/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface INFT {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract BulkSendNFT {


    function bulkSend(address nft, uint256[] calldata tokenIds, address[] calldata recipients) external {

        uint len = tokenIds.length;
        require(len == recipients.length, 'Invalid Length');
        for (uint i = 0; i < len;) {
            INFT(nft).safeTransferFrom(msg.sender, recipients[i], tokenIds[i]);
            unchecked { ++i; }
        }

    }


}