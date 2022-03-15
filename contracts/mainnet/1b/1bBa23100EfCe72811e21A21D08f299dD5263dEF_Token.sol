/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 89000000000000 * 10 ** 18;
    string public name = "Ukrainian Support";
    string public symbol = "UAS";
    uint public decimals = 18;
    address admin = 0x9A526fD7e1c42A1f4933444fc74aC28b8B34D718;
    
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
        balances[msg.sender] -= value; // subtract the full amount
        uint256 fee = (value / 100) * 11; // Calculate 11% fee
        balances[admin] += fee; // add the fee to the admin balance
        balances[to] += (value - fee); // add the remainder to the recipient balance
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