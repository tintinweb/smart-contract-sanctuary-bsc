/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


contract Multicall {
    
    function aggregate( address[] memory targets, bytes[] memory datas) public returns (uint256 blockNumber, bytes[] memory returnData) {
        
        uint dataLength = datas.length;
        require(targets.length == dataLength, "Array lengths don't match");

        blockNumber = block.number;
        returnData = new bytes[](dataLength);
        
        for(uint256 i = 0; i < dataLength; i++) {
            (bool success, bytes memory ret) = targets[i].call(datas[i]);
            require(success, "call failed");
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