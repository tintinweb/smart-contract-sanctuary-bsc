/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

pragma solidity ^0.8.2;

// SPDX-License-Identifier: GPL-3.0

contract Owned {
    address private owner;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender==owner, 'aksi hanya untuk perusahaan');
        _;
    }
}

contract Token is Owned {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 200000000 * 10 ** 18;
    string public name = "Teknoku Equity";
    string public symbol = "TDEQ";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address target) public returns(uint) {
        return balances[target];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'saldo terlalu rendah');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'saldo terlalu rendah');
        require(allowance[from][msg.sender] >= value, 'saldo terlalu rendah');
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

    function mintToken(address _target, uint _amount) public onlyOwner {
        balances[_target] += _amount;
        totalSupply += _amount;
    }

    function burnToken(address _target, uint _amount) public onlyOwner {
        balances[_target] -= _amount;
        totalSupply -= _amount;
    }
}