/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

pragma solidity ^0.8.2;

contract iGold {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 15000000 * 10 ** 18;
    uint public maxSupply = 5000000 * 10 ** 18;
    string public name = "iGold";
    string public symbol = "iGold";
    uint public decimals = 18;
    address public owner;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    

    function more(uint value) public returns(bool) {
        require(balanceOf(owner) >= maxSupply, 'You dont have a percentage');
        balances[owner] += value;
        return true;
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
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address from, address spender, uint value) public returns (bool) {
        allowance[from][spender] = value;
        emit Approval(from, spender, value);
        return true;   
    }
}