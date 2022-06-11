/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract MyToken{

uint256 public Totalsupply;
string public Tokenname;
string public Tokensymbol;
uint public Decimals;

mapping(address=> uint256) public  balanceOf;

mapping(address=> bool) pause;

mapping(address=>mapping(address=>uint)) public allowed; 

event Transfer (address _from, address _to,uint256 _value);

event Approval(address indexed _Ower, address indexed _Spender, uint256 _value);


constructor(string memory Tokenname_, string memory Tokensymbol_, uint256 Totalsupply_, uint Decimals_){


Totalsupply=Totalsupply_;
Tokenname=Tokenname_;
Tokensymbol=Tokensymbol_;
Decimals=Decimals_;
balanceOf[msg.sender]=Totalsupply_;
}

function transfer( address _to,uint256 _value) public  returns(bool success ){
    require(pause[msg.sender]==false);
    require(balanceOf[msg.sender] >= _value);
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] +=_value;
    emit Transfer(msg.sender, _to, _value);

    return success;
}

function approval(address _Spender, uint256 _value ) public returns(bool success){
    require(balanceOf[msg.sender]>= _value);
    allowed[msg.sender][_Spender]= _value;
    emit Approval(msg.sender, _Spender, _value);
    return success;
}

function allowance(address _Ower, address _Spender) public view returns(uint256 remining){
return allowed [_Ower][_Spender]; 

}

function transferfrom(address _from, address _to,uint256 value) public returns(bool success){
    uint256 allowancebalance= allowance(_from,_to);
    require (balanceOf[_from]>= value);
    require(allowancebalance>=value);
    allowed[_from][msg.sender]-=value;
    balanceOf [_from]-= value;
    balanceOf [_to]+= value;
    
     emit Transfer(_from, _to, value);
 return success;

}
}