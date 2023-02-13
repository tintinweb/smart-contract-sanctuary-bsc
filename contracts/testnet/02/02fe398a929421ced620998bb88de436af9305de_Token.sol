/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

pragma solidity ^0.8.2;

contract Token
{
    mapping(address=>uint) public balances;
    mapping(address=>mapping(address =>uint)) public allowance;//nested mapping

    uint  public totalSupply =10000 * 10 ** 18;
    string public name ="My Token";
    string public symbol="TKN";
    uint public decimals=18;

    event Transfer(address indexed from ,address indexed to,uint value); 
    event Approval(address indexed, address indexed spender, uint value);
    //send total supply amount another one contract deploy address
    constructor()
    {
        balances[msg.sender]=totalSupply;

    }
    //function to readbalnce and modify the data
    function balanceOf(address owner) public view returns(uint)
    {
        return balances[owner];
    }
    //Next smart contract coding transfer tokens
    //for example if you transfer 1  you use 1*10**18(10 power 18) bz decimal is 18
    function transfer(address to,uint value) public returns(bool)
    {
        require(balanceOf(msg.sender)>=value, 'Balance to low') ;//logical condition if truue excute otherwise error transaction cancel
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender,to,value);
        return true; //token almost we need one more fuctionality such as smarrt contract coding, delegated transfer
    }
    function transferFrom(address from,address to,uint value) public returns(bool)
    {
        require(balanceOf(from)>=value, 'balance to low');//check balance
        require(allowance[from][msg.sender] >= value,'allowance too low' );//check sender approve to transaction
        balances[to] +=value;
        balances[from] -=value;
         emit Transfer(from,to,value);
         return true;
    }
    //token almost we need one more fuctionality such as smarrt contract coding, delegated transfer
    function approve(address spender,uint value) public returns(bool){
        allowance[msg.sender][spender]=value; //its mean spender send token belongs with sender
        emit Approval(msg.sender,spender,value);
        return true;
    }
}