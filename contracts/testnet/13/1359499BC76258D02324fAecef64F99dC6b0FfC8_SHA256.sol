/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

pragma solidity ^0.8.7;
//SPDX-License-Identifier: UNLICENSED
//import ".deps/npm/hardhat/console.sol";
struct HashId{
    uint hashId;
}
struct Hash {
    bytes32 previousBlockHash;
    bytes32 hashValue;
}

contract SHA256{
    mapping(address => HashId) private hashId; 
    mapping(address => mapping (uint => Hash)) public hash;
    // event getPreviousBlockHashEvent(bytes32 previousBlockHash);  
   

    function getPreviousBlockHash() public view returns (bytes32) {
        bytes32 previousBlockHash = blockhash(block.number - 1);
       // emit getPreviousBlockHashEvent(previousBlockHash);
        return (previousBlockHash);
    }

    function newHash(bytes32 hashValue, bytes32 previousBlockHash) public {
        HashId storage id = hashId[msg.sender];
        Hash storage h = hash[msg.sender][id.hashId];
        id.hashId++;
        h.previousBlockHash = previousBlockHash;
        // emit getPreviousBlockHashEvent(previousBlockHash); 
        h.hashValue = hashValue;
    }

    function getStructure(uint id) public view returns (bytes32, bytes32){
        return(hash[msg.sender][id].previousBlockHash, hash[msg.sender][id].hashValue);
    }
}
//Current contract address: 0xFd7B50ebdac834216a94833053d22C1D5cC9EE2C