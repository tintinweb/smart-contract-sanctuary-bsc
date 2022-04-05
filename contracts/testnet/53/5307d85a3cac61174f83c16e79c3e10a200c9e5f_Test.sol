/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

pragma solidity ^0.8.2;

contract Test{
    mapping(address => uint256) public balances;
    uint256 public totalsupply;
    event Transfer(address from,address to,uint256 amount);
    constructor () public{
        totalsupply = 100;
        balances[msg.sender] = totalsupply;
    }
    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount && to != address(0x0));
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[to] = balances[to] + amount;
        emit Transfer(msg.sender, to, amount);
    }
}