// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Tooth.sol";

// Pre-sale contract
contract PreSale {
    // Address of the contract owner
    address public owner;

    // Address of the Tooth (HT) token contract
    Tooth public token;

    // Amount of HT tokens available for sale in the pre-sale
    uint public totalSupply;

    // Price of the HT tokens in wei
    uint public price;

    // Start and end time of the pre-sale
    uint public startTime;
    uint public endTime;

    // Flag to indicate if the pre-sale has ended
    bool public isClosed;

    // Soft cap for the pre-sale
    uint public softCap;

    // Hard cap for the pre-sale
    uint public hardCap;

    // Total amount of ETH collected in the pre-sale
    uint public totalCollected;

    // Event to be emitted when a purchase is made
    event Purchase(address indexed purchaser, uint indexed amount);

    // Constructor to initialize the contract
    constructor(Tooth _token, uint _totalSupply) {
        // Set the contract owner as the deployer
        owner = msg.sender;
        // Set the token and total supply
        token = _token;
        totalSupply = _totalSupply;
        // Hardcode the price as 1 ETH for 100,000 HT tokens
        price = 100000;

        // Hardcode the start time as the time of deployment
        startTime = block.timestamp;
        // Hardcode the end time as 42 days after the start time
        endTime = startTime + 42 days;

        // Hardcode the soft cap as 100 ETH
        softCap = 100 ether;
        // Hardcode the hard cap as 1000 ETH
        hardCap = 1000 ether;
    }

    // Fallback function to revert transactions that do not call a function
    fallback() external {
        revert();
    }

    // Modifier to ensure that the function can only be called during the pre-sale period
    modifier duringPreSale() {
        require(block.timestamp >= startTime && block.timestamp <= endTime && !isClosed, "Pre-sale has ended");
        _;
    }

    // Function to buy HT tokens
    function buy(uint amount) public payable duringPreSale {
        // Transfer the HT tokens to the purchaser
        token.transfer(msg.sender, amount);
        // Emit the Purchase event
        emit Purchase(msg.sender, amount);
    }

    // Modifier to ensure that the function can only be called by the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    // Function to close the pre-sale
    function closePreSale() public onlyOwner {
        isClosed = true;
    }

     // Function to get the ETH balance of the contract (view function)
    function balance() public view returns (uint) {
        return address(this).balance;
    }

    // Function to refund purchases (only if the soft cap has not been reached)
    function refund() public payable {
    // Only the contract owner can refund purchases
    require(msg.sender == owner, "Only the contract owner can refund purchases");
    // Check if the soft cap has been reached
    if (totalCollected >= softCap) {
        // Close the pre-sale if the hard cap has been reached
        if (totalCollected >= hardCap) {
            isClosed = true;
        }
    } else {
        // Refund the purchase if the soft cap has not been reached
        payable(msg.sender).transfer(msg.value);
    }
}

    // Function to get the balance of the contract owner
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Function to transfer the balance of the contract to the owner
    function withdrawBalance() public {
        // Only the contract owner can transfer the balance
        require(msg.sender == owner, "Only the contract owner can transfer the balance");
        // Ensure that the pre-sale has ended
        require(isClosed, "Pre-sale has not ended");
        // Transfer the balance to the contract owner
        payable(owner).transfer(address(this).balance);
    }

    // Function to get the soft cap
    function getSoftCap() public view returns (uint) {
        return softCap;
    }

    // Function to get the hard cap
    function getHardCap() public view returns (uint) {
        return hardCap;
    }
}