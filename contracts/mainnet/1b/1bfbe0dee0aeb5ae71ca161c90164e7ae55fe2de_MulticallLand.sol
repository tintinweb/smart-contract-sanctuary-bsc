/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

/**
 *Submitted for verification at BscScan.com on 2020-09-14
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

/// @title Multicall - Aggregate results from multiple read-only function calls
/// @author Michael Elliot <[email protected]>
/// @author Joshua Levine <[email protected]>
/// @author Nick Johnson <[email protected]>

interface IERC721 {
    
    function ownerOf(uint256 tokenId) external view returns (address owner);

}

contract MulticallLand {
    

    function multiOwnerOf(address land, uint256[] calldata tokenids) public view returns (address[] memory returnData) {
        returnData = new address[](tokenids.length);
        for (uint256 i = 0; i < tokenids.length; i++) {
            
            address ret = IERC721(land).ownerOf(tokenids[i]);
            
            returnData[i] = ret;
        }
    }

    // Helper functions
    function getEthBalance(address addr) public view returns (uint256 balance) {
        balance = addr.balance;
    }

    function getBlockHash(uint256 blockNumber) public view returns (bytes32 blockHash) {
        blockHash = blockhash(blockNumber);
    }

    function getLastBlockHash() public view returns (bytes32 blockHash) {
        blockHash = blockhash(block.number - 1);
    }

    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {
        timestamp = block.timestamp;
    }

    function getCurrentBlockDifficulty() public view returns (uint256 difficulty) {
        difficulty = block.difficulty;
    }

    function getCurrentBlockGasLimit() public view returns (uint256 gaslimit) {
        gaslimit = block.gaslimit;
    }

    function getCurrentBlockCoinbase() public view returns (address coinbase) {
        coinbase = block.coinbase;
    }
}