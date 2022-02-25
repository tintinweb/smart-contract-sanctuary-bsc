/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MyToken{
    string public constant name = "New Token";
    string public constant symbol = "NTM";

    uint8 public constant decimals = 18;

    uint256 public totalSupply = 1000000; 

    mapping(address => uint256) balances;

    address owner;

    constructor() {
        totalSupply = 1000 * 1000 * (10 ** decimals);
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer: Invalid receiver");
        require(balances[msg.sender] >= amount, "Transfer: insufficient tokens amount");
        require(amount > 0, "Transfer: invalid amount");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
        return true;
    }

    function MsgSender() public view returns(address) {
        return msg.sender;
    }

    function transferFrom(address sender, address receiver, uint256 amount) public returns(bool) {
        // require(msg.sender == owner, "Invalid Authorization");
        require(receiver != address(0) && sender != address(0), "Sender or Receiver's address is invalid");
        require(balances[sender] > amount, "insufficient amount");
        require(amount > 0, "invalid amount");

        balances[sender] -= amount;
        balances[receiver] += amount;
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}