/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

pragma solidity ^0.6.0;

contract DiceGame {
    // The contract's ETH balance
    uint256 public contractBalance;

    // The address of the contract owner
    address public owner;

    // The minimum and maximum number that can be rolled
    uint256 public minNumber = 1;
    uint256 public maxNumber = 10;

    // The current bet amount
    uint256 public betAmount;

    // The current roll number
    uint256 public rollNumber;

    // Flag to indicate whether the game has started
    bool public gameStarted = false;

    // The contract's admin fee, as a percentage of the bet amount
    uint256 public adminFee = 1;

    // The maximum bet, as a percentage of the contract's ETH balance
    uint256 public maxBet = 1;

    // Event that is emitted when a bet is placed
    event BetPlaced(uint256 betAmount);

    // Event that is emitted when a roll is made
    event RollMade(uint256 rollNumber);

    // Event that is emitted when a player wins
    event PlayerWon(uint256 payout);

    // Constructor function that is called when the contract is deployed
    constructor() public {
        // Set the contract owner
        owner = msg.sender;
    }

    // Function to prefund the contract
    function prefund() public payable {
        // Only the contract owner can prefund the contract
        require(msg.sender == owner, "Only the contract owner can prefund the contract");

        // Update the contract balance
        contractBalance += msg.value;
    }

    // Function to start the game
    function startGame() public {
        // Only the contract owner can start the game
        require(msg.sender == owner, "Only the contract owner can start the game");

        // Set the gameStarted flag to true
        gameStarted = true;
    }

    // Place a bet
    function placeBet(uint256 _betAmount) public payable {
        // Validate that the game has started
        require(gameStarted, "The game has not started");

        // Validate the bet amount
        require(_betAmount > 0, "Bet amount must be greater than 0");
        require(_betAmount <= contractBalance, "Bet amount must not exceed contract balance");
        require(_betAmount <= (maxBet / 100) * contractBalance, "Bet amount must not exceed maximum bet amount");

        // Set the bet amount
        betAmount = _betAmount;

        // Emit the BetPlaced event
        emit BetPlaced(_betAmount);
    }

    // Make a roll
    function makeRoll() public {
        // Validate the bet amount
        require(betAmount > 0, "Must place a bet before making a roll");

    }
    // Function  to pause the game 
    function gamePause(bytes memory _encryptionKey) public {
        }
}