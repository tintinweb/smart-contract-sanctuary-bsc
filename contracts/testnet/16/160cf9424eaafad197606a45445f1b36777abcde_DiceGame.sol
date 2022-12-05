/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

pragma solidity ^0.6.0;

contract DiceGame {
    // The contract's ETH balance
    uint256 public contractBalance;

    // The minimum and maximum number that can be rolled
    uint256 public minNumber = 1;
    uint256 public maxNumber = 10;

    // The current bet amount
    uint256 public betAmount;

    // The current roll number
    uint256 public rollNumber;

    // The contract's admin fee, as a percentage of the bet amount
    uint256 public adminFee = 1;

    // The maximum bet, as a percentage of the contract's ETH balance
    uint256 public maxBet = 10;

    // Event that is emitted when a bet is placed
    event BetPlaced(uint256 betAmount);

    // Event that is emitted when a roll is made
    event RollMade(uint256 rollNumber);

    // Event that is emitted when a player wins
    event PlayerWon(uint256 payout);

    // Place a bet
    function placeBet(uint256 _betAmount) public payable {
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

        // Generate a random roll number
        rollNumber = minNumber + uint256(keccak256(abi.encodePacked(now, betAmount))) % (maxNumber - minNumber + 1);

        // Emit the RollMade event
        emit RollMade(rollNumber);

        // Check if the player won
        if (rollNumber == minNumber) {
            // Calculate the payout
            uint256 payout = betAmount * 2;

            // Calculate the admin fee
            uint256 fee = (payout * adminFee) / 100;

            // Transfer the payout to the player, minus the admin fee
            msg.sender.transfer(payout - fee);

            // Emit the PlayerWon event
            emit PlayerWon(payout);
        }
    }

    // Withdraw the contract's ETH balance
    function withdraw() public {
        // Calculate the admin fee
        uint256 fee = (contractBalance * adminFee) / 100;

        // Transfer the contract balance to the caller, minus the admin fee
        msg.sender.transfer(contractBalance - fee);
    }

    // Function to Start and Pause the game 
    function gamePause(bytes memory _encryptionKey) private {
    }
}