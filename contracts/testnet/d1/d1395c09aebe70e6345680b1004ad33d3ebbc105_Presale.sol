// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol" ;


contract Presale {
    // Define the presale parameters
    address public immutable token;
    address public immutable beneficiary;
    uint256 public immutable rate;
    uint256 public immutable cap;
    uint256 public immutable minInvestment;
    uint256 public immutable maxInvestment;


    // Keep track of the amount raised and the investor list
    uint256 public raisedAmount;
    mapping(address => uint256) public investments;

    // Define the constructor
    constructor(
        address _token,
        address _beneficiary,
        uint256 _rate,
        uint256 _cap,
        uint256 _minInvestment,
        uint256 _maxInvestment

    ) {
        token = _token;
        beneficiary = _beneficiary;
        rate = _rate * 10**18;
        cap = _cap * 10**18; 
        minInvestment = _minInvestment * 10**18;
        maxInvestment = _maxInvestment * 10**18;

    }

    // Define the invest function
    function invest() public payable {
        // Check if the investment is within the limits

        require(raisedAmount < cap, "Presale cap has been reached");
        require(msg.value >= minInvestment, "Investment is below the minimum amount");
        require(msg.value <= maxInvestment, "Investment is above the maximum amount");

        // Calculate the amount of tokens to be transferred
        uint256 tokens = msg.value * rate;

        // Transfer the tokens to the investor
        require(IERC20(token).transfer(msg.sender, tokens), "Token transfer failed");

        // Update the amount raised and the investor list
        raisedAmount += msg.value;
        investments[msg.sender] += msg.value;

        // Transfer the invested ether to the beneficiary
        payable(beneficiary).transfer(msg.value);
    }

    // Define the withdraw function for the beneficiary
    function withdraw() public {
        // Check if the presale has ended

        // Transfer the raised funds to the beneficiary
        payable(beneficiary).transfer(address(this).balance);
    }
}