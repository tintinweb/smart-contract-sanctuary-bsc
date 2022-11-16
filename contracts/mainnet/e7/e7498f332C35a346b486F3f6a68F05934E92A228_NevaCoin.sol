/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
*		NevaCoin (Neva)
*
*
*		NevaCoin Website
*
*		https://nevacoin.net
*
**
*
*		NevaCoin Blockchain Explorer
*
*		http://explorer.nevacoin.net/
*
*
*		Source Code
*
*		https://github.com/Neva-Coin/
*
*
*		Whitepaper
*
*		https://nevacoin.net/#whitepaper
*
*
*		Social Profiles (NevaCoin Community)
*
*       https://www.facebook.com/nevacoin
*       https://twitter.com/Neva_Coin
*       https://t.me/NevaCoin_Official 
*       https://www.linkedin.com/company/neva-coin/
*       https://medium.com/@neva-coin
*       https://www.reddit.com/r/Neva_Coin/
*       https://instagram.com/neva_coin
*       https://www.youtube.com/neva_coin
*
*       Groups (Chat)
*
*		https://t.me/NevaCoin_Community
*		https://discord.nevacoin.net

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract NevaCoin {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 5431630 * 10 ** 18;
    string public name = "NevaCoin";
    string public symbol = "NEVA";
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
// This Smart Contract and all other NevaCoin dApps are secured by Adonis Network JSC.