/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

pragma solidity ^0.8.0;

contract AKG {
    // Variables
    mapping(address => uint256) balances;
    string public name;
    string public symbol;
    uint8 public decimal;
    uint256 public totalSupply;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    // Constructor
    constructor() public {
        name = "Arcade Kit Game";
        symbol = "AKG";
        decimal = 18;
        totalSupply = 1000000000000000000;
        balances[msg.sender] = totalSupply;
    }

    // Getters
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // Functions
    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender], "Insufficient balance.");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function mint(address to, uint256 value) public {
        require(msg.sender == address(this), "Only the contract owner can mint tokens.");
        totalSupply += value;
        balances[to] += value;
        emit Transfer(address(0), to, value);
    }

    function burn(uint256 value) public {
        require(value <= balances[msg.sender], "Insufficient balance.");
        totalSupply -= value;
        balances[msg.sender] -= value;
        emit Burn(msg.sender, value);
    }
}