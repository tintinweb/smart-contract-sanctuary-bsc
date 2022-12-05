/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

pragma solidity ^0.6.0;

contract DiceGame {
    // The contract's ETH balance
    uint256 public contractBalance;

    // The address of the contract owner
    address payable public owner;

    // The minimum and maximum number that can be rolled
    uint256 public minNumber = 1;
    uint256 public maxNumber = 12;

    // The current bet amount
    uint256 public betAmount;

    // The current roll number
    uint256 public rollNumber;

    // Flag to indicate whether the game has started
    bool public gameStarted = false;

    // The contract's admin fee, as a percentage of the bet amount
    uint256 public adminFee = 1;

    // The encryption key to use for the admin functions
    bytes32 private encryptionKey;

    // The address that the contract will send tax fees to
    address payable public taxAddress = 0x49a69028eB897a395C803684751E46166489bb42;

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

        // Set the encryption key for the admin functions
        encryptionKey = keccak256(abi.encodePacked("Chiko"));
    }

    // Function to allow the contract owner to prefund the contract
    function prefund(uint256 _amount, bytes32 _encryptionKey) public payable {
        // Validate the encryption key
        require(_encryptionKey == encryptionKey, "Incorrect encryption key");

        // Validate that the prefund amount is not zero
        require(_amount > 0, "Prefund amount must be greater than 0");

        // Update the contract balance
        contractBalance += _amount;
    }

    // Function to allow the contract owner to start the game
    function startGame(bytes32 _encryptionKey) public {
    }
}