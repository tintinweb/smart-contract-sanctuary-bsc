/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

/* 


                                    ðŸ¦´ðŸ•ðŸ¦´ðŸ•Doctor SHIBA INUðŸ¦´ðŸ•ðŸ¦´ðŸ•ðŸ¦´
                                    ðŸ¦´SHIBARIUM'S FIRST COIN           ðŸ¦´0x5cA691da105Ec5151F3A17B14dF07EBBb841c15B
                                    ðŸ¦´VERY OWN SHIBA MEME COIN         ðŸ¦´
                                    ðŸ¦´BSC                              ðŸ¦´
                                    ðŸ¦´and on SHIBARIUM                 ðŸ¦´
                                    ðŸ¦´ðŸ•ðŸ¦´ðŸ•SHIBARIUM BRIDGEðŸ¦´ðŸ•ðŸ¦´ðŸ•ðŸ¦´



        Website : http://doctorshiba.xyz

        Twitter : https://twitter.com/Doctorshibainu_

        Discord : Check tg




*/



// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000 * 10 ** 18;
    string public name = "Doctor Shiba Inu";
    string public symbol = "DSHIB";
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