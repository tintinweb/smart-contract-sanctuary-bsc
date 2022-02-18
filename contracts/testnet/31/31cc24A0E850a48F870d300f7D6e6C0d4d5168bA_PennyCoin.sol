/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

pragma solidity ^0.5.16;

contract PennyCoin 
{
    mapping(address => uint) public balances;
    mapping(address => uint) public total_bought;
    mapping(address => uint) public total_sold;
    mapping(address => bool) public whitelist;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Penny Coin";
    string public symbol = "Pny";
    uint public decimals = 18;
    uint private supplyPotence = 10 ** decimals;
    uint public totalSupply = 5000000000 * 10 ** 18;
    address public the_owner;
    bool public allow_sell = false;
    uint public max_sell = 1000; //percent, between 0 to 1000
    
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approve(address indexed owner, address indexed spender, uint amount);
    
    constructor() public
    {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'Saldo insuficiente (balance too low)');
        require(allowance[from][msg.sender] >= value, 'Sem permissao (allowance too low)');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approve(msg.sender, spender, value);
        return true;
    }
    
}