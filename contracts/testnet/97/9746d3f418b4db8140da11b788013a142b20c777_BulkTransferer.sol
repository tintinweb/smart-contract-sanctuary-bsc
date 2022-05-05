/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
// File: TranferNFTs.sol


pragma solidity ^0.8.2;
// 0x92C329af9e57AE53c6f5bdb2cD1d7bf66B4E54fA
interface IERC721 {
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
}

contract BulkTransferer {
    IERC721 collection;

    constructor (address _collection) {
        collection = IERC721(_collection);
    }

    function bulkTransfer(address _from, address _to, uint256[] memory _tokenIds) external {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            collection.safeTransferFrom(_from, _to, _tokenIds[i]);
        }
    }
}