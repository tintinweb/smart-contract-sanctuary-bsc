/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HODLERS {
    string public symbol = "HODL";
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    address public owner;
    uint256 public totalSupply = 1000;
    uint256 public sellLimit = 10;
    mapping(address => uint256) public lastSellTime;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {
        owner = msg.sender;
        balances[owner] = 1000;
    }

    function transfer(address to, uint256 value) public {
        require(balances[msg.sender] >= value, "Insufficient balance.");
        require(to != address(0), "Invalid address.");

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
    }

    function approve(address spender, uint256 value) public {
        require(spender != address(0), "Invalid address.");

        allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
    }

    function transferFrom(address from, address to, uint256 value) public {
        require(balances[from] >= value, "Insufficient balance.");
        require(allowed[from][msg.sender] >= value, "Insufficient allowance.");
        require(to != address(0), "Invalid address.");

        balances[from] -= value;
        allowed[from][msg.sender] -= value;
        balances[to] += value;

        emit Transfer(from, to, value);
    }

    function mint(uint256 value) public onlyOwner {
        require(value > 0, "Invalid value.");

        totalSupply += value;
        balances[owner] += value;

        emit Transfer(address(0), owner, value);
    }

    function sell(uint256 value) public {
        require(block.timestamp - lastSellTime[msg.sender] >= 1 hours, "Cannot sell within 1 hour.");
        require(value <= (balances[msg.sender] * sellLimit) / 100, "Exceeded sell limit.");

        balances[msg.sender] -= value;
        totalSupply -= value;

        lastSellTime[msg.sender] = block.timestamp;

        emit Transfer(msg.sender, address(0), value);
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized.");
        _;
    }
}