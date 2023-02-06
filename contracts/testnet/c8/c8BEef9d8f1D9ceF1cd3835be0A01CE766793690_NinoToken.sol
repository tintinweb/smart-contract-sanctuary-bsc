//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract NinoToken {
    // Some string type variables to identify the token.
    string public name = "Nino Token";
    string public symbol = "NINO";

    uint256 public totalSupply = 1000000;
    address public owner;

    mapping(address => uint256) balances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    // function transfer(address to, uint256 amount) external {
    //     // Check if the transaction sender has enough tokens.
    //     // If `require`'s first argument evaluates to `false` then the
    //     // transaction will revert.
    //     require(balances[msg.sender] >= amount, "Not enough tokens");

    //     // Transfer the amount.
    //     balances[msg.sender] -= amount;
    //     balances[to] += amount;

    //     // Notify off-chain applications of the transfer.
    //     emit Transfer(msg.sender, to, amount);
    // }

    // Chuyển token từ người gửi đến người nhận
    function transfer(address to, uint256 value) public {
        require(balances[msg.sender] >= value, "Not enough tokens");
        require(balances[to] + value >= balances[to], "Overflow error");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
    }

    // Chuyển nhiều token cùng một lúc
    function multiTransfer(address[] memory to, uint256[] memory value) public {
        require(
            to.length == value.length,
            "The number of addresses and the number of tokens do not match"
        );
        for (uint256 i = 0; i < to.length; i++) {
            transfer(to[i], value[i]);
        }
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}