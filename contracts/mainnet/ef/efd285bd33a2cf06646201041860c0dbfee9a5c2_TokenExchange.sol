/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT
//
// DevsFinance
// https://devsfinance.com/

pragma solidity ^0.8.0;

// Interface for BEP20 tokens
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

// TokenExchange contract for exchanging BNB for custom BEP20 tokens
contract TokenExchange {
    // Address of the custom BEP20 token contract
    address public tokenAddress;
    // Address of the contract owner
    address public owner;
    // Exchange rate between BNB and custom BEP20 tokens
    uint256 public exchangeRate;

    // Constructor to initialize the contract with the token address and exchange rate
    constructor(address _tokenAddress, uint256 _exchangeRate) {
        tokenAddress = _tokenAddress;
        owner = msg.sender;
        exchangeRate = _exchangeRate;
    }

    // Exchange function to exchange BNB for custom BEP20 tokens
    function exchange() public payable {
        // Check that the BNB amount is greater than 0
        require(msg.value > 0, "BNB amount must be greater than 0");

        // Get the instance of the BEP20 token contract
        IBEP20 token = IBEP20(tokenAddress);
        // Calculate the amount of tokens to be transferred based on the exchange rate
        uint256 tokenAmount = msg.value * exchangeRate;
        // Get the balance of the contract
        uint256 contractBalance = token.balanceOf(address(this));

        // Check that the contract has enough tokens to transfer
        require(
            contractBalance >= tokenAmount,
            "Not enough tokens in the contract"
        );

        // Transfer the tokens to the sender
        token.transfer(msg.sender, tokenAmount);
    }

    // Withdraw function to withdraw any BNB that has been sent to the contract
    function withdraw() public {
        // Check that only the contract owner can withdraw
        require(msg.sender == owner, "Only the owner can withdraw");

        // Get the balance of the contract and transfer it to the contract owner
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // Function to change the exchange rate
    function changeExchangeRate(uint256 newExchangeRate) public {
        // Check that only the contract owner can change the exchange rate
        require(
            msg.sender == owner,
            "Only the owner can change the exchange rate"
        );

        // Update the exchange rate
        exchangeRate = newExchangeRate;
    }
}