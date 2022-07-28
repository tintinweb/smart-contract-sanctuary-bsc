/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


interface IERC20 {
    
function totalSupply() external view returns (uint);

function balanceOf(address account) external view returns (uint);

function transfer(address recipient, uint amount) external returns (bool);

event Transfer(address indexed from, address indexed to, uint value);

}

contract ERC20 is IERC20 {
address  owner;
uint public totalSupply;
mapping(address => uint)  _balanceOf;
string public name;
string public symbol;
uint8 public decimals=0;

constructor(uint TotalSupply, string memory Name,string memory Symbol){
totalSupply=TotalSupply;
name=Name;
symbol=Symbol;
owner=msg.sender;
_balanceOf[owner]=totalSupply;
}


modifier _onlyOwner{
    require(msg.sender==owner,"Not the owner");
    _;
}

function balanceOf(address _address) external view returns(uint){
    return _balanceOf[_address];
}

function transfer(address recipient, uint amount) external returns (bool) {
        require(_balanceOf[msg.sender]>=amount && amount!=0,"Insufficient amount or amount can not be zero");
        _balanceOf[msg.sender] -= amount;
        _balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
}

function mint(uint amount) external _onlyOwner {
        _balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
}

function burn(uint amount) external _onlyOwner{
        _balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
}

}