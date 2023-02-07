/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FileStore {
    mapping(address => bool) public authorizedAddresses;
    mapping(bytes32 => string) public storedHashes;

    event LogHashStored(bytes32 blockchainHash, string ipfsHash);

    function authorize(address user) public {
        authorizedAddresses[user] = true;
    }

    function unauthorize(address user) public {
        authorizedAddresses[user] = false;
    }

    function storeHash(string memory ipfsHash) public {
        require(authorizedAddresses[msg.sender], "Unauthorized");
        bytes32 blockchainHash = keccak256(abi.encodePacked(ipfsHash));
        storedHashes[blockchainHash] = ipfsHash;
        emit LogHashStored(blockchainHash, ipfsHash);
    }

    function getHash(bytes32 blockchainHash) public view returns (string memory) {
        return storedHashes[blockchainHash];
    }

    function isAuthorized(address user) public view returns (bool) {
        return authorizedAddresses[user];
    }

    function isHashStored(bytes32 blockchainHash) public view returns (bool) {
        return (keccak256(abi.encodePacked(storedHashes[blockchainHash])) != keccak256(abi.encodePacked("")));
    }
}