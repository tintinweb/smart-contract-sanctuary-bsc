/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

pragma solidity ^0.6.0;

// Dice game contract
contract DiceGame {
    // The minimum bet amount in wei
    uint public constant MIN_BET_AMOUNT = 10000000000000000;  // 0.01 ETH

    // The maximum bet amount in wei
    uint public constant MAX_BET_AMOUNT = 1000000000000000000;  // 1 ETH

    // The player's bet amount in wei
    uint public betAmount;

    // The player's roll result (random number between 1 and 6)
    uint public rollResult;

    // The player's winnings in wei
    uint public winnings;

    // Event for logging the player's bet
    event LogBet(uint betAmount, uint rollResult, uint winnings);

    // Function to allow the player to place a bet
    function placeBet(uint _betAmount) public payable {
        require(_betAmount >= MIN_BET_AMOUNT, "Bet amount must be greater than or equal to the minimum bet amount.");
        require(_betAmount <= MAX_BET_AMOUNT, "Bet amount must be less than or equal to the maximum bet amount.");

        // Store the bet amount
        betAmount = _betAmount;

        // Generate a random roll result between 1 and 6
        rollResult = random();

        // Calculate the winnings based on the roll result
        if (rollResult <= 2) {
            winnings = betAmount * 2;
        } else {
            winnings = 0;
        }

        // Transfer the winnings to the player
        msg.sender.transfer(winnings);

        // Log the bet event
        emit LogBet(betAmount, rollResult, winnings);
    }

    // Function to generate a random number between 1 and 6
    function random() private view returns (uint) {
        // Seed the random number generator with the current block's timestamp
        uint seed = now;

        // Use a simple linear congruential generator to generate a random number between 0 and 5
        uint randomNumber = (seed * 997) % 6;

        // Add 1 to the random number to get a number between 1 and 6
        return randomNumber + 1;
    }
}