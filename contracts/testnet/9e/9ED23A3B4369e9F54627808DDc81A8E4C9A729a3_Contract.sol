/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// File: contracts/work/Contract.sol


pragma solidity >=0.7.0 <0.9.0;

contract Contract {
    address public owner;
    string public fileHash;
    string public metadataHash;
    string public metadata;
    string public folderId;
    
    event ContractCreated(Contract cntr);

    constructor(
        string memory fileHash_,
        string memory metadataHash_,
        string memory metadata_,
        string memory folderId_
    ) {
        owner = msg.sender;
        fileHash = fileHash_;
        metadataHash = metadataHash_;
        metadata = metadata_;
        folderId = folderId_;
        emit ContractCreated(this);
    }
}