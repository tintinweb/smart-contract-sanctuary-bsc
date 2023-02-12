/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

contract Bridge {
    // bscereum address where the lsc tokens will be transferred to
    address payable public bscAddress;

    // Binance Smart Chain contract address where tokens can be claimed
    address public lscAddress;

    // Event that is triggered when a token transfer is initiated
    event Transfer(address from, uint256 value);

    // Constructor to set the bscereum and lsc contract addresses
    constructor(address payable _bscAddress, address _lscAddress) public {
        bscAddress = _bscAddress;
        lscAddress = _lscAddress;
    }

    // Function to initiate the token transfer
    function transfer(uint256 value) public {
        // Trigger the transfer event
        emit Transfer(msg.sender, value);

        // Transfer the tokens to the bscereum contract
        bscAddress.transfer(value);
    }


    // Fallback function to receive tokens from lsc
    fallback() external payable {
        // Check if the transfer is from lsc
        if (msg.sender == lscAddress) {
            // Forward the tokens to the bscereum contract
            bscAddress.transfer(msg.value);
        }
    }

    function bridgeFromlscTobsc(address payable _destination) public payable {
        // Store the amount of funds to be received by _destination
        uint256 amount = msg.value;

        // Ensure that this function can only be called by the lsc address
        require(msg.sender == lscAddress, "This function can only be called from lsc");

        // Transfer the funds to the bsc _destination address
        _destination.transfer(amount);
    }
}