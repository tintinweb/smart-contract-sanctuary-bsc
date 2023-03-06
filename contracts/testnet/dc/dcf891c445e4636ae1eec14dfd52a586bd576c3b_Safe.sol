/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

pragma solidity ^0.8.18;
// SPDX-License-Identifier: MIT
contract Safe {
    address private owner;
    string private openSafeKey = "0000";
    mapping(address => bool) private unlockedWallets;
    mapping(address => uint256) private lastOpenSafeTimestamps;

    constructor() {
        owner = msg.sender;
    }

    function openSafe(string memory _key) public payable {
        require(msg.value == 0.01 ether, "0.01 ether required to open safe");
        uint256 lastTimestamp = lastOpenSafeTimestamps[msg.sender];
        require(block.timestamp - lastTimestamp >= 120, "Wait at least 10 minutes to open safe again");
        require(keccak256(bytes(_key)) == keccak256(bytes(openSafeKey)), "Invalid key");
        unlockedWallets[msg.sender] = true;
        lastOpenSafeTimestamps[msg.sender] = block.timestamp;
    }

    function claim() public {
        require(unlockedWallets[msg.sender], "Wallet is not unlocked");
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        unlockedWallets[msg.sender] = false;
        delete unlockedWallets[msg.sender];
        delete lastOpenSafeTimestamps[msg.sender];
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function setOpenSafeKey(string memory _key) public {
        require(msg.sender == owner, "Only owner can change openSafeKey");
        openSafeKey = _key;
    }

    function getOpenSafeKey() public view returns (string memory) {
        return openSafeKey;
    }
}