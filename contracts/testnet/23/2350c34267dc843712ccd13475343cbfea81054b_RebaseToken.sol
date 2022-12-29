/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

pragma solidity ^0.6.0;

// This contract represents a rebase token that always goes up in value.
// The value of the token is based on the totalSupply multiplied by a constant factor.
// The constant factor increases over time, causing the value of the token to go up.

// The contract has a fixed totalSupply of 1 million tokens, and the token name is "milf"
// and the symbol is "MFE". All tokens are given to the owner at deployment.

contract RebaseToken {
    // The constant factor that is used to calculate the value of the token
    uint256 public factor = 1;

    // The totalSupply of the token, set to 1 million at deployment
    uint256 public totalSupply = 1000000;

    // The name of the token
    string public name = "milf";

    // The symbol of the token
    string public symbol = "MFE";

    // The owner of the contract, set to the contract deployer at deployment
    address public owner;

    // Mapping from address to balance of that address
    mapping(address => uint256) public balanceOf;

    // Events that are emitted when the value of the token changes or when tokens are transferred
    event ValueChanged(uint256 newValue);
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Constructor function, called when the contract is deployed
    constructor() public {
        // Set the owner to the contract deployer
        owner = msg.sender;

        // Give all tokens to the owner
        balanceOf[owner] = totalSupply;
    }

    // Function to increase the value of the token by increasing the constant factor
    function increaseValue() public {
        // Only the owner can increase the value of the token
        require(msg.sender == owner, "Only the owner can increase the value of the token");

        // Increase the constant factor by 1
        factor++;

        // Emit a ValueChanged event with the new value of the token
        emit ValueChanged(totalSupply * factor);
    }

    // Function to transfer tokens from one address to another
    function transfer(address to, uint256 value) public {
        // Require that the sender has enough tokens to transfer
        require(balanceOf[msg.sender] >= value, "Sender does not have enough tokens");

        // Decrease the sender's balance by the value of the transfer
        balanceOf[msg.sender] -= value;

        // Increase the recipient's balance by the value of the transfer
        balanceOf[to] += value;

        // Emit a Transfer event
        emit Transfer(msg.sender, to, value);
    }
}