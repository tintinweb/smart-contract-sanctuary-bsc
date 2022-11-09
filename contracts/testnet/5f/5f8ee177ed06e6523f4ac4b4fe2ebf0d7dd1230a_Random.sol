/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Random {

    uint256 nonce = 15;

     function randomSeedFarm() public view returns (uint256) {
        uint256 randomN = uint256(blockhash(block.number));
        uint256 index = uint256(keccak256(abi.encodePacked(randomN, block.timestamp, nonce))) % (100);
        
        return index;
    }
}