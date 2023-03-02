/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract BEP20BatchTransfer {
    function batchTransfer(address tokenAddress, address sender, address[] memory recipients, uint256[] memory amounts) external {
        // Ensure that the recipients and amounts arrays have the same length
        require(recipients.length == amounts.length, "Arrays must have the same length");

        // Load the token contract
        IBEP20 token = IBEP20(tokenAddress);

// Approve the contract to spend tokens on behalf of the sender
//uint256 amount = 5; // The amount of tokens to transfer
//require(token.approve(address(this), amount), "Approval failed");

// Call the batchTransfer function to transfer tokens to the specified recipients
//address[] memory recipients = 5; // Array of recipient addresses
//uint256[] memory amounts = 5; // Array of corresponding token amounts
//batchTransfer(tokenAddress, sender, recipients, amounts);


        // Check the allowance of the sender
        uint256 allowance = token.allowance(sender, address(this));
        require(allowance >= amounts[0] * recipients.length, "Insufficient allowance");

        // Loop through each recipient and transfer the corresponding amount of tokens from the sender's address
        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transferFrom(sender, recipients[i], amounts[i]), "Token transfer failed");
        }
    }
}