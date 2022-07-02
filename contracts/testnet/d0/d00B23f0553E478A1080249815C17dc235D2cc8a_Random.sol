/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Random {
    uint private nonce; 
    event RandomNum(uint withinNumber, uint result);
    function randModulus(uint _mod) external returns (uint result) {
        nonce++;
        result = uint(keccak256(abi.encodePacked(block.timestamp, block.number, block.difficulty, msg.sender, nonce))) % _mod;
        emit RandomNum(_mod, result);
    }
}