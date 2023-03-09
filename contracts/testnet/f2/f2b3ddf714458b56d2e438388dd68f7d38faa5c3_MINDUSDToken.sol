/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MINDUSDToken {
    string public name = "MIND Stable coin";
    string public symbol = "MUSD";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public ethReserve;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    constructor() {
        totalSupply = 0 * 10 ** decimals;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(amount <= balances[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Insufficient allowance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 oldValue = allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            allowances[msg.sender][spender] = 0;
        } else {
            allowances[msg.sender][spender] = oldValue - subtractedValue;
        }
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }

    function deposit() public payable {
        ethReserve += msg.value;
        uint256 tokensToMint = msg.value;
        balances[msg.sender] += tokensToMint;
        totalSupply += tokensToMint;
        emit Transfer(address(0), msg.sender, tokensToMint);
    }

    function withdraw(uint256 amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance");
        require(amount <= ethReserve, "Insufficient reserve");
        ethReserve -= amount;
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        payable(msg.sender).transfer(amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function getETHReserve() public view returns (uint256) {
        return ethReserve;
    }

    function getMINDPrice() public view returns (uint256) {
        return ethReserve == 0 ? 0 : totalSupply / ethReserve;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}