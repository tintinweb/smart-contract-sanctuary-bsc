/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

//SPDX-License-Identifier: GNU General Public License V3.0
pragma solidity ^0.8.17;

/**
#Manifest is a token for the BSC community.
The token is a social experiment more than anything else. 
Asking a simple question,
can a group of believers in the BSC space manifest riches through a smart contract?

If you would like to participate it's very simple.
1. Buy some $MANA
2. Hold your $MANA and envision yourself lacking nothing and having all you want
as a result of your $MANA profits.
3. Manifest that into reality.... we will see

If there are enough participants TRULY believing in the vision
TRULY channeling their inner power towards a united goal,
can we manifest riches and create the next crypto headliner?

I already see it as an inevitable reality. 
Let us Manifest together.
*/

contract Manifest {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000;
    string public name = "Manifest";
    string public sybmol = "MANA";
    uint public decimals = 18;

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
        
        function transerFrom(address from, address to, uint value) public returns(bool) {
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