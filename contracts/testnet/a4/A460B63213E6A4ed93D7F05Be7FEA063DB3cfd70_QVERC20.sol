// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract QVERC20 {
    string public name = "";
    string public symbol = "";

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    uint256 public _totalSupply = 1000000000000000000000000;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        balances[msg.sender] = _totalSupply;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Not enough money");
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[to] = balances[to] + amount;
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Not enough money");
        allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        uint256 _allowance = allowances[from][msg.sender];
        require(_allowance >= amount, "Not allowed amount");
        allowances[from][msg.sender] = allowances[from][msg.sender] - amount;
        balances[from] = balances[from] - amount;
        balances[to] = balances[to] + amount;
        return true;
    }
}