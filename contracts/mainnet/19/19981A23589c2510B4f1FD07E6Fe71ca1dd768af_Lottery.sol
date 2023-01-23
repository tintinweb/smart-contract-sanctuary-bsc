/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

pragma solidity ^0.8.0;
//SPDX-License-Identifier: UNLICENSED
contract Lottery {
    address public owner;
    string[] public entries;
    address public winner;
    uint randomIndex;

    constructor() public {
        owner = msg.sender;
    }

    function addEntry(string memory entry) public {
        require(msg.sender == owner, "Only the owner can add entries.");
        entries.push(entry);
    }

    function selectWinner() public {
        require(msg.sender == owner, "Only the owner can select the winner.");
        require(entries.length > 0, "No entries to pick a winner from.");
        randomIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.number))) % entries.length;
        winner = msg.sender;
    }

    function checkWinner() public view returns (string memory, address) {
        require(winner != address(0), "No winner has been selected yet.");
        return (entries[randomIndex], winner);
    }

    function deleteEntries() public {
        require(msg.sender == owner, "Only the owner can delete entries.");
        delete entries;
    }
}