/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract NumberGuessingGame {
    address public owner;
    uint256 public depositAmount = 0.01 ether;
    uint256 public contractBalance;
    uint256 public randomNumber;
    bool public gameEnded;
    address public winner;

    constructor() {
        owner = msg.sender;
        contractBalance = 0;
    }

    function guessNumber(uint256 number) public payable {
        require(msg.value == depositAmount, "You must send 0.01 ether to play the game.");
        require(number >= 1 && number <= 10, "Your guess must be between 1 and 10.");
        require(gameEnded == false, "The game has already ended.");

        contractBalance += msg.value;

        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        randomNumber = random % 10 + 1;

        if (number == randomNumber) {
            winner = msg.sender;
            gameEnded = true;
            (bool success, ) = winner.call{value: contractBalance}("");
            require(success, "Failed to send prize money to winner.");
            contractBalance = 0;
        }
    }

    function getContractBalance() public view returns (uint256) {
        return contractBalance;
    }

    function getWinner() public view returns (address) {
        return winner;
    }

    function endGame() public {
        require(msg.sender == owner, "Only the owner can end the game.");
        require(gameEnded == false, "The game has already ended.");
        gameEnded = true;
    }

    receive() external payable {
        contractBalance += msg.value;
    }
}