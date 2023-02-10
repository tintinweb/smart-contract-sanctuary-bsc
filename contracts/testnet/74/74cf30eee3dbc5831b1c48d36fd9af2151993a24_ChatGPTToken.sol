/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

pragma solidity ^0.8.0;

contract ChatGPTToken {
    // Define the token name
    string public constant name = "ChatGPT Token";
    
    // Define the token symbol
    string public constant symbol = "ChatGPT";
    
    // Define the number of decimal places the token uses
    uint8 public constant decimals = 18;
    
    // Define the total supply of tokens
    uint256 public totalSupply;
    
    // Keep track of the balance of each address
    mapping (address => uint256) public balances;
    
    // Keep track of the allowed transfers of each address
    mapping (address => mapping (address => uint256)) public allowed;
    
    // Event that is triggered when tokens are transferred
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    
    // Event that is triggered when approvals are changed
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    
    // Constructor function to set the total supply of tokens
    constructor(uint256 initialSupply) public {
        totalSupply = initialSupply;
        balances[msg.sender] = totalSupply;
    }
    
    // Function to return the balance of a given address
    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }
    
    // Function to transfer tokens from one address to another
    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    // Function to approve and allow a third-party address to transfer tokens on behalf of the owner's address
    function approve(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    // Function to return the remaining number of tokens that a third-party address is allowed to transfer on behalf of the owner's address
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }
    
    // Function to transfer tokens from one address to another, with the ability to approve and limit token transfers by third-party addresses
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= balances[from], "Insufficient balance");
        require(value <= allowed[from][msg.sender], "Insufficient allowance");
        balances[from] -= value;
        allowed[from][msg.sender] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
}