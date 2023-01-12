/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

pragma solidity ^0.8.0;

contract Chatgbt {
    // Token metadata
    string public name;
    string public symbol;
    uint256 public totalSupply;

    // Mapping from address to balance
    mapping(address => uint256) public balanceOf;

    // Event for token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Initialize the contract with the token metadata
    constructor() public {
        name = "ChatGbt";
        symbol = "GBT";
        totalSupply = 1000000;

        // Assign the totalSupply to the address deploying the contract
        balanceOf[msg.sender] = totalSupply;
    }

    // Transfer tokens from one address to another
    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        require(to != address(0));

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
    }

    // burn tokens
    function burn(uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        require(value <= (balanceOf[msg.sender] * 10)/100);

        // update the balance
        balanceOf[msg.sender] -= value;
        totalSupply -= value;

        emit Transfer(msg.sender, address(0), value);
    }
}