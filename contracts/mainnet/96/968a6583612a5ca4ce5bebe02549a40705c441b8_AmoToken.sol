/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AmoToken {
    string public name = "Amo Token";
    string public symbol = "AMO";
    uint256 public totalSupply = 80000000; // 80 million tokens
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastStakedTime;

    address payable public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event Burn(address indexed burner, uint256 amount);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = payable(msg.sender);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid recipient address");
        require(value <= balanceOf[msg.sender], "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Invalid spender address");

        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid recipient address");
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Insufficient allowance");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Amount cannot be 0");

        balanceOf[msg.sender] -= amount;
        stakedBalance[msg.sender] += amount;
        lastStakedTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(amount > 0, "Amount cannot be 0");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");

        uint256 stakingTime = block.timestamp - lastStakedTime[msg.sender];
        uint256 reward = (stakingTime * stakedBalance[msg.sender]) / 31536000; // Reward = stakingTime * stakedBalance / 1 year

        balanceOf[msg.sender] += amount + reward;
        stakedBalance[msg.sender] -= amount;
        lastStakedTime[msg.sender] = 0;

        emit Unstaked(msg.sender, amount);
    }

    function sell(uint256 amount, uint256 price) public {
        require(amount > 0, "Amount cannot be 0");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[owner] += amount;
        payable(msg.sender).transfer(price);

        emit Transfer(msg.sender, owner, amount);
    }

    function burn(uint256 amount) public {
        require(amount > 0, "Amount cannot be 0");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        emit Burn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }}