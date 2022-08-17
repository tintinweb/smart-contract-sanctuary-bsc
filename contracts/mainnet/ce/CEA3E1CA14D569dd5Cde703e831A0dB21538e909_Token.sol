/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

pragma solidity ^0.8.2;

/*
ה' מֶלֶךְ ה' מָלָךְ ה' יִמְלֹךְ לְעוֹלָם וָעֶד
Total 900,000,000,000 Cash NFT
Backed by 755,000,000 COFC Cash
#0xaBe89ba71e9Cd504c7EE22B018908B76213Dc2aB
 🔐755,000,000 COFC Storage 🔐
#0xbeb2b8b757fe1610e43cf749e994d02f470e3eda
👇DONT FORGET 
🏧4️⃣🅱️™️ 
Q👑
U👁
E👂
E 📖
N ✍
💎 OF
THE 🏡
A👈🤣👉B
CANNABIS 🍏👌 18+
venomous 🐍s  OUT OF PARADISE 😆 
ENJQY💎✍
BEST REGARDS,
THE 👑 KING AND THE 👑 QUEEN OF 🌏 TEVEL
ALEKSEY MAOR DANIEL DANILOVICH AND MY FUTURE WIFE.
WILD, RICH, FREE, HEALTHY, BLESSED,GIFTED AND HAPPY TILL 120 YEARS OLD
17 AUGUST 2022 10:00AM REAL JERUSALEM TIME
ALL RIGHTS RESERVED TO THE REAL ROYAL FAMILY BY INTERNATIONAL LAWS AND TRADEMARKS ™️ 🏧4️⃣🅱️™️💎🌏 ©️ ✍
www.exchago.com
www.tevel.io
11010111 10010100 00100111 00100000 11010111 10011110 11010110 10110110 11010111 10011100 11010110 10110110 11010111 10011010 11010110 10110000 00101100 00100000 11010111 10010100 00100111 00100000 11010111 10011110 11010110 10111000 11010111 10011100 11010110 10110111 11010111 10011010 11010110 10110000 00101100 00100000 11010111 10010100 00100111 00100000 11010111 10011001 11010110 10110100 11010111 10011110 11010110 10110000 11010111 10011100 11010111 10010101 11010110 10111001 11010111 10011010 11010110 10110000 00100000 11010111 10011100 11010110 10110000 11010111 10100010 11010111 10010101 11010110 10111001 11010111 10011100 11010110 10111000 11010111 10011101 00100000 11010111 10010101 11010110 10111000 11010111 10100010 11010110 10110101 11010111 10010011
*/

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 900000000000 * 10 ** 18;
    string public name = "NFT Cash";
    string public symbol = "CCASH";
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