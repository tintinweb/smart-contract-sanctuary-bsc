/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public immutable creatorTokens;
    address public immutable creator;

    uint256 public lastReductionTimestamp;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor() {
        name = "BlockStamps";
        symbol = "SHTF";
        decimals = 18;
        totalSupply = 21000000 * 10 ** decimals;
        creatorTokens = 1000000 * 10 ** decimals;
        creator = msg.sender;

        balances[creator] = creatorTokens;
        balances[address(this)] = totalSupply - creatorTokens;

        lastReductionTimestamp = block.timestamp + 730.5 days; // Countdown starts upon deployment

        emit Transfer(address(0), creator, creatorTokens);
        emit Transfer(address(0), address(this), totalSupply - creatorTokens);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount <= balances[msg.sender], "BEP20: transfer amount exceeds balance");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount <= balances[sender], "BEP20: transfer amount exceeds balance");
        require(amount <= allowances[sender][msg.sender], "BEP20: transfer amount exceeds allowance");

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);

        return true;
    }

    function reduceSupply() public {
        require(block.timestamp >= lastReductionTimestamp, "Cannot reduce supply yet");

        uint256 newTotalSupply = totalSupply / 2;
        uint256 burnedTokens = totalSupply - newTotalSupply;
        lastReductionTimestamp = block.timestamp + 730.5 days; // Countdown starts again

        balances[address(this)] -= burnedTokens;
        totalSupply = newTotalSupply;

        emit Transfer(address(this), address(0), burnedTokens);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}