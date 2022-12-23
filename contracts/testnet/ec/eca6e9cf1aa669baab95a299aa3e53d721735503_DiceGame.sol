/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

pragma solidity ^0.6.0;

contract DiceGame {
    // The address that deployed the contract is the owner
    address public owner;

    // The minimum bet required to play the game
    uint public minBet;

    // The current bet made by the player
    uint public currentBet;

    // The player's roll
    uint public playerRoll;

    // The contract's roll
    uint public contractRoll;

    // Events for logging
    event NewBet(uint bet);
    event NewRoll(uint roll, bool player);
    event NewResult(string result);

    // Constructor function
    constructor() public {
        owner = msg.sender;
        minBet = 0.01 ether; // 0.01 ether is the minimum bet
    }

    // Function to place a bet
    function placeBet(uint _bet) public payable {
        require(_bet >= minBet, "Bet must be greater than or equal to the minimum bet");
        require(msg.value == _bet, "The value sent must be equal to the bet amount");
        currentBet = _bet;
        emit NewBet(currentBet);
    }

    // Function to roll the dice
    function rollDice() public {
        require(currentBet > 0, "You must place a bet first");

        // Generate a random number between 1 and 6 for the player's roll
        playerRoll = random();
        emit NewRoll(playerRoll, true);

        // Generate a random number between 1 and 6 for the contract's roll
        contractRoll = random();
        emit NewRoll(contractRoll, false);

        // Determine the result
        if (playerRoll > contractRoll) {
            // The player wins
            msg.sender.transfer(currentBet * 2);
            emit NewResult("You win!");
        } else if (contractRoll > playerRoll) {
            // The contract wins
            emit NewResult("You lose.");
        } else {
            // It's a draw
            msg.sender.transfer(currentBet);
            emit NewResult("It's a draw.");
        }

        // Reset the current bet
        currentBet = 0;
    }

    // Function to generate a random number between 1 and 6
    function random() private view returns (uint) {
        return (uint(keccak256(abi.encodePacked(block.difficulty, now, minBet))) % 6) + 1;
    }
}