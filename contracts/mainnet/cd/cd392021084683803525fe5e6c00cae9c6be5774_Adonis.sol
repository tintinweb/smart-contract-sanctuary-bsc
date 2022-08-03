/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

/**
*		Adonis (ADON)
*
*		Total Supply: 10,000,000,000   
*
*
*		Main website
*
*		https://adonis.network
*
*
*		Exchange website
*
*		https://adonis.exchange
*
*
*		Coin Website
*
*		https://adon.adonis.network
*
*
*		Wallets
*
*		https://adonis.network/wallets
*
*
*		Adonis Blockchain Explorer
*
*		http://explorer.adonis.network/
*
*
*		Source Code
*
*		https://github.com/Adonis-Network
*
*
*		Whitepaper
*
*		https://adonis.network/whitepaper
*
*
*		Social Profiles (Adonis Community)
*
*       https://www.facebook.com/www.adonis.network
*       https://twitter.com/adonis_network
*	    https://t.me/adonis_network
*       https://www.linkedin.com/company/adonis-network
*       https://medium.com/@Adonis_Network
*       https://www.reddit.com/r/Adonis_Exchange/
*       https://www.instagram.com/adonis_network/
*       https://www.youtube.com/c/Adonis_Network
*
*       Groups (Chat)
*
*		https://t.me/adonisnetwork
*		https://discord.com/invite/2BbxaPXCra

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Adonis {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000000000 * 10 ** 18;
    string public name = "Adonis";
    string public symbol = "ADON";
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
// This Smart Contract is encoded by Adonis Network JSC.
// This Smart Contract and all other Adonis dApps are secured by Adonis Network JSC.