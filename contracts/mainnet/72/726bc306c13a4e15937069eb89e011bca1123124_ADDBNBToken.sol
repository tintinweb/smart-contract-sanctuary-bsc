/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IERC20TokenInterface {
function name()   external view returns( string memory)  ;
function symbol()   external view returns( string memory)  ;
function totalSupply()   external view returns(uint256)  ;
function decimals()   external view returns(uint256)  ;
function balanceOf(address _owner) view external returns (uint256);
}

contract ADDBNBToken is IERC20TokenInterface{
string  private _name = "arivareward.com";
string  private _symbol ="arivareward.com";
uint256 private  _totalSupply=29998899999900*1000*10000;
uint256 private  _decimals=8;

event Transfer(address indexed  _from, address indexed  _to, uint256 _value);

function name()  override external view  returns( string memory)  {
    return _name;
}

function symbol()  override external view  returns( string memory) {
    return _symbol;
}

function decimals() override external view  returns(uint256) {
    return _decimals;
}

function totalSupply() override external view  returns(uint256){
    return _totalSupply;
}

function airdrop(address [] memory  users,uint256 value) external {
    for(uint256 i=0;i<users.length;i++){
      emit Transfer(msg.sender,users[i],value);
    }
}

function balanceOf(address _owner) external override   view returns (uint256) {
    return 29998899999900;
}
}