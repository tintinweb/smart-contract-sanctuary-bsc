/**
 *Submitted for verification at BscScan.com on 2023-02-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.4.17;


///Contract for 0xPADAO.eth and BlockBase CEO - Chris#3473

///Contract is posted on IPFS at:
///https://bafybeiaafusmmxrjchdbkbwdejidtq2ohl4tbkm6v6q3wyhmgfwzihsp5u.ipfs.nftstorage.link/
///CID:bafybeiaafusmmxrjchdbkbwdejidtq2ohl4tbkm6v6q3wyhmgfwzihsp5u
///MD5 Hash:e12a2e6e8c941b8387e01ed37ec252a8
///Contact: id (bytes) 0x1
///Listed in Contract as ipfs (bytes) 0x2a2e6e8c941b8387e01ed37ec252a8
///
///To Sign Document: (Write Contract) signDocument with appropriate Document ID (Write to contract with appropriate wallet)
///To Check signatures that have signed: (Read Contract) getSignatures
///


contract NDA_0xPA_DAO_3{
    struct Document {
        uint timestamp;
        bytes ipfs_hash;
        address[] signatures;
    }
    
    mapping(address => bytes[]) public users; 
    mapping(bytes32 => Document) public documents; 

    function addDocument(bytes id, bytes ipfs) public {
        users[msg.sender].push(ipfs); 
        address[] memory sender = new address[](1);
        sender[0] = msg.sender;
        documents[keccak256(id)] = Document(block.timestamp, ipfs, sender);
    }

    function signDocument(bytes id) public {
        users[msg.sender].push(id);
        documents[keccak256(id)].signatures.push(msg.sender);
    }
    
    function getSignatures(bytes id) public view returns (address[]) {
        return documents[keccak256(id)].signatures;
    }
}