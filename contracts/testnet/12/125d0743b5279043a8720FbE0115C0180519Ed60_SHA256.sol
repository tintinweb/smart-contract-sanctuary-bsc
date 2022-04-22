/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

pragma solidity ^0.8.7;
//SPDX-License-Identifier: UNLICENSED
struct Hash {
    bytes32 previousBlockHash;
    address metamaskAddress;
    bytes32 hashValue;
}

contract SHA256 {


uint hashId;
mapping (address => mapping (uint => Hash)) public hash;

function newHash() public {
        Hash storage h = hash[msg.sender][hashId];
        hashId++;
        h.previousBlockHash = blockhash(block.number - 1);
        h.metamaskAddress = msg.sender;
        h.hashValue = "yes";
    }
}
//TODO map the hashId to the address
//Current contract address: 0x125d0743b5279043a8720FbE0115C0180519Ed60