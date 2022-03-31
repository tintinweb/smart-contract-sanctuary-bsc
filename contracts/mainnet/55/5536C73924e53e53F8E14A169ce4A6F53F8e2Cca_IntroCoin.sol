/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

pragma solidity ^0.8.2;

contract IntroCoin {
    mapping(address => uint) public balances;
    mapping(address => uint) public total_bought;
    mapping(address => uint) public total_sold;
    mapping(address => bool) public whitelist;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Intro";
    string public symbol = "Int";
    uint public decimals = 18;
    uint public totalSupply = 1000000000 * 10 ** 18;
    address public the_owner;
    bool public allow_sell = false;
    uint public mas_sell_percent = 0;

    
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
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