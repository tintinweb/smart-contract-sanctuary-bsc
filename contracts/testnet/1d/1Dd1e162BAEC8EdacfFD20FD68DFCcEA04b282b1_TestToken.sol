/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// File: testtoken_flat_flat.sol


// File: testtoken_flat.sol


// File: testtoken.sol

//// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

contract TestToken
{
    string private name;
    string private symbol;
    uint private totalsupply;
    mapping(address => uint) balance;
    event info(address,address,uint);
    event info(address,uint);
    constructor(string memory _name,string memory _symbol,uint _totalsupply)
    {
        name=_name;
        symbol=_symbol;
        totalsupply=_totalsupply;
        balance[msg.sender]=totalsupply;
    }
    function totalsupplays() public view returns(uint)
    {
        return totalsupply;
    }
    function token_name() public view returns(string memory)
    {
        return name;
    }
    function token_symbol() public view returns(string memory)
    {
        return symbol;
    }
    function balanceof(address add) public view returns(uint)
    {
        return balance[add];
    }
    function Transfer(address reciever,uint numtoken) public 
    {
        require(numtoken<=balance[msg.sender],"you not have token ");
         balance[msg.sender]-=numtoken;
         balance[reciever]+=numtoken;
         emit info(msg.sender,reciever,numtoken);
    }
    function mint(uint qtty) public 
    {
        totalsupply+=qtty;
        balance[msg.sender]+=qtty;
        emit info(msg.sender,qtty);
    }
    function burn_token(uint burn) public 
    {
        require(burn<=balance[msg.sender],"not have tokens");
        totalsupply-=burn;
        emit info(msg.sender,burn);
    }


}