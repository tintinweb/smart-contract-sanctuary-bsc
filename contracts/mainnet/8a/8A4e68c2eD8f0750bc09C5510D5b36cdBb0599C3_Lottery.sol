/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

pragma solidity ^0.8.0;
//SPDX-License-Identifier: UNLICENSED
contract Lottery {
    address public owner;
    string[] public entries;

    constructor() public {
        owner = msg.sender;
    }

    function addEntry(string memory entry) public {
        require(msg.sender == owner, "Only the owner can add entries.");
        entries.push(entry);
    }

    function checkWinner() public view returns (string memory) {
        require(entries.length > 0, "No entries to pick a winner from.");
        uint randomIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % entries.length;
        return entries[randomIndex];
    }

    function deleteEntries() public {
        require(msg.sender == owner, "Only the owner can delete entries.");
        delete entries;
    }
}