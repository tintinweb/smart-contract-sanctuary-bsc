/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT
//to receive the prize, randomWallet.
pragma solidity ^0.8.18;

contract UsersWalletsandPoints {
    mapping (address => uint) public walletPoints;
    mapping (uint => address) public walletIndex;
    uint public walletCount;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function addPoints(uint _points) public {
    if (walletPoints[msg.sender] == 0) {
        walletIndex[walletCount] = msg.sender;
        walletCount++;
    }
    walletPoints[msg.sender] += _points;
}


    function getPoints() public view returns (uint) {
        return walletPoints[msg.sender];
    }



    function getRandomWallet() public view onlyOwner returns (address) {
        require(msg.sender == owner, "Only the owner can get a random wallet.");
        uint randomIndex = uint(keccak256(abi.encodePacked(block.timestamp))) % walletCount;
        return walletIndex[randomIndex];
    }
        modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can access this function.");
        _;
    }

   }