/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

pragma solidity ^0.8.7;
//SPDX-License-Identifier: UNLICENSED
//import ".deps/npm/hardhat/console.sol";
struct HashId{
    uint index;
}
struct Hash {
    bytes32 previousBlockHash;
    bytes32 hashValue;
}

contract SHA256{
    mapping(address => HashId) private hashId; 
    mapping(address => mapping (uint => Hash)) public hash;
    event StoredHashValue(bytes32 hashValue);  
   
    function getPreviousBlockHash() public view returns (bytes32) {
       // emit getPreviousBlockHashEvent(previousBlockHash);
        return (blockhash(block.number - 1));
    }

    function StoreHash(bytes32 hashValue, bytes32 previousBlockHash) public {
        HashId storage id = hashId[msg.sender];
        Hash storage h = hash[msg.sender][id.index];
        id.index++;
        h.previousBlockHash = previousBlockHash;
        h.hashValue = hashValue;
        emit StoredHashValue(hashValue);  
    }

    function getHashStructureData(address sender, uint id) public view returns (bytes32, bytes32){
        return(hash[sender][id].previousBlockHash, hash[sender][id].hashValue);
    }

    function getCurrentIndex(address sender) public view returns(uint){
        return (hashId[sender].index);
    }
}
//Current contract address: 0xFd7B50ebdac834216a94833053d22C1D5cC9EE2C