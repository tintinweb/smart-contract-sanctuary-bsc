// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract xPulsedoge {
    string public constant name = "xPulsedoge";
    string public constant symbol = "xPulsedoge";

    uint256 public totalSupply = 1e9 ; //1B tokens
    uint8 public constant decimals = 0;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        require(balances[from] >= amount, "Insufficient balance");

        balances[from] -= amount;
        balances[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function burn(address account, uint256 amount) external {
        require(account != address(0), "ERC20: burn from the zero address");

        balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}