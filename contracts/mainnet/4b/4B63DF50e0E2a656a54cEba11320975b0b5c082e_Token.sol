/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
        // 0xdjajjwii21 => 1200
    mapping(address => mapping(address => uint)) public allowance;
        // 0x12823380
        // -> 0xdjhawidu28821u => 1000 Gali isleisti 1000 coinu is tavo walleto
    uint public totalSupply = 1000000 * 10 ** 10;
    string public name = "Bitcoin bronze";
    string public symbol = "BTCNZ";
    uint public decimals = 10;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns(uint) {
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

    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}