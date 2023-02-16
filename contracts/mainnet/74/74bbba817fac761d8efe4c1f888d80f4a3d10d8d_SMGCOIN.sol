/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

pragma solidity ^0.8.4;
 
    contract SMGCOIN
{
    mapping (address => uint) public balances;
    mapping (address => mapping (address=>uint)) public allowance;
 
    uint private totalSupply = 0.25515 * 10 ** 18;
    string public name = "SMGC TOKEN";
    string public symbol = "SMGC";
    uint public decimals = 18;
 
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
 
    constructor(){
        balances[msg.sender]=totalSupply;
    }
 
    function balanceOf(address user) public view returns (uint)
    {
        return balances[user];
         
    }
 
    function transfer(address to, uint value) public returns (bool)
    {
        require(balanceOf(msg.sender)>=value, "Solde insuffisant");
        balances[to]+=value;
        balances[msg.sender]-=value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
 
    function approve(address spender, uint value) public  returns (bool)
    {
        allowance[msg.sender][spender]=value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
 
}