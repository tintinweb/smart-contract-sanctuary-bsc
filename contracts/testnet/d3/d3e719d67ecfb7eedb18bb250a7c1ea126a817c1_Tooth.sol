/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

    // Contract that implements the Tooth (HT) token
    contract Tooth {
    // Total supply of HT tokens
    uint public totalSupply;

    // Number of decimals for the token
    uint public decimals;

    // Owner declaration
    address public owner;

    // Mapping from addresses to their HT balance
    mapping(address => uint) public balances;

    // Event to be emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint value);

    // Constructor to initialize the contract with the total supply of HT tokens
    constructor(uint _totalSupply) {
        totalSupply = _totalSupply;
        decimals = 18; // Set the number of decimals to 18
        // Assign all HT tokens to the contract owner
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }

    // Function to get the balance of an address (view function)
    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    // Modifier to ensure that the function can only be called by the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    // Function to transfer HT tokens from one address to another
    function transfer(address recipient, uint amount) public onlyOwner {
        // Transfer the tokens
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        // Emit the Transfer event
        emit Transfer(msg.sender, recipient, amount);
    }
}