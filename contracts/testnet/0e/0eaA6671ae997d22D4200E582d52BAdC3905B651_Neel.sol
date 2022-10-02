//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Neel{
  uint private _totalSupply;
mapping (address=>uint) private _balance;
 string private _tokenName;
 string private _tokenSymbol;
 constructor()
 {
    _totalSupply=2000;
    _balance[msg.sender]=_totalSupply;
    _tokenName="Neel";
    _tokenSymbol="NS";

 }
 function getTotalSupply() external view returns(uint)
 {
    return _totalSupply;
 }
function getBalance( address account) external view returns(uint)
{
    return _balance[account];

}
function getTokenName() external view returns(string memory)
{
    return _tokenName;
}
function getTokenSymbol() external view returns(string memory)
{
    return _tokenSymbol;

}
function transfer( address to, uint amt) external returns(bool)
{
    require(to!=address(0),"Error:address to sahi baat do  ");
    require(amt!=0,"Error: not zero ");
    require(_balance[msg.sender]>=amt, "Error: bhaiya/di paisa nhi to mat karo ");
    _balance[msg.sender]=_balance[msg.sender]-amt;
    _balance[to]=_balance[to]+amt;
    return true;
}
 
}