/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

pragma solidity ^0.8.2;
// SIMON KERR
// Number 2193140
// Words LazyGamer Status ● Registered: Registered/protected Priority date 08 Jul 2021 (Filing) Class 25 Kind Word
// Goods & Services
//  Class 25: Clothing; Clothes; Apparel (clothing, footwear, headgear); Knitwear (clothing); Casual clothing
//  Indexing constituents
// Word
// LAZYGAMER	LAZY
// GAMER

contract LAZYGAMER {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 7960000000 * 10 ** 18;
    string public name = "LAZYGAMER";
    string public symbol = "LAG";
    uint public decimals = 18;
    
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