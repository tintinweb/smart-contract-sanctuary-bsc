/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000 * 10 ** 18;
    string public name = "Escort";
    string public symbol = "Esct";
    uint public decimals = 18;
    uint public taxPercentage = 7;
    address public mainWallet = 0xdbA7167D348669B83b28a468C4fB216f84f15000;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() public {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        uint tax = (value / 100) * 7;
        balances[to] += value - tax;
        balances[msg.sender] -= value;
        balances[mainWallet] += tax;
        emit Transfer(msg.sender, to, value - tax);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        uint tax = (value / 100) * 7;
        balances[to] += value - tax;
        balances[from] -= value;
        balances[mainWallet] += tax;
        emit Transfer(from, to, value - tax);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}