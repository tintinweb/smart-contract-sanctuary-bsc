// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol" ;


contract Presale {
    // Define the presale parameters
    address public immutable token;
    address public immutable beneficiary;
    uint public immutable rate;
    uint public immutable cap;

    // Keep track of the amount raised and the investor list
    uint public raisedAmount;
    mapping(address => uint256) public investments;

    // Define the constructor
    constructor(
        address _token,
        address _beneficiary,
        uint _rate,
        uint _cap

    ) {
        token = _token;
        beneficiary = _beneficiary;
        rate = _rate;
        cap = _cap; 

    }

    // Define the invest function
    function invest() public payable {
        // Check if the investment is within the limits

        require(raisedAmount < cap, "Presale cap has been reached");

        // Calculate the amount of tokens to be transferred
        uint tokens = msg.value * rate;

        payable(beneficiary).transfer(msg.value);
        // Transfer the tokens to the investor
        require(IERC20(token).transfer(msg.sender, tokens), "Token transfer failed");

        // Update the amount raised and the investor list
        raisedAmount += msg.value;
        investments[msg.sender] += msg.value;

        // Transfer the invested ether to the beneficiary
        
    }

    // Define the withdraw function for the beneficiary
    function withdraw() public {
        // Check if the presale has ended

        // Transfer the raised funds to the beneficiary
        payable(beneficiary).transfer(address(this).balance);
    }
}