/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

//-SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;
contract MetaErse
{
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 3000000000 * 10 ** 8;
    uint256 private maxSaleLimit = 3000000000 * 10 ** 8;
    string public name = "MetaErse";
    string public symbol = "MTE";
    uint public decimals = 8;
    address public owner;
    
    function setMaxSaleLimit(uint256 _amount) public
    {
        require(owner == msg.sender, 'Only owner');
        maxSaleLimit = _amount;
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    constructor() 
    {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
        }
    function balanceOf(address _owner) public view returns(uint) {
        return balances[_owner];
    }
    function transfer(address to, uint value) external returns(bool) 
    {
        require(balanceOf(msg.sender) >= value, 'Balance is low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) external returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    function approve(address spender, uint value) public returns (bool) 
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}