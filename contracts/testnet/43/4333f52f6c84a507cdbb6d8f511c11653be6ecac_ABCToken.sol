/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

pragma solidity ^0.6.0;

// This is the contract for the ABC token
contract ABCToken {
    // The name of the token
    string public name;
    // The symbol of the token
    string public symbol;
    // The number of decimals of the token
    uint8 public decimals;
    // The total supply of the token
    uint256 public totalSupply;
    // The balance of the token for each account
    mapping(address => uint256) public balanceOf;
    // The contract owner
    address public owner;
    
    // The constructor function is called when the contract is deployed
    constructor() public {
        // Set the name of the token
        name = "ABC";
        // Set the symbol of the token
        symbol = "XYZ";
        // Set the number of decimals of the token
        decimals = 2;
        // Set the total supply of the token
        totalSupply = 100000;
        // Set the contract owner to the address that deployed the contract
        owner = msg.sender;
        // Set the balance of the contract owner to the total supply
        balanceOf[owner] = totalSupply;
    }
    
    // This function allows the contract owner to issue more tokens
    function issueTokens(uint256 _amount) public {
        // Only the contract owner can issue more tokens
        require(msg.sender == owner, "Only the owner can issue more tokens");
        // Increase the total supply and the balance of the contract owner
        totalSupply += _amount;
        balanceOf[owner] += _amount;
    }
    
    // This function allows the contract owner to transfer tokens to another account
    function transfer(address _to, uint256 _amount) public {
        // Only the contract owner can transfer tokens
        require(msg.sender == owner, "Only the owner can transfer tokens");
        // Check that the contract owner has enough tokens to transfer
        require(balanceOf[owner] >= _amount, "Insufficient balance");
        // Transfer the tokens and update the balances
        balanceOf[owner] -= _amount;
        balanceOf[_to] += _amount;
    }
}